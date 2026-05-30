import SwiftUI

struct SwapView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var fromToken: String = "SOL"
    @State private var toToken: String = "USDC"
    @State private var fromAmount: String = ""
    @State private var toAmount: String = ""
    @State private var slippage: Double = 0.5
    @State private var isSwapping = false
    @State private var showSlippageSheet = false
    @FocusState private var fromFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Text("Swap")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        showSlippageSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                            Text("\(String(format: "%.1f", slippage))%")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#AB9FF2"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#AB9FF2").opacity(0.15))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Swap Card
                VStack(spacing: 4) {
                    // From
                    swapField(
                        label: "You pay",
                        tokenSymbol: $fromToken,
                        amount: $fromAmount,
                        balance: "2523.91040",
                        isFocused: $fromFieldFocused
                    )

                    // Swap Button Center
                    ZStack {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                let temp = fromToken
                                fromToken = toToken
                                toToken = temp
                                let tempAmount = fromAmount
                                fromAmount = toAmount
                                toAmount = tempAmount
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#1A1A1A"))
                                    .frame(width: 40, height: 40)
                                Circle()
                                    .strokeBorder(Color(hex: "#2A2A2A"), lineWidth: 2)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(height: 0)
                    .zIndex(1)

                    // To
                    swapField(
                        label: "You receive",
                        tokenSymbol: $toToken,
                        amount: $toAmount,
                        balance: "0.00",
                        isFocused: $fromFieldFocused,
                        isReadOnly: true
                    )
                }
                .padding(.horizontal, 16)

                // Rate Info
                if !fromAmount.isEmpty {
                    HStack {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                        Text("1 \(fromToken) ≈ 145.32 \(toToken)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                        Spacer()
                        Text("Best rate")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#3DD68C"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                // Swap CTA
                Button {
                    guard !fromAmount.isEmpty else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSwapping = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { isSwapping = false }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if isSwapping {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.9)
                        }
                        Text(isSwapping ? "Swapping..." : fromAmount.isEmpty ? "Enter amount" : "Swap \(fromToken) → \(toToken)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                fromAmount.isEmpty
                                ? Color(hex: "#2A2A2A")
                                : LinearGradient(
                                    colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .disabled(fromAmount.isEmpty || isSwapping)
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: fromAmount)
    }

    @ViewBuilder
    func swapField(
        label: String,
        tokenSymbol: Binding<String>,
        amount: Binding<String>,
        balance: String,
        isFocused: FocusState<Bool>.Binding,
        isReadOnly: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                Spacer()
                Button {
                    if !isReadOnly {
                        amount.wrappedValue = balance
                    }
                } label: {
                    Text("Balance: \(balance) \(tokenSymbol.wrappedValue)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#AB9FF2"))
                }
            }

            HStack(spacing: 12) {
                // Token Badge
                HStack(spacing: 8) {
                    CryptoIconSmall(symbol: tokenSymbol.wrappedValue)
                    Text(tokenSymbol.wrappedValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#6B6B6B"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(hex: "#2A2A2A"))
                )

                if isReadOnly {
                    Text(amount.wrappedValue.isEmpty ? "0.00" : amount.wrappedValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(amount.wrappedValue.isEmpty ? Color(hex: "#3A3A3A") : .white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    TextField("0", text: amount)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused(isFocused)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#232323"))
        )
    }
}

struct CryptoIconSmall: View {
    let symbol: String

    var body: some View {
        ZStack {
            Circle()
                .fill(iconColor)
                .frame(width: 28, height: 28)
            Text(iconText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }

    var iconColor: Color {
        switch symbol {
        case "BTC": return Color(hex: "#F7931A")
        case "SOL": return Color(hex: "#9945FF")
        case "ETH": return Color(hex: "#627EEA")
        case "USDC": return Color(hex: "#2775CA")
        default: return Color(hex: "#AB9FF2")
        }
    }

    var iconText: String {
        switch symbol {
        case "BTC": return "₿"
        case "SOL": return "S"
        case "ETH": return "Ξ"
        case "USDC": return "$"
        default: return String(symbol.prefix(1))
        }
    }
}
