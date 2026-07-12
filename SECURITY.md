# Security Policy

## Supported Versions

Only the latest release of SkyPulse is actively supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0.0 | :x:                |

---

## Reporting a Vulnerability

**Please do not open public issues for security vulnerabilities.**

If you discover a security vulnerability in this project, please report it privately:
1. Go to the [SkyPulse repository on GitHub](https://github.com/Amayyas/SkyPulse).
2. Click on the **Security** tab.
3. Under **Vulnerability reporting**, click **Report a vulnerability** to submit your report privately.

Alternatively, you can email security reports to **amayyas.dev@gmail.com**.

### Expected Response Time
We will acknowledge receipt of your report within 48 hours and provide a follow-up detailing the next steps within 7 days.

---

## Known & Accepted Limitations

> [!WARNING]
> **Client-Side API Key Exposure**
> Like most client-only Flutter applications connecting directly to third-party APIs, the OpenWeatherMap API key is packaged into the compiled client binary. 
> 
> Anyone with access to the client builds can decompile/extract this API key or intercept requests via a proxy. 
> - This is a **known and accepted design limitation** of the client-side architecture.
> - The API key used is on the **free tier** of OpenWeatherMap, representing minimal financial value and posing no threat to user private data.
> - Reports regarding the extractability of this key will be marked as accepted risks and will not be treated as actionable security vulnerabilities.

---

## Scope

### Out of Scope
The following issues are considered out of scope and do not constitute security vulnerabilities:
- Extraction of the client-side OpenWeatherMap API key (as noted above).
- Attacks requiring physical access to a rooted/jailbroken device.
- Standard dependency updates (unless a CVE is actively exploitable in our codebase).
