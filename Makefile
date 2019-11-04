# 'Makefile'

# Get extension version number from debian/changelog 
EXTVERSION=$(shell head -n1 debian/changelog |cut -d \( -f 2 |cut -d \) -f 1)
echo $(EXTVERSION)

EXTDIR=$(shell pg_config --sharedir)
echo $(EXTDIR)

# SUBDIRS = kanjitranscript icutranslit
CLEANDIRS = $(SUBDIRS:%=clean-%)
echo $(CLEANDIRS)

INSTALLDIRS = $(SUBDIRS:%=install-%)
echo $(INSTALLDIRS)

all: $(patsubst %.md,%.html,$(wildcard *.md)) INSTALL README Makefile $(SUBDIRS) osmabbrv.control country_languages.data  osmabbrv_country_osm_grid.data

INSTALL: INSTALL.md
	pandoc --from markdown_github --to plain --standalone $< --output $@

README: README.md
	pandoc --from markdown_github --to plain --standalone $< --output $@

%.html: %.md
	pandoc --from markdown_github --to html --standalone $< --output $@

.PHONY:	subdirs $(SUBDIRS)
      
subdirs:
	$(SUBDIRS)
                
$(SUBDIRS):
	$(MAKE) -C $@

# I have no idea how to use the Makefile from "pg_config --pgxs"
# for installation without interfering mine
# so will do it manually (fo now)
install: $(INSTALLDIRS) all 
	mkdir -p $(DESTDIR)$(EXTDIR)/extension
	install -D -c -m 644 osmabbrv--$(EXTVERSION).sql $(DESTDIR)$(EXTDIR)/extension/
	install -D -c -m 644 osmabbrv.control $(DESTDIR)$(EXTDIR)/extension/
	install -D -c -m 644 *.data $(DESTDIR)$(EXTDIR)/extension/

$(INSTALLDIRS):
	$(MAKE) -C $(@:install-%=%) install

deb:
	dpkg-buildpackage -b -us -uc

clean: $(CLEANDIRS)
	rm -rf $$(grep -v country_osm_grid.sql .gitignore)
	
# remove everything including the files from the interwebs
mrproper: clean
	rm country_osm_grid.sql
	rm country_languages.data
	
$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean

osmabbrv--$(EXTVERSION).sql: plpgsql/*.sql country_languages.data
	./gen_osmabbrv_extension.sh $(EXTDIR)/extension $(EXTVERSION)
	
osmabbrv.control: osmabbrv--$(EXTVERSION).sql
	sed -e "s/VERSION/$(EXTVERSION)/g" osmabbrv.control.in >osmabbrv.control

country_languages.data:
	grep -v \# country_languages.data.in >country_languages.data
