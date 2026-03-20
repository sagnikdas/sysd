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
      'Think of vertical scaling like upgrading to a bigger truck, and horizontal scaling like adding more trucks to your fleet — one has a size limit, the other doesn\'t',
      'At some point, the biggest server money can buy still can\'t handle your traffic. That\'s when you need to spread the load across many smaller machines instead',
      'Horizontal scaling puts a load balancer in front of multiple servers. Each server handles a slice of traffic, and you can add more servers as demand grows',
      'The catch with horizontal scaling: your servers can\'t store user sessions locally. You need shared storage (like Redis) so any server can handle any user\'s request',
      'In interviews, default to horizontal scaling for any system with millions of users. Mention auto-scaling groups that add/remove servers based on traffic automatically',
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
      'A load balancer is like a restaurant host — it decides which server each request goes to, so no single server gets overwhelmed',
      'There are two types: L4 works at the network level (just looks at IP addresses — fast but blind to content), and L7 works at the HTTP level (reads URLs, headers, cookies — smarter but slightly slower)',
      'L7 is more common because it can route /api requests to API servers, /images to image servers, and even split traffic for A/B testing — all based on the URL or headers',
      'Load balancers distribute traffic using algorithms like round-robin (take turns), least-connections (send to the least busy), or IP-hash (same user always hits the same server)',
      'Both types continuously health-check backend servers and automatically stop sending traffic to any server that goes down — this is how you get high availability',
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
      'Auto-scaling automatically adds servers when traffic spikes and removes them when it drops — like a store that opens more checkout lanes during rush hour and closes them when it\'s quiet',
      'Without auto-scaling, you either overpay for idle servers or crash during traffic surges. It lets you handle viral moments without manually scrambling to add capacity',
      'It works by watching metrics (CPU usage, request count, queue depth). When a threshold is crossed — like CPU exceeding 70% — new servers launch automatically from a template',
      'A cool-down period prevents "thrashing" — rapidly adding and removing servers. After scaling up, the system waits (e.g., 5 minutes) before evaluating again',
      'In interviews, always pair auto-scaling with stateless services — if any server can be killed and replaced without losing data, auto-scaling works seamlessly',
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
      'A cache is a fast shortcut layer (like Redis) between your app and the database — like keeping frequently used files on your desk instead of walking to the filing cabinet each time',
      'Without caching, every read hits the database directly. At millions of requests per second, this creates a bottleneck. Caches serve hot data in under 1ms vs 10–50ms from a database',
      'Cache-aside is the most common pattern: your app checks the cache first, and on a miss, reads from the DB and stores the result in cache for next time. You control exactly what gets cached',
      'Write-through writes to cache and DB together (consistent but slower). Write-behind writes to cache first, then DB asynchronously (faster but risks data loss on crash). Pick based on your consistency needs',
      'In interviews, always discuss TTL (expiry time) and invalidation — "how do you keep the cache fresh?" is the follow-up interviewers always ask. Mention cache-aside + TTL as your default',
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
      'When a cache is full and a new item needs space, the eviction policy decides which existing item to throw out — like deciding which books to remove from a full bookshelf to make room',
      'LRU (Least Recently Used) removes the item that hasn\'t been accessed for the longest time. This works well for most apps because recently accessed data is likely to be accessed again soon',
      'LFU (Least Frequently Used) removes the item accessed the fewest times overall. Better when some items are consistently popular — it keeps "evergreen hits" even if not accessed in the last few seconds',
      'TTL (Time-To-Live) automatically expires entries after a set duration regardless of access patterns. This prevents serving stale data — a 5-minute TTL means the worst-case staleness is 5 minutes',
      'In interviews, default to LRU + TTL as your eviction strategy. Mention that Redis supports multiple policies and you\'d choose based on workload — LRU for general use, LFU for popularity-driven data',
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
      'A CDN stores copies of your content (images, videos, scripts) on servers worldwide, so users download from a nearby server instead of one far away — like having local warehouses near customers instead of shipping everything from one central factory',
      'Without a CDN, a user in Tokyo requesting content from a US server experiences ~200ms latency. With a CDN, they hit a local edge server and get it in ~20ms — a 10x improvement users can feel',
      'CDNs work by caching content at Points of Presence (PoPs) globally. On the first request, the PoP fetches from your origin server and stores it. Subsequent requests from that region are served from cache',
      'The hardest part is cache invalidation — making sure users get updated content. Common approaches: version your file URLs (app-v2.js), set TTL headers, or use a purge API for emergency updates',
      'In interviews, mention CDN early for any read-heavy system. Edge computing (running code at PoPs, not just caching files) is the next level — useful for auth checks, redirects, or personalization close to the user',
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
      'Read replicas are copies of your main database that handle read queries, while the primary handles all writes — like having one teacher writing on the board and several TAs handing out photocopies to students',
      'Most apps are read-heavy (90%+ reads). Without replicas, one database handles everything and becomes the bottleneck. Adding 3–5 read replicas spreads read traffic across multiple machines',
      'Data flows from primary to replicas via replication. Async replication is faster but replicas may be milliseconds behind — a user who just updated their profile might briefly see the old version if they hit a replica',
      'To fix this "stale read" problem, route the user to the primary for a few seconds right after they write something (read-after-write consistency), then switch back to replicas',
      'In interviews, read replicas are your first scaling tool for read-heavy systems. If writes become the bottleneck instead, that\'s when you discuss sharding (splitting data across multiple databases)',
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
      'Sharding splits your database into smaller pieces (shards), each holding a subset of the data on different machines — like splitting a phone book into A–F, G–M, N–S, T–Z across four desks so each handles fewer lookups',
      'You need sharding when a single database can\'t handle the write volume or data size anymore. Read replicas help with reads, but sharding is how you scale writes beyond one machine',
      'A shard key (e.g., user_id) determines which shard stores each row. A good shard key distributes data evenly — user_id works well because users generate roughly equal amounts of data',
      'Bad shard keys cause "hot spots": timestamp sends all new writes to one shard, country puts 40% of data on the US shard. Uneven distribution defeats the purpose of sharding',
      'The major downside: queries that span multiple shards (joins, aggregations) become expensive and complex. Design your data model so the most common queries hit a single shard',
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
      'Denormalization means intentionally duplicating data to make reads faster — like printing a student\'s name on every exam paper instead of just using a student ID that requires looking up a separate list',
      'In a normalized database, related data lives in separate tables joined at query time. This avoids duplication but joins get slow at scale. Denormalization pre-joins the data so reads are a single table lookup',
      'Example: instead of joining "users" and "posts" tables to show "Alice posted X," you store the user\'s name directly in the posts table. One read, no join needed',
      'The trade-off: when Alice changes her name, you have to update it in every post row, not just one place. More write work and a risk of inconsistency if an update misses some rows',
      'In interviews, use the rule: normalize for write-heavy paths (fewer places to update), denormalize for read-heavy paths (faster reads). Most systems do both — normalized source of truth with denormalized read models',
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
      'A connection pool keeps a set of ready-to-use database connections open, so your app can borrow one instantly instead of creating a new one each time — like a car rental lot vs building a new car for every customer',
      'Opening a new database connection requires DNS lookup, TCP handshake, TLS negotiation, and authentication — that\'s 50–200ms of overhead. At thousands of requests per second, this adds up fast',
      'With a pool, connections are created once at startup and reused. Your app borrows a connection, runs a query, and returns it. The next request reuses the same connection with zero setup overhead',
      'Key settings to tune: max pool size (too high overwhelms the database, too low causes request queuing), idle timeout (close unused connections), and connection lifetime (recycle old connections to avoid leaks)',
      'In interviews, connection pooling is a go-to answer when asked "why is the database slow under load?" Tools like PgBouncer multiplex hundreds of app connections over fewer DB connections',
    ],
    mnemonic: 'Pool = Parking lot for connections — borrow, use, return',
    interviewQ: 'Debug slow DB queries under load — 50ms normally, 2s at peak traffic',
    interviewA: 'Likely connection exhaustion. Diagnosis: check active connections vs pool max. Fix: use PgBouncer in transaction mode (multiplexes many clients over fewer DB connections). Tune pool size = (cores * 2) + spindle_count. Add connection timeout to fail fast. Monitor: pg_stat_activity for idle connections, pool wait time metrics.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'performance', 'infrastructure'],
  ),
];
