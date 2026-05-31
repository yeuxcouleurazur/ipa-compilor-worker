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
                            .fill(Color(hex: "#2A2A2A")) // Lighter grey circle
                            .frame(width: 36, height: 36)
                        Text("💸") // Winged money avatar
                            .font(.system(size: 18))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.walletAddress)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text(viewModel.walletName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }

            Spacer()

            HStack(spacing: 20) {
                Button {
                } label: {
                    Image(systemName: "clock")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(hex: "#EBEBEB"))
                }

                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(hex: "#EBEBEB"))
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
                    // Force comma for thousands
                    let balanceString = String(format: "%.2f", viewModel.totalBalance)
                    let parts = balanceString.components(separatedBy: ".")
                    let integerPart = parts[0]
                    let decimalPart = parts.count > 1 ? ".\(parts[1])" : ""
                    let formattedInteger = integerPart.count > 3 ? "\(integerPart.prefix(integerPart.count - 3)),\(integerPart.suffix(3))" : integerPart
                    
                    Text("$\(formattedInteger)\(decimalPart)")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                } else {
                    Text("••••••••")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            // 24h Change
            HStack(spacing: 8) {
                Text(viewModel.formattedChange)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(viewModel.change24h >= 0 ? Color(hex: "#3DD68C") : Color(hex: "#FF453A"))

                Text(viewModel.formattedChangePercent)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.change24h >= 0 ? Color(hex: "#3DD68C") : Color(hex: "#FF453A")) // Green text for positive
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(viewModel.change24h >= 0 ? Color(hex: "#163324") : Color(hex: "#3A1D1D")) // Dark green/red background
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
            actionButton(icon: "qrcode", label: "Receive")
            actionButton(icon: "paperplane", label: "Send")
            actionButton(icon: "repeat", label: "Swap")
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
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "#A393FA")) // Purple icons
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#EBEBEB"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76) // Rectangular shape
            .background(Color(hex: "#1C1C1E")) // Darker grey
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)) // Ultra smooth squircle like iOS icons
        }
    }

    // MARK: - Cash Balance Card

    private var cashBalanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cash Balance")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8E8E93"))
                Text(String(format: "$%.2f", viewModel.cashBalance))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
            } label: {
                Text("Add Cash")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#221C35")) // Very dark purple/black text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#AB9FF2")) // Bright Phantom purple background
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "#181818"))
        )
    }

                    // Cash Balance Card
                    cashBalanceCard
                        .padding(.top, 24)

                    // Tokens Section
                    tokensSection
                        .padding(.top, 24)

    // MARK: - Tokens Section

    private var tokensSection: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("Tokens")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 4)

            // Token List
            VStack(spacing: 8) { // Smaller spacing between token cards
                ForEach(Array(viewModel.tokens.enumerated()), id: \.element.id) { index, token in
                    NavigationLink(destination: TokenDetailView(token: token)) {
                        TokenRowView(token: token)
                    }
                    .buttonStyle(PlainButtonStyle())
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

                if token.symbol == "USDT" || token.symbol == "CLAWD" {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            GeometryReader { geometry in
                                let w = geometry.size.width
                                let h = geometry.size.height
                                Path { path in
                                    // Top shape /
                                    path.move(to: CGPoint(x: w*0.15, y: h*0.35))
                                    path.addLine(to: CGPoint(x: w*0.70, y: h*0.35))
                                    path.addLine(to: CGPoint(x: w*0.85, y: h*0.20))
                                    path.addLine(to: CGPoint(x: w*0.30, y: h*0.20))
                                    path.closeSubpath()
                                    
                                    // Middle shape \
                                    path.move(to: CGPoint(x: w*0.15, y: h*0.45))
                                    path.addLine(to: CGPoint(x: w*0.70, y: h*0.45))
                                    path.addLine(to: CGPoint(x: w*0.85, y: h*0.60))
                                    path.addLine(to: CGPoint(x: w*0.30, y: h*0.60))
                                    path.closeSubpath()
                                    
                                    // Bottom shape /
                                    path.move(to: CGPoint(x: w*0.15, y: h*0.80))
                                    path.addLine(to: CGPoint(x: w*0.70, y: h*0.80))
                                    path.addLine(to: CGPoint(x: w*0.85, y: h*0.65))
                                    path.addLine(to: CGPoint(x: w*0.30, y: h*0.65))
                                    path.closeSubpath()
                                }
                                .fill(Color.black)
                            }
                        )
                        .offset(x: 14, y: 14)
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
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#8C7AE6"))
                    }
                }
                
                Text(token.formattedAmount)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }

            Spacer()

            // Value
            VStack(alignment: .trailing, spacing: 4) {
                Text(token.formattedValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(token.formattedChange)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(token.changeColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "#181818")) // Darker card background, closer to black
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
