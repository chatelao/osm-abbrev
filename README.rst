.. image:: https://readthedocs.org/projects/osm-abbrev/badge/?version=latest
   :target: https://osm-abbrev.readthedocs.io/en/latest/?badge=latest

.. readme-header-marker-do-not-remove

OSM Abbreviations
#################

The **osm-abbrev** project provides abbreviations of addresses. Especially names of streets, places and other geographic places.

Why abbreviations for street and place names?
==============================================

Abbreviated street names on maps help to increase the infomration density as you can see very well on the comparison between OpenStreetMap.org_  with long and OpenStreetMap.de_ with shortend street names below.

.. _OpenStreetMap.de: https://www.OpenStreetMap.de/karte.html
.. _OpenStreetMap.org: https://www.OpenStreetMap.org

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
the extension in your PostgreSQL database:

.. code-block:: sql
  :linenos:

   CREATE EXTENSION osmabbrv;

Usage
=====

The following functions are provided for use in the database. This sample will return

.. code-block:: sql
  :linenos:

   SELECT osmabbrv_street_abbrev_all('Gutenbergstrasse')

Gutenbergstr. to be used later.

Contributions
==============

The project is far away from being completed, if you would like to contritute a little bit or a lot feel free to fork and hand in pull-request or just open an issue. Below are some major steps on the roadmap, but priorities may change.

Abbreviation rules
~~~~~~~~~~~~~~~~~~

Target generators
~~~~~~~~~~~~~~~~~


The next ToDos
----------------

#. [ ] Build a Vagrant development box.
#. [ ] Export .csv definition to pgSQL (PostGre Extension).
#. [ ] Export .csv definition to Markdown
#. [ ] Export .csv definition to JSON.
#. [ ] Export .csv definition to XML.
#. [ ] Export .csv definition to Python.

About the  build 
----------------

The architecture is focused on two parts:

#. A set of CSV files, one per language to define the rules and testcaeses.
#. A another set of generators or implementations to provide solutions for as many languages & formats as possible. Currently main target are JSON and PGPLSQL, but feel free to extend it with any language you master well.
#. Integrated tests in the CI/CD pipeline to prove that the code produced by 2. is working well according to the testset of 1.

.. image:: https://raw.githubusercontent.com/chatelao/osm-abbrev/master/img/build/build.png
   :width: 300 px

Special thanks
==============

The technical foundation and inspiration for this project was laid in the mapnik-german-l10n_ project, which focus on transliteration of maps. Having is recommended for all omni-lingual fans, as well as the use of OpenStreetMap.de_.

.. _mapnik-german-l10n: https://github.com/giggls/mapnik-german-l10n

