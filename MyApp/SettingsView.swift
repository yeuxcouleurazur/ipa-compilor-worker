import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true
    @State private var showDemoInfo = false

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Nav
                    HStack {
                        Text("Settings")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Profile Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                            Text("👻")
                                .font(.system(size: 36))
                        }

                        VStack(spacing: 4) {
                            Text(viewModel.walletName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            HStack(spacing: 6) {
                                Text(viewModel.walletAddress)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                Button {} label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#AB9FF2"))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#232323"))
                    )
                    .padding(.horizontal, 16)

                    // Demo Notice
                    Button {
                        showDemoInfo.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "#AB9FF2").opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#AB9FF2"))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Application Démo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Toutes les données sont fictives")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#3A3A3A"))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#232323"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color(hex: "#AB9FF2").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Settings Groups
                    VStack(spacing: 12) {
                        settingsGroup(title: "Security", items: [
                            SettingsItem(icon: "faceid", label: "Face ID / Biometric", color: "#3DD68C", hasToggle: true, toggleValue: $biometricEnabled),
                            SettingsItem(icon: "lock.fill", label: "Auto-Lock", color: "#AB9FF2"),
                            SettingsItem(icon: "key.fill", label: "Export Private Key", color: "#FF6464"),
                        ])

                        settingsGroup(title: "Preferences", items: [
                            SettingsItem(icon: "bell.fill", label: "Notifications", color: "#F7931A", hasToggle: true, toggleValue: $notificationsEnabled),
                            SettingsItem(icon: "moon.fill", label: "Dark Mode", color: "#AB9FF2"),
                            SettingsItem(icon: "globe", label: "Language", color: "#627EEA", value: "English"),
                        ])

                        settingsGroup(title: "About", items: [
                            SettingsItem(icon: "doc.text.fill", label: "Privacy Policy", color: "#6B6B6B"),
                            SettingsItem(icon: "shield.fill", label: "Terms of Service", color: "#6B6B6B"),
                            SettingsItem(icon: "star.fill", label: "Rate the App", color: "#F7931A"),
                        ])
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Version
                    Text("GhostWallet Demo v1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#3A3A3A"))
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                }
            }
        }
        .alert("Mode Démo", isPresented: $showDemoInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Cette application est une démonstration uniquement. Aucune vraie cryptomonnaie n'est impliquée. Toutes les données affichées sont fictives à titre d'illustration.")
        }
    }

    func settingsGroup(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#4A4A4A"))
                .padding(.horizontal, 14)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    settingsRow(item: item)
                    if index < items.count - 1 {
                        Divider()
                            .background(Color(hex: "#2A2A2A"))
                            .padding(.horizontal, 14)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#232323"))
            )
        }
    }

    @ViewBuilder
    func settingsRow(item: SettingsItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: item.color).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: item.color))
            }

            Text(item.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            if item.hasToggle, let binding = item.toggleValue {
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .tint(Color(hex: "#AB9FF2"))
                    .scaleEffect(0.85)
            } else if let value = item.value {
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#3A3A3A"))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#3A3A3A"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

struct SettingsItem {
    let icon: String
    let label: String
    let color: String
    var hasToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    var value: String? = nil
}
