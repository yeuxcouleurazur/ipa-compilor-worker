# Compilation IPA iOS (CI / GitHub Actions)

Les erreurs suivantes signifient que **CocoaPods** et/ou les **sous-modules Git** n’ont pas été installés avant `xcodebuild` :

- `Unable to open ... Pods-MetaMask.release.xcconfig`
- `Unable to load contents of file list: '/Target Support Files/Pods-MetaMask/...'` (`PODS_ROOT` vide)
- `missing file 'Branch.framework'` (sous-module `ios/branch-ios-sdk` absent)

## Ordre obligatoire (sur le runner macOS)

Exécuter depuis la **racine** du dépôt (là où se trouvent `package.json` et `ios/`), pas seulement le dossier `ios/`.

```bash
# 1. Clone complet (Branch SDK = sous-module)
git submodule update --init --recursive

# 2. JavaScript
corepack enable
yarn install --immutable

# 3. Fichiers d’environnement (si absents)
cp -n .js.env.example .js.env 2>/dev/null || true
cp -n .ios.env.example .ios.env 2>/dev/null || true

# 4. Catalogue d’icônes (si outil exige Assets.xcassets)
node scripts/ensure-ios-assets-catalog.mjs

# 5. Ruby / CocoaPods
export BUNDLE_GEMFILE=ios/Gemfile
bundle install --gemfile=ios/Gemfile
echo "" > ios/debug.xcconfig
echo "" > ios/release.xcconfig
echo "export NODE_BINARY=$(command -v node)" > ios/.xcode.env.local
yarn pod:install

# 6. Vérifications avant archive
test -f "ios/Pods/Target Support Files/Pods-MetaMask/Pods-MetaMask.release.xcconfig"
test -d ios/branch-ios-sdk
test -f ios/MetaMask.xcworkspace/contents.xcworkspacedata

# 7. Build — utiliser le WORKSPACE, pas le .xcodeproj seul
cd ios
xcodebuild -workspace MetaMask.xcworkspace \
  -scheme MetaMask \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive -archivePath build/MetaMask.xcarchive
```

Ou depuis la racine : `yarn build:ios:main:prod` (équivalent au script MetaMask officiel).

## Exemple GitHub Actions (extrait)

```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive

- uses: actions/setup-node@v4
  with:
    node-version: '22' # aligner sur .nvmrc du repo

- uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.2.9'
    working-directory: ios
    bundler-cache: true

- name: Install JS and Pods
  run: |
    corepack enable
    yarn install --immutable
    node scripts/ensure-ios-assets-catalog.mjs
    echo "" > ios/debug.xcconfig
    echo "" > ios/release.xcconfig
    echo "export NODE_BINARY=$(command -v node)" > ios/.xcode.env.local
    yarn pod:install

- name: Assert iOS deps
  run: |
    test -f ios/Pods/Target\ Support\ Files/Pods-MetaMask/Pods-MetaMask.release.xcconfig
    test -d ios/branch-ios-sdk/carthage-files

- name: Archive
  run: yarn build:ios:main:prod
```

## Erreurs fréquentes

| Symptôme | Cause | Correctif |
|----------|--------|-----------|
| `Pods-MetaMask.release.xcconfig` introuvable | Pas de `pod install` | `yarn pod:install` après `yarn install` |
| Chemins `/Target Support Files/...` sans `Pods/` | Build via `.xcodeproj` au lieu du `.xcworkspace` | `MetaMask.xcworkspace` |
| `Branch.framework` manquant | Sous-module non cloné | `submodules: recursive` + `git submodule update --init` |
| Repo = ZIP sans `node_modules` / `Pods` | Normal : tout régénérer sur le Mac | Ne pas committer `Pods/`, les recréer en CI |

## Signature / export IPA

L’archive seule ne suffit pas pour un IPA installable : il faut certificats Apple, profil de provisioning, puis `xcodebuild -exportArchive` (ou Fastlane). Voir `ios/fastlane/` et `.github/workflows/build.yml`.
