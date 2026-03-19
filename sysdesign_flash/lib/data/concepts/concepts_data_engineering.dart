import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Data Engineering';
final _color = AppColors.dataEngineering;

final conceptsDataEngineering = <Concept>[
  Concept(
    id: 109,
    category: _cat,
    color: _color,
    icon: '🏗️',
    title: 'ETL vs ELT',
    tagline: 'When to transform',
    diagram: '''
  ETL: Extract → Transform (small engine) → Load warehouse

  ELT: Extract → Load raw → Transform in SQL (warehouse compute)

  Cloud favors ELT (Snowflake/BQ scale)''',
    bullets: [
      'ETL useful when transform needs specialized engine or PII scrub before landing',
      'ELT leverages warehouse SQL and separation of storage/compute',
      'Staging area for raw data aids reproducibility',
      'Transform in dbt as versioned analytics code',
      'Cost model: avoid reprocessing huge raw scans repeatedly',
    ],
    mnemonic: 'ELT = dump first, ask questions in SQL',
    interviewQ: 'Choose ETL vs ELT for SaaS product analytics',
    interviewA: 'ELT to cloud warehouse: ingest raw events and snapshots into S3/BigQuery, model in dbt for marts. Use ETL components only where PII must be tokenized before landing or formats are hostile. Keep lineage. For high-volume logs, preprocess cheaply (Kafka → compacted Parquet) then load.',
    difficulty: Difficulty.beginner,
    tags: ['data-engineering', 'warehouse', 'etl'],
  ),
  Concept(
    id: 110,
    category: _cat,
    color: _color,
    icon: '📦',
    title: 'Data Lake vs Warehouse',
    tagline: 'Cheap lake, fast warehouse',
    diagram: '''
  Lake: S3/GCS Parquet/Delta — cheap, flexible schema
  Warehouse: BQ/Snowflake — SQL perf, governance

  Lakehouse: merge both (Delta/Iceberg)''',
    bullets: [
      'Lake stores everything; warehouse curates trusted marts',
      'Schema-on-read in lake — discipline needed or swamp',
      'Partition lake data by date for query pruning',
      'Access controls harder in open formats — IAM + catalog',
      'Iceberg/Delta add ACID and time travel on lake',
    ],
    mnemonic: 'Lake = raw pantry; warehouse = meal prep kitchen',
    interviewQ: 'When warehouse over lake query?',
    interviewA: 'When analysts need fast interactive SQL, joins at scale, and strong governance/BI integration. Lake for ML features, archival, cheap retention, and diverse formats. Modern lakehouse tries to unify. Cost: scanning full lake expensive — aggregate to warehouse marts for dashboards.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'lake', 'warehouse'],
  ),
  Concept(
    id: 111,
    category: _cat,
    color: _color,
    icon: '🔄',
    title: 'Change Data Capture',
    tagline: 'Stream DB changes',
    diagram: '''
  WAL / binlog ──► Debezium ──► Kafka
                                    │
                            consumers: search, cache, lake''',
    bullets: [
      'Near-real-time sync without polling tables',
      'Initial snapshot + continuous stream',
      'Ordering per table/partition — consumers handle duplicates idempotently',
      'Schema evolution with compatibility modes',
      'Operational load on source DB — monitor replication slots',
    ],
    mnemonic: 'CDC = database twitch stream',
    interviewQ: 'Invalidate cache when row updates',
    interviewA: 'CDC from Postgres logical replication to Kafka topic per table. Consumer updates cache key by primary key. Idempotent upserts. Handle tombstones for deletes. Lag monitoring — if cache stale too long, fallback to DB read. Alternative: dual-write risky; CDC is safer single source of truth.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'cdc', 'messaging'],
  ),
  Concept(
    id: 112,
    category: _cat,
    color: _color,
    icon: '📐',
    title: 'Star Schema',
    tagline: 'Facts surrounded by dimensions',
    diagram: '''
        dim_date
            │
  dim_user ─┼─ fact_orders ─┬─ dim_product
            │                 │
                        dim_geo''',
    bullets: [
      'Fact table: metrics + foreign keys — large narrow rows',
      'Dimensions: descriptive attributes — slower changing',
      'Denormalized for query simplicity vs 3NF OLTP',
      'Surrogate keys in warehouse decouple from source IDs changing',
      'Slowly changing dimensions (SCD type 2) track history',
    ],
    mnemonic: 'Star = fact sun, dimension planets',
    interviewQ: 'Model subscriptions for revenue reporting',
    interviewA: 'Fact_subscription_daily grain: user_id, date_key, revenue, MRR movement. Dimensions: user (plan tier, region), product plan, date. Handle upgrades/downgrades with SCD2 on plan dimension. Conformed dimensions across facts for drill-across. Avoid fan-out double counting when joining multiple facts without care.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'warehouse', 'modeling'],
  ),
  Concept(
    id: 113,
    category: _cat,
    color: _color,
    icon: '✅',
    title: 'Data Quality',
    tagline: 'Trust or ignore analytics',
    diagram: '''
  Great Expectations / dbt tests
  Row counts, null rates, uniqueness, freshness SLA

  Alerts to Slack on failure''',
    bullets: [
      'Test at ingest and at mart layer',
      'Freshness: events delayed > 2h page pipeline owners',
      'Anomaly detection on volume spikes/drops',
      'Data contracts between producers and consumers',
      'Quarantine bad batches instead of silent corruption',
    ],
    mnemonic: 'No tests → Excel shadow IT',
    interviewQ: 'Dashboard wrong for a week — prevention?',
    interviewA: 'Add dbt tests: not null on keys, accepted values, referential integrity to dims, row count vs source tolerance. Freshness checks on tables. Canary queries comparing daily totals to finance source. Lineage to trace bug. Incident process for data quality SLOs. Producer schema registry with compatibility checks.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'quality', 'analytics'],
  ),
  Concept(
    id: 114,
    category: _cat,
    color: _color,
    icon: '⏰',
    title: 'Batch vs Stream Processing',
    tagline: 'Latency vs complexity',
    diagram: '''
  Batch: hourly/daily jobs, high throughput, simpler correctness

  Stream: Flink/Spark Streaming — low latency, stateful windows

  Lambda: both — reconcile''',
    bullets: [
      'Stream for fraud alerts, realtime dashboards, sessionization',
      'Batch for heavy joins, training data snapshots, cost efficiency',
      'Exactly-once stream processing costly — often at-least-once + dedup',
      'Watermarks handle event-time lateness',
      'Kappa architecture: stream-only — hard but idealized',
    ],
    mnemonic: 'Stream = live TV; batch = nightly rerun',
    interviewQ: 'Hourly batch too slow for fraud',
    interviewA: 'Move scoring to stream processor consuming transaction topic with stateful windows (e.g. 5-min spend per card). Combine with online feature store for model inputs. Keep batch for reconciliation and model retraining. Idempotent rules engine. Fallback human review queue when score borderline.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'streaming', 'architecture'],
  ),
  Concept(
    id: 115,
    category: _cat,
    color: _color,
    icon: '🔐',
    title: 'PII in Pipelines',
    tagline: 'Minimize, tokenize, audit',
    diagram: '''
  Hash user_id for joins analysts don’t need raw
  Tokenization vault for reversible cases
  Column-level ACL in warehouse''',
    bullets: [
      'Classify columns; default deny wide access',
      'Tokenize before landing in lake if possible',
      'Audit every query on sensitive tables',
      'Right to erasure propagates through marts — hard problem',
      'Separate dev/stage synthetic data',
    ],
    mnemonic: 'PII is toxic — handle with gloves',
    interviewQ: 'GDPR delete in warehouse',
    interviewA: 'Maintain mapping vault or use salted hashes that can be tombstoned. For event streams, append deletion events; consumers compact. Time-travel tables complicate erasure — legal retention policies. Some systems overwrite partitions on rewrite. Document impossible guarantees vs anonymization approach. Involve legal.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'privacy', 'compliance'],
  ),
  Concept(
    id: 116,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Apache Spark Mental Model',
    tagline: 'Distributed dataframe ops',
    diagram: '''
  Driver plans DAG
  Executors run tasks on partitions

  shuffle: expensive repartition/groupBy''',
    bullets: [
      'Narrow transforms pipeline without shuffle; wide triggers shuffle',
      'Partition pruning and predicate pushdown critical for perf',
      'Spill to disk if memory pressure — watch skew',
      'Avoid collect() on big data — take samples',
      'Adaptive query execution adjusts joins in newer versions',
    ],
    mnemonic: 'Spark = dataframe spread across cluster',
    interviewQ: 'Spark job slow after groupBy',
    interviewA: 'Likely skew — few keys dominate partitions. Salting keys for aggregation then merge. Increase shuffle partitions cautiously. AQE skew join handling. Broadcast small table if eligible. Check spill metrics. Repartition upstream evenly. Consider incremental processing instead of full scan.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'spark', 'big-data'],
  ),
  Concept(
    id: 117,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Data Lineage',
    tagline: 'Trace column to source',
    diagram: '''
  Raw.events ─► staging ─► mart_revenue
       │                        │
       └─ OpenLineage / dbt docs ─► UI graph''',
    bullets: [
      'Impact analysis: upstream break → downstream dashboards',
      'Debugging wrong metric — trace transforms',
      'Regulatory audits require lineage proof',
      'Automate from SQL parser or runtime hooks',
      'Pair with ownership tags in catalog',
    ],
    mnemonic: 'Lineage = family tree for data',
    interviewQ: 'SOC2 asks about data provenance',
    interviewA: 'Implement automated lineage capture: dbt exposes DAG, ingestion tools with OpenLineage, warehouse query logs for ad-hoc. Document owners per table. Access logs retained. For PII columns, track transforms (masking). Regular export of lineage graph for auditors. Integrate catalog (DataHub, Collibra).',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'governance', 'compliance'],
  ),
  Concept(
    id: 118,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'Feature Store',
    tagline: 'ML features online + offline',
    diagram: '''
  Offline: training historical feature snapshots
  Online: low-latency serving for inference

  Same definitions — point-in-time correctness''',
    bullets: [
      'Prevents training/serving skew — single feature definition code',
      'Point-in-time joins avoid future data leakage in training',
      'Materialize aggregates updated by stream jobs',
      'Feast/Tecton patterns — not only for hyperscalers',
      'Monitor feature freshness and null rates',
    ],
    mnemonic: 'Feature store = single recipe for train and prod',
    interviewQ: 'Model works offline, fails online',
    interviewA: 'Training-serving skew: different aggregation windows or missing default imputation online. Use feature store with shared transformation code. Validate online features logged and compared to offline expectations. Latency constraints may truncate history — document differences. Shadow traffic testing before full rollout.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'ml', 'architecture'],
  ),
];
