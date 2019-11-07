#  OSM Abbreviations

The **osm-abbrev** project provides rules to abbreviate geographic names, especially of streets and places.

## Why abbreviations for street and place names?

Abbreviated street names on maps, allow to provide information on the same space. See below the comparison between [OpenStreetMap.org](https://www.OpenStreetMap.org) with long and [OpenStreetMap.de](https://www.OpenStreetMap.de/karte.html) with shortend street names.

| Long names | Short names |
| --- | --- |
| ![Long](https://b.tile.openstreetmap.org/16/34123/23067.png)| ![Short names](https://b.tile.openstreetmap.de/16/34123/23067.png) |

## Installation

If you just installed the debian package all you have to do now ist to enable
our extension in your PostgreSQL database as follows:

```sql
CREATE EXTENSION osmabbrv;
```

## Usage

The following functions are provided for use in the database. This sample will return
```sql
SELECT abbrev_all('Gutenbergstrasse')
```
Gutenbergstr. to be used later.

## ToDo
1. [ ] Export .csv definition to pgSQL (PostGre Extension).
1. [ ] Export .csv definition to JSON.
1. [ ] Export .csv definition to XML.
1. [ ] Export .csv definition to Python.

## Special thanks

The technical foundation and inspiration is the [mapnik-german-l10n](https://github.com/giggls/mapnik-german-l10n) project, which provides a fabulous support to transliterate maps.
