# peano

## Run

### Docker

```bash
# Clear the old image and container, then rebuild:
docker compose down --rmi all
docker rm -f peano-fuseki

# Run in the foreground, with logs in the terminal:
docker compose up --build
```

## Use

- [Jena - Architecture](https://jena.apache.org/about_jena/architecture.html)

### Fuseki

```bash

# SELECT, ASK (default: application/sparql-results+xml):
OUT_FORMAT="text/plain"
OUT_FORMAT="text/csv"
OUT_FORMAT="text/tab-separated-values"
OUT_FORMAT="application/sparql-results+json"
OUT_FORMAT="application/sparql-results+xml"
OUT_FORMAT="application/sparql-results+thrift"

# CONSTRUCT, DESCRIBE, and the /data and /get endpoints (default: text/turtle):
OUT_FORMAT="text/turtle"
OUT_FORMAT="application/n-triples"
OUT_FORMAT="application/ld+json"
OUT_FORMAT="application/rdf+xml"
OUT_FORMAT="application/rdf+json"
OUT_FORMAT="application/trig"
OUT_FORMAT="application/n-quads"        
OUT_FORMAT="application/rdf+thrift"



peano_url() { echo "${FUSEKI_HOST}/${DATASET_CD}"; }
peano_sparql() { clear;  curl -s "$(peano_url)/sparql" -H "Accept: ${OUT_FORMAT}" --data-urlencode "query${1}"; }


# Starter
OUT_FORMAT="text/plain"

FUSEKI_HOST="http://localhost:3030"


# Get all datasets
curl -s 'http://localhost:3030/$/datasets'

DATASET_CD="sandbox"
DATASET_CD="persons"
DATASET_CD="dots"





peano_sparql '=SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }'




# Count element s in the default graph
peano_sparql '=SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }'

peano_sparql '=SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }'


# Count the number of triples in each named graph
peano_sparql '=SELECT ?g (COUNT(*) AS ?triples) { GRAPH ?g { ?s ?p ?o } } GROUP BY ?g ORDER BY ?g'

peano_url


# Count elements in all graphs
peano_sparql '=SELECT (COUNT(*) AS ?count) { GRAPH ?g { ?s ?p ?o } }'
# Count elements in a specific graph
peano_sparql '=SELECT (COUNT(*) AS ?count) { GRAPH <http://dots.local/persons/shapes> { ?s ?p ?o } }'



peano_sparql '=SELECT * WHERE { ?s ?p ?o } LIMIT 10000'

peano_sparql '=SELECT * { GRAPH ?g { ?s ?p ?o } } LIMIT 100000'
peano_sparql '=SELECT * { GRAPH <http://dots.local/persons/shapes> { ?s ?p ?o } } LIMIT 100000'

peano_sparql '=SELECT * WHERE { ?s ?p ?o } LIMIT 10'
peano_sparql '=SELECT * WHERE { ?s ?p ?o } LIMIT 10'

peano_sparql '@graph/_all/get_all.rq'

```
