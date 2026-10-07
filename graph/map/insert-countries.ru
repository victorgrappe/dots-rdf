# SPARQL Update: add three countries with simplified boundaries.
#
# Boundaries are rough polygons of a dozen points, good enough for spatial
# relations, not for maps. Shared borders use identical vertices, so France
# touches Spain and Germany, and Spain and Germany are disjoint.
#
# WKT coordinates are "longitude latitude" (CRS84, the GeoSPARQL default).
#
# The dataset is in memory: run this again after every server restart.

PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
PREFIX geo:  <http://www.opengis.net/ont/geosparql#>
PREFIX sf:   <http://www.opengis.net/ont/sf#>
PREFIX wd:   <http://www.wikidata.org/entity/>
PREFIX dots: <http://dots.local/schema#>
PREFIX dot:  <http://dots.local/dot/>

INSERT DATA {
  # Classes, as in dots/dot/Territory.md and dots/dot/Country.md.
  dot:Territory a owl:Class ;
      rdfs:subClassOf dot:Dot ;
      rdfs:label "Territory" ;
      dots:wikidata wd:Q4835091 .

  dot:Country a owl:Class ;
      rdfs:subClassOf dot:Territory , geo:Feature ;
      rdfs:label "Country" ;
      dots:wikidata wd:Q6256 .

  # Countries: `type: "[[Country]]"`, each with one geometry.
  dot:France a dot:Country ;
      rdfs:label "France" ;
      dots:wikidata wd:Q142 ;
      geo:hasGeometry dot:France__geometry .

  dot:France__geometry a sf:Polygon ;
      geo:asWKT "POLYGON((-1.8 43.4, -1.2 46.2, -4.8 48.4, -1.6 48.7, 1.6 50.9, 2.5 51.1, 4.2 49.9, 6.4 49.5, 8.2 49.0, 7.6 47.6, 6.0 46.1, 7.7 43.8, 3.0 43.3, 3.2 42.4, -1.8 43.4))"^^geo:wktLiteral .

  dot:Spain a dot:Country ;
      rdfs:label "Spain" ;
      dots:wikidata wd:Q29 ;
      geo:hasGeometry dot:Spain__geometry .

  dot:Spain__geometry a sf:Polygon ;
      geo:asWKT "POLYGON((-1.8 43.4, 3.2 42.4, 3.3 41.9, 0.8 40.7, -0.4 39.4, -2.1 36.7, -5.6 36.0, -7.4 37.2, -7.0 38.9, -8.9 41.9, -9.3 43.0, -1.8 43.4))"^^geo:wktLiteral .

  dot:Germany a dot:Country ;
      rdfs:label "Germany" ;
      dots:wikidata wd:Q183 ;
      geo:hasGeometry dot:Germany__geometry .

  dot:Germany__geometry a sf:Polygon ;
      geo:asWKT "POLYGON((6.4 49.5, 6.0 50.8, 6.0 51.9, 7.0 53.6, 8.6 55.0, 11.0 54.0, 14.2 53.9, 14.6 51.0, 12.1 50.3, 13.8 48.6, 13.0 47.5, 10.2 47.3, 7.6 47.6, 8.2 49.0, 6.4 49.5))"^^geo:wktLiteral .
}
