import SwiftUI

struct SwapView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var fromToken: String = "ETH"
    @State private var toToken: String = "SOL"
    @State private var fromAmount: String = "0.0075"
    @State private var toAmount: String = "0.1103"
    @State private var slippage: Double = 2.0
    @FocusState private var fromFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Nav Bar
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(0) // Hide action, just for layout balance if needed
                    
                    Spacer()
                    
                    Text("Swap Tokens")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Slippage action
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                            Text("\(String(format: "%.0f", slippage))%")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Main Swap Card
                VStack(spacing: 0) {
                    // From Field
                    swapField(
                        title: "You Pay",
                        amount: $fromAmount,
                        tokenSymbol: $fromToken,
                        usdValue: "$20.04",
                        balance: "0.03976 ETH",
                        isFocused: $fromFieldFocused
                    )
                    
                    // Middle Separator + Swap Button
                    ZStack {
                        Divider()
                            .background(Color(hex: "#3A3A3A"))
                            .padding(.horizontal, 16)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                let temp = fromToken
                                fromToken = toToken
                                toToken = temp
                                
                                let tempAmt = fromAmount
                                fromAmount = toAmount
                                toAmount = tempAmt
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#2A2A2A"))
                                    .frame(width: 32, height: 32)
                                Circle()
                                    .fill(Color(hex: "#3A3A3A"))
                                    .frame(width: 28, height: 28)
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "#AB9FF2"))
                            }
                        }
                    }
                    .frame(height: 32)
                    .zIndex(1)
                    
                    // To Field
                    swapField(
                        title: "You Receive",
                        amount: $toAmount,
                        tokenSymbol: $toToken,
                        usdValue: "$17.34",
                        balance: "0.28317 SOL",
                        isFocused: FocusState<Bool>().projectedValue, // Not focused
                        isReadOnly: true
                    )
                    
                    Divider()
                        .background(Color(hex: "#3A3A3A"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    // Provider Info
                    infoRow(title: "Provider", value: "Mayan >")
                    infoRow(title: "Price", value: "1 \(fromToken) = 14.6 \(toToken) ⇅")
                        .padding(.bottom, 16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "#2A2A2A"))
                )
                .padding(.horizontal, 16)

                Spacer()

                // Review Order Button
                Button {
                    // Action
                } label: {
                    Text("Review Order")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#AB9FF2"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Space for custom tab bar
            }
        }
    }
    
    @ViewBuilder
    func swapField(
        title: String,
        amount: Binding<String>,
        tokenSymbol: Binding<String>,
        usdValue: String,
        balance: String,
        isFocused: FocusState<Bool>.Binding,
        isReadOnly: Bool = false
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8B8B8B"))
                Spacer()
            }
            
            HStack(alignment: .center) {
                // Amount input
                if isReadOnly {
                    Text(amount.wrappedValue)
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.white)
                } else {
                    TextField("0", text: amount)
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .focused(isFocused)
                }
                
                Spacer()
                
                // Token Pill
                Button(action: {}) {
                    HStack(spacing: 6) {
                        CryptoIconSmall(symbol: tokenSymbol.wrappedValue)
                        Text(tokenSymbol.wrappedValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#1A1A1A"))
                    .cornerRadius(20)
                }
            }
            
            HStack {
                // USD Value
                HStack(spacing: 4) {
                    Text(usdValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#8B8B8B"))
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#8B8B8B"))
                }
                
                Spacer()
                
                // Balance
                Text(balance)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#8B8B8B"))
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    func infoRow(title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#8B8B8B"))
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8B8B8B"))
            }
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#8B8B8B"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

struct CryptoIconSmall: View {
    let symbol: String

    var body: some View {
        ZStack {
            Circle()
                .fill(iconColor)
                .frame(width: 24, height: 24)
            Text(iconText)
                .font(.system(size: 10, weight: .bold))
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
        case "SOL": return "S" // A simple fallback, a real icon is better.
        case "ETH": return "Ξ"
        case "USDC": return "$"
        default: return String(symbol.prefix(1))
        }
    }
}
