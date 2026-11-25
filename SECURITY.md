# Security Policy

## Reporting a vulnerability

Do not open a public issue containing personal photos, credentials, user data, or exploit details that could expose users. Report vulnerabilities privately to the project maintainers, including reproduction steps, affected versions, and potential impact.

## Data and credential safety

- Never commit API keys, tokens, passwords, private photos, user wardrobes, or production database files.
- The default demo user and local storage are for development only and are not an authentication system.
- Use HTTPS and managed secrets outside local development.
- AI providers require separate review for data region, retention, training use, deletion, and commercial terms.
- Research-only models must not receive real user photos.

## Native builds

Local Android cleartext traffic is enabled only in the debug manifest. Production builds must use HTTPS and a real identity layer.
