import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Interview Systems';
final _color = AppColors.interviewSystems;

final conceptsInterviewSystems = <Concept>[
  Concept(
    id: 119,
    category: _cat,
    color: _color,
    icon: '🐦',
    title: 'Design Twitter / News Feed',
    tagline: 'Fan-out on write vs read',
    diagram: '''
  Post ──► for each follower? (push — celeb problem)
       or
  Pull ──► merge on read (slow for heavy readers)

  Hybrid: push to active, pull for long tail''',
    bullets: [
      'The core question is "who assembles each user\'s feed?" Fan-out on write (pre-compute when posted) is fast for readers but expensive for popular users. Fan-out on read (assemble when requested) is simpler but slower',
      'Hybrid approach: when a normal user posts, push to all followers\' feed caches. For celebrities with millions of followers, skip the push — merge their posts at read time instead, avoiding millions of writes',
      'Each user\'s timeline is a list of post IDs in Redis. Background workers handle fan-out: when a post is created, workers asynchronously push the ID into each follower\'s timeline list',
      'The feed is eventually consistent — a post might appear in one follower\'s feed before another\'s. For a social feed, nobody notices a 2-second delay',
      'In interviews, clarify scale first (DAU, posts/day), then state the trade-off: "hybrid fan-out — push for normal users, pull for celebrities — with Redis timelines and eventual consistency"',
    ],
    mnemonic: 'Feed = who fans out the post?',
    interviewQ: 'Justin Bieber tweets — your push model dies',
    interviewA: 'Detect high fan-out accounts; for them skip push and merge their tweets at read time into follower timelines. Cap fan-out queue depth with shedding. Use ranked feed later — not strictly chronological. Store tweet ids, hydrate tweet bodies from object store. Rate limit posting. Monitor hot keys in cache.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'feed', 'social'],
  ),
  Concept(
    id: 120,
    category: _cat,
    color: _color,
    icon: '📸',
    title: 'Design Instagram',
    tagline: 'Photos, feed, stories',
    diagram: '''
  Upload ──► object storage (S3)
         ──► CDN for delivery
         ──► async transcoding thumbs

  Feed similar to Twitter hybrid fan-out''',
    bullets: [
      'The core is a media pipeline: user uploads → stored in S3 → transcoded into multiple resolutions asynchronously → served through CDN. Upload and viewing paths are completely separate',
      'The social graph drives the feed. Feed assembly works like Twitter\'s hybrid fan-out: pre-compute for normal users, merge at read time for celebrities',
      'Stories are ephemeral (24-hour TTL) with different requirements: higher churn, lower latency. A separate fast-path pipeline handles stories with aggressive edge caching',
      'Image processing is a pipeline: original → queue → resize to multiple resolutions → generate thumbnails → content moderation → mark as ready. Users see loading state until complete',
      'In interviews, separate concerns: "media storage and CDN, social graph database, hybrid fan-out feed, and async pipeline for processing and moderation. Each scales independently"',
    ],
    mnemonic: 'Instagram = storage + graph + feed',
    interviewQ: 'Resize images for many clients',
    interviewA: 'Generate standard variants (thumb, medium, full) async via queue; store URIs in DB. CDN with Accept-CH or client hints optional. On-the-fly resizing at CDN edge if provider supports. Lazy generation on first request with cache. Original archived in cold storage for reprocessing.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'media', 'cdn'],
  ),
  Concept(
    id: 121,
    category: _cat,
    color: _color,
    icon: '🚗',
    title: 'Design Uber',
    tagline: 'Matching, maps, real-time',
    diagram: '''
  Riders & drivers location streams
       │
  Spatial index (geohash / quadtree)
       │
  Dispatch service picks nearest ETA''',
    bullets: [
      'The core challenge is real-time matching: connect a rider to the nearest available driver within seconds. This requires tracking live locations of millions of drivers and querying "who is near this pickup?"',
      'Use a spatial index (geohash or quadtree) to partition the map. Drivers send location updates every few seconds. Dispatch queries nearby cells and ranks by estimated arrival time, not straight-line distance',
      'A trip follows a state machine: requested → matched → driver arriving → in progress → completed. Payment charges only after completion, using idempotency keys to prevent double-charging',
      'Surge pricing is a separate service monitoring supply/demand per zone. When demand exceeds supply, prices increase to attract drivers and moderate demand — decoupled from matching',
      'In interviews: "drivers stream locations via WebSocket to a dispatch service with a spatial index. Matching queries nearby cells sorted by ETA. Trip lifecycle is a state machine with events for downstream services"',
    ],
    mnemonic: 'Uber = moving dots + matching engine',
    interviewQ: 'Match rider to driver in 2s globally',
    interviewA: 'Partition world into cells; each cell has in-memory index of available drivers from recent heartbeats. Query neighboring cells for nearest N by road ETA using routing service with cache. Precompute heat maps for repositioning drivers. Handle split-brain with sticky session to dispatch shard. Fallback list if top match declines.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'geo', 'realtime'],
  ),
  Concept(
    id: 122,
    category: _cat,
    color: _color,
    icon: '💬',
    title: 'Design WhatsApp',
    tagline: 'Chat, delivery, privacy',
    diagram: '''
  Client ──► gateway ──► chat service
                    │
              message store (per conv shard)
                    │
              push notification if offline''',
    bullets: [
      'The core is reliable, ordered message delivery: every message must arrive in order, even if the recipient is offline. The server acts as a relay and store-and-forward system',
      'Messages within a conversation get monotonically increasing sequence numbers. If message 5 arrives before 4, the client waits for 4 before displaying. Gap detection triggers a sync request',
      'End-to-end encryption means the server stores only encrypted blobs it cannot read. The server\'s job is delivery, not content — it can\'t scan messages or build profiles from message content',
      'Delivery receipts (sent, delivered, read) are separate lightweight events. "Last seen" and "online" status use a key-value store with short TTLs — when the app closes, the TTL expires and they appear offline',
      'In interviews: "each conversation assigns sequence numbers for ordering. Store-and-forward for offline users. Media goes to object storage with a reference in the message. End-to-end encryption means the server can\'t read content"',
    ],
    mnemonic: 'Chat = ordered messages + push + presence',
    interviewQ: 'Guarantee message order in group chat',
    interviewA: 'Single leader per conversation shard assigns monotonic seq. Clients display by seq; gap detection triggers sync. Handle partition: choose availability with possible temporary fork — reconcile with CRDT or last-writer-wins with server timestamp. At-least-once delivery with client dedup keys.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'messaging', 'chat'],
  ),
  Concept(
    id: 123,
    category: _cat,
    color: _color,
    icon: '🎬',
    title: 'Design Netflix',
    tagline: 'Streaming, CDN, recommendations',
    diagram: '''
  Encode ladder (many bitrates)
       │
  Origin ──► Open Connect CDN (ISP edge)
       │
  Client adaptive bitrate (ABR)''',
    bullets: [
      'The key challenge is delivering high-quality video to millions of concurrent viewers with minimal buffering. Netflix\'s CDN (Open Connect) embeds servers inside ISP networks — content is physically close to users',
      'Videos are encoded at multiple quality levels and split into small chunks (2-10s). The Adaptive Bitrate player dynamically switches quality based on network speed — HD on WiFi, lower on weak cellular',
      'Popular content is pre-positioned on edge servers based on viewing predictions. If a new show will be popular in Brazil, chunks are pushed to Brazilian ISP edges before launch day',
      'The homepage is personalized per user: each row is a different recommendation algorithm. Recommendations are computed offline and cached — the real-time path is a fast lookup, not live ML inference',
      'In interviews: "multi-bitrate encoding ladder pushed to ISP-embedded CDN. ABR player adapts to conditions. Recommendations pre-computed offline, served from cache — the homepage is unique per user"',
    ],
    mnemonic: 'Netflix = encodes + edge + player smarts',
    interviewQ: 'Reduce buffering on variable networks',
    interviewA: 'ABR chooses lower bitrate on throughput drops; buffer health heuristics. Multiple CDN origins with failover. TCP vs QUIC experiments. Preposition popular content on edge based on predictions. Measure QoE not just average bitrate. Edge compute for manifest personalization.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'video', 'cdn'],
  ),
  Concept(
    id: 124,
    category: _cat,
    color: _color,
    icon: '📁',
    title: 'Design Dropbox',
    tagline: 'Sync, dedup, conflicts',
    diagram: '''
  Client watches filesystem
       │
  Chunk files ──► hash ──► upload missing chunks
       │
  Server metadata graph per user''',
    bullets: [
      'The core is file sync: keep files consistent across devices while handling conflicts, large files, and intermittent connectivity. Architecture separates content (chunks in block storage) from metadata (database)',
      'Files are split into chunks (~4MB) and each chunk is hashed. Only new or changed chunks are uploaded — content-defined chunking enables dedup across versions (small edits upload only changed chunks) and across users',
      'The metadata service tracks the file tree: paths, versions, chunk references, timestamps. Each modification increments a version counter and records which chunks changed, enabling version history',
      'Conflicts arise when two devices edit the same file offline. The sync service detects divergent versions and either auto-merges (text) or creates "conflicted copy" files for the user to resolve',
      'In interviews: "files are content-chunked and deduplicated by hash. Only new chunks are uploaded. Metadata is centrally consistent, conflict detection uses version vectors, and the client monitors filesystem changes via OS-level watchers"',
    ],
    mnemonic: 'Dropbox = chunks + metadata tree',
    interviewQ: 'Two offline edits same file',
    interviewA: 'Detect divergent versions on sync; surface conflict copies to user or merge for line-based text. Vector clocks or version vectors per file help identify causality. Server authoritative timestamp as tie-break only if business accepts. Mobile may prefer server-wins for photos with rename.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'storage', 'sync'],
  ),
  Concept(
    id: 125,
    category: _cat,
    color: _color,
    icon: '🔎',
    title: 'Design Google Search',
    tagline: 'Crawl, index, rank',
    diagram: '''
  Crawler frontier ──► fetch ──► parse
       │
  Inverted index: term → doc list
       │
  PageRank / ML rank on top hits''',
    bullets: [
      'Three major components: crawling (discovering and fetching pages), indexing (building a searchable data structure), and ranking (deciding which results best match the query and in what order)',
      'The inverted index is the core: for each word, it stores a list of documents containing it. "database" → [doc42, doc99, doc203]. This allows instant lookup of all pages containing any search term',
      'The crawler uses a URL frontier (priority queue) with distributed workers that fetch pages while respecting robots.txt and per-site rate limits. Links are extracted for future crawling, content goes to the indexer',
      'Query understanding transforms raw queries: correct spelling, expand synonyms ("car" → "automobile"), parse intent ("weather NYC" → weather card), handle natural language ("restaurants near me" → geo query)',
      'In interviews: "inverted index sharded by term or document. Queries fan out to shards, each returns top-K, coordinator merges and re-ranks. Popular queries cached. Snippets pre-generated from crawled content"',
    ],
    mnemonic: 'Search = crawl + invert + rank',
    interviewQ: 'Shard inverted index at scale',
    interviewA: 'Partition by term: high-frequency terms on dedicated shards with replicas; long tail terms co-located. Doc shards alternative for distributed scoring. Two-phase query: fetch postings from term shards, merge in coordinator. Cache hot queries. BM25 + signals in ranking layer. Compression for postings lists.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'search', 'scale'],
  ),
  Concept(
    id: 126,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Design URL Shortener',
    tagline: 'Keys, redirects, analytics',
    diagram: '''
  POST long URL ──► generate short key (base62)
       │
  GET /abc ──► 302 Location: long
       │
  Counter or random + uniqueness check''',
    bullets: [
      'A URL shortener maps short codes (bit.ly/abc123) to long URLs and redirects. Conceptually simple, but the interesting design decisions are in key generation, redirect performance, and analytics at scale',
      'Key generation: database counter (simple, no collisions, but predictable) or random base62 strings with collision checking (unpredictable, needs validation). A pre-generated key pool avoids runtime collision checking',
      'Use 302 (temporary redirect) not 301 (permanent) if you need analytics: browsers cache 301s and skip your server, so you lose click tracking. 302 forces every click through your service',
      'The redirect path must be fast — cache popular short URLs in Redis for O(1) lookup. The write path (creating URLs) is less frequent and can be slower',
      'In interviews: "pre-generated base62 keys from a distributed ID generator. Redis first for redirect, fallback to database. Click events published async to Kafka for analytics. Rate-limit creation, scan target URLs for malware"',
    ],
    mnemonic: 'Shortener = KV with HTTP redirect',
    interviewQ: 'Generate short URLs without collisions',
    interviewA: 'Pre-generate random 62^7 keys in batch from DB sequence sharded across allocators. Or base62 encode snowflake ID. UNIQUE constraint on key; retry on collision. Avoid predictable keys for security. Cache hot mappings in Redis. Optional signed URLs for private short links.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'api', 'scaling'],
  ),
  Concept(
    id: 127,
    category: _cat,
    color: _color,
    icon: '🕷️',
    title: 'Design Web Crawler',
    tagline: 'Polite, distributed frontier',
    diagram: '''
  URL frontier (priority queue)
       │
  Workers respect per-host rate
       │
  Dedup bloom + persistent seen set''',
    bullets: [
      'A web crawler systematically downloads pages to build a search index. Key challenges: scale (billions of pages), politeness (not overloading sites), deduplication (not re-fetching identical content), and freshness',
      'The URL frontier is a priority queue deciding what to crawl next. Each domain has a rate limit between requests. High-value pages (frequently updated, highly linked) get higher priority',
      'Deduplication at two levels: URL dedup (don\'t fetch the same URL twice — Bloom filter) and content dedup (detect identical content at different URLs — content hashing). Both save bandwidth and storage',
      'Distributed crawling assigns URL ranges to workers, partitioned by domain hash so one worker handles one domain — making per-domain rate limiting simple and avoiding flooding from multiple workers',
      'In interviews: "workers partitioned by domain hash for rate limiting. Bloom filter deduplicates URLs. Content hashing for content dedup. Frontier prioritizes by importance and change frequency. Crawling, parsing, and indexing are separate pipeline stages"',
    ],
    mnemonic: 'Crawler = polite ant colony',
    interviewQ: 'Avoid overloading small sites',
    interviewA: 'Central scheduler tracks per-host last fetch time and crawl-delay from robots.txt. Token bucket per domain. Prioritize high-value domains. Distributed workers pull from Kafka partitioned by hash(host) for locality. Backoff on 429/5xx. Monitor global QPS per ASN.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'crawler', 'distributed'],
  ),
  Concept(
    id: 128,
    category: _cat,
    color: _color,
    icon: '🎫',
    title: 'Design Ticket Booking (BookMyShow)',
    tagline: 'Seats, contention, fairness',
    diagram: '''
  User selects seat ──► hold (TTL) in Redis
       │
  Payment success ──► confirm in DB transaction
       │
  Release hold on timeout''',
    bullets: [
      'The core challenge is preventing double-booking: when 1,000 users try to book the same seat, exactly one must succeed and the rest fail gracefully — no overselling, no stuck inventory',
      'Two-phase approach: hold and confirm. Selecting a seat creates a temporary hold with TTL (10 minutes). If payment completes within TTL, confirm. If not, the hold expires and the seat becomes available again',
      'The hold must be atomic: use SELECT FOR UPDATE or Redis SETNX. If two requests try to hold the same seat simultaneously, one succeeds and the other gets "seat taken" immediately',
      'Seat availability must always read from the primary database, not read replicas. A replica might show a seat as available when it\'s already booked. Strong consistency is essential for inventory',
      'In interviews: "seat hold via atomic Redis SETNX with 10-minute TTL. Payment confirms within the TTL. Expired holds release automatically. We never read availability from replicas — only the primary, to prevent overselling"',
    ],
    mnemonic: 'Booking = hold seat like grocery cart timer',
    interviewQ: 'Two users book same seat',
    interviewA: 'Use transaction with SELECT FOR UPDATE on seat row or unique constraint insert on (show_id, seat_id). Optimistic retry on conflict. Redis hold with Lua atomic check-and-set before DB commit path. Never trust client — server validates. Load test thundering herd on onsale.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'transactions', 'ecommerce'],
  ),
  Concept(
    id: 129,
    category: _cat,
    color: _color,
    icon: '🛒',
    title: 'Design E-commerce Checkout',
    tagline: 'Cart, inventory, payments',
    diagram: '''
  Cart (session) ──► inventory reservation
        │
  Payment intent ──► PSP ──► webhook confirm
        │
  Saga: cancel reservation if payment fails''',
    bullets: [
      'Checkout is a multi-step saga across services — inventory (reserve items), pricing (calculate taxes), payment (charge card), and order (create record). Each step can fail and needs a compensation (undo)',
      'Inventory reservation prevents overselling: reserve items with a TTL when checkout starts. Payment success converts to confirmed deduction. Payment failure or timeout releases the reservation automatically',
      'Payment idempotency is non-negotiable: always send a unique key with the payment request. Network retries, webhook duplicates, and double-clicks must all result in exactly one charge',
      'Use the outbox pattern: write the order record and an "OrderCreated" event in the same database transaction. A separate publisher sends to downstream services. This prevents "order saved but event lost"',
      'In interviews, walk through failures: "if payment succeeds but order service crashes, reconciliation matches PSP settlements to orders. Every step has a compensation: failed payment releases inventory, failed order triggers refund"',
    ],
    mnemonic: 'Checkout = reservation + money + saga',
    interviewQ: 'Payment succeeds but order not created',
    interviewA: 'Reconciliation job matches PSP settlements to orders; repair or refund. Webhook processing must be idempotent with stored event id. Outbox pattern ties order row + outbox in same TX before calling payment. Compensating refund if downstream fails after charge. Audit log for support.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'ecommerce', 'payments'],
  ),
  Concept(
    id: 130,
    category: _cat,
    color: _color,
    icon: '💾',
    title: 'Design Distributed Cache',
    tagline: 'Memcached vs Redis cluster',
    diagram: '''
  Client consistent hash → node
  Node failure → remapped keys churn

  Replication vs client multiget shards''',
    bullets: [
      'A distributed cache spreads data across multiple nodes. The client uses consistent hashing to determine which node stores each key — minimizing data movement when nodes are added or removed',
      'Cache stampede is the biggest risk: when a popular key expires, hundreds of requests hit the database simultaneously. Prevent with a mutex (one rebuilds, others wait), probabilistic early refresh, or stale-while-revalidate',
      'TTL jitter prevents synchronized expiry: if all keys have exactly 1-hour TTL set at the same time, they all expire together causing a stampede. Random jitter (55-65 minutes) spreads expirations',
      'A cache is never the source of truth — it\'s a performance layer. If it crashes and restarts empty, the system should still work (just slower while warming up), not lose data',
      'In interviews: "consistent hashing distributes keys. Cache stampede prevented with single-flight. TTL jitter prevents synchronized expiry. LRU eviction. The database is always the source of truth"',
    ],
    mnemonic: 'Cache = fast forgetful scratchpad',
    interviewQ: 'Thundering herd on hot key expiry',
    interviewA: 'Mutex per key in app (single-flight), or request coalescing layer. Stale-while-revalidate serves old value while one worker refreshes. Random TTL jitter. Precompute on schedule for known hot keys. CDN layer for truly public data. Consider local in-process L1 + shared L2.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'caching', 'redis'],
  ),
  Concept(
    id: 131,
    category: _cat,
    color: _color,
    icon: '🚦',
    title: 'Design a Rate Limiter',
    tagline: 'Distributed token bucket',
    diagram: '''
  API gateway ──► Redis INCR + TTL / Lua token bucket
       │
  Headers: remaining, reset

  Per user, per IP, per API key tiers''',
    bullets: [
      'A rate limiter tracks how many requests each user makes within a time window and rejects excess with 429. The design challenge is doing this accurately across multiple servers with minimal latency',
      'Use Redis as the central counter: each request increments a counter with TTL for automatic window reset. Atomic Lua scripts ensure check-and-increment is a single operation, preventing race conditions',
      'For multiple servers, every request must check the same central counter. Redis provides this global view. For soft limits where minor over-allow is acceptable, use local per-server counters to skip the Redis round-trip',
      'Always return helpful headers: X-RateLimit-Limit (max allowed), X-RateLimit-Remaining (left), X-RateLimit-Reset (window reset time), and Retry-After on 429 responses',
      'In interviews: "rate limits in a config service — different tiers (free: 100/min, pro: 1000/min) and different limits for read vs write. Redis token bucket provides global accuracy across all API servers"',
    ],
    mnemonic: 'Rate limiter = traffic lights API',
    interviewQ: 'Precise global 100 req/min per user',
    interviewA: 'Redis sliding window with ZSET of timestamps or Lua atomic token bucket per user key. Expire keys to bound memory. Handle Redis failure: fail open vs closed product decision. Edge POP local counters with small overshoot vs central sync. Test at scale with parallel clients.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'rate-limiting', 'system-design'],
  ),
  Concept(
    id: 132,
    category: _cat,
    color: _color,
    icon: '🔔',
    title: 'Design Notification System',
    tagline: 'Multi-channel fan-out',
    diagram: '''
  Event ──► notification service
              │
        template + prefs filter
              │
    ┌─────────┼─────────┐
    push    email     sms''',
    bullets: [
      'A notification system delivers messages through multiple channels (push, email, SMS) based on user preferences. One event ("order shipped") may trigger push + email but not SMS, depending on settings',
      'Architecture: event triggers notification service → checks user preferences → renders template → routes to channel-specific queues → workers deliver via FCM (push), SMTP (email), or Twilio (SMS)',
      'Each channel has different characteristics: push is fast but unreliable, email is reliable but slow, SMS is expensive. Separate queues per channel so a slow email provider doesn\'t block push notifications',
      'Digest mode batches high-frequency notifications ("You have 15 new comments" instead of 15 pushes). Prevents notification fatigue, especially important for social apps with high activity',
      'In interviews: "each notification has a unique ID for deduplication. Users control preferences per channel and category. Every email includes one-click unsubscribe. We rate-limit per channel to avoid provider throttling"',
    ],
    mnemonic: 'Notifications = fan-out with user prefs',
    interviewQ: 'Email provider throttles us',
    interviewA: 'Multiple provider failover; backoff queue; prioritize transactional over marketing. Shard sending across IPs with good reputation. Honor rate limits with token bucket per provider. Retry DLQ for failures. Warm up new IPs gradually. Separate streams so marketing slowdown doesn’t block password reset.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'messaging', 'scale'],
  ),
  Concept(
    id: 133,
    category: _cat,
    color: _color,
    icon: '📰',
    title: 'Design News Feed Ranking',
    tagline: 'Not chronological',
    diagram: '''
  Candidate generation (1000s)
       │
  Lightweight ranker
       │
  Heavy ML rerank top K''',
    bullets: [
      'A ranked feed moves beyond chronological to show the most relevant content first. Multi-stage pipeline: retrieve candidates (thousands) → lightweight pre-rank (narrow to hundreds) → heavy ML ranking (final order) → business rules',
      'Candidate generation casts a wide net: friends\' posts, followed pages, suggested content, ads. The pre-ranker quickly scores with a lightweight model to narrow to top 50-100 for expensive ML scoring',
      'The heavy ranker uses features: engagement history (what does this user interact with?), author affinity (how often they engage with this poster?), recency, and content type to predict clicks, likes, comments',
      'Post-ranking rules enforce diversity: don\'t show 5 posts from one person, cap ad frequency, suppress low-quality content, inject new content types to prevent filter bubbles',
      'In interviews: "full pipeline in ~200ms. Candidates pre-computed offline. Lightweight ranker narrows on fast path. If heavy ranker times out, fall back to pre-ranked order. Results cached for smooth scroll pagination"',
    ],
    mnemonic: 'Ranking = retrieve then prune then score',
    interviewQ: 'Ranking latency budget 200ms',
    interviewA: 'Two-stage: cheap inverted index + linear model for 500→50, then small NN on 50→10 in parallel microservices with deadline. Precompute heavy user embeddings offline. Approximate nearest neighbor for similar posts. Fallback to chronological if timeout. Measure p99 tail.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'ml', 'feed'],
  ),
  Concept(
    id: 134,
    category: _cat,
    color: _color,
    icon: '📍',
    title: 'Design Yelp / Nearby Places',
    tagline: 'Geo queries at scale',
    diagram: '''
  Stores geohash indexed
       │
  Query: bounding box or radius
       │
  Filter + rank by distance/reviews''',
    bullets: [
      'The core is a geo-spatial query: "find restaurants within 2km." This requires a spatial index — regular B-tree indexes on latitude/longitude won\'t cut it',
      'Geohashing encodes a location into a string where nearby points share prefixes. Finding nearby places becomes a simple string prefix search on the geohash plus neighboring cells',
      'An alternative: Quadtree recursively divides the map into quadrants, with denser areas getting more subdivisions. Manhattan needs finer granularity than rural areas',
      'Results need secondary ranking: distance alone isn\'t enough. A 4.8-star restaurant 1.5km away should rank higher than a 3-star one 500m away. Combine distance + rating + review count',
      'In interviews: "locations stored with geohash indexes. Proximity queries use prefix matching. Results ranked by distance + rating. Reviews moderated async. Photos served through CDN"',
    ],
    mnemonic: 'Yelp = geo index + reviews',
    interviewQ: 'Find 20 coffee shops within 2km fast',
    interviewA: 'Geohash cells covering circle; query Redis/ES with those prefixes; exact distance filter after. Precomputed popular area tiles cached. For huge result sets, limit candidates by density. Secondary sort by rating + distance score. Shard by region. Consider S2/H3 cells for uniform areas.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'geo', 'search'],
  ),
  Concept(
    id: 135,
    category: _cat,
    color: _color,
    icon: '📝',
    title: 'Design Google Docs',
    tagline: 'OT, CRDTs, presence',
    diagram: '''
  Edits as operations with positions
       │
  OT transforms concurrent ops
       │
  WebSocket sync; snapshot checkpoints''',
    bullets: [
      'The core challenge is real-time collaborative editing: multiple users typing simultaneously without overwriting each other. This requires a conflict resolution mechanism that merges concurrent edits deterministically',
      'Operational Transform (OT) transforms each user\'s operations against concurrent ones. If user A inserts at position 5 and user B deletes character 3, A\'s position shifts because B changed the positions',
      'CRDTs (Conflict-Free Replicated Data Types) are an alternative: each character has a unique ID, operations reference IDs not positions, so they commute naturally — no transforms needed, works offline too',
      'For performance, store periodic snapshots plus an operation log. New users load the latest snapshot and replay recent operations — instead of replaying millions from the beginning',
      'In interviews: "users connect via WebSocket. Each keystroke becomes an operation sent to the server, which sequences and broadcasts. OT or CRDT ensures all clients converge. Cursor positions are ephemeral presence data"',
    ],
    mnemonic: 'Collaborative doc = ordered ops + merge math',
    interviewQ: 'Offline edits converge without conflicts',
    interviewA: 'CRDT text type (RGA/YATA) converges automatically; OT with central server transforms ops against history. Client buffers offline ops; on reconnect send batch; server returns transformed ops for others. Snapshot + vector clock to know divergence. Size limits per doc; compress op log.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'collaboration', 'crdt'],
  ),
  Concept(
    id: 136,
    category: _cat,
    color: _color,
    icon: '⏱️',
    title: 'Design Distributed Job Scheduler',
    tagline: 'Cron at scale',
    diagram: '''
  Scheduler picks due jobs ──► queue
       │
  Workers execute with at-least-once
       │
  Lease/lock prevents double run''',
    bullets: [
      'A distributed job scheduler manages recurring and one-time tasks across many servers — like cron at scale, where no single machine owns all jobs and losing one machine doesn\'t lose scheduled work',
      'Jobs are stored with next execution time in a sorted structure (Redis sorted set). A scheduler scans for due jobs, claims them with a lock/lease (preventing double execution), and dispatches to a work queue',
      'The biggest challenge: preventing a job from running twice. Use a distributed lock with lease TTL: the scheduler acquires a lease before dispatching. If it crashes, the lease expires and another scheduler picks up',
      'Exactly-once execution is impossible — the scheduler might crash after dispatching but before recording it. Every job must be idempotent: running twice produces the same result',
      'In interviews: "jobs in a sorted set by next_run. Scheduler acquires a lease before dispatching. Workers process idempotently with dedup keys. Failed jobs retry with backoff, land in DLQ after max retries. Alert on job lag"',
    ],
    mnemonic: 'Scheduler = fancy alarm clock cluster',
    interviewQ: 'Job must not run twice on two schedulers',
    interviewA: 'Acquire DB advisory lock or DynamoDB conditional lock per job id with lease TTL. Only lease holder dispatches. If worker dies, lease expires and retry. Cron dedup key includes scheduled time. At-least-once delivery to queue; consumer idempotent. Use existing system (Temporal) for complex workflows.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'distributed', 'jobs'],
  ),
  Concept(
    id: 137,
    category: _cat,
    color: _color,
    icon: '🏆',
    title: 'Design Real-Time Leaderboard',
    tagline: 'Sorted sets, sharding',
    diagram: '''
  UPDATE score ──► Redis ZADD leaderboard:game1

  Top 100: ZREVRANGE O(log N + K)

  Global scale: shard by game_id''',
    bullets: [
      'Redis Sorted Sets are the classic solution: ZADD updates a score in O(log N), ZREVRANGE returns top-K in O(log N + K) — both sub-millisecond even with millions of entries',
      'Tie-breaking: encode timestamp into the score (score = actual_score × 1,000,000 + MAX_TIMESTAMP - timestamp). Among tied scores, the earlier achiever ranks higher',
      'Redis is fast but not durable. Periodically snapshot to a database for durability. If Redis crashes, rebuild from the latest snapshot — in-flight updates are lost but acceptable for games',
      'For live UI updates, use pub/sub: when a score changes, publish on a channel. Connected clients (via WebSocket) receive the update and animate the rank change',
      'In interviews: "one Redis Sorted Set per game. For thousands of games, shard by game_id. A global leaderboard aggregates top-K from each shard periodically"',
    ],
    mnemonic: 'Leaderboard = always-sorted set',
    interviewQ: 'Billion scores — Redis too big',
    interviewA: 'Shard leaderboard per game or region; aggregate top-K periodically. Approximate algorithms (count-min, HyperLogLog) for display tiers. For global rank, use fractional cascading or segment trees in custom service. Cold storage in warehouse for history; hot set in memory only.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'gaming', 'redis'],
  ),
  Concept(
    id: 138,
    category: _cat,
    color: _color,
    icon: '🚪',
    title: 'Design API Gateway',
    tagline: 'Edge for microservices',
    diagram: '''
  Auth, rate limit, routing, WAF
       │
  /v1/users ──► user-service
  /v1/orders ──► order-service''',
    bullets: [
      'An API gateway is the single entry point for all client traffic — handling auth, rate limiting, and routing in one place so individual services don\'t have to, like airport security centralizing screening',
      'Core responsibilities: terminate TLS, validate JWT tokens, route to the right service (/users → user-service), rate limit per client, and inject tracing headers for observability',
      'Must be stateless and horizontally scalable — it\'s in the critical path of every request. If it goes down, everything is affected. Keep it thin: auth, routing, rate limiting only. Never business logic',
      'Add circuit breakers: if order-service is unhealthy, return a fast 503 instead of queuing requests that will timeout — protecting users and the struggling service',
      'In interviews: "gateway handles TLS, auth, coarse rate limiting, routing, and tracing. Fine-grained authorization and business rules live in individual services. Horizontally scaled behind a load balancer"',
    ],
    mnemonic: 'Gateway = airport security + gates',
    interviewQ: 'Gateway becomes bottleneck',
    interviewA: 'Scale gateway horizontally statelessly; anycast or LB. Offload auth crypto to hardware or fewer validations (introspection cache). Move heavy transforms to BFF. Use connection pooling to origins. Profile CPU — regex routes expensive. Consider service mesh for east-west leaving gateway thinner.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'gateway', 'microservices'],
  ),
  Concept(
    id: 139,
    category: _cat,
    color: _color,
    icon: '💳',
    title: 'Design Payment System',
    tagline: 'Ledger, idempotency, reconciliation',
    diagram: '''
  Double-entry ledger rows
       │
  PSP webhook ──► idempotent apply
       │
  Nightly reconcile PSP vs ledger''',
    bullets: [
      'A payment system handles the most sensitive operation — moving money. Core principles: every transaction in an immutable ledger, idempotency prevents double-charging, strong consistency ensures correct balances',
      'Double-entry ledger: every transaction creates two entries (debit one account, credit another) that sum to zero. Entries are append-only — never edit or delete. Corrections are new adjusting entries',
      'Card tokenization (Stripe, Adyen) keeps you out of PCI scope: the provider stores card numbers and gives you a token. Your system only handles tokens, dramatically reducing security requirements',
      'Every payment request includes a unique idempotency key. Network retries, webhook duplicates, and double-clicks must all result in exactly one charge',
      'In interviews: "payment intent creates a pending ledger entry. PSP webhook confirms or fails. Success updates to completed, failure triggers a refund entry. Nightly reconciliation compares our ledger against PSP settlements"',
    ],
    mnemonic: 'Payments = ledger + idempotency + lawyers',
    interviewQ: 'Double charge investigation',
    interviewA: 'Trace idempotency keys and PSP payment intent ids in ledger. Immutable event log. Reconciliation job flags duplicates. Refund duplicate with audit. Root cause often webhook retry without idempotency. Partition tolerance: choose consistency for money — not eventual for balances.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'payments', 'finance'],
  ),
  Concept(
    id: 140,
    category: _cat,
    color: _color,
    icon: '📡',
    title: 'Design IoT Telemetry Pipeline',
    tagline: 'Ingest firehose',
    diagram: '''
  Devices MQTT/HTTP ──► ingest tier
       │
  Kafka ──► stream processing
       │
  TSDB + cold storage''',
    bullets: [
      'An IoT pipeline ingests data from millions of devices. 10 million devices at one message per second = 10 million messages/second — requiring a high-throughput ingestion tier',
      'Devices connect via lightweight protocols (MQTT, HTTP) to regional endpoints. Batch multiple readings into one payload — one message with 10 readings is far cheaper than 10 separate messages',
      'After ingestion, data splits into two paths: hot path (stream processing for real-time alerts — "temperature exceeds 100°C, shut down") and cold path (batch storage in Parquet for analytics and ML training)',
      'Device authentication uses per-device keys (X.509 certificates) with rotation. Never use a shared secret for all devices — compromising one compromises the entire fleet',
      'In interviews: "regional MQTT brokers ingest, publish to Kafka. Flink runs real-time alerting. Cold path writes Parquet to S3. Each device has unique credentials. Commands to devices use a separate downlink channel"',
    ],
    mnemonic: 'IoT = many small noisy speakers',
    interviewQ: '10M devices each send 1 msg/sec',
    interviewA: 'Regional ingest endpoints; Kafka with millions of partitions impractical — aggregate at edge gateway into wider batches per region. Partition by device_id hash. Cold path to object storage (Parquet) for analytics. Hot path to TSDB (Influx, Timescale) downsampled. Backpressure devices on overload.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'iot', 'streaming'],
  ),
  Concept(
    id: 141,
    category: _cat,
    color: _color,
    icon: '⚙️',
    title: 'Design Distributed Config Service',
    tagline: 'Feature flags and dynamic config',
    diagram: '''
  Admin UI ──► config service ──► clients poll/long-poll
       │
  Version + hash; rollback instant

  etcd/Consul for strongly consistent core''',
    bullets: [
      'A config service lets you change application behavior without redeploying — feature flags, rate limits, experiment percentages, kill switches. Toggling a feature in seconds vs minutes for a redeploy is critical during incidents',
      'Architecture: admin UI → strongly consistent store (etcd, Consul) → client SDK in each service that caches locally and refreshes periodically. Local caching means config reads are instant with no network call',
      'Push vs pull: polling (every 30s) is simple but slow. Push (server notifies, SDK refreshes immediately) is faster for urgent changes. Hybrid: polling as baseline with push for critical updates',
      'Gradual rollout: enable for 1% of users, monitor, ramp to 10%, 50%, 100%. If something goes wrong, flip to 0% instantly — safer than deploying new code and hoping',
      'In interviews: "config changes audited, reviewed like code, rolled out gradually. Every critical feature has a kill switch. SDKs cache locally so config service downtime doesn\'t affect running services"',
    ],
    mnemonic: 'Config service = remote control knobs',
    interviewQ: 'Config push to 50k servers without storm',
    interviewA: 'Clients pull with jittered intervals; server returns 304 if unchanged. Use CDN-like edge cache for read scaling. Long polling or server-sent events for urgent flags. Namespace flags by service. Protect admin API with MFA. Store versioned history for rollback. Avoid giant payloads — diff patches.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'config', 'reliability'],
  ),
  Concept(
    id: 142,
    category: _cat,
    color: _color,
    icon: '🧱',
    title: 'Design Pastebin',
    tagline: 'Text storage, TTL, abuse',
    diagram: '''
  POST content ──► store blob (S3) + metadata (DB)
       │
  GET /abc ──► CDN cache if public
       │
  Expire job deletes after TTL''',
    bullets: [
      'Users submit text, get a short URL, anyone with the URL can view it. The architecture is similar to a URL shortener but with content storage — main concerns are storage at scale, abuse prevention, and expiration',
      'Content stored in object storage (S3) with metadata (creation time, expiry, visibility) in a database. Short key generation follows URL shortener patterns: base62 encoding or random ID with collision checking',
      'For reading, serve frequently accessed pastes through a CDN. Private pastes require authentication or signed URLs. Syntax highlighting is client-side (highlight.js) — the server just serves raw text',
      'Abuse prevention: rate-limit creation per IP, scan content for malware/secrets/illegal content asynchronously, support legal takedown, and auto-expire old pastes via TTL to prevent unbounded growth',
      'In interviews: "text in S3, metadata in database. Pre-generated base62 keys. Hot pastes in Redis and CDN. Content scanned async for abuse. TTL-based lifecycle policies. The read path is the hot path — optimize for retrieval"',
    ],
    mnemonic: 'Pastebin = S3 + metadata + expiry',
    interviewQ: 'Public pastes viral — cost spike',
    interviewA: 'CDN cache GET aggressively for public; origin only on miss. Object storage cheap; egress expensive — negotiate CDN pricing. Rate limit per IP; CAPTCHA. Separate hot path read from write. DDoS at edge. Optional login for higher limits. Lifecycle policy to Glacier after TTL.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'storage', 'cdn'],
  ),
];
