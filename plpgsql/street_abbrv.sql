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

/* 
   helper function "osmabbrv_street_abbrev_all_latin"
   call all latin osmabbrv_street_abbrev functions
   These are currently: english and german
   
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_latin(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
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

/* 
   helper function "osmabbrv_street_abbrev_non_latin"
   call all non latin osmabbrv_street_abbrev functions
   These are currently: russian, ukrainian
   
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_non_latin(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=osmabbrv_street_abbrev_ru(longname);
  abbrev=osmabbrv_street_abbrev_uk(abbrev);
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;



/* 
   helper function "osmabbrv_street_abbrev_de"
   replaces some common parts of german street names with their abbr
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_de(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  IF (position('traße' in abbrev)>2) THEN
   abbrev=regexp_replace(abbrev,'Straße\M','Str.');
   abbrev=regexp_replace(abbrev,'straße\M','str.');
  END IF;
  IF (position('trasse' in abbrev)>2) THEN
   abbrev=regexp_replace(abbrev,'Strasse\M','Str.');
   abbrev=regexp_replace(abbrev,'strasse\M','str.');
  END IF;
  IF (position('asse' in abbrev)>2) THEN
   abbrev=regexp_replace(abbrev,'Gasse\M','G.');
   abbrev=regexp_replace(abbrev,'gasse\M','g.');
  END IF;
  IF (position('latz' in abbrev)>2) THEN
   abbrev=regexp_replace(abbrev,'Platz\M','Pl.');
   abbrev=regexp_replace(abbrev,'platz\M','pl.');
  END IF;
  IF (position('Professor' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Professor ','Prof. ');
   abbrev=replace(abbrev,'Professor-','Prof.-');
  END IF;
  IF (position('Doktor' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Doktor ','Dr. ');
   abbrev=replace(abbrev,'Doktor-','Dr.-');
  END IF;
  IF (position('Bürgermeister' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Bürgermeister ','Bgm. ');
   abbrev=replace(abbrev,'Bürgermeister-','Bgm.-');
  END IF;
  IF (position('Sankt' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Sankt ','St. ');
   abbrev=replace(abbrev,'Sankt-','St.-');
  END IF;
  
  abbrev = regexp_replace(abbrev,'^Obere[sr]?\M','Ob.');
  abbrev = regexp_replace(abbrev,'^Untere[sr]?\M','Unt.');
  abbrev = regexp_replace(abbrev,'^Vordere[sr]?\M','Vord.');
  abbrev = regexp_replace(abbrev,'^Hintere[sr]?\M','Hint.');
  
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_fr"
   replaces some common parts of french street names with their abbreviation
   Main source: https://www.canadapost.ca/tools/pg/manual/PGaddress-f.asp#1460716
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_fr(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  abbrev=regexp_replace(abbrev,'^Avenue\M','Av.');
  abbrev=regexp_replace(abbrev,'^1([èe]?r)?e Avenue\M','1re Av.'); -- https://regex101.com/r/jbG1Sj/1
  abbrev=regexp_replace(abbrev,'(?<=^[0-9]+)e Avenue\M','e Av.');
  abbrev=regexp_replace(abbrev,'^Boulevard\M','Bd');
  abbrev=regexp_replace(abbrev,'^Chemin\M','Ch.');
  abbrev=regexp_replace(abbrev,'^Esplanade\M','Espl.');
  abbrev=regexp_replace(abbrev,'^Impasse\M','Imp.');
  abbrev=regexp_replace(abbrev,'^Passage\M','Pass.');
  abbrev=regexp_replace(abbrev,'^Promenade\M','Prom.');
  abbrev=regexp_replace(abbrev,'^Route\M','Rte');
  abbrev=regexp_replace(abbrev,'^Ruelle\M','Rle');
  abbrev=regexp_replace(abbrev,'^Sentier\M','Sent.');

  -- Use scripts (because we can)
  -- https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts#Latin_and_Greek_tables
  abbrev=regexp_replace(abbrev,'^1re\M','1ʳᵉ');
  abbrev=regexp_replace(abbrev,'(?<=^[0-9]+)e\M','ᵉ');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_es"
   replaces some common parts of spanish street names with their abbreviation
   currently just a stub :(
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_es(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  abbrev=regexp_replace(abbrev,'^Calle\M','C.');
  abbrev=regexp_replace(abbrev,'^Travesía\M','Trva.');
  abbrev=regexp_replace(abbrev,'^Plaza\M','Pl.');
  abbrev=regexp_replace(abbrev,'^Paseo Marítimo\M','P.º Mar.');
  abbrev=regexp_replace(abbrev,'^Paseo\M','P.º');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_pt"
   replaces some common parts of portuguese street names with their abbreviation
   currently just a stub :(
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_pt(longname text) RETURNS TEXT AS $$
 BEGIN
  return longname;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_pt"
   replaces some common parts of portuguese street names with their abbreviation
   currently just a stub :(
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_nl(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  abbrev=regexp_replace(abbrev,'straat\M','str.');
  abbrev=regexp_replace(abbrev,'Sint\M','St.');
  abbrev=regexp_replace(abbrev,'steenweg\M','stwg.');
  abbrev=regexp_replace(abbrev,'markt\M','mkt.');
  abbrev=regexp_replace(abbrev,'Monseigneur','Mgr.');
  abbrev=regexp_replace(abbrev,'Van De[nr]?\M','vd');
  abbrev=regexp_replace(abbrev,'Van\M','v');
  abbrev=regexp_replace(abbrev,'Koning(in)?\M','Kon.');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_it"
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_it(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  abbrev=regexp_replace(abbrev,'Santa\M','S.');
  abbrev=regexp_replace(abbrev,'Piazza\M','P.za');
  abbrev=regexp_replace(abbrev,'Ponte\M','P.te');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;


/* 
   helper function "osmabbrv_street_abbrev_en"
   replaces some common parts of english street names with their abbreviation
   Most common abbreviations extracted from:
   http://www.ponderweasel.com/whats-the-difference-between-an-ave-rd-st-ln-dr-way-pl-blvd-etc/
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_en(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=longname;
  -- Exclude french avenues
  abbrev=regexp_replace(abbrev,'(?<!^([0-9]+([èe]?r)?e )?)Avenue\M','Ave.'); -- https://regex101.com/r/bYk8ki/2
  abbrev=regexp_replace(abbrev,'(?<!^)Boulevard\M','Blvd.');
  abbrev=regexp_replace(abbrev,'Crescent\M','Cres.');
  abbrev=regexp_replace(abbrev,'Court\M','Ct');
  abbrev=regexp_replace(abbrev,'Drive\M','Dr.');
  abbrev=regexp_replace(abbrev,'Lane\M','Ln.');
  abbrev=regexp_replace(abbrev,'Place\M','Pl.');
  abbrev=regexp_replace(abbrev,'Road\M','Rd.');
  abbrev=regexp_replace(abbrev,'Street\M','St.');
  abbrev=regexp_replace(abbrev,'Square\M','Sq.');

  abbrev=regexp_replace(abbrev,'Expressway\M','Expy');
  abbrev=regexp_replace(abbrev,'Freeway\M','Fwy');
  abbrev=regexp_replace(abbrev,'Highway\M','Hwy');
  abbrev=regexp_replace(abbrev,'Parkway\M','Pkwy');

  abbrev=regexp_replace(abbrev,'North\M','N');
  abbrev=regexp_replace(abbrev,'South\M','S');
  abbrev=regexp_replace(abbrev,'West\M', 'W');
  abbrev=regexp_replace(abbrev,'East\M', 'E');

  abbrev=regexp_replace(abbrev,'Northwest\M', 'NW');
  abbrev=regexp_replace(abbrev,'Northeast\M', 'NE');
  abbrev=regexp_replace(abbrev,'Southwest\M', 'SW');
  abbrev=regexp_replace(abbrev,'Southeast\M', 'SE');

  -- Use superscripts (because we can)
  -- https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts#Latin_and_Greek_tables  
  abbrev=regexp_replace(abbrev,'1st\M','1ˢᵗ');
  abbrev=regexp_replace(abbrev,'2nd\M','2ⁿᵈ');
  abbrev=regexp_replace(abbrev,'3rd\M','3ʳᵈ');
  
  abbrev=regexp_replace(abbrev,'(?<=[0-9]+)th\M','ᵗʰ');

  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;



/* 
   helper function "osmabbrv_street_abbrev_ru"
   replaces улица (ulica) with ул. (ul.)
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_ru(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=regexp_replace(longname,'переулок','пер.');
  abbrev=regexp_replace(abbrev,'тупик','туп.');
  abbrev=regexp_replace(abbrev,'улица','ул.');
  abbrev=regexp_replace(abbrev,'бульвар','бул.');
  abbrev=regexp_replace(abbrev,'площадь','пл.');
  abbrev=regexp_replace(abbrev,'проспект','просп.');
  abbrev=regexp_replace(abbrev,'спуск','сп.');
  abbrev=regexp_replace(abbrev,'набережная','наб.');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

/* 
   helper function "osmabbrv_street_abbrev_uk"
   replaces ukrainian street suffixes with their abbreviations
*/
CREATE or REPLACE FUNCTION osmabbrv_street_abbrev_uk(longname text) RETURNS TEXT AS $$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=regexp_replace(longname,'провулок','пров.');
  abbrev=regexp_replace(abbrev,'тупик','туп.');
  abbrev=regexp_replace(abbrev,'вулиця','вул.');
  abbrev=regexp_replace(abbrev,'бульвар','бул.');
  abbrev=regexp_replace(abbrev,'площа','пл.');
  abbrev=regexp_replace(abbrev,'проспект','просп.');
  abbrev=regexp_replace(abbrev,'спуск','сп.');
  abbrev=regexp_replace(abbrev,'набережна','наб.');
  return abbrev;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
