import SwiftUI

struct ReceiveView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.dismiss) var dismiss
    @State private var copied = false
    @State private var selectedNetwork: String = "Solana"

    let networks = ["Solana", "Ethereum", "Bitcoin"]

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
                    Text("Receive")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Network Picker
                        HStack(spacing: 8) {
                            ForEach(networks, id: \.self) { net in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedNetwork = net
                                    }
                                } label: {
                                    Text(net)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(selectedNetwork == net ? .white : Color(hex: "#6B6B6B"))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedNetwork == net ? Color(hex: "#AB9FF2") : Color(hex: "#2A2A2A"))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // QR Code Card
                        VStack(spacing: 20) {
                            // QR Placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .frame(width: 220, height: 220)

                                // Fake QR pattern
                                QRCodePlaceholder()
                                    .frame(width: 196, height: 196)

                                // Center logo
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 48, height: 48)
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                    Text("👻")
                                        .font(.system(size: 20))
                                }
                            }
                            .shadow(color: Color(hex: "#AB9FF2").opacity(0.2), radius: 20, x: 0, y: 8)

                            VStack(spacing: 6) {
                                Text(viewModel.walletName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                Text("\(selectedNetwork) Network")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#AB9FF2"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color(hex: "#AB9FF2").opacity(0.15)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(hex: "#232323"))
                        )
                        .padding(.horizontal, 16)

                        // Address Copy
                        VStack(spacing: 12) {
                            Text("Your address")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                UIPasteboard.general.string = viewModel.walletAddress
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    copied = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { copied = false }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text("7xKp3mFd9...mR9f")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.middle)

                                    Spacer()

                                    HStack(spacing: 6) {
                                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(copied ? "Copied!" : "Copy")
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundColor(copied ? Color(hex: "#3DD68C") : Color(hex: "#AB9FF2"))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copied)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "#232323"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(
                                                    copied ? Color(hex: "#3DD68C").opacity(0.4) : Color(hex: "#2A2A2A"),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        // Warning
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#F7931A"))
                            Text("Only send \(selectedNetwork) assets to this address. Sending other tokens may result in permanent loss.")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#F7931A").opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color(hex: "#F7931A").opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)

                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - QR Code Placeholder (visual only)

struct QRCodePlaceholder: View {
    var body: some View {
        Canvas { context, size in
            let s = size.width
            let cell = s / 25
            // Draw a fake QR-like pattern
            context.fill(
                Path(CGRect(x: 0, y: 0, width: s, height: s)),
                with: .color(.white)
            )
            let pattern: [[Int]] = generateFakeQR()
            for row in 0..<25 {
                for col in 0..<25 {
                    if pattern[row][col] == 1 {
                        let rect = CGRect(
                            x: CGFloat(col) * cell,
                            y: CGFloat(row) * cell,
                            width: cell - 0.5,
                            height: cell - 0.5
                        )
                        context.fill(Path(rect), with: .color(.black))
                    }
                }
            }
        }
    }

    func generateFakeQR() -> [[Int]] {
        var grid = Array(repeating: Array(repeating: 0, count: 25), count: 25)
        // Top-left finder
        drawFinder(&grid, row: 0, col: 0)
        // Top-right finder
        drawFinder(&grid, row: 0, col: 18)
        // Bottom-left finder
        drawFinder(&grid, row: 18, col: 0)
        // Random data modules
        var rng: UInt64 = 0xDEADBEEF
        for row in 0..<25 {
            for col in 0..<25 {
                if grid[row][col] == 0 {
                    rng = rng &* 6364136223846793005 &+ 1442695040888963407
                    grid[row][col] = Int((rng >> 33) & 1)
                }
            }
        }
        return grid
    }

    func drawFinder(_ grid: inout [[Int]], row: Int, col: Int) {
        for r in 0..<7 {
            for c in 0..<7 {
                let onBorder = r == 0 || r == 6 || c == 0 || c == 6
                let onInner = r >= 2 && r <= 4 && c >= 2 && c <= 4
                grid[row + r][col + c] = (onBorder || onInner) ? 1 : 0
            }
        }
    }
}
