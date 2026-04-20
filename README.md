# Claude Code StatusLine: Token & Cost Monitor

A lightweight, real-time telemetry status line for Claude Code CLI.

Track token usage, cost, cache efficiency, and API limits directly in your terminal — with zero overhead and clean visual feedback.

---

## Overview

Claude Code StatusLine: Token & Cost Monitor transforms the default Claude Code status line into a compact observability layer for your sessions.

Instead of guessing what's happening under the hood, you get immediate insight into:

- Context window utilization  
- Token consumption  
- Cost per session  
- Cache behavior (read vs write)  
- API rate limits  
- Execution time  
- Current Git branch  

All rendered in a single, readable line.

---

## Features

- Real-time context usage bar (visual + percentage)
- Token tracking (input + output combined)
- Cost monitoring in USD
- Cache state detection:
  - ⚡ Active cache usage
  - 💰 Cache warming
  - 💎 High-efficiency reuse
- API rate limit tracking (5h window)
- Execution duration (ms → human-readable)
- Git branch detection
- Zero dependencies beyond `jq` and `bash`
- Fully terminal-native (no external services)

---

## Example Output

```bash
[Opus 4.7] 📁 project-dir | ███████░░░ 73% | $0.42 | 145k/200k | ⚡ CACHE IN USE | ⏳ API: 35% | ⏱️ 2m 14s
```

---

## Installation

```bash
mkdir -p ~/.claude
nano ~/.claude/statusline.sh
```

Paste the script and make it executable:

```bash
chmod +x ~/.claude/statusline.sh
```

---

## Configuration

Add this to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

---

## Requirements

- bash
- jq
- Claude Code CLI

---

## How It Works

The script reads JSON input from Claude Code via stdin and extracts telemetry fields using `jq`.

It then:
1. Aggregates token usage
2. Computes context window percentage
3. Builds a visual progress bar
4. Detects cache behavior
5. Formats everything into a single status line

No background processes. No polling. No latency.

---

## Design Philosophy

- **Zero friction** — install in seconds  
- **High signal** — no noise, only actionable metrics  
- **Terminal-first** — built for developers, not dashboards  
- **Stateless** — no storage, no tracking, no side effects  

---

## Why This Exists

Claude Code exposes a lot of useful runtime data — but it's buried in JSON.

This tool surfaces that data where it matters: directly in your workflow.

---

## Roadmap

- Configurable thresholds (colors, limits)
- Multi-line expanded view (optional mode)
- Per-request cost breakdown
- Plugin hooks for custom metrics

---

## Contributing

PRs are welcome. Keep it simple, fast, and dependency-free.

---

## License

MIT
