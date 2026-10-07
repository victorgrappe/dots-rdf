# AGENTS.md

## Layout (`graph/`)

One folder per topic. Each one holds its data, its SPARQL files and its page:

- `graph/dots/`: the dots graph, served as `/dots`.
- `graph/map/`: countries (inserted into `/dots`) and the map page.
- `graph/person/`: persons and their SHACL shapes, served as `/persons`.
- `graph/_tmp/`: scratch queries, against `/dots`.

Fuseki sees the folder as `/data/graph` (see `docker-compose.yml` and
`jena/config.ttl`). Moving or renaming a `.ttl` file means updating
`jena/config.ttl` too.

## SPARQL files

- `.rq` = SPARQL **Query** (read-only: `SELECT`, `CONSTRUCT`, `ASK`, `DESCRIBE`).
  Send to `/<dataset>/sparql` as `query@file`.
- `.ru` = SPARQL **Update** (writes: `INSERT DATA`, `DELETE`, …).
  Send to `/<dataset>/update` as `update@file`.

Every `.rq` and `.ru` file so far targets `/dots`, including those in
`graph/map/`. Keep the extensions accurate: scripts loop over
`graph/*/*.rq` to run every query, and must never run an update by accident.

The datasets are in memory: after a server restart, re-run
`graph/map/insert-countries.ru` before the country queries return anything.
