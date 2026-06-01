import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WalletViewModel()

    var body: some View {
        Group {
            switch viewModel.currentRoute {
            case .welcome:
                WelcomeView()
                    .environmentObject(viewModel)
            case .biometricSetup:
                BiometricAuthView()
                    .environmentObject(viewModel)
            case .mainWallet:
                MainWalletView()
                    .environmentObject(viewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Wallet View (Formerly ContentView body)

struct MainWalletView: View {
    @EnvironmentObject var viewModel: WalletViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#121212").ignoresSafeArea()

                TabView(selection: $viewModel.selectedTab) {
                    HomeView()
                        .environmentObject(viewModel)
                        .tag(WalletViewModel.Tab.home)

                    CollectiblesView() // Using this as placeholder for .wallet
                        .environmentObject(viewModel)
                        .tag(WalletViewModel.Tab.wallet)

                    SwapView()
                        .environmentObject(viewModel)
                        .tag(WalletViewModel.Tab.swap)

                    ChatsView()
                        .environmentObject(viewModel)
                        .tag(WalletViewModel.Tab.activity)

                    SettingsView() // Using this as placeholder for .browser
                        .environmentObject(viewModel)
                        .tag(WalletViewModel.Tab.browser)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom Tab Bar
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $viewModel.selectedTab)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Custom Icons

struct PhantomChatView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                PhantomChatOutline()
                    .stroke(style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                PhantomChatLines()
                    .stroke(style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            }
        }
    }
}

struct PhantomChatOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let leftX = w * 0.1
        let rightX = w * 0.9
        let topY = h * 0.15
        let botY = h * 0.75
        let rad = w * 0.15
        
        path.move(to: CGPoint(x: leftX, y: topY + rad))
        path.addArc(center: CGPoint(x: leftX + rad, y: topY + rad), radius: rad, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        path.addLine(to: CGPoint(x: rightX - rad, y: topY))
        path.addArc(center: CGPoint(x: rightX - rad, y: topY + rad), radius: rad, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        path.addLine(to: CGPoint(x: rightX, y: botY - rad))
        path.addArc(center: CGPoint(x: rightX - rad, y: botY - rad), radius: rad, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        path.addLine(to: CGPoint(x: leftX + rad * 2.5, y: botY))
        
        // Tail
        path.addCurve(to: CGPoint(x: leftX + rad * 0.8, y: botY + rad * 1.5), 
                      control1: CGPoint(x: leftX + rad * 1.5, y: botY), 
                      control2: CGPoint(x: leftX + rad * 1.2, y: botY + rad * 1.5))
                      
        path.addCurve(to: CGPoint(x: leftX, y: botY - rad * 0.2), 
                      control1: CGPoint(x: leftX + rad * 0.5, y: botY + rad * 1.0), 
                      control2: CGPoint(x: leftX, y: botY + rad * 0.5))
                      
        path.closeSubpath()
        return path
    }
}

struct PhantomChatLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let lineX = w * 0.32
        let lineEndX = w * 0.68
        let line1Y = h * 0.35
        let line2Y = h * 0.55
        
        path.move(to: CGPoint(x: lineX, y: line1Y))
        path.addLine(to: CGPoint(x: lineEndX, y: line1Y))
        
        path.move(to: CGPoint(x: lineX, y: line2Y))
        path.addLine(to: CGPoint(x: lineEndX, y: line2Y))
        
        return path
    }
}

struct PhantomCardView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                PhantomCardOutline()
                    .stroke(style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                PhantomCardInnerShapes()
                    .fill()
            }
        }
    }
}

struct PhantomCardOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let leftX = w * 0.05
        let rightX = w * 0.95
        let topY = h * 0.2
        let botY = h * 0.8
        let rad = w * 0.15
        
        path.move(to: CGPoint(x: leftX, y: topY + rad))
        path.addArc(center: CGPoint(x: leftX + rad, y: topY + rad), radius: rad, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        path.addLine(to: CGPoint(x: rightX - rad, y: topY))
        path.addArc(center: CGPoint(x: rightX - rad, y: topY + rad), radius: rad, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        path.addLine(to: CGPoint(x: rightX, y: botY - rad))
        path.addArc(center: CGPoint(x: rightX - rad, y: botY - rad), radius: rad, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        path.addLine(to: CGPoint(x: leftX + rad, y: botY))
        path.addArc(center: CGPoint(x: leftX + rad, y: botY - rad), radius: rad, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.closeSubpath()
        return path
    }
}

struct PhantomCardInnerShapes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Chip on top right
        let chipW = w * 0.15
        let chipH = h * 0.12
        let chipX = w * 0.72
        let chipY = h * 0.32
        let chipRad = w * 0.03
        
        path.addRoundedRect(in: CGRect(x: chipX, y: chipY, width: chipW, height: chipH), cornerSize: CGSize(width: chipRad, height: chipRad))
        
        // Line on bottom left
        let lineW = w * 0.25
        let lineH = h * 0.06
        let lineX = w * 0.15
        let lineY = h * 0.65
        let lineRad = lineH * 0.5
        
        path.addRoundedRect(in: CGRect(x: lineX, y: lineY, width: lineW, height: lineH), cornerSize: CGSize(width: lineRad, height: lineRad))
        
        return path
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: WalletViewModel.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WalletViewModel.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        tabIcon(for: tab, isSelected: selectedTab == tab)
                            .foregroundColor(selectedTab == tab ? (tab == .home ? Color(hex: "#AB9FF2") : .white) : Color(hex: "#6B6B6B"))
                            .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color(hex: "#121212"))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(hex: "#2A2A2A")),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    @ViewBuilder
    func tabIcon(for tab: WalletViewModel.Tab, isSelected: Bool) -> some View {
        switch tab {
        case .home:
            Image(systemName: isSelected ? "house.fill" : "house")
                .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
        case .wallet:
            PhantomCardView()
                .frame(width: 26, height: 26)
        case .swap:
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
        case .activity:
            PhantomChatView()
                .frame(width: 28, height: 28)
        case .browser:
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
        }
    }
}

