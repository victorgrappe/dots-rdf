# AGENTS.md

## SPARQL files (`sparql/`)

- `.rq` = SPARQL **Query** (read-only: `SELECT`, `CONSTRUCT`, `ASK`, `DESCRIBE`).
  Send to `/dots/sparql` as `query@file`.
- `.ru` = SPARQL **Update** (writes: `INSERT DATA`, `DELETE`, …).
  Send to `/dots/update` as `update@file`.

Keep the extensions accurate: scripts loop over `sparql/*.rq` to run every
query, and must never run an update by accident.

The dataset is in memory: after a server restart, re-run
`insert-countries.ru` before the country queries return anything.
