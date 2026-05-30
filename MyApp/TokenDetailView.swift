import SwiftUI

struct TokenDetailView: View {
    let token: Token
    @Environment(\.dismiss) var dismiss
    @State private var selectedPeriod: ChartPeriod = .week
    @State private var chartPoints: [CGFloat] = []

    enum ChartPeriod: String, CaseIterable {
        case day = "1D"
        case week = "1W"
        case month = "1M"
        case threeMonth = "3M"
        case year = "1Y"
        case all = "ALL"
    }

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Text(token.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        if token.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#AB9FF2"))
                        }
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Balance
                        VStack(spacing: 8) {
                            Text(token.formattedValue)
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text(token.formattedChange)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(token.changeColor)

                                Text(String(format: "%.2f%%", token.changePercent24h))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(token.changeColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(token.changeColor.opacity(0.15)))
                            }

                            Text(token.formattedAmount)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#6B6B6B"))
                        }
                        .padding(.horizontal, 20)

                        // Chart Placeholder
                        VStack(spacing: 16) {
                            MiniChartView(
                                isPositive: token.change24h >= 0,
                                color: token.changeColor
                            )
                            .frame(height: 140)
                            .padding(.horizontal, 8)

                            // Period Selector
                            HStack(spacing: 0) {
                                ForEach(ChartPeriod.allCases, id: \.self) { period in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedPeriod = period
                                        }
                                    } label: {
                                        Text(period.rawValue)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(selectedPeriod == period ? .white : Color(hex: "#6B6B6B"))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedPeriod == period
                                                ? Capsule().fill(Color(hex: "#2A2A2A"))
                                                : Capsule().fill(Color.clear)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Action Buttons
                        HStack(spacing: 12) {
                            ForEach(["Send", "Receive", "Swap", "Buy"], id: \.self) { action in
                                Button {} label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "#232323"))
                                                .frame(width: 48, height: 48)
                                            Image(systemName: actionIcon(action))
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        Text(action)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(Color(hex: "#8A8A8A"))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Stats Card
                        VStack(spacing: 0) {
                            statsRow(label: "Price", value: String(format: "$%.2f", token.valueUSD / max(token.amount, 0.0001)))
                            Divider().background(Color(hex: "#2A2A2A"))
                            statsRow(label: "Holdings", value: token.formattedAmount)
                            Divider().background(Color(hex: "#2A2A2A"))
                            statsRow(label: "Value", value: token.formattedValue)
                            Divider().background(Color(hex: "#2A2A2A"))
                            statsRow(label: "24h Change", value: token.formattedChange, valueColor: token.changeColor)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#232323"))
                        )
                        .padding(.horizontal, 16)

                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    func actionIcon(_ action: String) -> String {
        switch action {
        case "Send": return "arrow.up"
        case "Receive": return "qrcode"
        case "Swap": return "arrow.2.squarepath"
        case "Buy": return "dollarsign"
        default: return "circle"
        }
    }

    func statsRow(label: String, value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#6B6B6B"))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Mini Chart View

struct MiniChartView: View {
    let isPositive: Bool
    let color: Color
    @State private var appeared = false

    // Generate a realistic-looking chart curve
    private var points: [CGFloat] {
        let base: [CGFloat] = isPositive
            ? [0.5, 0.48, 0.52, 0.44, 0.46, 0.40, 0.43, 0.35, 0.38, 0.30, 0.28, 0.20, 0.15, 0.08, 0.05, 0.02]
            : [0.1, 0.15, 0.12, 0.20, 0.18, 0.25, 0.22, 0.30, 0.28, 0.38, 0.35, 0.44, 0.42, 0.50, 0.55, 0.60]
        return base
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pts = points.enumerated().map { i, y -> CGPoint in
                CGPoint(
                    x: CGFloat(i) / CGFloat(points.count - 1) * w,
                    y: h - (y * h)
                )
            }

            ZStack {
                // Fill gradient under curve
                Path { path in
                    guard pts.count > 1 else { return }
                    path.move(to: CGPoint(x: pts[0].x, y: h))
                    path.addLine(to: pts[0])
                    for i in 1..<pts.count {
                        let prev = pts[i - 1]
                        let curr = pts[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                    path.addLine(to: CGPoint(x: pts.last!.x, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: appeared)

                // Line
                Path { path in
                    guard pts.count > 1 else { return }
                    path.move(to: pts[0])
                    for i in 1..<pts.count {
                        let prev = pts[i - 1]
                        let curr = pts[i]
                        let midX = (prev.x + curr.x) / 2
                        path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
                    }
                }
                .trim(from: 0, to: appeared ? 1 : 0)
                .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .animation(.easeInOut(duration: 1.2), value: appeared)

                // End dot
                if let last = pts.last {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .position(last)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(1.1), value: appeared)
                }
            }
        }
        .onAppear { appeared = true }
    }
}
