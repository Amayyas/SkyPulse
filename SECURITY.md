# Security Policy

## Supported versions

SkyPulse has **not been released yet**. There are no tags, no published builds
and no version anyone can install
([#33](https://github.com/Amayyas/SkyPulse/issues/33),
[#34](https://github.com/Amayyas/SkyPulse/issues/34)).

Until a first release exists, `main` is the only supported code, and security
fixes land there.

This section will get a real version table when there is something to put in it.

## Reporting a vulnerability

**Please do not open a public issue for a security vulnerability.**

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/Amayyas/SkyPulse/security).
2. Click **Report a vulnerability**.

This opens a private advisory visible only to the maintainer. It is the
preferred channel — it keeps the report confidential and gives us a place to
coordinate a fix and credit you.

If GitHub's private reporting is unavailable to you, email
**amayyas.aouadene@epitech.eu**.

### What to expect

This is a side project maintained by one person, so let us be honest rather than
promise a response time we cannot keep: expect an acknowledgement **within a
week**. If a report is valid and serious, fixing it takes priority over
everything else on the board.

Please include enough detail to reproduce the issue — the platform, the steps,
and what you observed.

## Known and accepted limitations

### The OpenWeatherMap API key is embedded in the client

SkyPulse talks to OpenWeatherMap directly from the app, with no backend in
between. That means any build we eventually distribute will carry the API key
inside the binary, where it can be extracted by decompiling the app or by
intercepting its traffic with a proxy.

This is inherent to a client-only architecture. It is not a bug we can fix by
obfuscating the key better — the only real fix is to proxy requests through a
server that holds the key, which is out of scope for now.

We accept the risk deliberately, because:

- the key is on OpenWeatherMap's **free tier**, so it has negligible financial value;
- it grants access to **public weather data only** — no user data, no account
  data, nothing private;
- the worst realistic outcome is quota exhaustion, which degrades the app and
  affects nobody else.

**Reports whose only finding is "the API key can be extracted from the app" will
be closed as accepted risk.** We already know.

(Related: [#26](https://github.com/Amayyas/SkyPulse/issues/26) tracks moving the
key out of tracked source and into build-time injection. That prevents the key
from being *committed by accident*. It does not — and cannot — prevent it from
being extracted from a shipped binary. We would rather say that plainly than
imply a security property we do not have.)

## Out of scope

- Extraction of the client-side OpenWeatherMap key (see above).
- Attacks requiring physical access to an unlocked, rooted or jailbroken device.
- Vulnerabilities in dependencies with no demonstrated exploit path through
  SkyPulse's own code. Report those upstream; we will pick up the fix via
  Dependabot.
- Findings from automated scanners submitted without a working proof of concept.

## In scope

Anything that lets an attacker reach a user's device or data through SkyPulse.
For an app of this shape, the realistic candidates are:

- injection through unsanitised API responses rendered in the UI;
- the app's handling of network traffic, including TLS
  ([#3](https://github.com/Amayyas/SkyPulse/issues/3) — the geocoding endpoint
  currently uses cleartext HTTP, which is a real, open finding);
- misuse or leakage of location data;
- anything that turns a hostile API response into code execution or a crash loop.

If you are unsure whether something qualifies, report it privately and we will
work it out together.
