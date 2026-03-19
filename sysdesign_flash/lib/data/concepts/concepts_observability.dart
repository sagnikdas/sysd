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
      'Metrics for alerting and SLOs — cardinality discipline',
      'Logs for debugging — structured JSON not printf soup',
      'Traces find which hop added latency in microservices',
      'High-cardinality fields belong in traces/logs, not metric labels',
      'Unified query across pillars in modern platforms',
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
      'Simple checklist for request-driven services',
      'Pair with saturation (USE) for resources',
      'Dashboards slice by tenant/version during incidents',
      'SLOs often defined on error rate and latency tail',
      'Golden signals: latency, traffic, errors, saturation (Google)',
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
      'OpenTelemetry standardizes instrumentation across languages',
      'Sampling reduces cost — tail sampling keeps interesting traces',
      'Context propagation through async boundaries (tasks, queues)',
      'Baggage for small cross-cutting hints — don’t abuse size',
      'Service maps derived from trace graphs',
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
      'Stable field names — schema evolution discipline',
      'Include correlation ids from ingress',
      'Log levels: error for actionable, warn sparingly, info sampled',
      'Never log secrets or full PAN/PII — tokenize',
      'Centralize with agent sidecar or stdout collection',
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
      'Alert on user-visible symptoms and SLO budget consumption',
      'Multi-window, multi-burn-rate reduces noise (Google SRE workbook)',
      'Every alert needs owner, runbook, and severity',
      'Aggregation delays vs immediate paging trade-offs',
      'Weekly review of noisy alerts — delete or fix',
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
      'Multi-window detectors catch both sudden and gradual slips',
      'Recording rules pre-aggregate expensive queries',
      'Exclude planned maintenance from SLO if policy allows',
      'Error budget policy ties to release freezes',
      'Customer-facing SLO may differ from internal metric',
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
      'Complements real user monitoring (RUM)',
      'Test critical journeys: signup, checkout, login',
      'Run from multiple regions and ISPs',
      'Separate canary traffic from prod data where needed',
      'Don’t overload systems — backoff on failures',
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
      'High-cardinality labels (user_id, url path) explode memory',
      'Prefer histograms without per-path labels or use exemplars',
      'Tail sampling for traces instead of metric per span',
      'Use logs for high-cardinality drill-down linked from metrics',
      'Vendor limits — budget for observability cost',
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
      'Lab metrics ≠ field performance on 3G devices',
      'Sample client telemetry to control cost',
      'Privacy: minimize PII in client beacons',
      'Session replay for UX — secure and consent-aware',
      'Tie frontend RUM trace to backend trace id',
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
      'CPU and heap profiles explain latency spikes better than guessing',
      'Always-on low-rate sampling catches rare issues',
      'Compare profiles across versions during regressions',
      'Respect PII in stack args — scrub',
      'Pair with traces: slow span → profile that service',
    ],
    mnemonic: 'Profile = MRI for CPU',
    interviewQ: 'CPU high after deploy — steps?',
    interviewA: 'Pull continuous profile diff before/after deploy. Check flame graph for new hot functions. Correlate with traffic mix change. If GC heavy — heap profile for allocations. Roll back if customer-impacting while investigating. Add benchmark preventing regression. Document finding in postmortem if severe.',
    difficulty: Difficulty.intermediate,
    tags: ['observability', 'performance', 'profiling'],
  ),
];
