# Mode démo MetaMask Mobile

Ce fork inclut un **mode présentation** : pas d'écran de connexion/inscription, accès direct au portefeuille, soldes simulés en local.

## Comportement

- Au premier lancement, un coffre local est créé automatiquement.
- L'app ouvre directement le portefeuille (pas de Login / Onboarding).
- Les montants affichés peuvent être modifiés sans effet sur la blockchain réelle.

## Panneau caché

1. Ouvrir **Paramètres** → **À propos de MetaMask**
2. Appuyer **7 fois** sur la ligne de version (sous le logo renard)
3. Configurer le nom du compte et les montants des tokens, puis **Enregistrer**

## Désactiver le mode démo

Définir dans l'environnement de build :

```bash
DEMO_MODE=false
```

## Compilation iOS (résumé)

Depuis la racine du dépôt (`metamask-mobile-main`), pas seulement le dossier `ios/` :

```bash
yarn install
yarn setup          # ou yarn setup:expo sur machine limitée
yarn ios:ensure-assets   # si erreur « Assets.xcassets is missing »
cd ios && bundle install && bundle exec pod install
yarn start:ios      # build + lancement local
```

### Erreurs CI : Pods / Branch.framework / xcfilelist

Si le build échoue avec `Pods-MetaMask.release.xcconfig`, `Branch.framework` ou des chemins `/Target Support Files/Pods-...` :

1. Checkout avec **sous-modules** : `submodules: recursive`
2. `yarn install` puis **`yarn pod:install`** (depuis la racine du repo)
3. Compiler avec **`ios/MetaMask.xcworkspace`**, pas `MetaMask.xcodeproj` seul

Guide détaillé : [docs/ios-ipa-ci-setup.md](docs/ios-ipa-ci-setup.md)

### Erreur « Assets.xcassets is missing »

Le projet Xcode utilise `ios/MetaMask/Images.xcassets`, mais certains outils exigent aussi `ios/Assets.xcassets` avec un jeu d’icônes `AppIcon`.

1. Vérifier que `ios/MetaMask/Images.xcassets/AppIcon.appiconset/` contient des fichiers `.png` (sinon : `git lfs pull` après un clone Git).
2. Exécuter : `yarn ios:ensure-assets`
3. Relancer le build / archive IPA.

Fichiers requis :

| Élément | Chemin |
|--------|--------|
| Dépendances JS | `package.json`, `yarn.lock`, `node_modules/` |
| Projet iOS | `ios/Podfile`, `ios/MetaMask.xcodeproj` ou `.xcworkspace` |
| Code app | `app/`, `index.js` |

## Avertissement

Ne pas distribuer cette variante comme MetaMask officiel. Les soldes démo sont **purement visuels** et peuvent induire en erreur si l'app est présentée comme un vrai portefeuille.