// MARK: - Demo Banner

struct DemoBanner: View {
    @Binding var isVisible: Bool
    @State private var appear = false

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "#AB9FF2"))
                    .font(.system(size: 14))

                Text("⚡ DEMO MODE — Données fictives à titre d'illustration")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#AB9FF2"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#2A1F4A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(hex: "#AB9FF2").opacity(0.4), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .offset(y: appear ? 0 : -60)
            .opacity(appear ? 1 : 0)

            Spacer()
        }
        .padding(.top, 56)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                appear = true
            }
        }
    }
}
// MARK: - Appended Views for compilation



struct WelcomeView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(hex: "#AB9FF2").ignoresSafeArea()
            
            Image("Phantom-Logo-White")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animate = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.currentRoute = .mainWallet
                }
            }
        }
    }
}
// MARK: - Reusable Components

struct FloatingSparkle: View {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "sparkle")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(Color(hex: "#5A4C9A")) // Dark purple sparkles
            .position(x: x, y: y)
            .scaleEffect(isAnimating ? 1.2 : 0.8)
            .opacity(isAnimating ? 1 : 0.3)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(delay)) {
                    isAnimating = true
                }
            }
    }
}

struct FloatingToken: View {
    let iconView: AnyView
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let delay: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        iconView
            .frame(width: size, height: size)
            .position(x: x, y: isAnimating ? y - 10 : y + 10)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(delay)) {
                    isAnimating = true
                }
            }
    }
}



