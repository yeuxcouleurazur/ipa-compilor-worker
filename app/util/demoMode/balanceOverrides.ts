import { toChecksumHexAddress } from '@metamask/controller-utils';
import { getNativeTokenAddress } from '@metamask/assets-controllers';
import type { TokenBalancesControllerState } from '@metamask/assets-controllers';
import { Hex } from '@metamask/utils';
import { toWei } from '../number';
import { isDemoModeEnabled } from './isDemoModeEnabled';
import type { DemoTokenBalanceOverride } from './types';

function displayAmountToHexWei(
  displayAmount: string,
  decimals: number,
): Hex {
  const trimmed = displayAmount.trim();
  if (!trimmed || Number.isNaN(Number(trimmed))) {
    return '0x0' as Hex;
  }

  if (decimals === 18) {
    return `0x${toWei(trimmed, 'ether').toString(16)}` as Hex;
  }

  const [whole = '0', fraction = ''] = trimmed.split('.');
  const paddedFraction = fraction.padEnd(decimals, '0').slice(0, decimals);
  const combined = `${whole}${paddedFraction}`.replace(/^0+/, '') || '0';
  return `0x${BigInt(combined).toString(16)}` as Hex;
}

export function applyDemoTokenBalanceOverrides(
  balances: TokenBalancesControllerState['tokenBalances'],
  overrides: DemoTokenBalanceOverride[],
  accountAddresses: Hex[],
): TokenBalancesControllerState['tokenBalances'] {
  if (!isDemoModeEnabled() || overrides.length === 0) {
    return balances;
  }

  const result = { ...balances };

  for (const address of accountAddresses) {
    const checksummed = toChecksumHexAddress(address) as Hex;
    result[checksummed] = { ...(result[checksummed] ?? {}) };

    for (const override of overrides) {
      const chainId = override.chainId as Hex;
      const tokenAddress = (
        override.isNative
          ? getNativeTokenAddress(chainId)
          : toChecksumHexAddress(override.tokenAddress as Hex)
      ) as Hex;

      result[checksummed][chainId] = {
        ...(result[checksummed][chainId] ?? {}),
      };
      result[checksummed][chainId][tokenAddress] = displayAmountToHexWei(
        override.displayAmount,
        override.decimals,
      );
    }
  }

  return result;
}
