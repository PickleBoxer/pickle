---
name: benchmark-checklist
description: Vets a performance number (limiter, tuning, limits, errors, repeatability, relevance, whether the work ran) before it is reported or acted on. Use when a pickle playbook step names benchmark-checklist, or when running a benchmark, comparing two options on speed, or reporting a speedup or regression that was measured.
argument-hint: "[claim or measurement command]"
metadata:
  upstream: pstack/skills/benchmark-checklist
  upstream-version: 0.15.24
---

# Benchmark checklist

Measurement: $ARGUMENTS

Use this for every performance number: a before and after, a regression claim, a hillclimb harness, or a choice between libraries or configs. Answer each question with evidence from a run, not a guess from the code.

For a quick ballpark the user asked for, one run is enough. Still check questions 4 and 7, and say it is one run. Skip the rest unless that run looks wrong. A choice between options is never a ballpark.

## Before you run anything

- Write down the claim you expect to make, in the words you would ship ("export is 30% faster at p50 on the 60k-row dataset"). The questions test that sentence.
- Read the measurement script. Note what it times, counts and ignores.
- Check the load average (`uptime`) and the core count (`nproc` on Linux, `sysctl -n hw.ncpu` on macOS). If the machine is busy, find out what runs. If you cannot stop it, interleave the sides so both see the same noise, and say so in the report.

## The questions

1. **Why not double?** Name the limiter. Profile in a run you do not report, because profilers and tracers slow the work down. Use CPU per process, the stack's own profiler, I/O wait and syscall counts, then map the hot spot to source. Watch the load generator too: if it saturates first, you measured the load generator. If a change did not move the number, the limiter explains why, so find it before you call the change useless.
2. **Was it tuned?** Run every side the way production runs it: release builds, production flags and env, batching and transaction settings, connection pools, caches as warm or cold as production sees them, the same versions and data. If one side runs on defaults, you compared configurations, not implementations. A limiter that is a setting (a commit per row, a debug build, a missing index) means that side is untuned. Tune it and measure again before you pick a winner. If you cannot tune it, pick no winner from that run. When the user is choosing what to adopt, narrowing the claim to the code as it ships today does not fix this: they adopt the option, not today's settings.
3. **Did it break limits?** Do the arithmetic. Compare bytes per second with disk and network bandwidth, operations per second times cost per operation with your cores, and the time saved with the time the changed piece took. Removing a piece that takes 10% of the run makes the run at most about 11% faster. A result past a limit measured something other than the work: a cache, a no-op or a bug.
4. **Did it error?** Count failures and non-success responses, and check that outputs are correct, not just present. Rejections are often fast; timeouts and retries are slow. If the script counts no errors, add the count.
5. **Does it reproduce?** Run each side at least 5 times, alternating (A, B, A, B) so warmup, lazy initialization, caches and drift favour neither. Report the median and range. A gap smaller than the run-to-run spread is no measurable difference. When the call is close, use a rank-sum test or the harness's own statistics.
6. **Does it matter?** Next to any micro result, measure the end-to-end path a user waits on, with realistic data sizes and concurrency, and report the micro result as a share of the whole. A helper that takes 1% of a request makes the request at most 1% faster, however fast the helper gets.
7. **Did it even happen?** Confirm the work ran inside the timed region: the request reached the server, the rows were written, the bytes were read, the code used the result. Lazy code (unconsumed iterators, unawaited async work, results the compiler can discard) and timeouts produce numbers for work that never happened.

## Report

- Lead with the verdict: faster, slower, no measurable difference, or inconclusive.
- Give the number with its unit, the run count, the range and the limiter. For example: "p50 41 ms to 33 ms, median of 7 runs per side, range 32 to 35 ms after, bound by JSON parsing on one core."
- Call the verdict inconclusive when you claim a difference but cannot name the limiter, when a side ran untuned, or when you could not check questions 4 and 7. Name the gap.
- A PR body gets one primary number. Put the runs, range and limiter evidence in a linked notes file.
