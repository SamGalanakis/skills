---
name: performancesmash
description: "Audit a codebase or system for real performance bottlenecks and optimization opportunities across CPU, memory, allocation behavior, data access, caching, databases, network hops, payload size, batching, connection management, concurrency, queueing, and compression. Use when the user wants a serious performance pass, suspects the system is slow or wasteful, or wants guidance on where latency, throughput, or resource efficiency are being lost. Prefer this over ad-hoc micro-optimizing or style-level cleanup." 
---

# Performancesmash

Perform a top-down performance audit. Focus on where time, memory, IO, and network are actually being wasted, and on which changes will materially improve latency, throughput, or resource efficiency.

## Core Model

- Measure first. Guessing is how teams burn weeks for no gain.
- Treat data movement as a first-class cost: memory traffic, cache misses, serialization, network hops, disk reads, and cross-service chatter all count.
- Optimize the bottleneck that exists, not the one that is easiest to talk about.
- Prefer structural wins over heroics: fewer hops, fewer queries, less copying, better batching, better locality, better caching, simpler hot paths.
- Treat abstraction skeptically on hot paths. If indirection, layering, object churn, or generic machinery obscures the cost model, call it out.
- Broad before deep. First find whether the problem is CPU, memory, DB, network, lock contention, payload size, queueing, or coordination. Then drill into the dominant constraint.

## Positioning

- Use this skill for repo-wide or subsystem-wide performance work.
- Use this skill when the user wants bottlenecks, optimization opportunities, or a diagnosis of latency, throughput, or resource waste before editing code.
- Prefer this over style-level cleanup when the real issue is performance shape rather than code tidiness.
- Be blunt. Do not get hypnotized by micro-optimizations when the real loss is query shape, chatty boundaries, unnecessary copies, or long dependency chains.

## Audit Workflow

1. Map the performance shape.
   Identify entry points, latency-sensitive flows, background work, request fan-out, major storage systems, network boundaries, cache layers, queues, and concurrency model.
2. Find the dominant constraint.
   Determine whether the current pain is CPU, memory, allocations, GC, lock contention, database access, disk IO, network latency, payload size, queueing, or downstream dependency time.
3. Trace wasted work.
   Look for repeated computation, repeated fetching, repeated parsing, repeated allocation, repeated serialization, and repeated connection setup.
4. Check data movement.
   Audit memory layout, access locality, copies, marshaling, query shape, service hops, payload size, and cross-region or cross-process boundaries.
5. Prefer structural fixes.
   Recommend better access patterns, batching, caching, denormalization, co-location, connection reuse, async decoupling, precomputation, compression, or simpler hot paths before chasing instruction-level trivia.
6. Produce prioritized findings.
   Lead with the few changes most likely to move p95/p99 latency, throughput, and infrastructure cost.

## Performance Lenses

Check for these patterns:

1. **No measurement discipline**
   No profiler, no tracing, no before/after baseline, no percentile view, or optimization driven by anecdote.
2. **Chatty boundaries**
   Too many service calls, DB round trips, RPC hops, per-item fetches, or synchronous fan-out on the critical path.
3. **Bad access patterns**
   N+1 queries, row-by-row work, random access when sequential access would do, repeated full scans, over-fetching, or fetching wide blobs for narrow needs.
4. **Caching failure**
   Expensive repeated reads or computations with no cache, weak cache keys, low hit rate, cache invalidation fear blocking obvious wins, or cache layers that do not match access patterns.
5. **Batching failure**
   Tiny queries, tiny writes, tiny RPCs, or per-item work that should be grouped to amortize round trips and coordination overhead.
6. **Connection waste**
   New connections per request, weak pooling, missing keep-alive/reuse, poor DB pool sizing, handshake-heavy paths, or serial use of scarce connections.
7. **Payload bloat**
   Oversized responses, verbose formats, unused fields, repeated encoding/decoding, absent compression, or needless binary/text conversions.
8. **Allocation and copy churn**
   Temporary objects, repeated buffer growth, excessive parsing, string churn, hidden copies, or abstraction-heavy pipelines in the hot path.
9. **Locality and layout failure**
   Data structures hostile to caches, pointer chasing, scattered memory, branch-heavy polymorphic paths, or work organized around types instead of access patterns.
10. **Queueing and contention**
    Locks, thread pool starvation, saturated worker queues, head-of-line blocking, convoy effects, or systems that hide overload with unbounded buffers.
11. **Critical-path pollution**
    Logging, retries, retries inside retries, metrics emission, cache fills, or optional work happening synchronously on latency-sensitive requests.
12. **Wrong optimization target**
    Teams hand-tuning local code while the real cost sits in a database, network hop, cache miss, remote dependency, or serialization boundary.

## Decision Rules

- First ask: what is slow for users or expensive for the system? Then ask where the time or capacity actually goes.
- Prefer eliminating work over speeding it up.
- Prefer moving less data over processing the same data faster.
- Prefer one query over many, one hop over many, one parse over many, one allocation over many.
- Prefer hot-path clarity over elegant abstraction when the abstraction hides cost.
- If a result is read far more often than it changes, question why it is not cached or precomputed.
- If a request waits on many independent remote calls, question the API shape and system boundaries.
- If a DB query pattern mirrors an object graph instead of the actual read pattern, question the access model.
- If queue length is growing, investigate saturation and backpressure before adding more buffering.
- If CPU is low but latency is high, suspect waiting: network, locks, disk, downstream services, or queueing.
- If throughput is low but resource use is high, suspect overhead: context switching, small batches, serialization, copies, or bad locality.

## Output Format

Present findings first as a concise list ordered by severity.

- Prefer a short top-N list over exhaustive coverage.
- Each finding should be 1-2 sentences.
- Include the scope or location inline.
- State the core performance problem and the optimization move in the same short entry.
- Prioritize by expected impact on user-visible latency, throughput, and recurring resource cost.
- Do not turn the report into a long plan or essay.
- Avoid preamble, methodology recap, and long summaries unless the user asks for them.

If useful, end with a very short next-step recommendation, but keep the main output focused on the severity-ordered findings list.

## Relationship To Other Skills

- `complexitysmash`: use when the main problem is systemic design complexity rather than performance.
- `spring-cleaning`: use when the main job is cleanup, subtraction, and local restructuring.
- `wholehog`: use after this audit when the right move is to implement the clean high-performance end-state directly.
