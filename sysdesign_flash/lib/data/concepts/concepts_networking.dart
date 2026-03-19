import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Networking';
final _color = AppColors.networking;

final conceptsNetworking = <Concept>[
  Concept(
    id: 100,
    category: _cat,
    color: _color,
    icon: '🌐',
    title: 'DNS & Global Routing',
    tagline: 'Names to IPs worldwide',
    diagram: '''
  user ──► Recursive resolver
              │
         Authoritative NS
              │
         A/AAAA/CNAME records

  Geo DNS / latency-based routing''',
    bullets: [
      'TTL balances propagation speed vs flexibility during failover',
      'CNAME at apex issues — use ALIAS/ANAME at provider',
      'DNSSEC prevents cache poisoning where supported',
      'Health checks steer traffic away from bad regions',
      'Split-horizon DNS for internal vs external views',
    ],
    mnemonic: 'DNS = phone book of the internet',
    interviewQ: 'Failover DNS to DR region',
    interviewA: 'Lower TTL ahead of change window. Health-checked weighted records or traffic manager (Route53, Traffic Director) flip to DR when primary fails. Ensure DR stack can handle full load — tested quarterly. Application data replication must meet RPO before DNS flip. Document runbook with decision tree and rollback.',
    difficulty: Difficulty.intermediate,
    tags: ['networking', 'dns', 'reliability'],
  ),
  Concept(
    id: 101,
    category: _cat,
    color: _color,
    icon: '🔒',
    title: 'TLS Handshake',
    tagline: 'Encrypt and authenticate HTTP',
    diagram: '''
  ClientHello (ciphers, key share)
  ServerHello + cert
  Key exchange → session keys
  Encrypted Application Data

  TLS 1.3: 1-RTT (0-RTT with resumption cautions)''',
    bullets: [
      'Certificate chain must validate to trusted root',
      'OCSP stapling reduces client lookup latency',
      'TLS termination at LB vs pod trade-offs (cert management, mTLS)',
      'Session resumption improves performance',
      'Disable legacy TLS 1.0/1.1',
    ],
    mnemonic: 'TLS = secret tunnel after handshake',
    interviewQ: 'First byte latency high on HTTPS',
    interviewA: 'Measure TLS handshake vs TTFB. Use TLS 1.3, session tickets, OCSP stapling, HTTP/2 multiplexing. Edge CDN closer to users. Ensure cipher suites hardware-accelerated. Consider QUIC/HTTP3 for UDP-based handshake reduction on lossy networks. Check if app waits for full chain before sending data.',
    difficulty: Difficulty.intermediate,
    tags: ['networking', 'tls', 'security'],
  ),
  Concept(
    id: 102,
    category: _cat,
    color: _color,
    icon: '⚖️',
    title: 'Load Balancing Layers',
    tagline: 'L4 vs L7',
    diagram: '''
  L4 (TCP): fast, any protocol, simple
  L7 (HTTP): path routing, cookies, gRPC

  ECMP / Anycast at edge
  NLB → ALB → pods''',
    bullets: [
      'L4 preserves source IP with PROXY protocol',
      'L7 enables canary by header, path-based routing, WAF',
      'Connection draining on deploy — respect grace period',
      'Health checks should validate app readiness not just TCP open',
      'Sticky sessions reduce cache locality benefits — prefer stateless',
    ],
    mnemonic: 'L4 = packet plumber; L7 = HTTP smart',
    interviewQ: 'When NLB vs ALB on AWS?',
    interviewA: 'NLB for extreme throughput, static IPs, non-HTTP TCP/UDP, preserving client IP simply. ALB for HTTP/HTTPS path/host routing, WebSocket, integration with WAF, slow start, and fine-grained target groups. gRPC works on ALB with HTTP/2. Cost and feature set differ — pick by protocol and routing needs.',
    difficulty: Difficulty.intermediate,
    tags: ['networking', 'aws', 'scaling'],
  ),
  Concept(
    id: 103,
    category: _cat,
    color: _color,
    icon: '🚀',
    title: 'HTTP/2 & HTTP/3',
    tagline: 'Multiplexing and QUIC',
    diagram: '''
  HTTP/1.1: many TCP connections per host
  HTTP/2: one TCP, many streams (HOL blocking on TCP loss)

  HTTP/3: QUIC over UDP — loss affects one stream''',
    bullets: [
      'H2 multiplexing reduces head-of-line at HTTP layer',
      'TCP loss still blocks all H2 streams — QUIC fixes per-stream',
      'Server push in H2 often misused — prefer preload hints',
      'Connection coalescing and priority semantics differ by version',
      'CDN support required for HTTP/3 end-to-end',
    ],
    mnemonic: 'HTTP/3 = TCP pain moved out of the way',
    interviewQ: 'Benefit HTTP/3 for mobile app',
    interviewA: 'Mobile networks have packet loss; TCP H2 stalls all streams. QUIC isolates streams and improves handshake on connection migration (WiFi↔LTE). Requires UDP not blocked; corporate networks sometimes block. Measure real user metrics — not always win if middleboxes interfere. Terminate at CDN close to users.',
    difficulty: Difficulty.advanced,
    tags: ['networking', 'http', 'performance'],
  ),
  Concept(
    id: 104,
    category: _cat,
    color: _color,
    icon: '📡',
    title: 'CDN Caching',
    tagline: 'Edge copies reduce origin load',
    diagram: '''
  GET /static/app.js
  CDN POP cache hit → fast
  miss → origin fetch → store with Cache-Control''',
    bullets: [
      'Cache-Control: public, max-age, s-maxage, stale-while-revalidate',
      'Cache bust via fingerprinted filenames — immutable long TTL',
      'Private/no-store for personalized responses',
      'Purge API for emergency invalidation',
      'Shield origin with single regional origin shield POP',
    ],
    mnemonic: 'CDN = photocopier near the user',
    interviewQ: 'Users see stale JS after deploy',
    interviewA: 'Use content-hashed filenames so new deploy = new URL — no stale bundle. If HTML references old hash, ensure HTML not cached aggressively or purge on deploy. Service worker can cause sticky old assets — version cache carefully. For API JSON, short TTL or surrogate keys. Automate purge in CI/CD.',
    difficulty: Difficulty.intermediate,
    tags: ['networking', 'cdn', 'performance'],
  ),
  Concept(
    id: 105,
    category: _cat,
    color: _color,
    icon: '🕳️',
    title: 'NAT & Connection Tracking',
    tagline: 'Many inside, few public IPs',
    diagram: '''
  Private 10.x ──► NAT gateway ──► Public IP:port
  Stateful table maps return packets

  Exhaustion → ephemeral port limits''',
    bullets: [
      'SNAT gateway limits concurrent outbound connections per destination',
      'Many short-lived connections to same DB — watch connection pooling',
      'IPv6 reduces NAT complexity long term',
      'NAT traversal challenges for P2P — STUN/TURN',
      'Cloud NAT auto-scales but has quotas',
    ],
    mnemonic: 'NAT = apartment intercom for packets',
    interviewQ: 'Intermittent connection failures to Redis',
    interviewA: 'Check SNAT port exhaustion from Kubernetes nodes without sufficient outbound IPs. Increase node pool egress IPs or use VPC endpoints so traffic stays private. Reuse connections with pooling. TIME_WAIT tuning cautiously. Metrics on dropped SNAT on cloud provider. Avoid creating new TCP per request.',
    difficulty: Difficulty.advanced,
    tags: ['networking', 'cloud', 'kubernetes'],
  ),
  Concept(
    id: 106,
    category: _cat,
    color: _color,
    icon: '🧭',
    title: 'Anycast',
    tagline: 'Same IP announced from many sites',
    diagram: '''
  BGP routes users to nearest POP
  Same service IP globally

  DDoS absorption + low latency''',
    bullets: [
      'Used by large CDNs and DNS providers',
      'Routing changes shift traffic on failures — understand convergence',
      'TCP connections tied to POP — migration on mobility is hard without QUIC',
      'Requires own ASN and BGP expertise or managed provider',
      'Not same as multicast — unicast to nearest',
    ],
    mnemonic: 'Anycast = one address, many doors, nearest opens',
    interviewQ: 'Why Cloudflare uses anycast',
    interviewA: 'Same IP globally lets BGP send each user to closest edge for latency and DDoS scrubbing capacity. Attack traffic spreads across edges; legitimate users hit nearby POP. Operational complexity is high — not DIY for small teams. Pair with centralized control plane for config push.',
    difficulty: Difficulty.advanced,
    tags: ['networking', 'bgp', 'cdn'],
  ),
  Concept(
    id: 107,
    category: _cat,
    color: _color,
    icon: '🔥',
    title: 'WebSockets & Long Polling',
    tagline: 'Bidirectional real-time HTTP',
    diagram: '''
  WS: Upgrade HTTP → persistent framed connection
  Heartbeats + backpressure handling

  Long poll: hold GET until event or timeout''',
    bullets: [
      'WebSockets need sticky sessions or pub/sub backplane across instances',
      'Proxies/LBs must support WebSocket upgrade timeouts',
      'Authentication at upgrade — tokens in query or Sec-WebSocket-Protocol',
      'Scale with Redis pub/sub or dedicated realtime service',
      'Backpressure: drop/slow consumers to protect server',
    ],
    mnemonic: 'WebSocket = phone call; HTTP = postcards',
    interviewQ: 'Scale chat WebSockets horizontally',
    interviewA: 'Use Redis/Kafka pub/sub bus; each server subscribes to channels for rooms user sockets attached to. Sticky sessions optional if every message routes via bus to correct node holding socket. Heartbeat to detect dead connections. Rate limit messages. Consider managed realtime (Ably, Pusher) vs self-host.',
    difficulty: Difficulty.intermediate,
    tags: ['networking', 'websockets', 'realtime'],
  ),
  Concept(
    id: 108,
    category: _cat,
    color: _color,
    icon: '🛣️',
    title: 'VPC Peering vs Transit',
    tagline: 'Connect private networks',
    diagram: '''
  VPC A ←peering→ VPC B
  Transitive routing NOT automatic

  Transit Gateway: hub spoke model
  PrivateLink: service endpoint without routing mesh''',
    bullets: [
      'Peering is 1:1; large mesh becomes operational pain',
      'CIDR overlaps block peering — plan IP ranges early',
      'Transit Gateway simplifies many-VPC topologies',
      'PrivateLink exposes service without exposing full network',
      'Flow logs for security auditing east-west',
    ],
    mnemonic: 'Peering = two islands bridge; TGW = airport hub',
    interviewQ: '10 VPCs need private connectivity',
    interviewA: 'Use Transit Gateway with attachments per VPC and route tables pointing 10.0.0.0/8 to TGW. Avoid full mesh peering. Segment prod vs nonprod. PrivateLink for SaaS consumption (Datadog, etc.). Ensure no overlapping RFC1918 ranges. Centralize egress via NAT in shared services VPC for inspection if required.',
    difficulty: Difficulty.advanced,
    tags: ['networking', 'aws', 'cloud'],
  ),
];
