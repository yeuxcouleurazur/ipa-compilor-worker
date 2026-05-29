import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { createSelector } from 'reselect';
import { RootState } from '../../../../reducers';
import type { DemoTokenBalanceOverride } from '../../../util/demoMode/types';

export interface DemoModeState {
  accountDisplayName: string;
  tokenBalanceOverrides: DemoTokenBalanceOverride[];
  configLoaded: boolean;
}

export const defaultDemoModeState: DemoModeState = {
  accountDisplayName: 'Compte Démo',
  tokenBalanceOverrides: [
    {
      chainId: '0x1',
      symbol: 'ETH',
      isNative: true,
      displayAmount: '2.5',
      decimals: 18,
    },
    {
      chainId: '0x1',
      tokenAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      symbol: 'USDC',
      isNative: false,
      displayAmount: '1250.00',
      decimals: 6,
    },
  ],
  configLoaded: false,
};

const slice = createSlice({
  name: 'demoMode',
  initialState: defaultDemoModeState,
  reducers: {
    setDemoConfig: (state, action: PayloadAction<Partial<DemoModeState>>) => {
      if (action.payload.accountDisplayName !== undefined) {
        state.accountDisplayName = action.payload.accountDisplayName;
      }
      if (action.payload.tokenBalanceOverrides !== undefined) {
        state.tokenBalanceOverrides = action.payload.tokenBalanceOverrides;
      }
      state.configLoaded = true;
    },
    resetDemoConfig: () => defaultDemoModeState,
  },
});

export const { setDemoConfig, resetDemoConfig } = slice.actions;
export default slice.reducer;

export const selectDemoModeState = (state: RootState) => state.demoMode;

export const selectDemoAccountDisplayName = createSelector(
  selectDemoModeState,
  (demo) => demo.accountDisplayName,
);

export const selectDemoTokenBalanceOverrides = createSelector(
  selectDemoModeState,
  (demo) => demo.tokenBalanceOverrides,
);

export const selectDemoConfigLoaded = createSelector(
  selectDemoModeState,
  (demo) => demo.configLoaded,
);
