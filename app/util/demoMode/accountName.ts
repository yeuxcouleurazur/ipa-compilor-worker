import Engine from '../../core/Engine';
import { selectSelectedInternalAccount } from '../../selectors/accountsController';
import { store } from '../../store';

export function applyDemoAccountDisplayName(displayName: string): void {
  const state = store.getState();
  const account = selectSelectedInternalAccount(state);
  if (!account?.id || !displayName.trim()) {
    return;
  }

  const { AccountsController } = Engine.context;
  AccountsController.setAccountName(account.id, displayName.trim());
}
