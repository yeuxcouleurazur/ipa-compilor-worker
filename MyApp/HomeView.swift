import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var balanceVisible = true
    @State private var scrollOffset: CGFloat = 0
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Nav
                    topNavBar
                        .padding(.top, 4)

                    // Balance Section
                    balanceSection
                        .padding(.top, 8)

                    // Action Buttons
                    actionButtons
                        .padding(.top, 24)

                    // Cash Balance Card
                    cashBalanceCard
                        .padding(.top, 16)

                    // Tokens Section
                    tokensSection
                        .padding(.top, 16)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Top Nav Bar

    private var topNavBar: some View {
        HStack {
            // Wallet selector
            Button {
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)
                        Text("👻")
                            .font(.system(size: 14))
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("@ghostwallet")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                        Text(viewModel.walletName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8A8A"))
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#8A8A8A"))
                }

                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#8A8A8A"))
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Balance Section

    private var balanceSection: some View {
        VStack(spacing: 6) {
            // Total Balance
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    balanceVisible.toggle()
                }
            } label: {
                if balanceVisible {
                    Text(viewModel.formattedTotalBalance)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                } else {
                    Text("••••••••")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 24h Change
            HStack(spacing: 8) {
                Text(viewModel.formattedChange)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(viewModel.changeColor)

                Text(viewModel.formattedChangePercent)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(viewModel.changeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(viewModel.changeColor.opacity(0.15))
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 0) {
            ForEach(WalletAction.allCases, id: \.self) { action in
                Button {
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#2A2A2A"))
                                .frame(width: 56, height: 56)

                            Image(systemName: action.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }

                        Text(action.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: appearAnimation)
    }

    // MARK: - Cash Balance Card

    private var cashBalanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Cash Balance")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                Text(String(format: "$%.2f", viewModel.cashBalance))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
            } label: {
                Text("Add Cash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#AB9FF2"))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#232323"))
        )
    }

    // MARK: - Tokens Section

    private var tokensSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("Tokens")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                    }
                }
                Spacer()
            }
            .padding(.bottom, 12)

            // Token List
            VStack(spacing: 2) {
                ForEach(Array(viewModel.tokens.enumerated()), id: \.element.id) { index, token in
                    TokenRowView(token: token)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(
                            .easeOut(duration: 0.5).delay(Double(index) * 0.07 + 0.2),
                            value: appearAnimation
                        )

                    if index < viewModel.tokens.count - 1 {
                        Divider()
                            .background(Color(hex: "#2A2A2A"))
                            .padding(.horizontal, 4)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#232323"))
            )
        }
    }
}

// MARK: - Wallet Action

enum WalletAction: String, CaseIterable {
    case send, swap, receive, buy

    var icon: String {
        switch self {
        case .send: return "arrow.up"
        case .swap: return "arrow.2.squarepath"
        case .receive: return "qrcode"
        case .buy: return "dollarsign"
        }
    }
    var label: String { rawValue.capitalized }
}

// MARK: - Token Row

struct TokenRowView: View {
    let token: Token

    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            ZStack {
                Circle()
                    .fill(token.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                tokenIcon
                    .frame(width: 28, height: 28)

                // Verified badge
                if token.isVerified {
                    Circle()
                        .fill(Color(hex: "#AB9FF2"))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 14, y: 14)
                }
            }
            .frame(width: 44, height: 44)

            // Token Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(token.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text(token.formattedAmount)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#6B6B6B"))
            }

            Spacer()

            // Value
            VStack(alignment: .trailing, spacing: 3) {
                Text(token.formattedValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(token.formattedChange)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(token.changeColor)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var tokenIcon: some View {
        switch token.symbol {
        case "BTC":
            ZStack {
                Circle().fill(Color(hex: "#F7931A"))
                Text("₿")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        case "SOL":
            ZStack {
                Circle().fill(
                    LinearGradient(
                        colors: [Color(hex: "#9945FF"), Color(hex: "#14F195")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                Image(systemName: "s.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        case "ETH":
            ZStack {
                Circle().fill(Color(hex: "#627EEA"))
                Text("Ξ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        case "MON":
            ZStack {
                Circle().fill(Color(hex: "#836EF9"))
                Text("M")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        case "USDC":
            ZStack {
                Circle().fill(Color(hex: "#2775CA"))
                Text("$")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        default:
            ZStack {
                Circle().fill(token.color)
                Text(String(token.symbol.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
