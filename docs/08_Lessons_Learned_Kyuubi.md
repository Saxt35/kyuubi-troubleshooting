# 08 - Lessons Learned - Kyuubi Network Troubleshooting

1. **Siempre validar en 3 capas:** Pod local -> Service DNS -> Airflow/Zeppelin. El fallo estaba en capa 2.
2. **No usar IPs literales en docs:** Usar placeholders `<HIVE_HOST>` y DNS interno.
3. **Documentar como Runbook:** Convertir investigación en runbook reusable reduce MTTR de 4h a 15min.
4. **GraphRAG Link:** Este incidente evidenció necesidad de Knowledge Graph de linaje de infra: Servicio -> NSG -> Namespace -> Job.
5. **Para portfolio:** Este tipo de troubleshooting de Big Data es muy valorado en rol AI Architect porque demuestra dominio de plataforma completa, no solo LLM.

**Valor para entrevista:** Puedes contar historia STAR: Situación (no alcanzaba Hive), Tarea (diagnosticar), Acción (nc, telnet, logs, NSG), Resultado (conectividad restablecida y runbook).