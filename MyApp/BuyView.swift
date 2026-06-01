import SwiftUI

struct BuyView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedAmount: Int = 100
    @State private var customAmount: String = ""
    @State private var selectedToken: String = "SOL"
    @State private var selectedPayment: PaymentMethod = .card
    @State private var isBuying = false
    @State private var showSuccess = false

    let quickAmounts = [50, 100, 250, 500]

    enum PaymentMethod: String, CaseIterable {
        case card = "Credit Card"
        case apple = "Apple Pay"
        case bank = "Bank Transfer"

        var icon: String {
            switch self {
            case .card: return "creditcard.fill"
            case .apple: return "applelogo"
            case .bank: return "building.columns.fill"
            }
        }
    }

    var displayAmount: Int {
        if let custom = Int(customAmount), custom > 0 { return custom }
        return selectedAmount
    }

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color(hex: "#2A2A2A")))
                    }
                    Spacer()
                    Text("Buy Crypto")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Token Selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Token")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                                .textCase(.uppercase)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(["BTC", "SOL", "ETH", "USDC"], id: \.self) { sym in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedToken = sym
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                CryptoIconSmall(symbol: sym)
                                                Text(sym)
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(selectedToken == sym ? .white : Color(hex: "#8A8A8A"))
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 11)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedToken == sym ? Color(hex: "#2A2A4A") : Color(hex: "#232323"))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .strokeBorder(selectedToken == sym ? Color(hex: "#AB9FF2").opacity(0.5) : Color.clear, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Amount Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amount (USD)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                                .textCase(.uppercase)

                            // Quick amounts
                            HStack(spacing: 8) {
                                ForEach(quickAmounts, id: \.self) { amt in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAmount = amt
                                            customAmount = ""
                                        }
                                    } label: {
                                        Text("\(viewModel.currency)\(amt)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(selectedAmount == amt && customAmount.isEmpty ? .white : Color(hex: "#8A8A8A"))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedAmount == amt && customAmount.isEmpty ? Color(hex: "#AB9FF2") : Color(hex: "#232323"))
                                            )
                                    }
                                }
                            }

                            // Custom amount
                            HStack {
                                Text("$")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                TextField("Custom amount", text: $customAmount)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#232323"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(customAmount.isEmpty ? Color.clear : Color(hex: "#AB9FF2").opacity(0.5), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)

                        // You receive preview
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("You'll receive approx.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                Text("~\(String(format: "%.4f", Double(displayAmount) / 142.5)) \(selectedToken)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color(hex: "#3A3A3A"))
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#232323")))
                        .padding(.horizontal, 20)

                        // Payment Method
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Payment Method")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                                .textCase(.uppercase)

                            ForEach(PaymentMethod.allCases, id: \.self) { method in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPayment = method
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: "#2A2A2A"))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: method.icon)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                        }
                                        Text(method.rawValue)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .strokeBorder(
                                                    selectedPayment == method ? Color(hex: "#AB9FF2") : Color(hex: "#3A3A3A"),
                                                    lineWidth: 2
                                                )
                                                .frame(width: 22, height: 22)
                                            if selectedPayment == method {
                                                Circle()
                                                    .fill(Color(hex: "#AB9FF2"))
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(hex: "#232323"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(selectedPayment == method ? Color(hex: "#AB9FF2").opacity(0.4) : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 24)
                    }
                }

                // Buy CTA
                VStack(spacing: 8) {
                    Text("Powered by MoonPay Â· DEMO")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#3A3A3A"))

                    Button {
                        isBuying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isBuying = false
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showSuccess = true
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if isBuying { ProgressView().tint(.white).scaleEffect(0.9) }
                            Text(isBuying ? "Processing..." : "Buy $\(displayAmount) of \(selectedToken)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .disabled(isBuying)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .padding(.top, 12)
                .background(Color(hex: "#1A1A1A"))
            }

            if showSuccess {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .transition(.opacity)
                VStack(spacing: 20) {
                    Text("ðŸŽ‰")
                        .font(.system(size: 64))
                    Text("Purchase Successful!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(viewModel.currency)\(displayAmount) of \(selectedToken) will arrive shortly")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#6B6B6B"))
                        .multilineTextAlignment(.center)
                    Button { dismiss() } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 52)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#AB9FF2")))
                    }
                }
                .padding(32)
                .background(RoundedRectangle(cornerRadius: 28).fill(Color(hex: "#232323")))
                .padding(32)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
    }
}

