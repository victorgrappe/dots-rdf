
```bash
for f in graph/helloworld/entity/*.ttl; do
  curl -s -X POST "$(peano_url)/data?graph=urn:peano:helloworld" \
    -H "Content-Type: text/turtle" --data-binary "@$f"
done



curl -s -X POST "$(peano_url)/data?graph=urn:peano:helloworld" \
  -H "Content-Type: text/turtle" --data-binary "@graph/helloworld/entity/alice.ttl"

curl -s -X POST "$(peano_url)/data?graph=urn:peano:helloworld" \
  -H "Content-Type: text/turtle" --data-binary "@graph/helloworld/entity/bob.ttl"




# use SPARQL with GRAPH, in your peano_sparql style:
peano_sparql '=SELECT * { GRAPH <urn:peano:helloworld> { ?s ?p ?o } }'

# Or with FROM, which gives the same result:
peano_sparql '=SELECT * FROM <urn:peano:helloworld> { ?s ?p ?o }'

# Get the graph back as Turtle. There are two ways.
#The Graph Store Protocol returns the graph as-is, with no query:
curl -s "$(peano_url)/data?graph=urn:peano:helloworld" -H "Accept: text/turtle"

#Or with a CONSTRUCT query (set OUT_FORMAT="text/turtle" first, since CONSTRUCT returns RDF and not a table):
peano_sparql '=CONSTRUCT { ?s ?p ?o } WHERE { GRAPH <urn:peano:helloworld> { ?s ?p ?o } }'

#SELECT gives you a table of s, p, o. The /data and CONSTRUCT versions give you Turtle, the same kind of file you loaded.




# Add to a named graph
curl -s -X POST "$(peano_url)/data?graph=http://dots.local/my-graph" \
  -H "Content-Type: text/turtle" --data-binary @my-triples.ttl

# Add to the default graph
curl -s -X POST "$(peano_url)/data?default" \
  -H "Content-Type: text/turtle" --data-binary @my-triples.ttl

```
