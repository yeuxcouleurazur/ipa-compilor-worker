import StorageWrapper from '../../store/storage-wrapper';
import { DEMO_CONFIG_STORAGE_KEY } from '../../constants/demoMode';
import {
  defaultDemoModeState,
  setDemoConfig,
} from '../../core/redux/slices/demoMode';
import { store } from '../../store';
import type { StoredDemoConfig } from './types';

export async function loadDemoConfigIntoStore(): Promise<void> {
  const raw = await StorageWrapper.getItem(DEMO_CONFIG_STORAGE_KEY);
  if (!raw) {
    store.dispatch(setDemoConfig(defaultDemoModeState));
    return;
  }

  try {
    const parsed = JSON.parse(raw) as StoredDemoConfig;
    store.dispatch(
      setDemoConfig({
        accountDisplayName:
          parsed.accountDisplayName ?? defaultDemoModeState.accountDisplayName,
        tokenBalanceOverrides:
          parsed.tokenBalanceOverrides ??
          defaultDemoModeState.tokenBalanceOverrides,
      }),
    );
  } catch {
    store.dispatch(setDemoConfig(defaultDemoModeState));
  }
}

export async function persistDemoConfig(
  config: StoredDemoConfig,
): Promise<void> {
  await StorageWrapper.setItem(
    DEMO_CONFIG_STORAGE_KEY,
    JSON.stringify(config),
  );
  store.dispatch(setDemoConfig(config));
}
