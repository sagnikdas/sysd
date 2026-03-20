import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Observability';
final _color = AppColors.observability;

final conceptsObservability = <Concept>[
  Concept(
    id: 90,
    category: _cat,
    color: _color,
    icon: '🔺',
    title: 'Three Pillars',
    tagline: 'Metrics, logs, traces',
    diagram: '''
  Metrics: RED/USE, counters, histograms — cheap aggregates
  Logs: discrete events — rich context
  Traces: request path across services — latency breakdown

  Correlate with trace_id in logs''',
    bullets: [
      'Observability rests on three pillars: metrics (numbers tracking trends — "error rate is 2%"), logs (detailed event records — "user 42 hit a null pointer"), and traces (the journey of a request across services — "this request spent 800ms in the database")',
      'Metrics are cheap aggregates that tell you something IS wrong: CPU spiked, error rate jumped. But they don\'t tell you WHY — for that, you need logs and traces',
      'Logs capture detailed context about individual events: which user, which endpoint, what error. Structure them as JSON with consistent fields (trace_id, user_id, service) — not messy printf strings',
      'Traces follow a single request across multiple services, showing exactly where time was spent. When a request takes 3 seconds, a trace reveals: 50ms in gateway, 100ms in auth, 2800ms in the database',
      'In interviews, connect all three: "metrics alert us that p99 latency spiked, traces show which service added latency, logs reveal the specific query. The trace_id links all three together"',
    ],
    mnemonic: 'Metrics = speedometer; logs = black box; traces = flight path',
    interviewQ: 'When logs vs metrics?',
    interviewA: 'Metrics for aggregates and alerts: error rate, latency histograms, saturation. Logs for forensic detail after alert: user id, request id, stack context. Don’t metric per-user IDs — cardinality explosion. Sample debug logs in prod. Use traces to connect user complaint to slow span without grep marathon.',
    difficulty: Difficulty.beginner,
    tags: ['observability', 'monitoring', 'sre'],
  ),
  Concept(
    id: 91,
    category: _cat,
    color: _color,
    icon: '📈',
    title: 'RED Method',
    tagline: 'Rate, Errors, Duration',
    diagram: '''
  Rate: requests/sec
  Errors: failed requests / total
  Duration: latency distribution (p50/p99)

  Per service, per route''',
    bullets: [
      'RED is a simple framework for monitoring request-driven services: Rate (requests per second — how busy?), Errors (failed percentage — how reliable?), and Duration (how long requests take — how fast?)',
      'RED captures user experience: if rate drops, traffic might be failing upstream. If errors spike, something is broken. If duration increases, the service is slow. Dashboard all three per service and endpoint',
      'Google\'s "Four Golden Signals" extend RED with Saturation (how full are resources). RED covers the request perspective, USE (Utilization, Saturation, Errors) covers infrastructure — use both',
      'Slice your RED dashboards by useful dimensions during incidents: by API version (did the new deploy cause this?), by tenant (is one customer causing the spike?), by region (is it only EU?)',
      'In interviews: "every service has a RED dashboard showing request rate, error percentage, and p50/p99 latency. Our SLOs are defined on error rate and p99 duration. During incidents, we slice by version and tenant"',
    ],
    mnemonic: 'RED = heartbeat of a web service',
    interviewQ: 'Define SLIs using RED',
    interviewA: 'Rate: successful+failed RPCs per second. Errors: ratio of 5xx+timeouts to all requests (exclude 4xx if client fault). Duration: p99 latency under 300ms from edge. Alert on burn rate of error budget. Exclude health checks from SLO. Break down by dependency to find culprit during incidents.',
    difficulty: Difficulty.beginner,
    tags: ['observability', 'sre', 'metrics'],
  ),
  Concept(
    id: 92,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Distributed Tracing',
    tagline: 'Follow one request end-to-end',
    diagram: '''
  Trace ID propagated: W3C traceparent
  Span: single operation + timing
  Parent-child spans form tree

  [gateway]──[auth]──[orders]──[db]''',
    bullets: [
      'Distributed tracing follows a single request as it flows through multiple services, showing each step (span) and how long it took — like tracking a package through every warehouse from sender to recipient',
      'Each trace has a unique trace_id and contains spans with parent-child relationships forming a tree: the API gateway span is the parent, auth is a child, and the database query inside auth is a grandchild',
      'OpenTelemetry is the standard for tracing across languages. It automatically generates spans and propagates trace context between services via HTTP headers. Add it once and get visibility across your architecture',
      'Tracing every request is expensive. Head sampling (1% of all traces) is cheap but misses rare issues. Tail sampling (keep traces with errors or high latency) is smarter but requires a collector service',
      'In interviews: "we use OpenTelemetry with tail sampling for slow or failed requests. When a user reports slowness, we look up the trace by request_id and see exactly which service and query caused the delay"',
    ],
    mnemonic: 'Trace = movie of one user’s request',
    interviewQ: 'Traces broken at async boundary',
    interviewA: 'Ensure context is attached to async tasks (OpenTelemetry context API). For message consumers, inject trace context in message headers and continue trace. Avoid losing parent when using thread pools — use explicit scope. Test propagation in CI. Broken traces hide real latency contributors.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'tracing', 'opentelemetry'],
  ),
  Concept(
    id: 93,
    category: _cat,
    color: _color,
    icon: '📝',
    title: 'Structured Logging',
    tagline: 'JSON fields, not grep regex',
    diagram: '''
  {"ts":"...","level":"error","msg":"payment_failed",
   "trace_id":"abc","user_id":"u1","reason":"timeout"}

  → queryable in Loki/ELK/Datadog''',
    bullets: [
      'Structured logging means writing log entries as JSON with consistent field names instead of free-form text — making them searchable and queryable like database rows rather than a messy text file',
      'Example: instead of "Error processing payment for user 42: timeout", log {level: error, msg: payment_failed, user_id: 42, reason: timeout, trace_id: abc, duration_ms: 5023}. Now you can search instantly',
      'Always include correlation identifiers: trace_id (links to traces), request_id (unique per request), and user_id. These let you reconstruct the full story of a failed request across all services in seconds',
      'Be disciplined about log levels: ERROR for immediate attention, WARN sparingly, INFO for important business events (sampled in high-traffic paths). Never log secrets, credit card numbers, or PII — redact automatically',
      'In interviews: "structured JSON logs with trace_id, shipped to a central platform. During incidents, I query by trace_id to see the full request flow and filter by error level to find failures"',
    ],
    mnemonic: 'Structured log = spreadsheet row',
    interviewQ: 'Logs unusable in incident',
    interviewA: 'Move from string concatenation to JSON with trace_id, service, version, tenant. Add duration_ms for operations. Consistent error codes. Sample high-volume info logs but keep errors. Train engineers on query language. Create saved searches/dashboards for common failures. Redact PII automatically.',
    difficulty: Difficulty.beginner,
    tags: ['observability', 'logging', 'devops'],
  ),
  Concept(
    id: 94,
    category: _cat,
    color: _color,
    icon: '🔔',
    title: 'Alerting Best Practices',
    tagline: 'Pages wake humans — use sparingly',
    diagram: '''
  Symptom-based alert: p99 latency SLO burn
  not cause-based: single pod restart

  Runbook link in alert''',
    bullets: [
      'A good alert wakes someone because something needs immediate action. A bad alert wakes someone for something that self-heals or has no clear action — leading to alert fatigue where real problems get ignored',
      'Alert on symptoms (what users experience), not causes. "Error rate exceeds 5% for 5 minutes" is good. "One pod restarted" is usually not — pods restart routinely. Symptom-based alerting has fewer false positives',
      'Every alert must have three things: an owner (who gets paged), a runbook (step-by-step investigation), and a severity level (page immediately vs business-hours ticket). Alerts without runbooks waste time',
      'Use multi-window, multi-burn-rate alerting: page if the error budget burns fast enough to exhaust in hours (fast burn), create a ticket if it burns slowly over days. This reduces noise dramatically',
      'In interviews: "we review alert noise weekly — if an alert fires 10 times with no action, we fix the issue or delete the alert. Every page should be actionable, or it trains us to ignore real problems"',
    ],
    mnemonic: 'If you aren’t sure it’s bad, don’t page',
    interviewQ: 'Too many false positive pages',
    interviewA: 'Tighten thresholds using historical data; use burn rate alerts instead of instant thresholds. Require multiple windows of violation. Remove alerts that don’t drive action. Fix flaky dependencies instead of muting. On-call retro: classify noise vs signal. Shift left — dashboards for investigation, pages for customer impact.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'sre', 'oncall'],
  ),
  Concept(
    id: 95,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'SLO Monitoring in Practice',
    tagline: 'Error budget burn alerts',
    diagram: '''
  99.9% monthly budget ≈ 43m downtime
  Fast burn in 5m → page immediately
  Slow burn over days → ticket''',
    bullets: [
      'SLO monitoring tracks how fast you\'re consuming your error budget. A 99.9% monthly SLO allows ~43 minutes of downtime. If you\'ve used 30 minutes by day 10, you\'re burning too fast',
      'Use burn rate alerts: if current errors would exhaust the monthly budget in 3 hours, page immediately. If it would exhaust in 3 days, create a ticket. Catches both sudden outages and gradual degradation',
      'Pre-compute SLO metrics using recording rules in your monitoring system. Calculating "percentage of successful requests in 30 days" from raw data on every dashboard refresh is too expensive',
      'When the error budget is spent, trigger a release freeze: no new features until stability improves. This creates healthy tension between velocity and reliability',
      'In interviews: "our search SLO is 99.5% at p99 under 500ms. We track burn rate with multi-window alerts. Last quarter we froze features for two sprints after burning 80% of the budget due to an index issue"',
    ],
    mnemonic: 'Burn rate = how fast you spend mistake allowance',
    interviewQ: 'Set alert for 99.95% availability SLO',
    interviewA: 'Use multi-burn-rate approach: e.g. page if 14.4× budget burn in 5m (would exhaust in 3h if continued) and ticket if 6× over 6h. Implement in Prometheus recording rules or vendor equivalent. Validate with historical incident injection. Align on exclusion windows. Document in SLO doc with diagram.',
    difficulty: Difficulty.advanced,
    tags: ['observability', 'slo', 'sre'],
  ),
  Concept(
    id: 96,
    category: _cat,
    color: _color,
    icon: '🧪',
    title: 'Synthetic Monitoring',
    tagline: 'Proactive checks from outside',
    diagram: '''
  Global probes: HTTP canary every 1m
  Login flow script in browser

  Catches DNS, CDN, cert issues users see''',
    bullets: [
      'Synthetic monitoring runs automated checks against your live system from external vantage points — like a mystery shopper who visits every minute to check if the doors are open and checkout works',
      'It catches problems internal monitoring misses: DNS failures, expired TLS certificates, CDN misconfigurations, regional outages. Your servers might be healthy but users can\'t reach them',
      'Test critical user journeys end-to-end: sign up, log in, search, checkout. Run from multiple regions every 1-5 minutes. If any check fails, alert immediately — these are your highest-value probes',
      'Complements Real User Monitoring (RUM): synthetics tell you "is the system working right now?" with consistent tests. RUM tells you "what are actual users experiencing?" with real-world data',
      'In interviews: "synthetic checks for signup, search, and checkout from 10 global regions every minute. This caught a CDN certificate expiry at 3 AM before any user reported it"',
    ],
    mnemonic: 'Synthetic = robot user knocking every minute',
    interviewQ: 'Users see outage we didn’t alert',
    interviewA: 'Internal metrics green but edge broken — add synthetic checks from external vantage matching user regions. Monitor TLS expiry, DNS, CDN. RUM captures client-side failures internal metrics miss. Gap analysis: user journey map vs current probes. Post-incident add probe for the failure mode.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'monitoring', 'reliability'],
  ),
  Concept(
    id: 97,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Cardinality Explosion',
    tagline: 'Too many label combinations',
    diagram: '''
  http_requests{user_id="..."}  ← millions of series
  Prometheus/Grafana melt

  Aggregate: topk, recording rules, separate tracing''',
    bullets: [
      'Cardinality explosion happens when a metric label has too many unique values — adding user_id to a request counter with 1 million users creates 1 million time series, overwhelming your monitoring system',
      'Metrics are designed for low-cardinality aggregates: labels like service, method, status_code (hundreds of combinations) are fine. Labels like user_id, order_id, or full URL path (millions) belong in logs and traces',
      'Rule of thumb: if a label could have more than a few hundred unique values, don\'t put it on a metric. Use exemplars (sample trace_ids on histogram buckets) to link from metric spikes to specific traces',
      'Cardinality is also a cost issue: observability platforms charge by time series. One engineer adding user_id to a popular metric can multiply your bill 1000x overnight',
      'In interviews: "low-cardinality labels on metrics for alerting, linked to high-cardinality traces via exemplars for drill-down. We review new metric labels in code review to prevent cardinality explosions"',
    ],
    mnemonic: 'Cardinality = combinatorial explosion',
    interviewQ: 'Prometheus OOM after new label',
    interviewA: 'Identify label with unbounded values — often user_id or order_id. Remove or replace with low-cardinality bucketing (tenant tier, region). Use recording rules to pre-aggregate. For debugging single user, use traces/logs with exemplars pointing from histograms. Educate teams in code review checklist.',
    difficulty: Difficulty.advanced,
    tags: ['observability', 'prometheus', 'metrics'],
  ),
  Concept(
    id: 98,
    category: _cat,
    color: _color,
    icon: '👤',
    title: 'Real User Monitoring',
    tagline: 'What clients actually experience',
    diagram: '''
  Browser SDK: Web Vitals (LCP, FID, CLS)
  Mobile: cold start, ANR rate

  Correlate with releases and regions''',
    bullets: [
      'Real User Monitoring (RUM) captures performance from actual users\' devices — showing the real experience on a slow 3G phone, not just what your fast lab machine reports',
      'Lab testing measures controlled conditions. RUM measures reality: slow devices, congested networks, browser extensions, diverse screens. The gap between lab and real-world performance is often shocking',
      'Key web metrics: LCP (how fast does main content appear?), FID/INP (how quickly does the page respond to clicks?), CLS (does the layout jump?). For mobile: cold start time, ANR rate, crash rate',
      'Connect frontend and backend: pass trace_id from browser through API requests to backend services. Correlate "user reported slow page" with the exact backend trace showing which query was slow',
      'In interviews: "backend showed p99 of 200ms, but RUM revealed 3 seconds on mobile due to large JS bundles. We split the bundle and reduced mobile load time by 60% — invisible without client-side measurement"',
    ],
    mnemonic: 'RUM = truth from real phones',
    interviewQ: 'Backend fast but users complain slow',
    interviewA: 'Measure Web Vitals and mobile TTID. Large JS bundles, render-blocking assets, or chatty APIs from client composition hurt. CDN cache miss geography. Use RUM percentiles by country and device class. Distributed trace from browser (OpenTelemetry web) through API. Compare p95 mobile vs desktop.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'frontend', 'performance'],
  ),
  Concept(
    id: 99,
    category: _cat,
    color: _color,
    icon: '🗂️',
    title: 'Profiling in Production',
    tagline: 'Find hot code safely',
    diagram: '''
  Continuous profiling (eBPF, pprof)
  Flame graphs: wide bar = CPU time

  Low overhead sampling''',
    bullets: [
      'Production profiling continuously samples where your app spends CPU and memory — like a thermal camera showing which parts of a machine run hot. It answers "WHERE in the code is the bottleneck?"',
      'Flame graphs show time spent in each function: wider bars mean more time. Comparing flame graphs before and after a deploy instantly reveals what changed performance-wise',
      'Always-on, low-rate sampling (1-5% overhead) catches intermittent issues that ad-hoc profiling misses. When a spike happens at 3 AM, you already have the data — no need to reproduce',
      'Modern tools (Parca, Pyroscope) use eBPF for near-zero overhead. They automatically correlate profiles with traces: click a slow span and see which function consumed the time',
      'In interviews: "after a deploy increased p99, we compared CPU flame graphs — a new JSON serialization path was 10x slower due to reflection. Fixed and p99 dropped back in 20 minutes, without guessing"',
    ],
    mnemonic: 'Profile = MRI for CPU',
    interviewQ: 'CPU high after deploy — steps?',
    interviewA: 'Pull continuous profile diff before/after deploy. Check flame graph for new hot functions. Correlate with traffic mix change. If GC heavy — heap profile for allocations. Roll back if customer-impacting while investigating. Add benchmark preventing regression. Document finding in postmortem if severe.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'performance', 'profiling'],
  ),
];
