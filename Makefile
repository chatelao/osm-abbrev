# 'Makefile'

# Get extension version number from debian/changelog 
EXTVERSION=$(shell head -n1 debian/changelog |cut -d \( -f 2 |cut -d \) -f 1)
# EXTDIR=$(shell sudo -u postgres pg_config --sharedir)
EXTDIR=/usr/share/postgresql/10

# SUBDIRS = kanjitranscript icutranslit
CLEANDIRS = $(SUBDIRS:%=clean-%)
INSTALLDIRS = $(SUBDIRS:%=install-%)

all: $(patsubst %.md,%.html,$(wildcard *.md)) INSTALL README Makefile $(SUBDIRS) osmabbrv.control

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

$(INSTALLDIRS):
	$(MAKE) -C $(@:install-%=%) install

deb:
	dpkg-buildpackage -b -us -uc

clean: $(CLEANDIRS)
	rm -rf $$(grep .gitignore)
	
$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean

osmabbrv--$(EXTVERSION).sql: plpgsql/*.sql
	./gen_osmabbrv_extension.sh $(EXTDIR)/extension $(EXTVERSION)
	
osmabbrv.control: osmabbrv--$(EXTVERSION).sql
	sed -e "s/VERSION/$(EXTVERSION)/g" osmabbrv.control.in >osmabbrv.control
