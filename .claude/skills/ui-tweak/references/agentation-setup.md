# Agentation Setup Reference

## Overview

Agentation is a **React 18+ npm package** (not a browser extension) that enables visual annotation feedback.
Users add `<Agentation />` to their app, annotate UI elements in the browser, and AI receives structured context
(selector, component tree, styles, a11y info, intent/severity) to fix the code.

**License:** PolyForm Shield 1.0.0 — free for internal/personal use, commercial license required for competitors.

## Install

```bash
npm install agentation -D
```

## Add Component

Add the `<Agentation />` component to your app root (dev only):

```tsx
import { Agentation } from 'agentation';

// Inside your root component (e.g., App.tsx)
{import.meta.env.DEV && <Agentation endpoint="http://localhost:4747" />}
```

## MCP Setup

### Option A: Auto-init

```bash
npx agentation-mcp init
```

This adds the server entry to `.mcp.json` and configures Claude Code settings.

### Option B: Manual

Add to `.mcp.json`:

```json
"agentation": {
  "command": "npx",
  "args": ["-y", "agentation-mcp", "server"]
}
```

Add `"agentation"` to `enabledMcpjsonServers` in `.claude/settings.json`.

## Start Server

```bash
npx agentation-mcp server
```

## Verify

```bash
npx agentation-mcp doctor
```

Expected: MCP server reachable, Agentation component detected in running app.

## Vue Limitation

React projects get **full component hierarchy** detection (`reactComponents` field in annotation data).
Vue projects receive **DOM selectors and CSS classes only** — no `.vue` file mapping from component tree.
CSS/layout fixes still work; component-level refactoring requires manual file identification.

## Annotation Data Shape (Key Fields)

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique annotation ID |
| `selector` | `string` | CSS selector of annotated element |
| `elementPath` | `string[]` | DOM path from root to element |
| `reactComponents` | `string[]` | React component hierarchy (empty for Vue) |
| `cssClasses` | `string[]` | Applied CSS classes |
| `computedStyles` | `object` | Relevant computed styles snapshot |
| `a11y` | `object` | Accessibility info (role, aria-*, tab index) |
| `intent` | `"fix" \| "change" \| "question" \| "approve"` | User's desired action |
| `severity` | `"blocking" \| "major" \| "minor" \| "suggestion"` | Issue severity |
| `comment` | `string` | User's free-text description |
| `screenshot` | `string` | Base64 screenshot of annotated area |
