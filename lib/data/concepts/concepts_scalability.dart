import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Scalability';
final _color = AppColors.scalability;

final conceptsScalability = <Concept>[
  Concept(
    id: 1,
    category: _cat,
    color: _color,
    icon: '⚡',
    title: 'Horizontal vs Vertical Scaling',
    tagline: 'Scale out, not just up',
    diagram: '''
  VERTICAL (Scale Up)
  ┌─────────────┐
  │   Server     │ ← bigger CPU,
  │   (beefy)    │   more RAM
  └─────────────┘

  HORIZONTAL (Scale Out)
  ┌─────┐ ┌─────┐ ┌─────┐
  │ S1  │ │ S2  │ │ S3  │
  └──┬──┘ └──┬──┘ └──┬──┘
     └───┬────┘──────┘
    ┌────┴────┐
    │  Load   │
    │Balancer │
    └─────────┘''',
    bullets: [
      'Vertical: upgrade one machine (CPU, RAM, SSD) — simple but has a ceiling',
      'Horizontal: add more machines behind a load balancer — scales linearly',
      'Horizontal requires stateless services or shared state (Redis, DB)',
      'Cost: vertical hits diminishing returns; horizontal uses commodity hardware',
      'Most FAANG systems use horizontal scaling with auto-scaling groups',
    ],
    mnemonic: '"OUT not UP" — horizontal scales OUT by adding nodes',
    interviewQ: 'Design Twitter\'s feed system for 500M users — which scaling approach and why?',
    interviewA: 'Horizontal scaling with stateless API servers behind an L7 load balancer. User sessions in Redis, feed data in Cassandra (horizontally partitioned). Vertical scaling alone cannot handle 500M users — a single machine has a hardware ceiling. Auto-scaling groups add/remove instances based on request rate.',
    difficulty: Difficulty.beginner,
    tags: ['scaling', 'infrastructure', 'load-balancer'],
  ),
  Concept(
    id: 2,
    category: _cat,
    color: _color,
    icon: '⚖️',
    title: 'Load Balancing (L4 vs L7)',
    tagline: 'Distribute traffic intelligently',
    diagram: '''
  Clients
    │
    ▼
┌──────────┐
│   L7 LB  │ ← inspects HTTP headers,
│ (ALB/    │   URL path, cookies
│  Nginx)  │
└────┬─────┘
  ┌──┴──┬─────┐
  ▼     ▼     ▼
┌───┐ ┌───┐ ┌───┐
│ A │ │ B │ │ C │  App Servers
└───┘ └───┘ └───┘

  L4 LB (NLB): TCP/UDP level
  → faster, no content inspection
  → good for non-HTTP protocols''',
    bullets: [
      'L4 (Transport): routes by IP + port, no payload inspection — lower latency',
      'L7 (Application): routes by HTTP path, headers, cookies — smarter routing',
      'Algorithms: round-robin, least-connections, IP-hash, weighted',
      'L7 enables: path-based routing, A/B testing, SSL termination',
      'Health checks: both layers ping backends, remove unhealthy nodes',
    ],
    mnemonic: 'L4 = Layer 4 (TCP fast), L7 = Layer 7 (HTTP smart)',
    interviewQ: 'Design a global CDN — where would you use L4 vs L7 load balancers?',
    interviewA: 'L4 (NLB) at the edge for raw TCP performance and TLS passthrough. L7 (ALB/Nginx) behind it for path-based routing to origin servers — e.g., /images → image service, /api → API servers. L7 also handles SSL termination, caching headers, and request routing based on geography cookies.',
    difficulty: Difficulty.beginner,
    tags: ['load-balancing', 'networking', 'infrastructure'],
  ),
  Concept(
    id: 3,
    category: _cat,
    color: _color,
    icon: '📈',
    title: 'Auto-scaling',
    tagline: 'Scale up on demand, scale down on savings',
    diagram: '''
  CloudWatch / Metrics
       │
       ▼  CPU > 70%?
  ┌─────────┐
  │  ASG /  │──→ Launch new instance
  │  HPA    │
  └─────────┘
       │  CPU < 30%?
       └──→ Terminate instance

  Timeline:
  ──────────────────────►
  2 pods → 5 pods → 8 pods → 3 pods
  (morning) (peak)  (viral) (night)''',
    bullets: [
      'HPA (Kubernetes): scales pods based on CPU, memory, or custom metrics',
      'ASG (AWS): scales EC2 instances with launch templates',
      'Scaling policies: target tracking, step scaling, scheduled',
      'Cool-down period prevents thrashing (rapid scale up/down cycles)',
      'Key: make services stateless so instances are disposable',
    ],
    mnemonic: 'ASG = Auto Scaling Group, HPA = Horizontal Pod Autoscaler',
    interviewQ: 'Design a viral video platform that handles 100x traffic spikes',
    interviewA: 'Stateless API servers behind an ASG with target tracking (CPU 60%). CDN absorbs most read traffic. Video processing uses a job queue with separate ASG that scales on queue depth. Database uses read replicas that auto-scale. Key: pre-warm capacity for predicted events, use spot instances for batch processing.',
    difficulty: Difficulty.beginner,
    tags: ['scaling', 'cloud', 'kubernetes'],
  ),
  Concept(
    id: 4,
    category: _cat,
    color: _color,
    icon: '💾',
    title: 'Caching Strategies',
    tagline: 'Trade freshness for speed',
    diagram: '''
  Cache-Aside (Lazy Loading)
  App ──→ Cache hit? ──→ Return
   │         miss
   └──→ DB ──→ Write to cache ──→ Return

  Write-Through
  App ──→ Write Cache ──→ Write DB
                          (sync)

  Write-Behind (Write-Back)
  App ──→ Write Cache ──→ Async write DB
                          (queue/batch)''',
    bullets: [
      'Cache-aside: app manages cache — read from cache first, miss → DB → populate cache',
      'Write-through: write to cache + DB synchronously — consistent but slower writes',
      'Write-behind: write to cache, async flush to DB — fast writes, risk of data loss',
      'Read-through: cache itself fetches from DB on miss (transparent to app)',
      'TTL (Time-To-Live): stale data expires automatically — balance freshness vs hit rate',
    ],
    mnemonic: 'ASIDE = App Sides with cache first; THROUGH = writes go Through both',
    interviewQ: 'Design a URL shortener — which caching strategy for redirect lookups?',
    interviewA: 'Cache-aside with Redis. On redirect: check Redis first (O(1) lookup), miss → query DB → populate Redis with TTL of 24h. Popular URLs stay hot in cache. Write-through on URL creation ensures cache is immediately warm. Use consistent hashing for Redis cluster to distribute keys evenly.',
    difficulty: Difficulty.beginner,
    tags: ['caching', 'redis', 'performance'],
  ),
  Concept(
    id: 5,
    category: _cat,
    color: _color,
    icon: '🗑️',
    title: 'Cache Eviction Policies',
    tagline: 'What to drop when cache is full',
    diagram: '''
  LRU (Least Recently Used)
  ┌─────────────────────────┐
  │ [D] [C] [A] [B]  ← B used │
  │ [D] [C] [A]  evict D    │
  └─────────────────────────┘

  LFU (Least Frequently Used)
  ┌─────────────────────────┐
  │ A:5  B:3  C:1  D:8      │
  │ Evict C (lowest count)   │
  └─────────────────────────┘

  FIFO: First In, First Out
  TTL:  Time-based expiry''',
    bullets: [
      'LRU: evicts least recently accessed — good for temporal locality',
      'LFU: evicts least frequently accessed — good for popularity-based workloads',
      'FIFO: evicts oldest entry — simplest, ignores access patterns',
      'TTL: entries expire after fixed time — prevents serving stale data',
      'Redis supports: volatile-lru, allkeys-lru, volatile-ttl, noeviction',
    ],
    mnemonic: 'LRU = Least Recently Used (time), LFU = Least Frequently Used (count)',
    interviewQ: 'Design a browser cache — which eviction policy and why?',
    interviewA: 'LRU is ideal for browser caches. Users revisit recent pages (temporal locality), so evicting least-recently-used entries maximizes hit rate. Combine with TTL from HTTP Cache-Control headers for freshness. For a CDN, LFU might be better since popular content should stay cached regardless of recency.',
    difficulty: Difficulty.beginner,
    tags: ['caching', 'algorithms', 'redis'],
  ),
  Concept(
    id: 6,
    category: _cat,
    color: _color,
    icon: '🌐',
    title: 'CDN & Edge Computing',
    tagline: 'Bring content closer to users',
    diagram: '''
  User (Tokyo)
    │
    ▼
  ┌───────────┐
  │ Edge PoP  │ ← cache hit → return
  │ (Tokyo)   │
  └─────┬─────┘
        │ cache miss
        ▼
  ┌───────────┐
  │  Origin   │
  │ (US-East) │
  └───────────┘

  PoPs worldwide: 200+ locations
  Latency: 200ms → 20ms''',
    bullets: [
      'CDN caches static assets (images, JS, CSS, video) at edge PoPs worldwide',
      'Reduces latency by serving from nearest PoP — 200ms origin → 20ms edge',
      'Edge computing runs logic at PoPs (Cloudflare Workers, Lambda@Edge)',
      'Cache invalidation: purge API, versioned URLs, TTL headers',
      'Pull CDN: fetches on miss; Push CDN: you upload to edge proactively',
    ],
    mnemonic: 'CDN = Content Delivery Network — copies closer to users',
    interviewQ: 'Design YouTube video delivery for global users',
    interviewA: 'Multi-tier CDN: edge PoPs cache popular videos, mid-tier caches for long-tail, origin for rare content. Use adaptive bitrate streaming (HLS/DASH). Popular videos pre-warmed to edge. Manifest files have short TTL, video segments have long TTL. Edge handles TLS termination and HTTP/2 multiplexing.',
    difficulty: Difficulty.intermediate,
    tags: ['cdn', 'performance', 'networking'],
  ),
  Concept(
    id: 7,
    category: _cat,
    color: _color,
    icon: '📖',
    title: 'Read Replicas',
    tagline: 'Scale reads without touching the primary',
    diagram: '''
  Writes          Reads
    │               │
    ▼               ▼
  ┌──────┐    ┌──────────┐
  │Primary│──→│ Replica 1│
  │  (RW) │──→│ Replica 2│
  └──────┘──→│ Replica 3│
   async      └──────────┘
   replication''',
    bullets: [
      'Primary handles all writes; replicas handle read queries',
      'Async replication: slight lag (ms–s), but higher throughput',
      'Sync replication: zero lag but slower writes (wait for replica ACK)',
      'Read-after-write consistency: read from primary briefly after write',
      'Typical ratio: 1 primary, 3-5 replicas for read-heavy workloads (90% reads)',
    ],
    mnemonic: 'One writer, many readers — like a teacher and students',
    interviewQ: 'Design an e-commerce product page with 10:1 read-to-write ratio',
    interviewA: 'Primary PostgreSQL for writes (inventory updates, reviews). 3+ read replicas behind a connection pool for product page queries. Cache-aside with Redis for hot products. Read-after-write: after posting a review, read from primary for 5s to show own review immediately. Cross-region replicas for global latency.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'replication', 'scaling'],
  ),
  Concept(
    id: 8,
    category: _cat,
    color: _color,
    icon: '🔪',
    title: 'Database Sharding',
    tagline: 'Split data across multiple databases',
    diagram: '''
  Shard Key: user_id % 4

  ┌─────────┐
  │ Router  │
  └────┬────┘
  ┌────┼────┬────┐
  ▼    ▼    ▼    ▼
┌───┐┌───┐┌───┐┌───┐
│ 0 ││ 1 ││ 2 ││ 3 │ Shards
│A,E││B,F││C,G││D,H│
└───┘└───┘└───┘└───┘

  Each shard = independent DB
  Cross-shard queries = expensive''',
    bullets: [
      'Sharding splits data horizontally across multiple DB instances',
      'Shard key determines which shard stores each row — choose carefully',
      'Good shard keys: user_id, tenant_id — avoid hot spots',
      'Bad shard keys: timestamp (all writes hit latest shard), country (uneven)',
      'Cross-shard queries (joins, aggregations) are expensive — avoid in hot paths',
    ],
    mnemonic: 'SHARD = Split Horizontally Across Replicated Databases',
    interviewQ: 'Design Instagram\'s data layer to handle 2B users',
    interviewA: 'Shard by user_id using consistent hashing. Each shard holds user profile + posts + followers for that user range. Feeds require fan-out across shards (pre-compute into Redis). Use a shard map service for routing. Rebalancing: virtual shards (1024 virtual → 16 physical) for smooth scaling. Cross-shard social graph queries via async materialized views.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'sharding', 'scaling'],
  ),
  Concept(
    id: 9,
    category: _cat,
    color: _color,
    icon: '📋',
    title: 'Denormalization',
    tagline: 'Duplicate data for faster reads',
    diagram: '''
  Normalized (3NF):
  users ──┐
          ├──→ join → slow
  posts ──┘

  Denormalized:
  posts_with_user_name
  ┌──────────────────────┐
  │ post_id │ user_name  │ ← duplicated
  │ content │ avatar_url │
  └──────────────────────┘
  → single table read, no join''',
    bullets: [
      'Normalization: no data duplication, uses joins — write-efficient, read-slow',
      'Denormalization: embed/duplicate data — read-efficient, write-overhead',
      'Trade-off: faster reads vs data consistency on writes (update in multiple places)',
      'Common pattern: denormalize for read-heavy paths, normalize for write-heavy',
      'NoSQL databases are inherently denormalized — design for query patterns',
    ],
    mnemonic: 'Normalize for writes, Denormalize for reads',
    interviewQ: 'Design a leaderboard that updates in real-time for 1M concurrent users',
    interviewA: 'Denormalized leaderboard in Redis Sorted Set (ZADD/ZRANGE). User scores duplicated from the source-of-truth DB. On score update: write to PostgreSQL (normalized) + ZADD to Redis (denormalized). Top-100 served from Redis in O(log N). Full leaderboard pagination via ZREVRANGE. Eventual consistency acceptable for rankings (1-2s lag).',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'performance', 'nosql'],
  ),
  Concept(
    id: 10,
    category: _cat,
    color: _color,
    icon: '🔌',
    title: 'Connection Pooling',
    tagline: 'Reuse connections instead of creating new ones',
    diagram: '''
  Without pooling:
  Request → Open conn → Query → Close
  Request → Open conn → Query → Close
  (expensive: TCP + TLS handshake each time)

  With pooling:
  ┌────────────────┐
  │  Pool (20 conn) │
  │  ┌──┐┌──┐┌──┐  │
  │  │C1││C2││C3│  │ ← pre-established
  │  └──┘└──┘└──┘  │
  └────────────────┘
  Request → Borrow → Query → Return''',
    bullets: [
      'Creating a DB connection is expensive: DNS + TCP + TLS + auth = 50-200ms',
      'Pool maintains pre-established connections, app borrows and returns them',
      'Key settings: min/max pool size, idle timeout, connection lifetime',
      'PgBouncer / ProxySQL: external poolers for PostgreSQL / MySQL',
      'Too many connections overwhelm DB — pool acts as a bounded queue',
    ],
    mnemonic: 'Pool = Parking lot for connections — borrow, use, return',
    interviewQ: 'Debug slow DB queries under load — 50ms normally, 2s at peak traffic',
    interviewA: 'Likely connection exhaustion. Diagnosis: check active connections vs pool max. Fix: use PgBouncer in transaction mode (multiplexes many clients over fewer DB connections). Tune pool size = (cores * 2) + spindle_count. Add connection timeout to fail fast. Monitor: pg_stat_activity for idle connections, pool wait time metrics.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'performance', 'infrastructure'],
  ),
];
