---
---

# Architecture Alternatives

Alternative project structure options. Override in your project's CLAUDE.md by setting `architecture:` to the desired value.

## architecture: layer-based

```text
src/
├── components/     # All UI components
│   ├── ui/         # Primitives (Button, Input, Badge)
│   └── {Name}/     # Feature components
├── hooks/          # Custom hooks / composables
├── services/       # API clients
├── utils/          # Helpers
└── types/          # Shared TypeScript interfaces
```

## architecture: domain-based

```text
src/
├── {domain}/           # e.g., auth/, products/, orders/
│   ├── components/     # Domain-specific components
│   ├── hooks/          # Domain-specific hooks
│   └── services/       # Domain API calls
├── shared/             # Cross-domain utilities
└── components/
    └── ui/             # Shared UI primitives
```
