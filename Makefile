# 'Makefile'

vpath %.csv  src
vpath %.json gen
vpath %.sql  gen

# Get extension version number from debian/changelog 
EXTVERSION=$(shell head -n1 debian/changelog |cut -d \( -f 2 |cut -d \) -f 1)
# EXTDIR=$(shell sudo -u postgres pg_config --sharedir)
EXTDIR=/usr/share/postgresql/10

CLEANDIRS   = $(SUBDIRS:%=clean-%)
INSTALLDIRS = $(SUBDIRS:%=install-%)
DOCS = $(patsubst %.rst,%.html,$(wildcard *.rst))
JSON = $(patsubst src/%.csv,%.json,$(wildcard src/*.csv))

all: $(JSON) $(DOCS) latin_fr.sql osmabbrv.control

%.html: %.rst
	pandoc --from rst --to html --standalone $< --output $@

%.json: %.csv
	csvtojson $(<) > $(@)

%.sql: %.json
	mustache $(<) src/street_abbrv.mustache.sql > $@

clean: $(CLEANDIRS)
	rm -rf $$(grep .gitignore)
	
$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean

# I have no idea how to use the Makefile from "pg_config --pgxs"
# for installation without interfering mine
# so will do it manually (fo now)
osmabbrv--$(EXTVERSION).sql: plpgsql/*.sql
	./gen_osmabbrv_extension.sh $(EXTDIR)/extension $(EXTVERSION)
	
osmabbrv.control: osmabbrv--$(EXTVERSION).sql
	sed -e "s/VERSION/$(EXTVERSION)/g" osmabbrv.control.in >osmabbrv.control

install: $(INSTALLDIRS) 
	mkdir -p $(DESTDIR)$(EXTDIR)/extension
	install -D -c -m 644 osmabbrv--$(EXTVERSION).sql $(DESTDIR)$(EXTDIR)/extension/
	install -D -c -m 644 osmabbrv.control $(DESTDIR)$(EXTDIR)/extension/

$(INSTALLDIRS):
	$(MAKE) -C $(@:install-%=%) install

deb:
	dpkg-buildpackage -b -us -uc
