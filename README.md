# GhostWallet — Phantom Wallet Demo Clone (Swift / SwiftUI)

> ⚡ **APPLICATION DÉMO** — Toutes les données sont fictives. Aucune vraie cryptomonnaie n'est impliquée.

## Structure du projet

```
PhantomWallet/
│
├── Package.swift                        ← Swift Package Manager
├── MyApp.xcodeproj/
│   └── project.pbxproj                 ← Fichier Xcode projet
│
└── MyApp/
    ├── App.swift                        ← Point d'entrée @main
    ├── ContentView.swift                ← Navigation principale + TabBar
    ├── Models.swift                     ← Modèles de données + ViewModel
    │
    ├── HomeView.swift                   ← Écran principal (balance + tokens)
    ├── ActivityView.swift               ← Historique transactions
    ├── SwapView.swift                   ← Échange de tokens
    ├── CollectiblesView.swift           ← Galerie NFTs
    ├── SettingsView.swift               ← Paramètres
    │
    ├── TokenDetailView.swift            ← Détail token + graphique
    ├── SendView.swift                   ← Envoi de crypto
    ├── ReceiveView.swift                ← QR Code réception
    ├── BuyView.swift                    ← Achat de crypto
    │
    ├── Info.plist
    └── Assets.xcassets/
        ├── AppIcon.appiconset/
        └── AccentColor.colorset/
```

## Fonctionnalités reproduites

### Écran principal (HomeView)
- ✅ En-tête wallet avec nom et sélecteur de compte
- ✅ Balance totale en USD avec animation d'apparition
- ✅ Variation 24h (montant + pourcentage avec badge coloré)
- ✅ Boutons d'action : Send / Swap / Receive / Buy
- ✅ Card "Cash Balance" avec bouton "Add Cash"
- ✅ Liste des tokens avec icônes, soldes et variations
- ✅ Badge de vérification violet sur chaque token
- ✅ Animations d'entrée en cascade (staggered)

### Tokens inclus
- Bitcoin (BTC) — Orange `#F7931A`
- Solana (SOL) — Gradient violet/vert `#9945FF → #14F195`
- Ethereum (ETH) — Bleu `#627EEA`
- Monad (MON) — Violet `#836EF9`
- USDC — Bleu `#2775CA`

### Navigation (TabBar personnalisé)
- 🏠 Home
- 🕐 Activity (filtres par type)
- 🔄 Swap (avec slippage, champs interactifs)
- 🖼️ Collectibles (grille NFT)
- 👤 Settings

### Fonctionnalités interactives
- **Send** : sélecteur de token, adresse destinataire, montant, frais réseau, écran de succès
- **Receive** : QR Code généré procéduralement, sélecteur de réseau, copie d'adresse
- **Swap** : inversion des tokens animée, aperçu du taux, slippage configurable
- **Buy** : montants rapides, montant custom, méthode de paiement, aperçu tokens reçus
- **Token Detail** : graphique animé (courbe SVG), périodes 1D/1W/1M/3M/1Y/ALL
- **Demo Banner** : bannière "MODE DÉMO" dismissable en haut de l'écran

## Prérequis

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Installation

### Option A — Ouvrir avec Xcode
```bash
open PhantomWallet/MyApp.xcodeproj
```
Puis **⌘R** pour lancer sur simulateur.

### Option B — Swift Package Manager
```bash
cd PhantomWallet
swift build
```

## Design System

| Élément            | Valeur                  |
|--------------------|-------------------------|
| Background         | `#1A1A1A`               |
| Card background    | `#232323`               |
| Accent violet      | `#AB9FF2`               |
| Accent violet foncé| `#7C5CFC`               |
| Vert positif       | `#3DD68C`               |
| Rouge négatif      | `#FF6464`               |
| Texte secondaire   | `#6B6B6B`               |
| Police             | SF Pro (système iOS)    |

## Note légale

Cette application est une **reproduction à titre éducatif et de démonstration** de l'interface Phantom Wallet. Elle ne permet aucune transaction réelle. Toutes les données affichées (soldes, tokens, transactions) sont entièrement fictives.
