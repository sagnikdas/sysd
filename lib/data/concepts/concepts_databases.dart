import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Databases';
final _color = AppColors.databases;

final conceptsDatabases = <Concept>[
  Concept(
    id: 21,
    category: _cat,
    color: _color,
    icon: '🗄️',
    title: 'SQL vs NoSQL',
    tagline: 'Structure vs flexibility',
    diagram: '''
  SQL (Relational):
  ┌─────────────────────┐
  │ users               │
  │ id │ name  │ email  │
  │  1 │ Alice │ a@x.co │
  │  2 │ Bob   │ b@x.co │
  └─────────────────────┘
  → Schema enforced, ACID, JOINs

  NoSQL (Document):
  {
    "id": 1,
    "name": "Alice",
    "posts": [{...}, {...}]
  }
  → Flexible schema, embedded data''',
    bullets: [
      'SQL: fixed schema, ACID transactions, powerful JOINs — PostgreSQL, MySQL',
      'NoSQL: flexible schema, horizontal scale, denormalized — MongoDB, DynamoDB',
      'SQL excels at: complex queries, relationships, transactional integrity',
      'NoSQL excels at: high write throughput, schema evolution, horizontal scaling',
      'Choose based on query patterns, not hype — many systems use both (polyglot)',
    ],
    mnemonic: 'SQL = Structured + Safe; NoSQL = Scalable + Flexible',
    interviewQ: 'Design Instagram storage — SQL or NoSQL?',
    interviewA: 'Both (polyglot persistence). PostgreSQL for user profiles, relationships, and auth (needs ACID + JOINs). Cassandra for posts/feed (high write throughput, time-series queries, horizontal scaling). Redis for caching hot data and feed assembly. S3 for image/video storage. The choice depends on the specific data access pattern, not one-size-fits-all.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'sql', 'nosql'],
  ),
  Concept(
    id: 22,
    category: _cat,
    color: _color,
    icon: '🐘',
    title: 'Relational DB (PostgreSQL)',
    tagline: 'The gold standard for structured data',
    diagram: '''
  ┌──────────┐    ┌──────────┐
  │  users   │    │  posts   │
  │──────────│    │──────────│
  │ id  (PK) │←──┤ user_id  │
  │ name     │    │ title    │
  │ email    │    │ content  │
  └──────────┘    │ created  │
                  └──────────┘

  SELECT u.name, p.title
  FROM users u
  JOIN posts p ON u.id = p.user_id
  WHERE u.id = 1;''',
    bullets: [
      'ACID: Atomicity, Consistency, Isolation, Durability — guaranteed',
      'Rich query language (SQL), views, stored procedures, triggers',
      'Indexes: B-tree (default), GIN (full-text), GiST (geo), BRIN (time-series)',
      'Extensions: PostGIS (geo), pg_trgm (fuzzy search), timescaledb',
      'Scaling: read replicas, partitioning, Citus for horizontal sharding',
    ],
    mnemonic: 'PostgreSQL = Swiss army knife of databases',
    interviewQ: 'Design a user-relationship graph — can PostgreSQL handle it?',
    interviewA: 'Yes, for moderate scale. Use a junction table: friendships(user_a, user_b). Index both columns. For "friends of friends": recursive CTE or 2-hop join. At scale (billions of edges), switch to a graph DB like Neo4j. PostgreSQL handles up to ~100M relationships well with proper indexing. Use materialized views for precomputed social queries.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'sql', 'postgresql'],
  ),
  Concept(
    id: 23,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Wide-Column Store (Cassandra)',
    tagline: 'Massive write throughput, distributed by design',
    diagram: '''
  Row Key: user_123
  ┌─────────────────────────────┐
  │ Col: post_ts1 │ Col: post_ts2 │
  │ {title, body} │ {title, body} │
  └─────────────────────────────┘

  Ring topology:
  ┌───┐   ┌───┐
  │ N1│───│ N2│
  └─┬─┘   └─┬─┘
    │       │
  ┌─┴─┐   ┌─┴─┐
  │ N4│───│ N3│
  └───┘   └───┘
  → Data partitioned by consistent hash''',
    bullets: [
      'Column families with dynamic columns — no fixed schema per row',
      'Masterless: all nodes are equal, no single point of failure',
      'Tunable consistency: ONE, QUORUM, ALL per query',
      'Optimized for writes: append-only LSM tree, compaction in background',
      'Best for: time-series, IoT, activity feeds, messaging — write-heavy workloads',
    ],
    mnemonic: 'Cassandra = write-heavy, masterless, linearly scalable',
    interviewQ: 'Design a time-series metrics store for 10M data points/sec',
    interviewA: 'Cassandra with time-bucketed partition keys: metric_name + day. Each row holds one day of data points as columns (sorted by timestamp). Write path: client → any node → coordinator → replicate to N nodes. Tunable consistency: ONE for writes (speed), QUORUM for reads (accuracy). TTL for auto-expiry of old data. Compaction strategy: TimeWindowCompactionStrategy.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'nosql', 'cassandra'],
  ),
  Concept(
    id: 24,
    category: _cat,
    color: _color,
    icon: '📄',
    title: 'Document DB (MongoDB)',
    tagline: 'Schema flexibility for evolving data',
    diagram: '''
  Collection: users
  ┌──────────────────────────┐
  │ {                        │
  │   "_id": "abc123",       │
  │   "name": "Alice",       │
  │   "posts": [             │
  │     {"title": "...",     │
  │      "tags": ["go"]}     │
  │   ],                     │
  │   "address": {           │
  │     "city": "SF"         │
  │   }                      │
  │ }                        │
  └──────────────────────────┘
  → Embedded documents, no JOINs needed''',
    bullets: [
      'Documents (JSON/BSON) with nested objects and arrays',
      'Schema-less: each document can have different fields',
      'Embed related data to avoid joins — denormalized by design',
      'Good for: CMS, user profiles, catalogs, prototyping',
      'Trade-off: no cross-document ACID (until v4.0 multi-doc transactions)',
    ],
    mnemonic: 'MongoDB = JSON in, JSON out — model your objects directly',
    interviewQ: 'Design a CMS — why choose a document DB?',
    interviewA: 'CMS content is heterogeneous: blog posts have different fields than product pages or FAQs. Document DB lets each content type have its own schema without migrations. Embed comments within the document for single-read performance. Index on tags and content_type for filtering. Use MongoDB Atlas Search for full-text search. Downside: cross-content-type queries and reporting are harder without JOINs.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'nosql', 'mongodb'],
  ),
  Concept(
    id: 25,
    category: _cat,
    color: _color,
    icon: '🔑',
    title: 'Key-Value Store (Redis)',
    tagline: 'Blazing fast in-memory data',
    diagram: '''
  SET user:123 "Alice"      → O(1)
  GET user:123              → "Alice"

  Data structures:
  ┌──────────────────────────┐
  │ Strings: simple K-V      │
  │ Hashes:  user:{name,age} │
  │ Lists:   message queue   │
  │ Sets:    unique tags     │
  │ Sorted Sets: leaderboard │
  │ Streams: event log       │
  └──────────────────────────┘
  All operations: O(1) or O(log N)''',
    bullets: [
      'In-memory: sub-millisecond reads/writes — 100K+ ops/sec per node',
      'Rich data structures: strings, hashes, lists, sets, sorted sets, streams',
      'Use cases: caching, sessions, rate limiting, pub/sub, leaderboards',
      'Persistence: RDB snapshots + AOF append-only file for durability',
      'Cluster mode: hash slots (16384) distributed across nodes for horizontal scale',
    ],
    mnemonic: 'Redis = Remote Dictionary Server — in-memory Swiss army knife',
    interviewQ: 'Design a session store for 10M concurrent users',
    interviewA: 'Redis Cluster with hash-slot sharding. Key: session:{token}, Value: hash of user data. TTL: 30 minutes (auto-expire idle sessions). SET with NX for atomic session creation. Pipeline commands for batch operations. Persistence: AOF with fsync every second (balance durability vs speed). Sentinel for automatic failover. Memory: ~1KB per session × 10M = 10GB — fits in memory easily.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'redis', 'caching'],
  ),
];
