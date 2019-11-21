OSM Abbreviations
#################

The **osm-abbrev** project provides rules to abbreviate geographic names, especially of streets and places.

Why abbreviations for street and place names?
==============================================

Abbreviated street names on maps, allow to provide information on the same space. See below the comparison between OpenStreetMap.org_  with long and OpenStreetMap.de_ with shortend street names.

.. _OpenStreetMap.de: https://www.OpenStreetMap.de
.. _OpenStreetMap.org: https://www.OpenStreetMap.de/karte.html

+----------------------------------------------------------------+---------------------------------------------------------------+
| Long names                                                     | Short names                                                   |
+================================================================+===============================================================+
|  |img_org|                                                     | |img_de|                                                      |
+----------------------------------------------------------------+---------------------------------------------------------------+

.. |img_org| image:: https://b.tile.openstreetmap.org/16/34123/23067.png
   :scale: 50 %

.. |img_de| image:: https://b.tile.openstreetmap.de/16/34123/23067.png
   :scale: 50 %

Installation
============

If you just installed the debian package all you have to do now ist to enable
our extension in your PostgreSQL database as follows:

.. code-block:: sql

   CREATE EXTENSION osmabbrv;

Usage
============

The following functions are provided for use in the database. This sample will return

.. code-block:: sql

   SELECT osmabbrv_street_abbrev_all('Gutenbergstrasse')

Gutenbergstr. to be used later.

Contributions
==============

The next ToDos
----------------

#. [ ] Build a Vagrant development box.
#. [ ] Export .csv definition to pgSQL (PostGre Extension).
#. [ ] Export .csv definition to Markdown
#. [ ] Export .csv definition to JSON.
#. [ ] Export .csv definition to XML.
#. [ ] Export .csv definition to Python.

The build pipline
-----------------

The project is focused on two parts:

1. A CSV file per language to define the rules and testcaeses
1. A several generators to produce language / format specific output like JSON, SQL, etc.

.. image:: https://raw.githubusercontent.com/chatelao/osm-abbrev/master/img/build/build.png

Special thanks
==============

The technical foundation and inspiration for this project is the mapnik-german-l10n_ , which provides a fabulous support to transliterate maps. A look over there is recommended for all omni-lingual fans.

.. _mapnik-german-l10n: https://github.com/giggls/mapnik-german-l10n
