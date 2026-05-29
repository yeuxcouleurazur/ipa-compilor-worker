import StorageWrapper from '../../store/storage-wrapper';
import {
  seedphraseBackedUp,
  setExistingUser,
  setMultichainAccountsIntroModalSeen,
} from '../../actions/user';
import { setCompletedOnboarding } from '../../actions/onboarding';
import {
  HAS_USER_TURNED_OFF_ONCE_NOTIFICATIONS,
  OPTIN_META_METRICS_UI_SEEN,
  PREDICT_GTM_MODAL_SHOWN,
  TRUE,
  USE_TERMS,
} from '../../constants/storage';
import { storePrivacyPolicyClickedOrClosed } from '../../actions/legalNotices';
import { Authentication } from '../../core';
import AUTHENTICATION_TYPE from '../../constants/userProperties';
import { store } from '../../store';
import { setLockTime } from '../../actions/settings';
import {
  DEMO_VAULT_INITIALIZED_KEY,
  DEMO_WALLET_PASSWORD,
} from '../../constants/demoMode';
import { isDemoModeEnabled } from './isDemoModeEnabled';
import { loadDemoConfigIntoStore } from './storage';
import { applyDemoAccountDisplayName } from './accountName';
import { selectDemoAccountDisplayName } from '../../core/redux/slices/demoMode';

/**
 * Crée un coffre démo au premier lancement et marque l'onboarding comme terminé.
 */
export async function applyDemoModeInitialization(): Promise<void> {
  if (!isDemoModeEnabled()) {
    return;
  }

  await loadDemoConfigIntoStore();

  const alreadyInitialized = await StorageWrapper.getItem(
    DEMO_VAULT_INITIALIZED_KEY,
  );

  if (!alreadyInitialized) {
    await Authentication.newWalletAndKeychain(DEMO_WALLET_PASSWORD, {
      currentAuthType: AUTHENTICATION_TYPE.PASSWORD,
    });

    await StorageWrapper.setItem(DEMO_VAULT_INITIALIZED_KEY, 'true');

    store.dispatch(seedphraseBackedUp());
    store.dispatch(storePrivacyPolicyClickedOrClosed());
    store.dispatch(setMultichainAccountsIntroModalSeen(true));
    store.dispatch(setLockTime(-1));
    store.dispatch(setExistingUser(true));
    store.dispatch(setCompletedOnboarding(true));

    await StorageWrapper.setItem(USE_TERMS, TRUE);
    await StorageWrapper.setItem(OPTIN_META_METRICS_UI_SEEN, TRUE);
    await StorageWrapper.setItem(PREDICT_GTM_MODAL_SHOWN, TRUE);
    await StorageWrapper.setItem(
      HAS_USER_TURNED_OFF_ONCE_NOTIFICATIONS,
      TRUE,
    );
  }

  const displayName = selectDemoAccountDisplayName(store.getState());
  applyDemoAccountDisplayName(displayName);
}
