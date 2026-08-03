# Static enforcement, not style theatre

My larger projects use a layered gate: formatter, ESLint, AST rules, dependency
boundaries and baseline ratchets. The point is not uniform-looking code. The
point is to make architectural decisions executable before review.

This directory contains the portable first layer: ast-grep rules that match
syntax trees rather than text. They survive whitespace, line wrapping and most
refactors that make regex-based checks lie.

## Run

Install [`ast-grep`](https://ast-grep.github.io/) as `sg`, then run from this
repository:

```sh
sg scan --config enforcement/ast-grep/sgconfig.yml --error
```

To adopt the rules in another repository, copy `enforcement/ast-grep/`, adjust
the `files` globs to its domain boundaries, and wire the scan into the local
pre-commit or verification command.

## What is enforced

| Rule | Architectural reason |
|---|---|
| `no-eval` | Dynamic code execution is not an application dispatch mechanism |
| `no-dangerously-set-inner-html` | Rich HTML crosses one reviewed sanitizer component |
| `no-auth-material-in-local-storage` | Browser storage must not become session authority |
| `no-ambient-time-in-domain` | Domain decisions receive an injected clock |
| `no-inline-environment-access` | Configuration is parsed once at the process boundary |
| `no-drizzle-in-domain` | Domain code depends on repository ports, not an ORM |

## The larger pattern

These examples are intentionally small. In production repositories I combine
the same AST layer with:

- a custom, tested ESLint plugin for project vocabulary and semantic rules;
- import/dependency graph checks for package and NestJS boundaries;
- staged-file hooks for fast feedback;
- full local verification before push;
- debt baselines that grandfather known violations but reject every new one.

A baseline is not permission to add debt. It is a monotonic migration device:
the accepted set may shrink, while a new violation fails immediately.

## Escape policy

Do not scatter disable comments. A rule exemption needs a narrow adapter or
approved component whose name communicates why the boundary exists. If a rule
is wrong, change the rule and its tests rather than teaching every caller to
ignore it.
