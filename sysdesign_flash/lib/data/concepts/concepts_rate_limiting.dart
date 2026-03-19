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
      'Popular in APIs — tolerates legitimate spikes better than fixed window',
      'Implement with Redis atomic Lua or leaky abstraction libraries',
      'Tune C for burst UX, R for sustainable load on origin',
      'Distributed: one bucket per key (user_id, IP, API key)',
      'Return headers: X-RateLimit-Remaining, Retry-After',
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
      'Fixed window simple but has edge doubling problem at boundaries',
      'Sliding window log accurate but memory heavy per key',
      'Sliding counter approximates with Redis INCR + TTL',
      'Align window to business fairness (per user vs per IP)',
      'Global vs local counters in distributed edge POPs — sync challenges',
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
      'NAT and mobile carriers collapse many users behind one IP',
      'Layered limits: global, per tenant, per user, per IP',
      'Anonymous endpoints need CAPTCHA or proof-of-work at abuse levels',
      'Premium tiers get higher quotas — product + infra alignment',
      'Log exceeded limits for security signals',
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
      'Better to fail fast with 503 than queue unbounded and melt down',
      'Priority classes: paid > free, control plane > analytics',
      'Concurrency limits per dependency inside service',
      'Coordinated with autoscaling — not a substitute for capacity',
      'Communicate Retry-After honestly',
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
      'Prevents one tenant from starving others in shared worker pools',
      'Weighted fair queuing extends to unequal SLAs',
      'Applies to thread pools, Kafka consumer per-tenant topics, batch jobs',
      'Measure per-tenant latency separately to detect unfairness',
      'Combine with per-tenant concurrency caps',
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
      'Redis INCR + TTL is common; use Lua for atomic token bucket',
      'Redis Cluster: watch cross-slot hot keys — hash tags or local overshoot',
      'Eventually consistent local counters OK for soft limits',
      'Stale reads in replication cause brief over-allow — acceptable sometimes',
      'Consider dedicated rate-limit service with local cache + async sync',
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
      'SDKs should default sane retry policies respecting Retry-After',
      'Jitter prevents thundering herd after incident recovery',
      'Mobile apps: queue actions offline with user feedback',
      'Don’t spin tight loops on errors — battery and server harm',
      'Surface rate limit state in UI (“try again in 12s”)',
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
      'Application rate limits don’t stop volumetric L3/L4 floods — need network layer',
      'WAF rules, bot management, geo blocking during attack',
      'Anycast and CDN absorb many HTTP attacks',
      'Challenge suspicious ASNs with JS/CAPTCHA',
      'Runbooks with provider support contacts',
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
      'Separate soft warnings (80%, 100%) from hard enforcement',
      'Eventually consistent usage aggregation — reconcile with source logs',
      'Idempotent usage events with unique keys',
      'Expose usage dashboards to customers',
      'Grace periods for first overage to reduce support tickets',
    ],
    mnemonic: 'Meter what you monetize',
    interviewQ: 'Enforce monthly API quotas accurately',
    interviewA: 'Stream API calls to durable log (Kafka) → aggregate to usage table per key per billing period. Idempotent event ingestion. Near-real-time counters in Redis for enforcement with periodic reconciliation to warehouse. At period rollover, atomic reset. Handle timezone boundaries clearly. Hard block returns 402/403 with upgrade CTA.',
    difficulty: Difficulty.intermediate,
    tags: ['rate-limiting', 'billing', 'saas'],
  ),
];
