import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @StateObject private var networkManager = NetworkManager()
    @State private var balanceVisible = true
    @State private var appearAnimation = false
    @State private var showReceiveSheet = false

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

                    // Tokens Section
                    tokensSection
                        .padding(.top, 32)
                        
                    // Predictions Section
                    predictionsSection
                        .padding(.top, 24)
                        
                    // Perps Section
                    perpsSection
                        .padding(.top, 24)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .refreshable {
                viewModel.isRefreshing = true
                viewModel.recalculate()
                networkManager.fetchMemeCoins(currency: viewModel.currencyCode)
                networkManager.fetchPredictions()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.isRefreshing = false
            }
        }
        .onAppear {
            networkManager.fetchMemeCoins(currency: viewModel.currencyCode)
            networkManager.fetchPredictions()
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
                            .fill(Color(hex: "#FFE5B4")) // Light peach background
                            .frame(width: 54, height: 54)
                        Text(viewModel.profileEmoji) // Avatar
                            .font(.system(size: 30))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.username)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text(viewModel.walletName)
                            .font(.system(size: 22, weight: .bold))
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
                    
                    Text("\(viewModel.currency)\(formattedInteger)\(decimalPart)")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                } else {
                    Text("â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            // 24h Change
            HStack(spacing: 8) {
                Text(viewModel.formattedChange)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(viewModel.change24h >= 0 ? Color(hex: "#1FAD66") : Color(hex: "#FF453A"))

                Text(viewModel.formattedChangePercent)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#121212")) // Black text
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(viewModel.change24h >= 0 ? Color(hex: "#1FAD66") : Color(hex: "#FF453A")) // Solid background
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
            actionButton(label: "Receive", action: { showReceiveSheet = true }) {
                Image(systemName: "qrcode")
                    .font(.system(size: 26, weight: .bold))
            }
            actionButton(label: "Send", action: {}) {
                Image("Send")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            actionButton(label: "Swap", action: {}) {
                Image("Swap")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            actionButton(label: "Buy", action: {}) {
                Image("Buy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: appearAnimation)
        .sheet(isPresented: $showReceiveSheet) {
            ReceiveView()
        }
    }

    private func actionButton<Icon: View>(label: String, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                icon()
                    .foregroundColor(Color(hex: "#A393FA"))
                    .frame(width: 34, height: 34) // Consistent container size
                
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#EBEBEB"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80) // Rectangular squircle shape
            .background(Color(hex: "#1C1C1E")) // Darker grey
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)) // Ultra smooth squircle like iOS icons
        }
    }

    // MARK: - Tokens Section

    private var tokensSection: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("Tokens")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                }
                Spacer()
            }
            .padding(.bottom, 4)

            // Token List
            VStack(spacing: 8) {
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
    
    // MARK: - Predictions Section
    private var predictionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Predictions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#8E8E93"))
                Spacer()
            }
            
            if networkManager.isLoadingPredictions && networkManager.predictions.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#A393FA")))
                    .frame(height: 140)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(networkManager.predictions) { prediction in
                            predictionCard(prediction: prediction)
                        }
                    }
                }
            }
        }
    }
    
    private func predictionCard(prediction: PredictionModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#2A2A2A"))
                    .frame(width: 48, height: 48)
                
                if let imgStr = prediction.image, let url = URL(string: imgStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.white)
                        case .success(let image):
                            image.resizable().scaledToFill().frame(width: 48, height: 48).clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            Image(systemName: "chart.pie.fill").foregroundColor(.white).font(.system(size: 24))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "chart.pie.fill").foregroundColor(.white).font(.system(size: 24))
                }
            }
            Spacer()
            Text(prediction.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(prediction.volumeText)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(hex: "#8E8E93"))
        }
        .padding(16)
        .frame(width: 140, height: 150, alignment: .leading)
        .background(Color(hex: "#1C1C1E"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Perps Section
    private var perpsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Perps")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#8E8E93"))
                Spacer()
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
                Text("\(viewModel.currency)\(token.formattedValue)")
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
                Text("â‚¿")
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

// MARK: - Custom Vector Icons

struct PhantomSendIconView: View {
    var body: some View {
        ZStack {
            SendIconShape()
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            
            SendCenterShape()
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
        }
    }
}

struct SendIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 179.0
        let sy = rect.height / 180.0

        var p = Path()
        p.move(to: CGPoint(x: 121.5*sx, y: 21*sy))

        p.addCurve(
            to: CGPoint(x: 145*sx, y: 34*sy),
            control1: CGPoint(x: 132*sx, y: 21*sy),
            control2: CGPoint(x: 141*sx, y: 25*sy)
        )

        p.addCurve(
            to: CGPoint(x: 143*sx, y: 57*sy),
            control1: CGPoint(x: 149*sx, y: 42*sy),
            control2: CGPoint(x: 148*sx, y: 50*sy)
        )

        p.addLine(to: CGPoint(x: 110*sx, y: 147*sy))

        p.addCurve(
            to: CGPoint(x: 92*sx, y: 159*sy),
            control1: CGPoint(x: 107*sx, y: 155*sy),
            control2: CGPoint(x: 101*sx, y: 159*sy)
        )

        p.addCurve(
            to: CGPoint(x: 74*sx, y: 145*sy),
            control1: CGPoint(x: 83*sx, y: 159*sy),
            control2: CGPoint(x: 78*sx, y: 154*sy)
        )

        p.addLine(to: CGPoint(x: 56*sx, y: 104*sy))
        p.addLine(to: CGPoint(x: 33*sx, y: 97*sy))

        p.addCurve(
            to: CGPoint(x: 21*sx, y: 87*sy),
            control1: CGPoint(x: 26*sx, y: 95*sy),
            control2: CGPoint(x: 21*sx, y: 91*sy)
        )

        p.addCurve(
            to: CGPoint(x: 31*sx, y: 71*sy),
            control1: CGPoint(x: 21*sx, y: 80*sy),
            control2: CGPoint(x: 25*sx, y: 75*sy)
        )

        p.addLine(to: CGPoint(x: 111*sx, y: 44*sy))
        p.closeSubpath()

        return p
    }
}

struct SendCenterShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 179.0
        let sy = rect.height / 180.0

        var p = Path()
        p.move(to: CGPoint(x: 72*sx, y: 108*sy))
        p.addLine(to: CGPoint(x: 103*sx, y: 78*sy))

        return p
    }
}

struct PhantomSwapIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Top Arrow (Points Right)
        let topY = h * 0.35
        path.move(to: CGPoint(x: w * 0.1, y: topY))
        path.addLine(to: CGPoint(x: w * 0.9, y: topY))
        
        path.move(to: CGPoint(x: w * 0.65, y: topY - h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.9, y: topY))
        path.addLine(to: CGPoint(x: w * 0.65, y: topY + h * 0.2))
        
        // Bottom Arrow (Points Left)
        let botY = h * 0.65
        path.move(to: CGPoint(x: w * 0.9, y: botY))
        path.addLine(to: CGPoint(x: w * 0.1, y: botY))
        
        path.move(to: CGPoint(x: w * 0.35, y: botY - h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.1, y: botY))
        path.addLine(to: CGPoint(x: w * 0.35, y: botY + h * 0.2))
        
        return path
    }
}