struct BiometricAuthView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var useBiometrics = false
    
    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        withAnimation {
                            viewModel.currentRoute = .welcome
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Progress Bars
                    HStack(spacing: 4) {
                        Capsule().fill(Color.white).frame(width: 40, height: 3)
                        Capsule().fill(Color(hex: "#4A4A4A")).frame(width: 40, height: 3)
                        Capsule().fill(Color(hex: "#4A4A4A")).frame(width: 40, height: 3)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            viewModel.currentRoute = .mainWallet
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Illustration
                ZStack {
                    // Dark Squiggly Background (Simplified using circles and curves for effect)
                    Path { path in
                        path.move(to: CGPoint(x: 40, y: 120))
                        path.addQuadCurve(to: CGPoint(x: 100, y: 160), control: CGPoint(x: 60, y: 180))
                        path.addQuadCurve(to: CGPoint(x: 160, y: 100), control: CGPoint(x: 140, y: 140))
                    }
                    .stroke(Color(hex: "#2A2A2A"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .offset(x: -40, y: 20)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 120, y: 60))
                        path.addQuadCurve(to: CGPoint(x: 180, y: 120), control: CGPoint(x: 160, y: 40))
                        path.addQuadCurve(to: CGPoint(x: 220, y: 180), control: CGPoint(x: 200, y: 160))
                    }
                    .stroke(Color(hex: "#2A2A2A"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .offset(x: 20, y: 40)
                    
                    // Main Lock Shape
                    VStack(spacing: -12) {
                        // Lock Shackle (Unlocked)
                        ZStack {
                            Path { path in
                                path.addArc(center: CGPoint(x: 50, y: 50), radius: 35, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            }
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .frame(width: 100, height: 50)
                            
                            // Unlocked opening (cutting out right side)
                            Rectangle()
                                .fill(Color(hex: "#1A1A1A"))
                                .frame(width: 20, height: 40)
                                .offset(x: 35, y: 10)
                        }
                        
                        // Lock Body
                        ZStack {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color(hex: "#433A70")) // Darker purple left side
                                    .frame(width: 40, height: 100)
                                Rectangle()
                                    .fill(Color(hex: "#A393FA")) // Lighter purple right side
                                    .frame(width: 80, height: 100)
                            }
                            .cornerRadius(4)
                            
                            // Keyhole
                            VStack(spacing: -2) {
                                Circle()
                                    .fill(Color(hex: "#1A1A1A"))
                                    .frame(width: 20, height: 20)
                                
                                // Keyhole bottom part using custom triangle-ish shape
                                Path { path in
                                    path.move(to: CGPoint(x: 10, y: 0))
                                    path.addLine(to: CGPoint(x: 16, y: 20))
                                    path.addLine(to: CGPoint(x: 4, y: 20))
                                    path.closeSubpath()
                                }
                                .fill(Color(hex: "#1A1A1A"))
                                .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .offset(y: -20)
                    
                    // Sparkles
                    Image(systemName: "sparkle")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#FDF5A9"))
                        .offset(x: -80, y: -60)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FDF5A9"))
                        .offset(x: 80, y: 50)
                        
                    Image(systemName: "sparkle")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#FDF5A9"))
                        .offset(x: 60, y: -20)
                }
                .frame(height: 250)
                
                Spacer()
                
                // Texts
                VStack(spacing: 12) {
                    Text("Protect your wallet")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Adding biometric security will ensure that\nyou are the only one that can access your\nwallet.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "#B0B0B0"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Device Toggle Component
                HStack(spacing: 16) {
                    Image(systemName: "faceid")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Device")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Use Device Authentication")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#8B8B8B"))
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $useBiometrics)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#14F195")))
                }
                .padding()
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

// MARK: - Chats View
struct ChatsView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @StateObject private var networkManager = NetworkManager()
    
    var trendingGroups: [[Token]] {
        let tokens = networkManager.memeCoins
        var groups: [[Token]] = []
        for i in stride(from: 0, to: tokens.count, by: 3) {
            let chunk = Array(tokens[i..<min(i + 3, tokens.count)])
            groups.append(chunk)
        }
        return groups
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2C2C2E"))
                            .frame(width: 44, height: 44)
                        Text(viewModel.profileEmoji)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.username)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text("Chats")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // MARK: - Tendance
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tendance")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            if networkManager.isLoadingTokens && networkManager.memeCoins.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#A393FA")))
                                        .padding(.top, 40)
                                    Spacer()
                                }
                            } else if trendingGroups.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("Aucune tendance")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                        .padding(.top, 40)
                                    Spacer()
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        Spacer().frame(width: 4)
                                        ForEach(0..<trendingGroups.count, id: \.self) { index in
                                            TrendingCardView(tokens: trendingGroups[index])
                                        }
                                        Spacer().frame(width: 4)
                                    }
                                }
                            }
                        }
                        
                        // MARK: - RÃ©cent
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RÃ©cent")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                Spacer().frame(height: 40)
                                
                                // Placeholder graphic matching the screenshot
                                ZStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 70))
                                        .foregroundColor(Color(hex: "#2C2C2E"))
                                        .rotationEffect(.degrees(15))
                                        
                                    Image(systemName: "xmark")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(Color(hex: "#3A3A3A"))
                                        .offset(y: 20)
                                }
                                
                                Text("Aucuns chats Ã  afficher pour le moment.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#8E8E93"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            if networkManager.memeCoins.isEmpty {
                networkManager.fetchMemeCoins()
            }
        }
    }
}

struct TrendingCardView: View {
    let tokens: [Token]
    
    private func formatMarketCap(_ mc: Double?) -> String {
        guard let mc = mc, mc > 0 else { return "\(viewModel.currency)-- MC" }
        if mc >= 1_000_000_000 {
            return String(format: "\(viewModel.currency)%.1fB MC", mc / 1_000_000_000)
        } else if mc >= 1_000_000 {
            return String(format: "\(viewModel.currency)%.1fM MC", mc / 1_000_000)
        } else if mc >= 1_000 {
            return String(format: "\(viewModel.currency)%.1fK MC", mc / 1_000)
        } else {
            return String(format: "\(viewModel.currency)%.0f MC", mc)
        }
    }
    
    private func usersCount(for symbol: String) -> Int {
        let hash = abs(symbol.hashValue)
        return (hash % 40) + 2
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(tokens) { token in
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2A2A2A"))
                            .frame(width: 44, height: 44)
                        
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
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                @unknown default:
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(Color(hex: "#8E8E93"))
                                }
                            }
                            .frame(width: 44, height: 44)
                        } else {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color(hex: "#8E8E93"))
                        }
                    }
                    
                    // Texts
                    VStack(alignment: .leading, spacing: 4) {
                        Text(token.symbol.uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(formatMarketCap(token.marketCapValue))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    
                    Spacer()
                    
                    // Users count
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text("\(usersCount(for: token.symbol))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(24)
    }
}


