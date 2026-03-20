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
      'DNS translates domain names (api.example.com) into IP addresses. It\'s the first step of every internet request, and its configuration directly affects latency, availability, and failover speed',
      'TTL controls how long resolvers cache records. High TTL (1 hour) means fewer DNS lookups but slow failover — clients keep hitting the old IP. Low TTL (60 seconds) enables fast failover but increases DNS traffic',
      'Global routing uses DNS to direct users to their nearest region: a user in Tokyo resolves to Tokyo\'s IP, London resolves to London\'s. Done via geo-DNS or latency-based routing policies',
      'Health-checked DNS records automatically steer traffic away from unhealthy regions. If US-East fails a check, the provider stops returning its IP and sends all traffic to US-West — automated failover',
      'In interviews: "before failover, we lower DNS TTL to 60 seconds. Health-checked records redirect traffic if the primary fails. DNS config lives in infrastructure-as-code with change review"',
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
      'The TLS handshake establishes an encrypted connection — client and server agree on encryption, verify the server\'s identity via certificates, and generate session keys. This happens before any data is exchanged',
      'TLS 1.3 reduced the handshake from 2 round trips to 1 (and 0 for repeat connections with session resumption). On slow networks, a 100ms round trip × 2 = 200ms overhead just for encryption setup',
      'TLS termination decides where encryption ends: at the load balancer (simpler cert management, unencrypted internally) or at each service (end-to-end encryption, required for mTLS, more certs to manage)',
      'Certificate validity is verified by chain: your cert signed by an intermediate CA, signed by a root CA trusted by the browser. OCSP stapling lets the server include proof of validity, avoiding slow client checks',
      'In interviews: "TLS 1.3 at the CDN edge for minimal handshake latency. Session tickets enable 0-RTT for returning clients. Internally, mTLS via service mesh for east-west encryption"',
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
      'Load balancers operate at two layers: L4 (TCP/UDP — fast, sees only IP/ports) and L7 (HTTP — reads URLs, headers, cookies for intelligent routing). Most web applications use L7',
      'L7 enables: route /api/* to API servers and /static/* to CDN, split traffic by header for canary deployments, integrate with WAFs — all based on HTTP content',
      'L4 is simpler and faster — forwards raw TCP without inspecting content. Use for non-HTTP protocols (database connections, gRPC) or as the first layer in front of L7 balancers',
      'During deployments, connection draining is critical: stop sending NEW requests to a server being shut down but let existing ones finish. Without this, active requests are killed mid-flight',
      'In interviews: "NLB (L4) at the edge for TCP performance. ALB (L7) behind it for path-based routing, canary splits, and WAF. Health checks verify the app is ready, not just that the port is open"',
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
      'HTTP/1.1 opens a separate connection per request. HTTP/2 multiplexes many requests over a single TCP connection — multiple files download simultaneously, dramatically improving page load speed',
      'HTTP/2\'s weakness: since it runs on TCP, a single dropped packet blocks ALL streams until retransmitted (head-of-line blocking). On lossy mobile networks, this can make HTTP/2 slower than HTTP/1.1',
      'HTTP/3 replaces TCP with QUIC (built on UDP). Each stream is independent — a lost packet in one doesn\'t block others. It also integrates TLS, enabling faster connection setup (0-RTT for repeat connections)',
      'HTTP/3 handles mobile network switches (WiFi → cellular) gracefully because connections use a connection ID, not the IP+port pair that changes during handoff',
      'In interviews: "we serve through a CDN supporting HTTP/3 and QUIC for mobile performance. Connection migration keeps sessions alive during WiFi-to-cellular handoffs"',
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
      'CDN caching stores content at edge servers worldwide. The Cache-Control header tells the CDN what to cache, for how long, and when to revalidate',
      'For static assets (JS, CSS, images), use content-hashed filenames (app.a3f8b2.js) with long Cache-Control (immutable). Since the filename changes with content, you get perfect caching with instant updates',
      'For dynamic content, be careful: Cache-Control: private, no-store for personalized data. Short public caching (s-maxage=60) for semi-public pages with stale-while-revalidate to serve slightly stale content while fetching fresh',
      'Emergency invalidation (purge): remove content from all edges immediately via the CDN\'s purge API. But design to minimize purges — fingerprinted filenames and short TTLs are better than frequent purges',
      'In interviews: "static assets use immutable content-hash filenames cached forever. API responses use short TTLs with stale-while-revalidate. We shield our origin behind a single regional PoP so cache misses don\'t overwhelm it"',
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
      'NAT lets many devices share a single public IP — like an apartment building where residents share one address, and the mailroom routes incoming letters to the right apartment using a tracking table',
      'NAT gateways maintain a connection tracking table mapping internal to external ports. This table has limits — thousands of short-lived connections to the same destination can exhaust available ports',
      'This is a common Kubernetes issue: pods behind NAT making many connections to the same database. Intermittent failures under load are often NAT port exhaustion. Fix with connection pooling or more NAT IPs',
      'IPv6 gives every device a globally unique address, eliminating NAT. But NAT is deeply embedded and will persist for years. Cloud NAT auto-scales but has quotas you must monitor',
      'In interviews: "intermittent connection failures to Redis under load were caused by SNAT port exhaustion — one NAT IP on our nodes. We added more egress IPs and implemented connection pooling"',
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
      'Anycast announces the same IP address from multiple locations worldwide. BGP routing sends each request to the nearest location — like printing the same phone number everywhere and always being answered by the nearest office',
      'Large CDNs and DNS providers use anycast to minimize latency globally and absorb DDoS attacks. An attack targeting one IP spreads across all locations — each handles a fraction',
      'The challenge with TCP: if BGP routing changes mid-connection, the connection shifts to a different server that doesn\'t know about it. QUIC/HTTP3 handles this better since connections use an ID, not IP+port',
      'Running anycast yourself requires BGP expertise and an AS number. For most teams, using a managed CDN or DNS provider with an existing anycast network is far simpler',
      'In interviews: "CDN with anycast for edge caching and DDoS absorption. Users automatically hit the nearest PoP via BGP, and attack traffic distributes across all edges instead of overwhelming one"',
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
      'WebSockets create a persistent, bidirectional connection — unlike HTTP where the client keeps asking "anything new?", a WebSocket lets the server push updates instantly. Essential for chat, live dashboards, and real-time notifications',
      'Long polling is simpler: the client makes an HTTP request and the server holds it open until there\'s data or a timeout. Works through all proxies but is less efficient than WebSockets for high-frequency updates',
      'Scaling challenge: each connected user holds an open connection to a specific server. Across 20 servers, you need a pub/sub backplane (Redis, Kafka) to fan out messages to the right servers',
      'Authenticate at the WebSocket upgrade request, not after — once connected, it stays open. Pass auth tokens in the query parameter or protocol header during the handshake',
      'In interviews: "chat via WebSocket with Redis pub/sub across server instances. Each server subscribes to channels for rooms its clients are in. Heartbeats detect and clean up dead connections"',
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
      'VPC Peering connects two private cloud networks as if they\'re one — but it\'s 1:1. Connecting 10 VPCs requires 45 peering connections (full mesh), which becomes an operational nightmare',
      'Transit Gateway acts as a central hub: instead of 45 direct connections between 10 VPCs, each VPC has 1 connection to the hub — 10 total, much simpler to manage',
      'Common gotcha: VPC peering requires non-overlapping IP ranges. If two VPCs both use 10.0.0.0/16, they can\'t be peered. Plan IP ranges upfront across all environments — retrofitting is painful',
      'PrivateLink is different: it exposes a specific service from one VPC to another without network routing. The consumer gets an endpoint that reaches the service privately — no need to expose the entire network',
      'In interviews: "for 2-3 VPCs, peering is fine. For 10+, Transit Gateway with route tables. PrivateLink to expose our payment API to a partner\'s VPC without giving them network access"',
    ],
    mnemonic: 'Peering = two islands bridge; TGW = airport hub',
    interviewQ: '10 VPCs need private connectivity',
    interviewA: 'Use Transit Gateway with attachments per VPC and route tables pointing 10.0.0.0/8 to TGW. Avoid full mesh peering. Segment prod vs nonprod. PrivateLink for SaaS consumption (Datadog, etc.). Ensure no overlapping RFC1918 ranges. Centralize egress via NAT in shared services VPC for inspection if required.',
    difficulty: Difficulty.advanced,
    tags: ['networking', 'aws', 'cloud'],
  ),
];
