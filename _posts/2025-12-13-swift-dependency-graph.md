---
layout: post
lang: en
author: "Tim Searle"
title: "swift-dependency-graph"
date: "2025-12-13 00:00:00"
tags:
  - "swift"
  - "ios"
  - "xcode"
  - "tooling"
---

I’ve just open sourced a small tool called [`swift-dependency-graph`](https://github.com/timsearle/swift-dependency-graph). This was coded completely via [copilot-cli](https://github.com/features/copilot/cli), including publishing this blog post!

Given the root of an iOS app, it builds a dependency graph across Xcode targets and SwiftPM packages, and can export it in a few formats (including an interactive HTML graph).

If you want to try it out:

```bash
git clone https://github.com/timsearle/swift-dependency-graph
cd swift-dependency-graph
swift run swift-dependency-graph --help
```

It’s still early, and I’m mostly interested in correctness and good fixtures — if you run it on a real project and spot gaps, I’d love an issue (or a PR).
