---
name: profilesmash
description: "Run an agent-orchestrated audit of a codebase's performance measurement infrastructure: profilers, benchmarks, load tests, tracing, metrics, budgets, and regression gates. It does not hunt bottlenecks; it asks whether the project could find one, trust the number, and notice a regression. Catalogs every measurement asset as delete (misleading or dead), unclear, or keep; fills a flow-by-dimension visibility matrix across CPU, waiting, latency, memory, stack, IO and round trips, concurrency, startup, build, client and GPU, and cost; and proposes approaches (sampling and off-CPU profiling, continuous profiling, tracing, flight recorders, heap and allocation profiling, hardware counters, causal profiling, deterministic and statistical benchmarks, open-loop load, change-point detection, counted budgets) where they fit. The coordinator inventories assets and flows as a coverage contract, fans out catalog, dimension, trust, regression and approach agents sized to the repo, verifies every deletion and blind spot, then ranks. Use when the user wants profiling or benchmarking infrastructure reviewed, cannot tell where time or memory goes, distrusts their benchmarks, or keeps shipping regressions nobody saw. Changes nothing in the repo; probes run only in a throwaway copy and never against shared or production systems."
---

# Profilesmash

Audit the instruments, not the program. `performancesmash` asks where the time goes; this asks whether anyone could find out. A project without attribution optimizes by anecdote, and one with untrustworthy numbers optimizes the wrong thing with confidence. Agents make it worse: they add a benchmark that compiles to nothing, report a mean from one run on a laptop, and call it measured.

Audit only. Do not edit, commit, or push. You may build, run benchmarks, and run profilers locally, writing output to the scratchpad. A slowdown probe (inject a sleep, an extra allocation, or an extra query, then run the gates) is allowed only in a throwaway worktree or copy. Never generate load against shared, staging, or production systems, and never attach to a production process.

You are the coordinator. Continue until every asset has a verdict, every matrix cell is filled, and the final audit is validated.

## The Three Questions

Ask them of every critical flow, for every cost dimension it has:

1. **Can someone attribute it?** Given "this got slow" or "this uses too much", can a person or an agent get from the symptom to a line, query, span, or allocation site with one documented command, in minutes? A total is not an answer.
2. **Can the number be trusted?** Production build and flags, production-shaped workload, a distribution instead of a mean, known noise, known overhead, symbols that resolve.
3. **Would a regression be noticed?** By a gate before merge, a trend after it, an alert in production, or nobody.

## Dimensions

Each is a different question needing a different instrument. A project that owns only a CPU flame graph diagnoses everything as CPU.

| Dimension | What must be answerable |
|---|---|
| CPU | time by function and line; instructions and cycles; inlining and vectorization on the hot loop; cache misses, branch mispredicts, front-end vs back-end stalls |
| Waiting | where wall time goes when CPU is idle: blocking IO, locks, sleeps, run-queue delay, page faults, GC and allocator pauses |
| Latency | per-operation distribution to p99.9 and max; queueing vs service time; the critical path through a request; time to first byte or token; jitter; what the slowest one in ten thousand did |
| Throughput and saturation | sustainable rate and where the knee is; utilization, saturation, and errors per resource; queue depths, pool waits, backpressure |
| Memory | live heap by allocation site; peak; allocation rate and temporaries; growth over hours; RSS vs live (fragmentation, retained pages); bytes copied; object size and layout; per-request footprint |
| Stack | frame sizes and deepest call chain; high-water mark per thread; recursion bounds; size of futures and tasks; thread-stack reservation times thread count |
| IO and round trips | queries, RPCs, and syscalls per operation; serial vs parallel fan-out; retries; rows scanned vs returned and the plan; payload bytes and serialization time; fsyncs; connection setups and handshakes; cache hit ratio |
| Concurrency | lock hold and wait time by site; scheduler health (long polls, blocked workers, queue depth); context switches; false sharing; speedup as cores are added |
| Scale | how cost grows with input size, data volume, tenant count, and concurrency; behavior at ten times today |
| Startup and cold paths | process start to first useful work; warmup; cold caches; lazy initialization; cold start on scale-out |
| Build and inner loop | compile, link, and incremental time by unit; test-suite time; binary size by symbol and dependency |
| Client | frame time and long tasks with attribution; input-to-paint; load milestones in the field and in the lab; bundle bytes; render counts; network waterfall |
| GPU and accelerators | time per pass or kernel; draw calls; device memory; host-device transfers and sync points; utilization and input-pipeline starvation |
| Cost | CPU-seconds, bytes, tokens, and money per operation; egress; storage growth; energy where it matters |

Drop dimensions the system does not have; add ones this domain does.

