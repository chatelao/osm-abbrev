# 'Makefile'

# Get extension version number from debian/changelog 
EXTVERSION=$(shell head -n1 debian/changelog |cut -d \( -f 2 |cut -d \) -f 1)
# EXTDIR=$(shell sudo -u postgres pg_config --sharedir)
EXTDIR=/usr/share/postgresql/10

# SUBDIRS = kanjitranscript icutranslit
CLEANDIRS = $(SUBDIRS:%=clean-%)
INSTALLDIRS = $(SUBDIRS:%=install-%)

all: $(patsubst %.rst,%.html,$(wildcard *.rst)) README Makefile $(SUBDIRS) osmabbrv.control $(patsubst %.csv,%.json,$(wildcard src/*.csv))

README: README.rst
	pandoc --from rst --to plain --standalone $< --output $@

%.html: %.rst
	pandoc --from rst --to html --standalone $< --output $@

%.json: %.csv
	csvtojson $(<) > $(<F).json

%.sql: %.json
	mustache $< src/street_abbrv.mustache.sql > $@

.PHONY:	subdirs $(SUBDIRS)
      
subdirs:
	$(SUBDIRS)
                
$(SUBDIRS):
	$(MAKE) -C $@

# I have no idea how to use the Makefile from "pg_config --pgxs"
# for installation without interfering mine
# so will do it manually (fo now)
install: $(INSTALLDIRS) 
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
