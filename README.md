# dots-rdf

## Summary

An RDF view of the dots graph, served over SPARQL by
[Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/) in Docker.

```
dots-rdf/
├── README.md
├── docker-compose.yml       # one service, port 3030 on localhost
├── jena/
│   ├── Dockerfile           # Fuseki 6.2.0 on Java 21, from the Apache binary release
│   ├── config.ttl           # the "dots" and "persons" datasets: in memory, loaded from files
│   └── shiro.ini            # access control: open, for local use
├── map/
│   └── index.html           # full-window map of a query's geometries
├── persons/
│   └── index.html           # SHACL form to view and edit the persons
├── shacl/
│   └── persons.ttl          # SHACL shapes for the persons
├── sparql/                  # saved queries (.rq) and updates (.ru), for /dots
└── ttl/
    ├── dots.ttl             # the graph
    └── persons.ttl          # persons and their relations (SHACL showcase)
```

## Run

Run these from the repository root. You need Docker Desktop running.

### Docker

```bash
# Clear the old image and container, then rebuild:
docker compose down --rmi all
docker rm -f dots-fuseki

# Run in the foreground, with logs in the terminal:
docker compose up --build


# In detached mode
docker compose up -d --build
docker compose logs -f
docker compose down
```

The first build downloads Fuseki (about 50 MB). In the logs, wait for `Start Fuseki`.

**The dataset is in memory.** It is reloaded from `ttl/dots.ttl` each time the
container starts. Edit the file, then run `docker compose restart`. SPARQL updates
work, but they are lost on restart. The Turtle file is the source of truth.

### Endpoints

| What | URL |
| --- | --- |
| Web UI | <http://localhost:3030/> |
| SPARQL query | <http://localhost:3030/dots/sparql> (also `/dots/query`) |
| SPARQL update | <http://localhost:3030/dots/update> |
| Graph Store, read/write | <http://localhost:3030/dots/data> |
| Graph Store, read only | <http://localhost:3030/dots/get> |

### Sparql

```bash
clear; curl -s http://localhost:3030/dots/sparql \
  -H 'Accept: text/csv' \
  --data-urlencode 'query=SELECT * WHERE { ?s ?p ?o } LIMIT 10'
```

## Mapping from the vault

`ttl/dots.ttl` is a hand-written slice of `dots/dot/`. It covers the food
chain, the matter chain, and one link dot.

| Frontmatter | RDF |
| --- | --- |
| file `dots/dot/{Name}.md` | IRI `dot:{Name}`, spaces become `_` (`http://dots.local/dot/`) |
| `class: "[[B]]"` | `rdfs:subClassOf dot:B` (transitive) |
| `type: "[[B]]"` | `rdf:type dot:B` (not transitive) |
| `wikidata__cd: Q81` | `dots:wikidata wd:Q81` |
| `description:` | `rdfs:comment` |
| `name__fr:` | `rdfs:label "…"@fr` |
| link dot (`class: "[[in]]"`, `in`, `out`) | node typed `dots:In`, with `dots:in`, `dots:out`, `dots:order`, `dots:multiplier` |

`Dot` is the root, as in the vault. Every `rdfs:subClassOf` chain ends at `dot:Dot`.

## Query

The dataset has no inference. Use property paths (`+`, `*`) to follow transitive
`class` chains.

All ancestors of Carrot, equivalent to the `class__1…8` columns in `dots.base`:

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dot:  <http://dots.local/dot/>

SELECT ?ancestor WHERE { dot:Carrot rdfs:subClassOf+ ?ancestor }
```

Every instance (`type:`), with the top-level class it belongs to:

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dot:  <http://dots.local/dot/>

SELECT ?instance ?top WHERE {
  ?instance a ?type .
  ?type rdfs:subClassOf* ?top .
  ?top  rdfs:subClassOf dot:Dot .
}
```

To run a query from the shell:

```bash
curl -s http://localhost:3030/dots/sparql \
  -H 'Accept: text/csv' \
  --data-urlencode 'query=SELECT * WHERE { ?s ?p ?o } LIMIT 10'
```

Results come back in the format named by the `Accept` header: `text/csv`,
`text/tab-separated-values`, `text/plain` (a text table),
`application/sparql-results+json` or `application/sparql-results+xml`.

## Saved queries

`sparql/` holds ready-made queries, one per `.rq` file:

| File | Returns |
| --- | --- |
| `class-hierarchy.rq` | every class, its parent (`class:`) and its depth below Dot |
| `instances.rq` | every `type:` instance, its type and its top-level class |
| `link-dots.rq` | link dots: `in` → `out`, with `order` and `multiplier` |
| `insert-countries.ru` | *update*: adds France, Spain and Germany with simplified boundaries |
| `countries-geo.rq` | GeoSPARQL: each pair of countries, whether they touch, and their distance |
| `countries-map.rq` | the country polygons, for the 🌍 **Geo** map tab of the web UI |

Run one from the repository root while the server is up. `query@file` makes curl read the
query from the file:

```bash
curl -s http://localhost:3030/dots/sparql -H 'Accept: text/csv' --data-urlencode 'query@sparql/class-hierarchy.rq'
```

`.ru` files are updates: send them to `/dots/update` as `update@file`. The
dataset is in memory, so run the insert again after every restart. GeoSPARQL
functions (`geof:`) are built into Fuseki and need no extra setup.

```bash
curl -s http://localhost:3030/dots/update --data-urlencode 'update@sparql/insert-countries.ru'
curl -s http://localhost:3030/dots/sparql -H 'Accept: text/plain' --data-urlencode 'query@sparql/countries-geo.rq'
```

