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

### Set environment

```bash
source bin/main.sh;
peano;
peano_env "main.local"
    
peano_env "dots.local"
peano_env "victor.local"
```

### Import

```bash
peano_post "urn:peano:helloworld" "graph/helloworld/entity/alice.ttl"
peano_post "urn:peano:helloworld" "graph/helloworld/entity/bob.ttl"

peano_put "urn:peano:helloworld" "graph/helloworld/entity/alice.ttl"

```

### Query

```bash
GRAPH_CD="urn:peano:helloworld"


# Get all datasets
curl -s 'http://localhost:3030/$/datasets'



# Select elements in the named graph
peano_sparql "=SELECT * { GRAPH <${GRAPH_CD}> { ?s ?p ?o } }"
peano_sparql "=SELECT *   FROM  <${GRAPH_CD}> { ?s ?p ?o }"

# Count elements in the named graph
peano_sparql "=SELECT (COUNT(*) AS ?count) { GRAPH <${GRAPH_CD}> { ?s ?p ?o } }"
peano_sparql "=SELECT (COUNT(*) AS ?count)   FROM  <${GRAPH_CD}> { ?s ?p ?o }"

# Count the number of triples in each named graph
peano_sparql "=SELECT ?g (COUNT(*) AS ?triples) { GRAPH ?g { ?s ?p ?o } } GROUP BY ?g ORDER BY ?g"



# Count elements in all graphs
peano_sparql "=SELECT (COUNT(*) AS ?count) { GRAPH ?g { ?s ?p ?o } }"
# Count elements in a specific graph



peano_sparql "=SELECT * WHERE { ?s ?p ?o } LIMIT 10000"

peano_sparql '=SELECT * { GRAPH ?g { ?s ?p ?o } } LIMIT 100000'
peano_sparql '=SELECT * { GRAPH <http://dots.local/persons/shapes> { ?s ?p ?o } } LIMIT 100000'

peano_sparql '=SELECT * WHERE { ?s ?p ?o } LIMIT 10'
peano_sparql '=SELECT * WHERE { ?s ?p ?o } LIMIT 10'

peano_sparql '@graph/_all/get_all.rq'

```

### Export

```bash

# Get the graph back as Turtle. There are two ways.
#The Graph Store Protocol returns the graph as-is, with no query:
curl -s "$(peano_url)/data?graph=urn:peano:helloworld" -H "Accept: text/turtle"

#Or with a CONSTRUCT query (set OUT_FORMAT="text/turtle" first, since CONSTRUCT returns RDF and not a table):
peano_sparql '=CONSTRUCT { ?s ?p ?o } WHERE { GRAPH <urn:peano:helloworld> { ?s ?p ?o } }'

#SELECT gives you a table of s, p, o. The /data and CONSTRUCT versions give you Turtle, the same kind of file you loaded.




```
