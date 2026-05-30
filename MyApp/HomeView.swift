import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var balanceVisible = true
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea() // Deep black background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Nav
                    topNavBar
                        .padding(.top, 4)

                    // Balance Section
                    balanceSection
                        .padding(.top, 24)

                    // Action Buttons
                    actionButtons
                        .padding(.top, 24)

                    // Cash Balance Card
                    cashBalanceCard
                        .padding(.top, 24)

                    // Tokens Section
                    tokensSection
                        .padding(.top, 24)

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
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2A2A2A"))
                            .frame(width: 40, height: 40)
                        Text("💸")
                            .font(.system(size: 20))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.walletAddress)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#B3B3B3"))
                        Text(viewModel.walletName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            Spacer()

            HStack(spacing: 20) {
                Button {
                } label: {
                    Image(systemName: "clock")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Balance Section

    private var balanceSection: some View {
        VStack(spacing: 8) {
            // Total Balance
            HStack {
                if balanceVisible {
                    Text(viewModel.formattedTotalBalance)
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .tracking(-1)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                } else {
                    Text("••••••••")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            // 24h Change
            HStack(spacing: 8) {
                Text(viewModel.formattedChange)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(viewModel.change24h >= 0 ? Color(hex: "#42C779") : Color(hex: "#FF453A"))

                Text(viewModel.formattedChangePercent)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.change24h >= 0 ? Color(hex: "#42C779") : Color(hex: "#FF453A"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(viewModel.change24h >= 0 ? Color(hex: "#1F382E") : Color(hex: "#3A1D1D"))
                    )
                Spacer()
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(icon: "paperplane.fill", label: "Send")
            actionButton(icon: "arrow.left.arrow.right", label: "Swap")
            actionButton(icon: "qrcode", label: "Receive")
            actionButton(icon: "dollarsign", label: "Buy")
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: appearAnimation)
    }

    private func actionButton(icon: String, label: String) -> some View {
        Button {
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#A393FA")) // Slightly brighter purple for icons
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(Color(hex: "#232323")) // Lighter grey than background
            .cornerRadius(20) // More rounded corners
        }
    }

    // MARK: - Cash Balance Card

    private var cashBalanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cash Balance")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8B8B8B"))
                Text(String(format: "$%.2f", viewModel.cashBalance))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
            } label: {
                Text("Add Cash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#312859")) // Dark purple text
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#D0C4FF")) // Soft light purple background
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#232323"))
        )
    }

    // MARK: - Tokens Section

    private var tokensSection: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("Tokens")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 4)

            // Token List
            VStack(spacing: 12) {
                ForEach(Array(viewModel.tokens.enumerated()), id: \.element.id) { index, token in
                    TokenRowView(token: token)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(
                            .easeOut(duration: 0.5).delay(Double(index) * 0.07 + 0.2),
                            value: appearAnimation
                        )
                }
            }
        }
    }
}

// MARK: - Token Row

struct TokenRowView: View {
    let token: Token

    var body: some View {
        HStack(spacing: 16) {
            // Token Icon
            ZStack {
                tokenIcon
                    .frame(width: 48, height: 48)

                // Network overlay (e.g. Solana icon bottom right)
                // We'll simulate it for USDT and others like the real app
                if token.symbol == "USDT" || token.symbol == "CLAWD" {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image("solana_logo_tiny") // Simulated local overlay
                                .resizable()
                                .scaledToFit()
                                .padding(2)
                                .overlay(
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        )
                        .offset(x: 16, y: 16)
                }
            }
            .frame(width: 48, height: 48)

            // Token Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(token.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if token.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#AB9FF2"))
                    }
                }
                
                Text(token.formattedAmount)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#B3B3B3"))
            }

            Spacer()

            // Value
            VStack(alignment: .trailing, spacing: 4) {
                Text(token.formattedValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Text(token.formattedChange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(token.changeColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1E1E1E"))
        )
    }

    @ViewBuilder
    private var tokenIcon: some View {
        if let imageUrl = token.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Circle().fill(Color(hex: "#2A2A2A"))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                case .failure:
                    fallbackIcon
                @unknown default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    @ViewBuilder
    private var fallbackIcon: some View {
        switch token.symbol {
        case "BTC":
            ZStack {
                Circle().fill(Color(hex: "#F7931A"))
                Text("₿")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        case "SOL":
            ZStack {
                Circle().fill(Color.black)
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#14F195"))
            }
        default:
            ZStack {
                Circle().fill(token.color)
                Text(String(token.symbol.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
