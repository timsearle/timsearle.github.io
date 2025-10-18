---
layout: post
title: "Theme Stress Test"
date: 2025-03-25 09:00:00 +0000
categories: testing
tags: theme dark-mode mermaid slides
slides: "demystifying-git"
mermaid: true
---

This is a living checklist post to make sure the new light/dark theme looks sharp across real content. It pulls in a few of my favourite components and sprinkles in some code and tables for good measure. If anything looks off in light or dark mode, this is the page to spot it.

## Mermaid Diagram

<div class="mermaid">
  sequenceDiagram
    autonumber
    participant User
    participant Blog
    participant Browser

    User->>+Blog: Request themed page
    Blog-->>+Browser: HTML + CSS + JS
    Browser->>Browser: Match `prefers-color-scheme`
    Browser->>-Blog: Load Mermaid bundle
    Blog-->>-Browser: Mermaid diagrams render with correct theme
    Browser-->>User: Displays diagram that matches site theme
</div>

## Syntax Highlighting

Here’s a quick Ruby snippet showing a timed cache fetch. The goal is to make sure fenced code blocks pick up the right colors in both modes.

```ruby
class CachedFetcher
  EXPIRE_IN = 5.minutes

  def call(key)
    Rails.cache.fetch("stress-test:#{key}", expires_in: EXPIRE_IN) do
      Instrumentation.timed("stress_test.fetch") { yield }
    end
  end
end
```

Inline code like `bundle exec jekyll build` or `color-scheme` should also be readable against the background.

## Blockquote & Lists

> “Design is not just what it looks like and feels like. Design is how it works.” — Steve Jobs

- Light and dark text links [should stand out](#) without being harsh.
- Ordered lists keep the rhythm:
  1. Header stays jet black.
  2. Code blocks adapt.
  3. Slide controls remain readable.

## Table Check

| Component        | What to verify                          | Status |
| ---------------- | --------------------------------------- | ------ |
| Header           | Sticks to black background              | ✅     |
| Mermaid diagrams | Theme changes redraw without flashing   | ✅     |
| Code blocks      | Background, text, and scrollbar blend   | ✅     |
| Slides include   | Buttons, slider, counter contrast well  | ✅     |

If you spot anything questionable, leave a note and I’ll tweak the palette.
