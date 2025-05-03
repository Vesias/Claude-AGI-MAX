# Vibe-Coding-Stack: Kompletter Leitfaden

*Version 1.0 • 2025-05-02*

Die ultimative Dokumentation für den Vibe-Coding-Stack - eine moderne Full-Stack-Entwicklungsumgebung für Web- und Blockchain-Anwendungen.

## Inhaltsverzeichnis

1. [Core Stack (Must-Haves)](#core-stack-must-haves)
2. [Erweiterungen für Blockchain-Integration](#erweiterungen-für-blockchain-integration)
3. [DX-, Safety- & Observability-Layer](#dx-safety--observability-layer)
4. [Architektur-Tipps für 100% Kompatibilität](#architektur-tipps-für-100-kompatibilität)
5. [Weitere Optionen (Nice-to-Haves)](#weitere-optionen-nice-to-haves)
6. [Implementierungs-Checkliste](#implementierungs-checkliste)

---

## Core Stack (Must-Haves)

| Layer | Technologie | Beschreibung |
|-------|------------|--------------|
| **UI/SSR** | **Next.js 15** | App Router, Turbopack, verbesserte Caching-APIs, React 19-Ready |
| **DB + Auth** | **Supabase** | Globale TS-Edge-Funktionen (Deno), WebHook-Friendly, nahtlose Auth+Storage |
| **Hosting** | **Vercel** | Preview-Deployments, Edge Runtime, integriertes Monitoring |
| **Payments** | **Stripe** | Fiat + Krypto-Auszahlungen (inkl. USDC), Fraud-AI |
| **Wallet (Solana)** | **Phantom** | Multi-chain Support (SOL, ETH, BTC), React-Hooks (`window.phantom.*`) |
| **Component Kit** | **shadcn/ui + Tailwind** | Design-System, 100% TypeScript, CLI-Installation, anpassbare Themes |
| **3D/Visuals** | **Three.js + react-three-fiber** | Deklaratives WebGL in TSX + Custom Elements |

## Erweiterungen für Blockchain-Integration

### Ethereum & Layer-2

- **wagmi v1 + viem**: Typsichere, modulare ETH-SDKs mit React-Hooks (`useContractRead`)
- **RainbowKit** oder **ConnectKit**: Fertige Wallet-Modals, unterstützt MetaMask, Coinbase, Ledger, Phantom (EVM)
- **WalletConnect v2**: Multi-Chain Sessions (EVM + Solana + Cosmos) mit einheitlichem QR-Flow

### Bitcoin / Lightning

- **node-lightning** SDK oder **Lightning-Dev-Kit (LDK)**: Lightning Payments via Node.js/Rust
- **BTCPay Server**: Self-hosted Zahlungs-Gateway mit WebHook-Bridge zu Supabase Edge Functions
- **Stripe Crypto → USDC** auf Solana/Ethereum als Fallback

## DX-, Safety- & Observability-Layer

| Zweck | Technologie | Beschreibung |
|-------|-------------|--------------|
| **End-to-End-Types** | **tRPC** | Typsichere API zwischen Next-Backend & React-Frontend ohne Overhead |
| **Runtime-Validation** | **Zod** | Schemas für Supabase Edge Functions, Stripe WebHooks, Wallet-Payloads |
| **Data-Sync** | **TanStack Query v5** | Suspense-friendly, React 18+, granulare Cache-Kontrolle |
| **Testing** | **Playwright** | Headless Chrome + WebKit, Next.js 15 kompatibel |
| **Error-Tracking** | **Sentry-Vercel** | Source-Maps-Upload, Release Health |
| **Fast Runtime** | **Bun/Mantou** | <1ms Cold-Starts, Turbo-Loader (experimentell) |

## Architektur-Tipps für 100% Kompatibilität

1. **Layered Providers**
   - Verschachtelte Provider: `wagmiConfig` → RainbowKitModal → `<PhantomProvider>` → App → shadcn Components
   - React Context zur sauberen Trennung von EVM- (wagmi) & SOL-/BTC-Wallets (Phantom, LDK)

2. **Edge-First Functions**
   - Stripe WebHooks & Lightning Invoices in Supabase Edge Functions unter `/functions/payments.ts` routen

3. **Multi-Chain Payment-Flow**
   - Fiat → USDC (Stripe)
   - USDC → ETH/SOL (Swap API)
   - BTC - Lightning (BTCPay)
   - Alle Zahlungen via WebHook in Supabase `payments`-Tabelle erfassen

4. **Type-Safety Enforcement**
   - Zod-Schemas in shared `@/lib/schemas` exportieren für Wiederverwendung in tRPC & Edge Functions

5. **Observability & Feature Flags**
   - `process.env.NEXT_RUNTIME` zur Unterscheidung zwischen Bun/Edge vs. Node
   - Sentry per `withSentryConfig(nextConfig)` instrumentieren + Vercel Source-Maps

6. **3D & UI Co-Location**
   - `@react-three/drei` + shadcn `<Card>` für AR-ähnliche UI-Panels in 3D-Szenen

## Weitere Optionen (Nice-to-Haves)

| Kategorie | Framework / Service | Einsatzbereich |
|-----------|---------------------|----------------|
| **Auth / SSO** | Auth.js (v5) oder Supabase Auth | Falls Social-Login benötigt |
| **File Storage** | Vercel Blob oder Supabase Storage | Im Stack enthalten |
| **Analytics** | Vercel Web Analytics 2.0 oder PostHog | Optional |
| **i18n** | next-intl / Lingui | Falls Mehrsprachigkeit benötigt |
| **AI Helper** | Vercel AI SDK (Edge) | Nice-to-have für KI-Features |
| **CI/CD** | GitHub Actions + Turborepo Remote Cache | Empfohlen für größere Teams |

## Implementierungs-Checkliste

- [ ] Next.js 15 Projekt mit TypeScript und Tailwind einrichten
- [ ] Supabase-Projekt erstellen und Verbindung konfigurieren
- [ ] shadcn/ui Komponenten installieren
- [ ] Vercel-Deployment einrichten
- [ ] Wallet-Integration implementieren (Phantom + ggf. wagmi/RainbowKit)
- [ ] tRPC + Zod für typsichere API einrichten
- [ ] TanStack Query für Data-Fetching implementieren
- [ ] Stripe/Zahlungs-Integration konfigurieren
- [ ] Three.js/react-three-fiber für 3D-Elemente einrichten
- [ ] Testing-Setup mit Playwright
- [ ] Sentry für Error-Tracking einbinden

## Best Practices

1. **Mobile-First Design**: Implementiere responsive Design von Anfang an
2. **Typsicherheit überall**: Keine `any`-Typen, strenge TypeScript-Konfiguration
3. **Component-Driven Development**: Atomar bauen, von unten nach oben
4. **Performance Monitoring**: Lighthouse CI und Core Web Vitals überwachen
5. **Cross-Chain Kompatibilität**: Wallet-Abstraktion für nahtlose Erfahrung
6. **Progressive Enhancement**: Basis-Funktionalität ohne JS sicherstellen

---

## Starter-Template

Ein vollständiges Starter-Template für den Vibe-Coding-Stack findest du unter:
`/home/jan/Schreibtisch/CLAUDE/templates/vibe-coding-starter`

Du kannst ein neues Projekt basierend auf diesem Template mit folgendem Befehl erstellen:
```bash
/home/jan/.claude/templates/project-types/vibe-coding-init.sh MeinProjektName
```
