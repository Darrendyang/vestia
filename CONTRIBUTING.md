# Contributing to Vestia

## Development principles

- Keep recommendations grounded in real user data.
- Never silently substitute fabricated AI output for an unavailable provider.
- Keep research-only models and datasets out of production artifacts.
- Preserve user isolation, consent, deletion, and commercial neutrality.
- Match the existing module boundaries and avoid premature microservices.

## Before submitting changes

Run the relevant checks:

```bash
make api-build
make mobile-analyze
make mobile-build
```

For product-flow changes, also exercise the corresponding real API or application workflow. Compilation alone is not end-to-end verification.

## Dependency review

New dependencies require a license review. AI additions require separate review of code, weights, training data, body assets, provider terms, data retention, and commercial use. Record the version and review outcome with the change.

## Documentation

Contributor-facing documentation is written in English. Update documentation when behavior, API contracts, setup, provider requirements, or roadmap status changes.
