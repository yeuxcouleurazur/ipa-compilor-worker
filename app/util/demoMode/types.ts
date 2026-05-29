import { Hex } from '@metamask/utils';

export interface DemoTokenBalanceOverride {
  /** Chaîne EVM, ex. 0x1 pour Ethereum mainnet */
  chainId: Hex;
  /** Adresse du contrat ; ignoré si isNative */
  tokenAddress?: Hex;
  symbol: string;
  isNative: boolean;
  /** Montant affiché (ex. "1.5" pour 1,5 ETH) */
  displayAmount: string;
  decimals: number;
}

export interface StoredDemoConfig {
  accountDisplayName: string;
  tokenBalanceOverrides: DemoTokenBalanceOverride[];
}
