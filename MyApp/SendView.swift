import SwiftUI

struct SendView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.dismiss) var dismiss
    @State private var recipientAddress: String = ""
    @State private var amount: String = ""
    @State private var selectedToken: String = "SOL"
    @State private var isSending = false
    @State private var showSuccess = false
    @FocusState private var amountFocused: Bool

    var selectedTokenData: Token? {
        viewModel.tokens.first { $0.symbol == selectedToken }
    }

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            if showSuccess {
                successOverlay
            } else {
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
                        Text("Send")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Token Selector
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Token")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                    .textCase(.uppercase)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(viewModel.tokens.filter { $0.valueUSD > 0 }) { token in
                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedToken = token.symbol
                                                }
                                            } label: {
                                                HStack(spacing: 8) {
                                                    CryptoIconSmall(symbol: token.symbol)
                                                    VStack(alignment: .leading, spacing: 1) {
                                                        Text(token.symbol)
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(selectedToken == token.symbol ? .white : Color(hex: "#8A8A8A"))
                                                        Text(token.formattedValue)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(Color(hex: "#6B6B6B"))
                                                    }
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(selectedToken == token.symbol ? Color(hex: "#2A2A4A") : Color(hex: "#232323"))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .strokeBorder(
                                                                    selectedToken == token.symbol ? Color(hex: "#AB9FF2").opacity(0.5) : Color.clear,
                                                                    lineWidth: 1
                                                                )
                                                        )
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)

                            // Recipient Address
                            VStack(alignment: .leading, spacing: 8) {
                                Text("To")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 20)

                                HStack(spacing: 12) {
                                    TextField("Address or username", text: $recipientAddress)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .autocorrectionDisabled()
                                        .autocapitalization(.none)

                                    if recipientAddress.isEmpty {
                                        Button {} label: {
                                            Image(systemName: "qrcode.viewfinder")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(hex: "#AB9FF2"))
                                        }
                                    } else {
                                        Button { recipientAddress = "" } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color(hex: "#4A4A4A"))
                                        }
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "#232323"))
                                )
                                .padding(.horizontal, 16)
                            }

                            // Amount
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Amount")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "#6B6B6B"))
                                        .textCase(.uppercase)
                                    Spacer()
                                    if let t = selectedTokenData {
                                        Button {
                                            amount = String(format: "%.4f", t.amount)
                                        } label: {
                                            Text("Max: \(t.formattedAmount)")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(hex: "#AB9FF2"))
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)

                                VStack(spacing: 8) {
                                    HStack {
                                        TextField("0.00", text: $amount)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                            .keyboardType(.decimalPad)
                                            .focused($amountFocused)

                                        Text(selectedToken)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(hex: "#6B6B6B"))
                                    }

                                    if let usdValue = Double(amount), let t = selectedTokenData, t.amount > 0 {
                                        let usd = usdValue * (t.valueUSD / t.amount)
                                        Text("â‰ˆ \(String(format: "\(viewModel.currency)%.2f", usd))")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#6B6B6B"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "#232323"))
                                )
                                .padding(.horizontal, 16)
                            }

                            // Network Fee
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                Text("Network fee: ~$0.00025")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                Spacer()
                                Text("Fast")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "#3DD68C"))
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                    }

                    Spacer()

                    // Send Button
                    Button {
                        guard !recipientAddress.isEmpty, !amount.isEmpty else { return }
                        isSending = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isSending = false
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showSuccess = true
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if isSending {
                                ProgressView().tint(.white).scaleEffect(0.9)
                            }
                            Text(isSending ? "Sending..." : "Send \(selectedToken)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    recipientAddress.isEmpty || amount.isEmpty
                                    ? AnyShapeStyle(Color(hex: "#2A2A2A"))
                                    : AnyShapeStyle(LinearGradient(
                                        colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                )
                        )
                    }
                    .disabled(recipientAddress.isEmpty || amount.isEmpty || isSending)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var successOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "#3DD68C").opacity(0.15))
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(Color(hex: "#3DD68C").opacity(0.25))
                    .frame(width: 75, height: 75)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "#3DD68C"))
            }

            VStack(spacing: 8) {
                Text("Sent!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("\(amount) \(selectedToken)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                Text("to \(recipientAddress.prefix(6))...\(recipientAddress.suffix(4))")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#4A4A4A"))
            }

            Spacer()

            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#AB9FF2"))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
}

