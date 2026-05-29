#!/usr/bin/env node
/**
 * MetaMask iOS uses MetaMask/Images.xcassets in Xcode, but some tools
 * (Expo prebuild, repack, EAS) expect ios/Assets.xcassets with AppIcon.
 * This script mirrors the icon catalog when Assets.xcassets is missing.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(__dirname, '..');
const iosDir = path.join(repoRoot, 'ios');
const sourceCatalog = path.join(iosDir, 'MetaMask', 'Images.xcassets');
const targetCatalog = path.join(iosDir, 'Assets.xcassets');
const appIconSource = path.join(sourceCatalog, 'AppIcon.appiconset');
const appIconTarget = path.join(targetCatalog, 'AppIcon.appiconset');

function copyRecursive(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function main() {
  if (!fs.existsSync(sourceCatalog)) {
    console.error(
      `✗ Fatal error: ${sourceCatalog} is missing. Clone the full MetaMask repo (with ios/MetaMask/Images.xcassets).`,
    );
    process.exit(1);
  }

  if (!fs.existsSync(appIconSource)) {
    console.error(
      `✗ Fatal error: AppIcon.appiconset is missing in Images.xcassets.`,
    );
    process.exit(1);
  }

  const iconPngCount = fs
    .readdirSync(appIconSource)
    .filter((name) => name.endsWith('.png')).length;

  if (iconPngCount === 0) {
    console.error(
      `✗ Fatal error: No PNG files in AppIcon.appiconset. Run: git lfs pull`,
    );
    console.error(
      '  (Icons are often stored with Git LFS in the official repository.)',
    );
    process.exit(1);
  }

  if (fs.existsSync(targetCatalog)) {
    const targetIconCount = fs.existsSync(appIconTarget)
      ? fs.readdirSync(appIconTarget).filter((n) => n.endsWith('.png')).length
      : 0;
    if (targetIconCount > 0) {
      console.log(`✓ ${targetCatalog} already exists with icons.`);
      return;
    }
    fs.rmSync(targetCatalog, { recursive: true, force: true });
  }

  fs.mkdirSync(targetCatalog, { recursive: true });
  fs.writeFileSync(
    path.join(targetCatalog, 'Contents.json'),
    JSON.stringify(
      {
        info: { author: 'xcode', version: 1 },
      },
      null,
      2,
    ),
  );
  copyRecursive(appIconSource, appIconTarget);

  console.log(
    `✓ Created ${targetCatalog} with AppIcon.appiconset (${iconPngCount} PNG files).`,
  );
}

main();
