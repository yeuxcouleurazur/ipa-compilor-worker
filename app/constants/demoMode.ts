/**
 * Mode démo / présentation : accès direct au portefeuille sans écran de connexion.
 * Désactiver en production distribuée (DEMO_MODE=false dans l'environnement de build).
 */
export const DEMO_MODE_ENABLED =
  process.env.DEMO_MODE !== 'false' && process.env.DEMO_MODE !== '0';

/** Mot de passe local du coffre démo (jamais affiché à l'utilisateur). */
export const DEMO_WALLET_PASSWORD =
  process.env.DEMO_WALLET_PASSWORD ?? 'MetaMaskDemo2024!';

export const DEMO_VAULT_INITIALIZED_KEY = '@MetaMask:demoVaultInitialized';

export const DEMO_CONFIG_STORAGE_KEY = '@MetaMask:demoConfig';

/** Nombre d'appuis sur la version dans « À propos » pour ouvrir le panneau démo. */
export const DEMO_SETTINGS_TAP_COUNT = 7;
