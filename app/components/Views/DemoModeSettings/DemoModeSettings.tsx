import React, { useCallback, useState } from 'react';
import {
  Alert,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useSelector } from 'react-redux';
import HeaderCompactStandard from '../../../component-library/components-temp/HeaderCompactStandard';
import { useTheme } from '../../../util/theme';
import { fontStyles } from '../../../styles/common';
import {
  selectDemoAccountDisplayName,
  selectDemoTokenBalanceOverrides,
} from '../../../core/redux/slices/demoMode';
import { persistDemoConfig } from '../../../util/demoMode/storage';
import { applyDemoAccountDisplayName } from '../../../util/demoMode/accountName';
import type { DemoTokenBalanceOverride } from '../../../util/demoMode/types';
import { isDemoModeEnabled } from '../../../util/demoMode/isDemoModeEnabled';

const DemoModeSettings = () => {
  const { colors } = useTheme();
  const navigation = useNavigation();
  const savedName = useSelector(selectDemoAccountDisplayName);
  const savedOverrides = useSelector(selectDemoTokenBalanceOverrides);

  const [accountName, setAccountName] = useState(savedName);
  const [tokens, setTokens] = useState<DemoTokenBalanceOverride[]>(
    savedOverrides,
  );

  const styles = StyleSheet.create({
    wrapper: {
      flex: 1,
      backgroundColor: colors.background.default,
    },
    content: {
      padding: 16,
      gap: 16,
    },
    label: {
      ...fontStyles.normal,
      color: colors.text.default,
      marginBottom: 6,
    },
    hint: {
      ...fontStyles.normal,
      color: colors.text.alternative,
      fontSize: 13,
      marginBottom: 12,
    },
    input: {
      borderWidth: 1,
      borderColor: colors.border.muted,
      borderRadius: 8,
      padding: 12,
      color: colors.text.default,
      backgroundColor: colors.background.alternative,
      marginBottom: 12,
    },
    tokenCard: {
      borderWidth: 1,
      borderColor: colors.border.muted,
      borderRadius: 12,
      padding: 12,
      marginBottom: 12,
    },
    saveButton: {
      backgroundColor: colors.primary.default,
      borderRadius: 12,
      padding: 16,
      alignItems: 'center',
      marginTop: 8,
    },
    saveButtonText: {
      ...fontStyles.normal,
      color: colors.primary.inverse,
      fontWeight: '600',
    },
    addButton: {
      padding: 12,
      alignItems: 'center',
    },
    addButtonText: {
      color: colors.primary.default,
      ...fontStyles.normal,
    },
  });

  const updateToken = useCallback(
    (index: number, patch: Partial<DemoTokenBalanceOverride>) => {
      setTokens((prev) =>
        prev.map((item, i) => (i === index ? { ...item, ...patch } : item)),
      );
    },
    [],
  );

  const addToken = useCallback(() => {
    setTokens((prev) => [
      ...prev,
      {
        chainId: '0x1',
        symbol: 'TOKEN',
        isNative: false,
        tokenAddress: '0x0000000000000000000000000000000000000000',
        displayAmount: '0',
        decimals: 18,
      },
    ]);
  }, []);

  const onSave = useCallback(async () => {
    await persistDemoConfig({
      accountDisplayName: accountName,
      tokenBalanceOverrides: tokens,
    });
    applyDemoAccountDisplayName(accountName);
    Alert.alert(
      'Mode démo',
      'Paramètres enregistrés. Revenez au portefeuille pour voir les changements.',
    );
  }, [accountName, tokens]);

  if (!isDemoModeEnabled()) {
    return null;
  }

  return (
    <SafeAreaView style={styles.wrapper} edges={{ bottom: 'additive' }}>
      <HeaderCompactStandard
        title="Configuration démo"
        onBack={() => navigation.goBack()}
      />
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.hint}>
          Panneau réservé aux démonstrations. Les soldes affichés sont simulés
          localement et ne reflètent pas la blockchain.
        </Text>

        <Text style={styles.label}>Nom du compte</Text>
        <TextInput
          style={styles.input}
          value={accountName}
          onChangeText={setAccountName}
          placeholder="Compte Démo"
          placeholderTextColor={colors.text.alternative}
        />

        <Text style={styles.label}>Cryptomonnaies (montants affichés)</Text>
        {tokens.map((token, index) => (
          <View key={`${token.symbol}-${index}`} style={styles.tokenCard}>
            <TextInput
              style={styles.input}
              value={token.symbol}
              onChangeText={(symbol) => updateToken(index, { symbol })}
              placeholder="Symbole (ETH, USDC…)"
              placeholderTextColor={colors.text.alternative}
            />
            <TextInput
              style={styles.input}
              value={token.displayAmount}
              onChangeText={(displayAmount) =>
                updateToken(index, { displayAmount })
              }
              placeholder="Montant"
              keyboardType="decimal-pad"
              placeholderTextColor={colors.text.alternative}
            />
            <TextInput
              style={styles.input}
              value={token.chainId}
              onChangeText={(chainId) =>
                updateToken(index, { chainId: chainId as DemoTokenBalanceOverride['chainId'] })
              }
              placeholder="Chain ID (ex. 0x1)"
              placeholderTextColor={colors.text.alternative}
            />
            {!token.isNative && (
              <TextInput
                style={styles.input}
                value={token.tokenAddress ?? ''}
                onChangeText={(tokenAddress) =>
                  updateToken(index, {
                    tokenAddress: tokenAddress as DemoTokenBalanceOverride['tokenAddress'],
                  })
                }
                placeholder="Adresse du contrat"
                placeholderTextColor={colors.text.alternative}
              />
            )}
          </View>
        ))}

        <TouchableOpacity style={styles.addButton} onPress={addToken}>
          <Text style={styles.addButtonText}>+ Ajouter un token</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.saveButton} onPress={onSave}>
          <Text style={styles.saveButtonText}>Enregistrer</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
};

export default DemoModeSettings;