## Verdicts for existing assets

An asset is anything that produces a performance number or picture: a benchmark, a load script, a profiling script or build profile, a span or metric, a dashboard or alert defined in the repo, a perf job in CI, a budget assertion.

- **delete**: it cannot inform a decision, or it misleads. Give a reason code.
- **unclear**: what it was meant to measure cannot be recovered. State the question that settles it.
- **keep**: name the decision it supports. Optionally `strengthen`.

A misleading measurement of something important is `delete` plus a blind-spot entry.

| Code | Shape |
|---|---|
| `dead` | does not build or run, is in no pipeline, and nobody has run it |
| `wrong-build` | debug or unoptimized build, different allocator or flags than production, or instrumented so heavily the instrument is the cost |
| `optimized-away` | result unused, input constant-folded, or the work hoisted or eliminated; the benchmark times an empty loop |
| `toy-workload` | input size, shape, or distribution unlike production: one key, warm cache only, empty database, no concurrency |
| `wrong-statistic` | mean or single run; no variance; percentiles averaged across hosts or windows; max discarded; buckets too coarse for the tail |
| `coordinated-omission` | closed-loop load, or latency timed from actual send instead of scheduled send, so stalls hide their own victims |
| `noisy-gate` | wall-time threshold on a shared runner; a gate that flakes and is ignored, or is loose enough never to fire |
| `no-baseline` | a number with nothing to compare against and no history |
| `unattributable` | a total with no way down to a cause |
| `cold-path` | measures code on no hot path, while the paths that matter have nothing |
| `duplicate` | same flow, dimension, and workload as another asset |

## 1. Survey and coverage contract

Before spawning anything, read the repo yourself: languages and runtimes, deploy shape (library, CLI, service, client, embedded), where it runs, the flows a user or operator would call slow or expensive, stated targets or SLOs, existing assets, build profiles, CI runners, and what telemetry exists as code.

Write one canonical scratchpad report holding two inventories. The **asset inventory** lists every asset with its flow, dimension, where it runs (dev, CI, production), and its lane. The **visibility matrix** has one row per critical flow and one column per relevant dimension; every cell ends as `attributed` (cause reachable with one command), `measured` (number only), `blind`, or `n/a`, plus how a regression would surface: `gated`, `trended`, `alerting`, or `none`. Together they are the coverage contract. Also hold trust findings, proposals, skips, and an audit log.

## 2. Fan out, shaped to the repo

Use fresh agents, bounded to what you can coordinate, with non-overlapping ownership. Choose lanes from the survey; drop roles the repo has no use for and split the ones it is heavy in.

- **Asset catalog workers**, one per lane of assets split by kind or subsystem. One row per asset: `path | kind | flow | dimension | verdict | reason code | decision supported | action`. They run what can be run and say what happened.
- **Dimension scouts**, one per relevant dimension or small group of them. Each reads the source for where that cost arises in the critical flows, then tries to get an attributed answer using only what the repo documents, and records the time it took and where it broke. They fill their matrix column and never see catalog verdicts.
- **Trust reviewer**, one: applies the trust lenses across every harness, and runs the same commit against itself to learn what difference the tooling reports for no change.
- **Regression reviewer**, one: what gates merges, what is trended, what alerts, who looks. Runs slowdown probes in a throwaway copy, one per dimension that claims a gate, and reports which were caught.
- **Production visibility reviewer**, one, only if the project is deployed: from the code and config, what is always on, what can be turned on per request or per host, what links a slow request to its profile, and who can reach it.
- **Approach scout**, one: which techniques are absent and fit, with the tool for this stack and platform. The fit table is a floor; the scout researches current practice for this runtime and domain and what comparable projects run.

Trust lenses:

- **Build**: is there a profile that is production-optimized with debug info and reliable unwinding (frame pointers or equivalent), and is it what the benchmarks and profilers use; do symbols resolve, including inlined frames and across the runtime or FFI boundary.
- **Workload**: is there a production-shaped dataset and request mix, recorded or synthesized; are size, skew, concurrency, and cold starts represented; is warmup separated from steady state.
- **Statistics**: distributions with tail-preserving histograms; repeated runs with intervals; percentiles never averaged; achieved rate checked against target rate.
- **Noise**: dedicated or pinned runners, frequency scaling and neighbors controlled, series partitioned by machine; deterministic metrics (instruction counts, allocation counts, query counts) for gates, wall time reported beside them.
- **Observer effect**: profiler overhead measured; sampling bias known (on-CPU only, safepoints, skid); trace sampling that does not throw away the slow ones.
- **Reach**: can the same instruments run in dev, CI, and production, or does each environment see a different program.
- **Legibility**: does one command emit a text result (top-N table, folded stacks, diff against baseline) that an agent can read and act on, or only a picture for a human.