To run all the queries:

```bash
for q in sparql/*.rq; do echo "== $q"; curl -s http://localhost:3030/dots/sparql -H 'Accept: text/csv' --data-urlencode "query@$q"; done
```

For other formats, change the `Accept` header (see [Query](#query)). You can also
paste a file into the query editor of the web UI.

## Map

`map/index.html` draws the geometries of a SPARQL query on a full-window map.
Open it straight from disk while the server is up. Fuseki allows cross-origin
requests, so no web server is needed:

```bash
open map/index.html
```

It runs `countries-map.rq` on load. Edit the query in the panel and press
**Run** or ⌘+Enter. **Reset** restores the default query. Press **F** or ⛶ for
fullscreen, and use the layer button to switch background maps.

It follows the same conventions as the web UI's 🌍 **Geo** tab:

- every column holding a `geo:wktLiteral` (or `geo:geoJSONLiteral`) is drawn;
- a column named `wktColor` sets the colour;
- a column named `wktLabel` sets the label (otherwise the first plain-text column);
- clicking a shape shows its whole row.

## Persons: SHACL and shacl-form

A small second dataset, `/persons`, to show SHACL at work. It is separate from
`/dots`, so the saved queries in `sparql/` are not affected.

| File | Role |
| --- | --- |
| `ttl/persons.ttl` | five persons ([FOAF](http://xmlns.com/foaf/0.1/)) and their relations: `foaf:knows`, `rel:spouseOf`, `rel:parentOf` ([REL](http://purl.org/vocab/relationship/)) |
| `shacl/persons.ttl` | the shapes: a name is required, age is 0–150, e-mail is a `mailto:` IRI, relations point to a `foaf:Person`, at most one spouse, spouse and children are disjoint |
| `persons/index.html` | a form generated from the shapes by [shacl-form](https://github.com/ULB-Darmstadt/shacl-form) |

At startup Fuseki loads the persons into the default graph and the shapes into
the named graph `<http://dots.local/persons/shapes>`. Eve breaks three
constraints on purpose, so validation has something to show.

### Validate with Fuseki

The `/persons/shacl` endpoint validates a graph against shapes POSTed to it, and
returns a SHACL validation report:

```bash
curl -s -X POST 'http://localhost:3030/persons/shacl?graph=default' \
  -H 'Content-Type: text/turtle' --data-binary @shacl/persons.ttl
```

`sh:conforms false`, with one `sh:result` per violation: Eve's age, e-mail and
second spouse.

### Edit with the form

```bash
open persons/index.html
```

- The list on the left shows every `foaf:Person`. A ⚠ marks the persons with violations.
- Click a person to view them. **Edit** turns the view into a form. The form
  validates as you type and marks invalid fields. **Save** is refused until
  the form is valid. It then replaces the person's triples with a SPARQL update.
- **+ New person** opens an empty form with a fresh IRI under `http://dots.local/person/`.
- **Validate dataset** runs the Fuseki validation above on the whole graph.
- *Turtle produced by the form* shows the RDF the form would save.

The form is built from the shapes alone: `sh:name` gives the labels,
`sh:order` the order, `sh:datatype` the input type, and `sh:class` the
dropdowns of persons. Edit a shape, reload the shapes graph (see below), then
reload the page.

Like every dataset here, `/persons` is in memory: edits are lost on restart.
To keep them, export the default graph into `ttl/persons.ttl` (see below).

## Import, clear, export

These use the Graph Store Protocol (`/data`) and SPARQL Update (`/update`).
Replace `persons` with `dots` for the other dataset.

The standard formats: **Turtle** (`.ttl`) for one graph, and **N-Quads**
(`.nq`) for a whole dataset, named graphs included. N-Quads is also what
Fuseki backups contain.

```bash
B=http://localhost:3030/persons

# Export
curl -s "$B/data?default" -H 'Accept: text/turtle' > persons.ttl            # default graph
curl -s "$B/data?graph=http://dots.local/persons/shapes" -H 'Accept: text/turtle' > shapes.ttl
curl -s "$B/data" -H 'Accept: application/n-quads' > persons.nq             # whole dataset

# Clear
curl -s "$B/update" --data-urlencode 'update=CLEAR DEFAULT'                 # default graph only
curl -s "$B/update" --data-urlencode 'update=DROP ALL'                      # everything

# Import: POST adds to what is there, PUT replaces it
curl -s -X PUT  "$B/data?default" -H 'Content-Type: text/turtle' --data-binary @ttl/persons.ttl
curl -s -X PUT  "$B/data?graph=http://dots.local/persons/shapes" -H 'Content-Type: text/turtle' --data-binary @shacl/persons.ttl
curl -s -X POST "$B/data" -H 'Content-Type: application/n-quads' --data-binary @persons.nq
```

For TriG instead of N-Quads, use `application/trig`. To take a gzipped N-Quads
backup on the server side, `curl -X POST http://localhost:3030/$/backup/persons`.
It lands in `/fuseki/run/backups` inside the container.

## Upgrading Fuseki

In `jena/Dockerfile`, set `JENA_VERSION` and `JENA_SHA512` together. Take the
checksum from
`https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-<version>.tar.gz.sha512`.
Maven Central's own `.sha512` file is not published for this artifact.
Then run `docker compose up -d --build`.

## Security

`jena/shiro.ini` opens everything, including the admin API under `/$/`. This is safe
only because `docker-compose.yml` publishes the port on `127.0.0.1`. If you expose
the port more widely, first restrict `/$/**` in `jena/shiro.ini`. The commented default
in the Fuseki distribution shows how.
