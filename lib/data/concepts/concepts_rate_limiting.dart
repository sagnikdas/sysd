import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Rate Limiting';
final _color = AppColors.rateLimiting;

final conceptsRateLimiting = <Concept>[
  Concept(
    id: 61,
    category: _cat,
    color: _color,
    icon: '🪣',
    title: 'Token Bucket',
    tagline: 'Smooth bursts with refill rate',
    diagram: '''
  Bucket capacity C tokens
  Refill R tokens/sec

  Request costs 1 token
  If empty → reject or queue

  Allows bursts up to C, average rate R''',
    bullets: [
      'A token bucket is a rate limiting algorithm that allows short bursts while enforcing a long-term average rate — imagine a bucket that holds tokens and refills steadily. Each request costs one token; if empty, the request is rejected',
      'This is the most popular approach for APIs because it\'s flexible: an idle user accumulates tokens and can burst (up to bucket capacity), while a constant stream is throttled to the refill rate',
      'You configure two values: capacity (maximum burst size) and refill rate (sustained requests per second). Capacity=10 and rate=2/sec means a user can burst 10 requests instantly but sustains only 2/sec long-term',
      'In distributed systems, each user has their own bucket stored in Redis. Use an atomic Lua script to check-and-decrement in a single operation — this prevents race conditions where two servers both think tokens remain',
      'In interviews, mention token bucket as your default rate limiting choice. Always return helpful headers: X-RateLimit-Remaining, X-RateLimit-Reset, and Retry-After on 429 responses so clients can pace themselves',
    ],
    mnemonic: 'Bucket refills — burst until empty',
    interviewQ: 'Token bucket vs leaky bucket?',
    interviewA: 'Token bucket allows bursts when tokens accumulate — good for APIs with occasional spikes. Leaky bucket enforces smoother output rate — better when downstream needs strictly constant rate. Token bucket is more common at edge for HTTP. Leaky bucket maps to queue draining at fixed rate.',
    difficulty: Difficulty.intermediate,
    tags: ['rate-limiting', 'algorithms', 'api'],
  ),
  Concept(
    id: 62,
    category: _cat,
    color: _color,
    icon: '🪟',
    title: 'Fixed & Sliding Windows',
    tagline: 'Count requests per time slice',
    diagram: '''
  Fixed window (per minute):
  | 00:00-00:59 | 01:00-01:59 |
  Spike at boundary → 2× traffic

  Sliding window log:
  drop events older than T from deque
  count remaining vs limit''',
    bullets: [
      'Fixed window rate limiting counts requests in discrete time buckets (e.g., per minute): at 2:00:00 the counter resets. Simple but flawed — a user can send 100 requests at 2:00:59 and 100 more at 2:01:00, getting 200 in 2 seconds',
      'This "boundary burst" happens because the window resets at exact intervals. A user who times requests at the boundary gets twice the allowed rate. For many apps this is acceptable, but it can be exploited',
      'Sliding window fixes this by looking at a rolling time range: "how many requests in the last 60 seconds?" instead of "how many this calendar minute?" More accurate but requires tracking individual request timestamps',
      'A practical middle ground: the sliding window counter. Approximate by weighting current and previous windows. If 30 seconds into the current minute, previous had 60 requests and current has 20, estimate: 60×0.5 + 20 = 50',
      'In interviews, know the trade-off: fixed window is simplest (Redis INCR + TTL), sliding window log is most accurate (sorted set of timestamps), and sliding counter is the best compromise for most systems',
    ],
    mnemonic: 'Fixed window = cheap but seamy',
    interviewQ: 'Users game our per-minute limit',
    interviewA: 'Boundary spike: switch to sliding window or combine small sub-windows (e.g. 12×5s). Add jitter to window start per key. For distributed POPs, centralize counts in Redis/Redis Cluster or allow small overshoot with sync. Consider leaky bucket behind gateway for smoothing.',
    difficulty: Difficulty.intermediate,
    tags: ['rate-limiting', 'distributed', 'api'],
  ),
  Concept(
    id: 63,
    category: _cat,
    color: _color,
    icon: '👤',
    title: 'User vs IP Throttling',
    tagline: 'Fairness and abuse',
    diagram: '''
  Corporate NAT: many users → one IP
  → per-IP limits punish innocents

  Prefer: API key / user id + softer IP cap''',
    bullets: [
      'Rate limiting by IP is unreliable because many users share one IP — a corporate office with 1,000 employees behind a NAT looks like a single user, and throttling that IP punishes everyone for one person\'s behavior',
      'The better approach is layered limiting: per-user (authenticated requests), per-API-key (machine clients), and per-IP (fallback for unauthenticated requests). Each layer catches different abuse patterns',
      'For anonymous endpoints (login, signup, public search), IP-based limits are your primary defense. Add CAPTCHA or proof-of-work when abuse is detected rather than hard-blocking legitimate users',
      'Rate limit tiers should align with your business: free users get 100 requests/minute, premium gets 1,000. This protects infrastructure while creating a natural upgrade path — rate limits become a product feature',
      'In interviews, describe multi-layer strategy: "global limits protect capacity, per-tenant ensures fair sharing, per-user prevents individual abuse, and per-IP catches unauthenticated attacks. Each has different thresholds"',
    ],
    mnemonic: 'IP is a hint, identity is truth',
    interviewQ: 'Rate limit public search without accounts',
    interviewA: 'Use composite key: fingerprint + IP + optional session cookie. Progressive penalties: soft limit with CAPTCHA, hard block on abuse patterns. CDN/WAF bot scores. Per-ASN tuning if one carrier spikes. Cache expensive search results to reduce origin hits. Offer API keys for higher limits with accountability.',
    difficulty: Difficulty.advanced,
    tags: ['rate-limiting', 'security', 'api'],
  ),
  Concept(
    id: 64,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'Admission Control',
    tagline: 'Reject work before overload',
    diagram: '''
  Load > threshold → shed low-priority traffic
  Keep checkout alive, drop recommendations

  Queue depth limits at load balancer''',
    bullets: [
      'Admission control rejects incoming requests before they overload your system — like a nightclub with maximum capacity: it\'s better to turn people away at the door than pack them in until the building is unsafe',
      'When overwhelmed, blindly accepting every request makes everything slow for everyone. By rejecting excess with a fast 503, the requests you DO accept get processed at full speed',
      'Not all requests are equal: assign priority classes so critical traffic survives overload. Paid users over free, checkout over browsing, control plane over analytics. Shed the least important traffic first',
      'Admission control works alongside auto-scaling, not instead of it. Auto-scaling adds capacity over minutes; admission control protects during the seconds before new capacity arrives',
      'In interviews: "during Black Friday, I\'d protect the purchase path with admission control — shed recommendation and review traffic before touching checkout. Return 503 with Retry-After"',
    ],
    mnemonic: 'Bouncer stops the club from catching fire',
    interviewQ: 'Black Friday — protect core purchase path',
    interviewA: 'Disable or heavily throttle non-critical features via feature flags. Admission control on checkout service with small queue + reject. Pre-scale based on forecast; cache catalog aggressively. CDN static assets. Rate limit bots. Separate bulkheads for payment vs inventory reads. Practice load tests with 3× expected peak.',
    difficulty: Difficulty.advanced,
    tags: ['rate-limiting', 'reliability', 'scaling'],
  ),
  Concept(
    id: 65,
    category: _cat,
    color: _color,
    icon: '⚖️',
    title: 'Fair Queuing (WRR)',
    tagline: 'Noisy neighbor isolation',
    diagram: '''
  Tenants A,B,C share workers
  Weighted round-robin:
  A:A:A:B:C → A gets 3 shares, B 1, C 1''',
    bullets: [
      'Fair queuing ensures that in a shared system, one heavy user can\'t consume all resources and starve everyone else — like a roundabout where every car gets a turn, even if one lane has much more traffic',
      'The "noisy neighbor" problem: one enterprise customer sends 100x more requests, monopolizing workers, and all other customers slow down even though they\'re within their limits',
      'Weighted Round-Robin gives each tenant a proportional share. If Tenant A has premium (weight 3) and B has basic (weight 1), the worker processes 3 of A\'s jobs for every 1 of B\'s — fair but not equal',
      'Implementation: per-tenant queues with weighted scheduling and a concurrency cap per tenant. Monitor per-tenant latency separately to detect unfairness before customers complain',
      'In interviews, mention fair queuing for multi-tenant systems: "each tenant gets a separate queue with weighted scheduling and a concurrency cap — preventing one large customer from degrading service for everyone"',
    ],
    mnemonic: 'Fair queue = everyone gets a turn',
    interviewQ: 'One enterprise customer floods our async workers',
    interviewA: 'Per-tenant queues with WRR scheduling across tenants. Cap max concurrent jobs per tenant. Dynamic weight reduction when tenant exceeds SLO repeatedly. Dedicated worker pool for largest customers (noisy neighbor isolation). Alert sales when customer needs dedicated capacity tier.',
    difficulty: Difficulty.advanced,
    tags: ['rate-limiting', 'multi-tenant', 'architecture'],
  ),
  Concept(
    id: 66,
    category: _cat,
    color: _color,
    icon: '🧮',
    title: 'Distributed Rate Limiting',
    tagline: 'Consistent limits at scale',
    diagram: '''
  Edge POPs ──► Central Redis cluster
         or
  Gossip approx counters (less accurate)

  Trade-off: latency vs precision''',
    bullets: [
      'When your API runs across multiple servers, each needs access to the same rate limit counters — otherwise a user can hit 10 different servers and effectively get 10x the allowed rate',
      'The most common solution: centralize counters in Redis with atomic Lua scripts. This gives accurate global counts but adds a network round-trip to Redis for every request',
      'For soft limits where minor over-allowing is acceptable, use local counters on each server and sync periodically. Each server gets a quota slice and reconciles with a central store',
      'Redis replication lag can cause brief over-allow: two servers read from different replicas, both see capacity, both allow. For strict limits read from the primary. For approximate limits this is usually fine',
      'In interviews: "centralized Redis for strict per-user limits with one extra hop. For edge rate limiting across 20 global PoPs, per-PoP counters with periodic reconciliation — accepting small over-allow to avoid cross-region latency"',
    ],
    mnemonic: 'Many doors, one tally (usually Redis)',
    interviewQ: 'Rate limit across 20 edge nodes',
    interviewA: 'Centralize counters in Redis near core or regional Redis per geography. Alternative: allocate per-POP quota slices with periodic rebalance — allows some inaccuracy. For strict global limits, synchronous Redis round-trip per request adds latency — optimize with pipelining or local token bucket with periodic central reconciliation.',
    difficulty: Difficulty.advanced,
    tags: ['rate-limiting', 'redis', 'distributed'],
  ),
  Concept(
    id: 67,
    category: _cat,
    color: _color,
    icon: '📉',
    title: 'Client-Side Throttling',
    tagline: 'Backoff when server says slow down',
    diagram: '''
  429 + Retry-After: 30
  Client sleeps 30s before retry

  Exponential backoff on 503 storms''',
    bullets: [
      'Client-side throttling means the client respects the server\'s signals to slow down — when the server returns 429 with Retry-After, a well-behaved client waits instead of immediately hammering the server again',
      'Without client-side throttling, a recovering server faces a thundering herd: thousands of clients blocked during an outage instantly retry at the same moment. Adding jitter to retries spreads the load',
      'For mobile apps, queue failed actions locally with user feedback ("Your changes will sync when connection is restored") instead of showing error dialogs. Process the queue with exponential backoff',
      'Tight retry loops kill two things: the server (flood of requests) and the user\'s battery (constant network activity). A well-built SDK defaults to exponential backoff, respects Retry-After, and caps retries',
      'In interviews: "the server returns 429 with Retry-After, our SDK respects it with jittered backoff, and we show the user a countdown instead of a raw error"',
    ],
    mnemonic: 'Listen to 429 — it’s advice',
    interviewQ: 'Mobile app hammers API after reconnect',
    interviewA: 'Implement queued sync with max concurrency and exponential backoff per endpoint class. Persist failed operations with idempotency keys. Respect Retry-After. Use connectivity listeners to batch uploads. Add client-side token bucket so one bug doesn’t DDOS yourself. Monitor client SDK versions for bad loops.',
    difficulty: Difficulty.beginner,
    tags: ['rate-limiting', 'mobile', 'api'],
  ),
  Concept(
    id: 68,
    category: _cat,
    color: _color,
    icon: '🛡️',
    title: 'DDoS vs Rate Limiting',
    tagline: 'Edge absorption before app logic',
    diagram: '''
  Attack volume
       │
       ▼
  CDN / WAF / scrubbing center
       │
       ▼
  API gateway rate limits
       │
       ▼
  App (should rarely see raw flood)''',
    bullets: [
      'Application rate limiting (429 per user) and DDoS protection operate at completely different layers — like a door lock (rate limit) versus flood barriers (DDoS mitigation). A rate limiter can\'t stop a traffic tsunami',
      'DDoS attacks overwhelm infrastructure with raw traffic volume. They\'re stopped at the network level: CDN/WAF services absorb attack traffic at edge locations before it reaches your servers',
      'Application rate limits protect against abuse by legitimate users: scrapers, bots, buggy clients. These come from real IPs with valid-looking traffic — they pass network-layer DDoS filters',
      'Layer your defenses: network scrubbing absorbs volume, WAF rules block known patterns, geo-blocking restricts non-user regions, and CAPTCHA challenges filter bots from humans at the application layer',
      'In interviews, distinguish clearly: "rate limiting is for fair usage (per-user quotas). DDoS mitigation is infrastructure-level (CDN, WAF, anycast) — our app never sees DDoS traffic because it\'s filtered upstream"',
    ],
    mnemonic: 'Stop the tsunami at the beach, not the kitchen',
    interviewQ: 'Difference between abuse protection and product quotas',
    interviewA: 'DDoS/abuse is adversarial volumetric or credential stuffing — mitigate at edge with WAF, bot scores, IP reputation, and provider scrubbing. Product quotas are fair allocation of capacity to customers — enforced close to business logic with authenticated identity. Different keys, alerts, and responses (block vs 429 with upgrade path).',
    difficulty: Difficulty.intermediate,
    tags: ['rate-limiting', 'security', 'networking'],
  ),
  Concept(
    id: 69,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Quota & Billing Meters',
    tagline: 'Limits tied to money',
    diagram: '''
  Plan: 10k API calls / month
  Counter in billing system + hard stop at limit
  Overage alerts before invoice shock''',
    bullets: [
      'Quotas are rate limits tied to billing: "your plan includes 10,000 API calls per month." Unlike rate limits that protect servers, quotas define what customers paid for — a product feature that affects revenue',
      'Send progressive warnings: "you\'ve used 80% of your quota" at 80%, a notification at 100%, and hard enforcement at the limit. Grace periods for first-time overages reduce support tickets',
      'Usage metering must be accurate because it drives billing. Stream API call events to a durable log (Kafka), aggregate per customer per billing period, and reconcile periodically to catch drift',
      'Make each usage event idempotent with a unique key so retries don\'t inflate counts. A double-counted API call that triggers overage charges is a billing nightmare',
      'In interviews, separate enforcement from metering: "real-time Redis counters for enforcement (allowing small inaccuracy), durable event log reconciled nightly for accurate invoicing. Customers see usage on a live dashboard"',
    ],
    mnemonic: 'Meter what you monetize',
    interviewQ: 'Enforce monthly API quotas accurately',
    interviewA: 'Stream API calls to durable log (Kafka) → aggregate to usage table per key per billing period. Idempotent event ingestion. Near-real-time counters in Redis for enforcement with periodic reconciliation to warehouse. At period rollover, atomic reset. Handle timezone boundaries clearly. Hard block returns 402/403 with upgrade CTA.',
    difficulty: Difficulty.intermediate,
    tags: ['rate-limiting', 'billing', 'saas'],
  ),
];
