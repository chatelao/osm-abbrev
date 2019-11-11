/*

renderer independent name abbreviations

- https://github.com/chatelao/osm-abbrev

(c) 2019      Olivier Chatelain - olivier.chatelain(ät)gmail.com
(c) 2014-2016 Sven Geggus       - https://github.com/giggls/mapnik-german-l10n

Licence AGPL http://www.gnu.org/licenses/agpl-3.0.de.html

Street abbreviation functions

*/

/* 
   helper function "osmabbrv_street_abbrev"
   will call the osmabbrv_street_abbrev function of the given language if available
   and return the unmodified input otherwise   
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev(longname text, langcode text) RETURNS TEXT AS $$
 DECLARE
  call text;
  func text;
  result text;
 BEGIN
  IF (position('-' in langcode)>0) THEN
    return longname;
  END IF;
  IF (position('_' in langcode)>0) THEN
    return longname;
  END IF;  
  func ='osmabbrv_street_abbrev_'|| langcode;
  call = 'select ' || func || '(' || quote_nullable(longname) || ')';
  execute call into result;
  return result;
 EXCEPTION
  WHEN undefined_function THEN
   return longname;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_all"
   call all osmabbrv_street_abbrev functions
   These are currently russian, english and german
   
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_all(longname text) RETURNS TEXT AS $$
DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  abbrev=osmabbrv_street_abbrev_latin(abbrev);
  abbrev=osmabbrv_street_abbrev_non_latin(abbrev);
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_latin(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
{{#latin}}
{{/latin}}
  abbrev=longname;
  abbrev=osmabbrv_street_abbrev_en(abbrev);
  abbrev=osmabbrv_street_abbrev_de(abbrev);
  abbrev=osmabbrv_street_abbrev_nl(abbrev);
  abbrev=osmabbrv_street_abbrev_fr(abbrev);
  abbrev=osmabbrv_street_abbrev_it(abbrev);
  abbrev=osmabbrv_street_abbrev_es(abbrev);
  abbrev=osmabbrv_street_abbrev_pt(abbrev);
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_non_latin(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
{{#non-latin}}
{{/non-latin}}
  abbrev=longname;
  abbrev=osmabbrv_street_abbrev_ru(abbrev);
  abbrev=osmabbrv_street_abbrev_uk(abbrev);
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


{{#latin}}
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_{{lang}}(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
{{#rules}}
  abbrev=regexp_replace(longname,{{regexp_search}},{{regexp_replace}};
{{/rules}}
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
{{/latin}}

{{#non-latin}}
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_{{lang}}(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
{{#rules}}
  abbrev=regexp_replace(longname,{{regexp_search}},{{regexp_replace}};
{{/rules}}
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
{{/non-latin}}
