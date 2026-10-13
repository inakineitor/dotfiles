---
name: react-component-organization
description: Folder layout and coding conventions for React components. Use when creating, moving, splitting, or refactoring React components, adding subcomponents, hooks, contexts, or component-scoped utilities, writing React imports, or defining custom error classes in a React/TypeScript codebase.
---

# React component organization

## Folder structure

Organize non-trivial React components as follows:

```text
react-component-name/
  index.tsx
  components/
    simple-sub-component.tsx
    complex-sub-component/
  lib/
    some-util-file.ts
  contexts/
    some-context.tsx
  hooks/
    some-hook.ts
```

- `index.tsx` is the component's public entry point.
- `components/` contains subcomponents used only by this component. Simple subcomponents can be single files. Complex subcomponents follow the same structure recursively.
- `lib/` contains utilities scoped to this component.
- `contexts/` contains React contexts scoped to this component.
- `hooks/` contains hooks scoped to this component.
- A context, its provider component, and its consumption hook must live together in the same context file.
- Follow the repository-wide hook and component split, single-return component pattern, absolute-import rule, and prohibition on inline SVG.

## React imports

- Import React runtime values directly. For example, use `import { useEffect } from "react";` and call `useEffect(...)`.
- Import the React namespace as a type-only default import for types. For example, use `import type React from "react";` with `React.ComponentProps`, `React.ReactNode`, and `React.PointerEvent`.

## Error classes

- Custom error constructors must accept an optional `ErrorOptions` object as their second and final argument and pass it to `super`.
