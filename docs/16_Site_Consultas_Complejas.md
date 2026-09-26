# 16 - Complex Query Site - Secure Architecture

## Goal
Portal for complex queries across whole platform that cannot be solved with SQL in Metabase.

## Public Architecture

Frontend (Node.js + Next.js + Graph.js / Tree.js)
  ↓ HTTPS / REST API (no direct data access)
Backend Node.js (filter & orchestration)
  ↓
  ├─ Apache Jena Fuseki (Knowledge Graph / SPARQL)
  ├─ Postgres (relational + permissions)
  ├─ Hive via Kyuubi JDBC (jdbc:hive2://<KYUUBI_HOST>:<PORT>)
  ├─ ClickHouse (OLAP)
  └─ pgvector (embeddings for semantic search)

## Security Pattern
Frontend NEVER talks directly to DBs. Backend filters:

Frontend -> Backend Node (auth + validate profile + sanitize query) ->
Jena/Postgres/Hive/ClickHouse/pgvector -> Backend filters -> Frontend

Prevents SQL/SPARQL injection and data leakage by profile.

## Stack
- Frontend: Node.js, Next.js, GraphJS / Three.js
- Backend: Node.js orchestrator
- DBs: Jena Fuseki, Postgres, Hive via Kyuubi, ClickHouse, pgvector

Publicable: YES