Fit table for proposals:

| The project has | Propose |
|---|---|
| any compiled or JIT hot path | one-command sampling CPU profile with flame graph and text top-N; differential flame graph between two commits |
| latency that CPU time does not explain | off-CPU and wall-clock profiling; blocked-time samples; per-thread state breakdown |
| a deployed service | always-on low-overhead continuous profiling labeled by version, so releases diff; profiles linked to trace and span |
| requests crossing processes | distributed tracing with spans at every boundary; critical-path analysis; tail-based sampling that keeps slow and failed traces; exemplars from latency metrics to traces |
| rare tail outliers | flight recorder: ring-buffer capture snapshotted on a slow-request trigger (hardware control-flow trace, runtime event recorder) |
| a latency target | tail-preserving histograms per operation; open-loop load at fixed arrival rate timed from scheduled send; rate sweep to find the knee |
| allocation-heavy or long-lived processes | heap profile by site (live, peak, temporaries); allocator stats beside RSS; growth tracked over a soak; allocation-count budgets in tests |
| deep recursion, large async state, many threads, or embedded targets | static stack-frame and call-depth analysis; stack high-water marks; future and task size reports |
| a database | query count per operation asserted in tests and counted per trace; repeated-shape detection; statement statistics by shape; slow-plan capture; the same test at two data sizes |
| chatty service boundaries | round trips and payload bytes per operation as metrics with budgets; fan-out shape visible in traces |
| locks or an async runtime | contention profile by site; runtime scheduler metrics and a task console; core-count scaling sweep |
| tight loops or data-oriented code | hardware counters and top-down stall breakdown; deterministic cache and instruction simulation |
| parallel code with no obvious lever | causal profiling: virtual speedup per line to rank what is worth optimizing |
| microbenchmarks | statistical harness with warmup and outlier handling; instruction-count twin for the gate; inputs guarded from the optimizer |
| regressions found late | continuous benchmarking with history; change-point detection on the series instead of fixed thresholds; detector validated by injecting a known slowdown |
| no end-to-end number | macro benchmark on a production-shaped workload; replay of recorded traffic; sweep over input size and concurrency |
| startup that matters | startup trace by phase; cold-start benchmark from a clean state |
| frames | instrumented frame profiler with zones, frame-time histogram, GPU timers |
| a web client | field metrics from real users beside lab runs in CI; bundle budgets; long-task attribution |
| slow builds or large binaries | per-unit compile timings; size by symbol and dependency; both tracked over time |
| a stable hot binary and production profiles | feed them back: profile-guided and post-link optimization from sampled profiles |
| model or agent calls | per-step latency, tokens, cache hits, and cost on the trace |
| costs known only to operators | cheap always-on counters and static tracepoints at the boundaries; per-flow budgets as tests |

A proposal must name the flow and dimension, the instrument, the first concrete artifact (the command, the benchmark, the span, the budget and its number), the question it answers that cannot be answered today, its overhead, and where it runs. "Add profiling" is not a finding. Prefer the cheapest instrument that answers the question: a counted budget in a test before a timing benchmark, a local one-command profile before a platform, always-on production tooling only where there is production.

## 3. Verify, deduplicate, rank

Verify independently before accepting. Every `delete`: re-read the asset and confirm the reason, running it where cheap; downgrade to `unclear` on doubt. Every `blind` cell: search for an existing way to get the answer, in any environment. Every proposal: confirm the tool supports this platform, runtime, and privilege level, and that the seam exists. Reject proposals that duplicate an instrument, name no question, or exist for symmetry.

Promote a misleading shape repeated across three or more lanes to a pattern with one rule that would stop it at authoring time. Then run one fresh coverage pass: which flows, dimensions, environments, or assets does the contract miss? Audit any real omission as its own row.

## Output

Lead with the visibility matrix, compact: flows by dimensions, each cell showing attribution and regression status. Then, briefly:

1. Blind spots, ranked by what a problem there would cost.
2. Misleading assets by reason code, each with one example.
3. Regression detection: what is gated, what the slowdown probes got past.
4. Trust findings that cut across harnesses.
5. Proposals, ranked by blind cost covered over effort, each with its first concrete artifact.
6. Authoring rules that would have prevented the top patterns.

The full asset catalog lives in the report, referenced once. No code, no plan, no methodology recap. End with one line naming the first move, then stop.

Complete only when every asset has a verdict, every matrix cell is filled, every deletion and blind spot was re-verified by you, and the repository is unchanged.
