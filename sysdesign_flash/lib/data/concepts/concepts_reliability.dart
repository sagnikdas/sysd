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
      'SLI should be as close to user experience as possible',
      'SLOs are internal goals; SLAs are external commitments — leave margin',
      'Error budget policy: halt features when budget burns, focus on reliability',
      'Multi-window alerting (5m + 1h) reduces false pages',
      'Not every metric needs an SLO — pick critical user journeys',
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
      'Retry only idempotent operations or with dedup keys',
      'Jitter prevents synchronized retries from many clients',
      'Combine with circuit breaker when failure is persistent',
      'Respect Retry-After header from servers',
      'Hedge requests sparingly — doubles load',
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
      'Stops hammering failing services so they can recover',
      'Tune thresholds to actual SLI — too sensitive causes flapping',
      'Expose state in metrics for debugging',
      'Pair with bulkhead thread pools',
      'Libraries: resilience4j, Polly, Envoy outlier detection',
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
      'Separate thread pools / connection limits per dependency or feature',
      'Prevents one slow client or dependency from exhausting all capacity',
      'Similar idea: cell-based architecture at infra level',
      'Trade-off: unused capacity in one pool while other starves — monitor utilization',
      'Combine with timeouts everywhere',
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
      'Identify non-critical features to drop under stress',
      'Serve stale cache with TTL banner vs hard error',
      'Feature flags to disable expensive paths quickly',
      'User communication: “live scores delayed” beats white screen',
      'Test degradation paths — they rot without drills',
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
      'Without timeouts, threads and connections leak into queues of doom',
      'Shorter timeouts on edge; budget time for each hop',
      'Cancel work when deadline exceeded — don’t ignore cancellation tokens',
      'Log remaining budget on slow traces',
      'Align timeouts with SLO — p99 dependency latency + margin',
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
      'Start small: dev/stage, one failure mode, clear rollback',
      'Blast radius control — one AZ, one service, one tenant canary',
      'Not sabotage — learning tool with observability prerequisites',
      'Fix gaps found before real incidents',
      'Tools: Chaos Monkey, Litmus, Gremlin, cloud fault injection',
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
      'Blameless culture focuses on systems and processes, not individuals',
      'Five whys to dig past proximate cause',
      'Customer impact and detection time matter as much as fix time',
      'Action items should be concrete and tracked like features',
      'Avoid “human error” as final root — ask why safeguards failed',
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
      'Latency wins for global users; complexity explodes in data layer',
      'Conflict resolution: last-write-wins, CRDTs, or single-writer regions',
      'DNS/global load balancer health checks steer traffic',
      'RTO/RPO drive sync vs async replication choices',
      'Test failover regularly — configs drift',
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
      'Automate backups; encrypt and test restore quarterly',
      'Runbooks for region failure — who declares, how to cutover DNS',
      'Immutable backups protect ransomware scenarios',
      'Document dependencies — DR is only as good as weakest link',
      'Game days simulate region loss',
    ],
    mnemonic: 'Untested backup = wishful thinking',
    interviewQ: 'Difference between RPO and RTO?',
    interviewA: 'RPO is how much data you may lose (time between last durable replica and incident). RTO is how long until service is back. Async replication might give 5-minute RPO but 30-minute RTO if failover is manual. Strongly consistent multi-master lowers RPO but costs complexity. Align both with business tolerance and cost.',
    difficulty: Difficulty.intermediate,
    tags: ['reliability', 'operations', 'backup'],
  ),
];
