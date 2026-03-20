import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Reliability';
final _color = AppColors.reliability;

final conceptsReliability = <Concept>[
  Concept(
    id: 51,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'SLI, SLO, SLA',
    tagline: 'Measure what users feel',
    diagram: '''
  SLI: metric (availability, latency p99)
       │
       ▼
  SLO: target (99.9% monthly availability)
       │
       ▼
  SLA: contract with customer — credits if breached

  Error budget = 1 - SLO → pace of risky deploys''',
    bullets: [
      'SLIs, SLOs, and SLAs form a reliability hierarchy: an SLI is what you measure (e.g., "99.2% of requests succeed under 500ms"), an SLO is your target ("we aim for 99.9%"), and an SLA is the contractual promise to customers ("below 99.5%, you get credits")',
      'Measure SLIs as close to the user experience as possible — latency from the client is more meaningful than latency inside the server. Users don\'t care that your server was fast if the load balancer added 2 seconds',
      'The error budget (1 minus SLO) is how much failure you can "afford." A 99.9% monthly SLO allows ~43 minutes of downtime. When the budget is spent, freeze risky deployments and focus on stability',
      'Set SLOs only for critical user journeys (checkout, login, search), not every endpoint. Over-measuring creates alert fatigue. Leave margin between your SLO and SLA — aim for 99.9% internally while promising 99.5% externally',
      'In interviews, define SLOs upfront: "our search API SLO is 99.5% of requests returning 200 with p99 under 500ms. If the error budget burns fast, we freeze feature launches"',
    ],
    mnemonic: 'SLI = speedometer; SLO = speed limit',
    interviewQ: 'Define SLO for a search API',
    interviewA: 'SLI: successful queries (2xx) under 500ms at p99 from edge, excluding client errors. SLO: 99.5% of minutes meet that SLI. Measure via distributed tracing + metrics. Track burn rate. If dependency (index service) degrades, error budget drains — freeze launches. Document exclusions (maintenance windows) in SLA.',
    difficulty: Difficulty.beginner,
    tags: ['reliability', 'sre', 'monitoring'],
  ),
  Concept(
    id: 52,
    category: _cat,
    color: _color,
    icon: '🔁',
    title: 'Retries & Exponential Backoff',
    tagline: 'Recover without amplifying outages',
    diagram: '''
  fail → wait 1s → fail → wait 2s → fail → wait 4s
  + jitter (random spread) to avoid thundering herd

  Cap max delay; limit max attempts''',
    bullets: [
      'When a request fails, retrying often succeeds because the failure was transient (network blip, momentary overload). Exponential backoff means waiting longer between each retry (1s → 2s → 4s) to give the failing service time to recover',
      'Always add jitter (random variation) to retry delays. Without it, thousands of clients that failed at the same moment all retry simultaneously — creating a "thundering herd" that overwhelms the already-struggling service',
      'Only retry operations that are safe to repeat (idempotent). Retrying a GET is always safe. Retrying a payment POST without an idempotency key could charge the user twice',
      'Cap your retry attempts (e.g., 3-5 retries). If the failure persists, stop retrying and use a circuit breaker to fail fast — continuing to hammer a down service only makes the outage worse',
      'In interviews, the full recipe is: "exponential backoff with full jitter, capped at 3 retries, only for idempotent operations. If the circuit breaker trips, fail fast with a fallback response"',
    ],
    mnemonic: 'Backoff + jitter = polite retries',
    interviewQ: 'Retries caused a retry storm — what happened?',
    interviewA: 'Likely synchronized clients retrying same interval into an already overloaded dependency. Add full jitter, reduce concurrency, and circuit break on high error rates. Fix root capacity. For non-idempotent paths, disable blind retries. Use bulkheads so one tenant’s retries don’t starve others.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'http', 'distributed'],
  ),
  Concept(
    id: 53,
    category: _cat,
    color: _color,
    icon: '🔌',
    title: 'Circuit Breaker',
    tagline: 'Fail fast when dependency is sick',
    diagram: '''
  CLOSED: calls pass
     │ many failures
     ▼
  OPEN: fail immediately (fallback?)
     │ after timeout
     ▼
  HALF-OPEN: trial call
     success → CLOSED
     fail → OPEN''',
    bullets: [
      'A circuit breaker works like the electrical breaker in your home: when too many failures happen, it "trips open" and stops sending requests to the failing service — protecting both your system and the struggling dependency',
      'Three states: CLOSED (normal, requests flow through), OPEN (service is down, fail immediately without calling it), and HALF-OPEN (after a timeout, let one trial request through — if it succeeds, close the breaker; if it fails, stay open)',
      'Without a circuit breaker, your service keeps calling a dead dependency, requests pile up waiting for timeouts, threads are exhausted, and your service crashes too — a cascade failure',
      'When the circuit is open, serve a fallback: cached data, default values, or a graceful error message. This keeps your application working even when one piece is broken',
      'In interviews, pair circuit breakers with retries: "retry transient failures 2-3 times, but if the failure rate exceeds 50% in 30 seconds, trip the breaker and fail fast with a fallback for 60 seconds"',
    ],
    mnemonic: 'Breaker trips before the house burns',
    interviewQ: 'Circuit breaker vs retry?',
    interviewA: 'Retries help transient faults. Breaker helps sustained outages by skipping calls after error threshold, giving quick failures to callers and reducing load on dependency. Use together: retry a few times, then if cluster-wide failure, open breaker. Fallbacks return degraded responses when open.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'patterns', 'microservices'],
  ),
  Concept(
    id: 54,
    category: _cat,
    color: _color,
    icon: '🛡️',
    title: 'Bulkhead Pattern',
    tagline: 'Isolate resource pools',
    diagram: '''
  Without bulkhead:
  All threads stuck waiting on slow payment API

  With bulkhead:
  Pool A: checkout (10 threads)
  Pool B: catalog  (50 threads)
  slowdown in A doesn’t drain B''',
    bullets: [
      'The Bulkhead pattern isolates different parts of your system into separate resource pools — named after watertight compartments in a ship that prevent a leak in one section from sinking the entire vessel',
      'Without bulkheads, one slow dependency can drain all resources: if the payment API hangs, all threads wait on payment, and suddenly catalog pages can\'t load either — everything is stuck',
      'With bulkheads, you allocate separate thread pools per dependency: 10 threads for payments, 50 for catalog. If payments hang and exhaust their 10 threads, catalog\'s 50 threads are unaffected',
      'The trade-off: reserved capacity might sit idle. If payments are healthy but catalog is overloaded, those 10 payment threads can\'t help. Monitor utilization and adjust limits based on real traffic',
      'In interviews, mention bulkheads for failure isolation: "separate connection pools per downstream service with timeouts, so a slow recommendation service can\'t starve the checkout path"',
    ],
    mnemonic: 'Bulkhead = watertight compartments',
    interviewQ: 'One downstream hung and froze the whole service',
    interviewA: 'Unbounded waits consumed all worker threads — catastrophic blocking. Add timeouts, dedicated client pool with limit for that dependency, and async processing. Bulkhead thread pools per domain. Circuit breaker on that client. Consider non-blocking IO. Load test with slow dependency simulation.',
    difficulty: Difficulty.advanced,
    tags: ['reliability', 'architecture', 'performance'],
  ),
  Concept(
    id: 55,
    category: _cat,
    color: _color,
    icon: '🎭',
    title: 'Graceful Degradation',
    tagline: 'Partial failure still ships value',
    diagram: '''
  Homepage: recommendations API down
  → show cached defaults or popular items
  → hide widget instead of 500 page''',
    bullets: [
      'Graceful degradation means keeping core features running even when some components fail — like a car that turns off the AC when the engine overheats, instead of shutting down completely',
      'Not all features are equally important. Classify yours: checkout and login are critical (never drop), recommendations are nice-to-have (show defaults when down), analytics tracking is invisible (fail silently)',
      'When a non-critical service fails, serve a fallback: cached recommendations from an hour ago, a generic "popular items" list, or simply hide the broken section rather than showing a 500 error page',
      'Use feature flags to disable expensive features instantly during an outage without redeploying. A one-click kill switch for the recommendation widget can keep your site alive during a traffic surge',
      'In interviews, show mature thinking: "not every component needs the same availability. I\'d design checkout with no single points of failure, and wrap non-critical features in circuit breakers with cached fallbacks"',
    ],
    mnemonic: 'Limp mode beats a crash',
    interviewQ: 'Payment works but recommendations failing at checkout',
    interviewA: 'Checkout path should not hard-depend on recs. Load recommendations async; if timeout, skip upsell section. Use circuit breaker around rec service. Precompute generic “customers also bought” cache. Monitor checkout conversion without rec block — if identical, recs are truly optional.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'ux', 'architecture'],
  ),
  Concept(
    id: 56,
    category: _cat,
    color: _color,
    icon: '⏱️',
    title: 'Timeouts & Deadlines',
    tagline: 'Bound waiting everywhere',
    diagram: '''
  Client timeout: 2s
    Service A calls B with deadline 1.5s
      B calls C with 1s

  Propagate deadline context (gRPC, OpenTelemetry)''',
    bullets: [
      'Every network call needs a timeout — a maximum wait time before giving up. Without timeouts, a stalled dependency causes threads to wait forever, exhausting all resources and bringing your entire service down',
      'Set timeouts from the outside in: if the user-facing request has a 2-second timeout, the API gets ~1.5s, and each downstream call gets ~500ms. This "deadline budget" ensures no inner call exceeds the total allowed time',
      'When a timeout fires, cancel the work — don\'t let it continue in the background consuming resources. Pass cancellation tokens so downstream operations stop immediately when the deadline expires',
      'Align timeouts with your SLOs: if your p99 latency target is 500ms, set your timeout slightly above that. A 30-second timeout when your SLO is 500ms means users wait forever before seeing an error',
      'In interviews, mention timeouts as your first defense against cascading failures: "every RPC has a timeout based on target p99 latency plus margin. I propagate a deadline context so downstream services know how much budget remains"',
    ],
    mnemonic: 'Every call needs a stopwatch',
    interviewQ: 'Cascading latency across microservices',
    interviewA: 'Each hop adds variance; without end-to-end deadline, tail latency explodes. Pass deadline or timeout budget in context. Use client-side timeouts per RPC. Shed load when budget exhausted. Prefer parallel fan-out where possible. Cache and async precompute for slow paths. Profile which service eats the budget.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'microservices', 'latency'],
  ),
  Concept(
    id: 57,
    category: _cat,
    color: _color,
    icon: '🧪',
    title: 'Chaos Engineering',
    tagline: 'Prove resilience before production does',
    diagram: '''
  Steady state hypothesis: p99 < 200ms
  Inject: kill random pod / latency on DB
  Observe: metrics, alerts, user impact
  Automate game days → continuous chaos''',
    bullets: [
      'Chaos engineering intentionally injects failures (killing servers, adding latency) in a controlled way to discover weaknesses before a real outage does — like a fire drill that tests if your sprinklers actually work',
      'It\'s NOT about randomly breaking things. You form a hypothesis ("if one replica fails, failover should happen in 5 seconds"), inject the failure, and measure whether the system behaved as expected',
      'Start small and safe: one service in staging with a clear rollback plan. Once confident, move to production with blast radius controls — e.g., only affect 1% of traffic in one availability zone',
      'Prerequisites: solid observability (dashboards and alerts), runbooks for common failures, and a team ready to respond. Chaos without monitoring is just sabotage — you need to see what happens to learn from it',
      'In interviews, chaos engineering shows operational maturity: "we run monthly game days simulating failures — killing a cache node, adding latency to the payment API — and measure whether our circuit breakers and fallbacks work"',
    ],
    mnemonic: 'Chaos = vaccine for outages',
    interviewQ: 'How would you start chaos in production?',
    interviewA: 'Prereq: dashboards, alerting, on-call runbooks. Begin with non-customer-facing namespace or single canary cell. Inject controlled pod kills during business hours with team ready. Measure recovery time and error budget impact. Expand only after fixes. Never chaos without ability to abort and communicate.',
    difficulty: Difficulty.advanced,
    tags: ['reliability', 'testing', 'sre'],
  ),
  Concept(
    id: 58,
    category: _cat,
    color: _color,
    icon: '📝',
    title: 'Postmortems',
    tagline: 'Blameless learning from incidents',
    diagram: '''
  Timeline → root causes (often multiple)
          → what went well
          → what went wrong
          → action items (owner, date)
  Share widely; track completion''',
    bullets: [
      'A postmortem is a structured review after an incident: "what happened, why, and how do we prevent it?" The most important rule: blameless — focus on system and process gaps, not who pressed the wrong button',
      'Structure: timeline of events (with timestamps), what went well, what went wrong, root causes (usually multiple), and concrete action items with owners and deadlines',
      'Never stop at "human error" as the root cause. Ask "why was it possible for one person to bring down production?" Missing safeguards — no code review, no canary deploy, no automated rollback — are the real fixes',
      'Action items must be tracked like product features with owners and deadlines — not just "we should add monitoring" but "Alice adds latency alert to payment service by March 15"',
      'In interviews, mention postmortems as part of reliability culture: "after every incident, we write a blameless postmortem, share it with the org, and track action items in our sprint backlog"',
    ],
    mnemonic: 'Postmortem = flight recorder review',
    interviewQ: 'What makes a good postmortem?',
    interviewA: 'Clear timeline with logs and metrics, honest assessment of detection and mitigation gaps, contributing factors (not single root), prioritized remediations with owners, and follow-up verification. Distribute to org for pattern matching. No blame language. Link to tickets. Optional: publish summary externally for severe outages.',
    difficulty: Difficulty.beginner,
    tags: ['reliability', 'culture', 'operations'],
  ),
  Concept(
    id: 59,
    category: _cat,
    color: _color,
    icon: '🌍',
    title: 'Multi-Region Active-Active',
    tagline: 'Availability across geography',
    diagram: '''
  Region A ◄────────► Region B
     │                    │
  Users routed nearest
  Data: CRDT / async repl / Spanner''',
    bullets: [
      'Multi-region active-active means running your service in multiple geographic regions simultaneously, each handling real traffic — like a restaurant chain where every location serves customers, not just one main location with backups',
      'The main benefit is latency: users connect to the nearest region. A secondary benefit is resilience: if one region goes down, traffic shifts to others via DNS or global load balancing',
      'The main challenge is data consistency: if a user updates their profile in the US region, how quickly does London see it? You must choose a conflict resolution strategy — last-writer-wins (simple, may lose data) or CRDTs (complex, preserves everything)',
      'Active-active is much harder than active-passive (one live region, one standby). Every write must either replicate synchronously (strong consistency, higher latency) or asynchronously (eventual consistency, potential conflicts)',
      'In interviews, only propose active-active for truly global systems. For most applications, active-passive with automated failover is sufficient and dramatically simpler. Always mention testing failover regularly',
    ],
    mnemonic: 'Active-active = two hearts, one tricky brain',
    interviewQ: 'Design multi-region for a shopping cart',
    interviewA: 'Cart is session-like — prefer sticky region or route user consistently. Replicate cart events async with vector clocks or merge by item line. Inventory checkout needs strong consistency — single authoritative shard per SKU or reservation token valid in one region. Use global load balancing with health checks. Measure cross-region replication lag for UX messaging.',
    difficulty: Difficulty.advanced,
    tags: ['reliability', 'scaling', 'distributed'],
  ),
  Concept(
    id: 60,
    category: _cat,
    color: _color,
    icon: '🔧',
    title: 'Disaster Recovery',
    tagline: 'Backups mean nothing without restores',
    diagram: '''
  RPO: max acceptable data loss (e.g. 5 min)
  RTO: max acceptable downtime (e.g. 1 h)

  Cold/warm/hot standby
  Regular restore drills''',
    bullets: [
      'Disaster recovery (DR) is your plan for catastrophic failure — a region goes down, data gets corrupted, or ransomware encrypts your database. Two key metrics: RPO (how much data can you lose) and RTO (how long can you be down)',
      'RPO (Recovery Point Objective): if your last backup was 1 hour ago, you could lose up to 1 hour of data. RTO (Recovery Time Objective): if failover takes 30 minutes, that\'s your downtime. Tighter targets cost more',
      'Backups are worthless if you\'ve never tested restoring. Schedule quarterly restore drills. Many teams learned the hard way that their "daily backups" were corrupted or took 8 hours to restore',
      'Store backups as immutable (cannot be modified or deleted) to protect against ransomware. Keep copies in a different region and account. Encrypt at rest with separately managed keys',
      'In interviews, ask about acceptable RPO/RTO before proposing a strategy: "I\'d document a runbook covering who declares a disaster, how DNS cuts over, how data is verified, and we\'d run a full DR drill quarterly"',
    ],
    mnemonic: 'Untested backup = wishful thinking',
    interviewQ: 'Difference between RPO and RTO?',
    interviewA: 'RPO is how much data you may lose (time between last durable replica and incident). RTO is how long until service is back. Async replication might give 5-minute RPO but 30-minute RTO if failover is manual. Strongly consistent multi-master lowers RPO but costs complexity. Align both with business tolerance and cost.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'operations', 'backup'],
  ),
];
