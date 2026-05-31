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

                    ActivityView()
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
                        Image(systemName: selectedTab == tab && tab == .home ? "house.fill" : (tab == .home ? "house" : (tab == .wallet ? "creditcard" : (tab == .swap ? "arrow.left.arrow.right" : (tab == .activity ? "message" : "magnifyingglass")))))
                            .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? (tab == .home ? Color(hex: "#AB9FF2") : .white) : Color(hex: "#6B6B6B"))
                            .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 16)
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
            Color(hex: "#1A1A1A").ignoresSafeArea()
            
            // Background Stars / Sparkles
            FloatingSparkle(x: 80, y: 120, size: 24, delay: 0.2)
            FloatingSparkle(x: UIScreen.main.bounds.width - 60, y: 160, size: 32, delay: 0.5)
            FloatingSparkle(x: 100, y: 380, size: 20, delay: 0.8)
            FloatingSparkle(x: UIScreen.main.bounds.width - 80, y: 400, size: 24, delay: 1.1)

            // Floating Icons Layer
            ZStack {
                // Top: Ethereum (White diamond in circle)
                FloatingToken(
                    iconView: AnyView(
                        ZStack {
                            Circle().fill(Color(hex: "#F2F2F2"))
                            Image(systemName: "diamond.fill").foregroundColor(.black)
                        }
                    ),
                    size: 70, x: UIScreen.main.bounds.width / 2, y: 100, delay: 0
                )
                
                // Left: Claynosaurz NFT (Dinosaur)
                FloatingToken(
                    iconView: AnyView(
                        Image("claynosaurz")
                            .resizable()
                            .scaledToFill()
                            .background(Circle().fill(Color.gray.opacity(0.3)))
                            .clipShape(Circle())
                    ),
                    size: 80, x: 70, y: 240, delay: 0.4
                )
                
                // Right: Polygon (Purple)
                FloatingToken(
                    iconView: AnyView(
                        ZStack {
                            Circle().fill(Color(hex: "#8247E5"))
                            Image(systemName: "hexagon.fill").foregroundColor(.white)
                                .font(.system(size: 32))
                        }
                    ),
                    size: 70, x: UIScreen.main.bounds.width - 60, y: 280, delay: 0.2
                )
                
                // Center: Phantom Ghost
                FloatingToken(
                    iconView: AnyView(
                        Image("phantom_ghost")
                            .resizable()
                            .scaledToFit()
                            // Placeholder if missing
                            .overlay(
                                Image(systemName: "ghost.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .opacity(0.1) // Visible only if asset is missing
                            )
                    ),
                    size: 110, x: UIScreen.main.bounds.width / 2, y: 320, delay: 0.6
                )
                
                // Bottom Left: Bitcoin
                FloatingToken(
                    iconView: AnyView(
                        ZStack {
                            Circle().fill(Color(hex: "#F7931A"))
                            Image(systemName: "bitcoinsign").foregroundColor(.white)
                                .font(.system(size: 32, weight: .bold))
                        }
                    ),
                    size: 80, x: 80, y: 460, delay: 0.8
                )
                
                // Bottom Center: Solana
                FloatingToken(
                    iconView: AnyView(
                        ZStack {
                            Circle().fill(Color(hex: "#14F195"))
                            Image(systemName: "s.circle.fill").foregroundColor(.white)
                                .font(.system(size: 40))
                        }
                    ),
                    size: 90, x: UIScreen.main.bounds.width / 2, y: 560, delay: 1.0
                )
                
                // Bottom Right: Pudgy Penguin NFT
                FloatingToken(
                    iconView: AnyView(
                        Image("pudgy_penguin")
                            .resizable()
                            .scaledToFill()
                            .background(Circle().fill(Color.gray.opacity(0.3)))
                            .clipShape(Circle())
                    ),
                    size: 70, x: UIScreen.main.bounds.width - 70, y: 500, delay: 0.5
                )
            }

            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Welcome to Phantom")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("To get started, create a new wallet or import\nan existing one.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "#B0B0B0"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 24)
                
                // Page indicator dots
                HStack(spacing: 6) {
                    Capsule()
                        .fill(Color(hex: "#AB9FF2"))
                        .frame(width: 20, height: 4)
                    Circle()
                        .fill(Color(hex: "#3A3A3A"))
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(Color(hex: "#3A3A3A"))
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(Color(hex: "#3A3A3A"))
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(Color(hex: "#3A3A3A"))
                        .frame(width: 4, height: 4)
                }
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            viewModel.currentRoute = .biometricSetup
                        }
                    }) {
                        Text("Create a new wallet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#AB9FF2"))
                            .cornerRadius(28)
                    }
                    
                    Button(action: {
                        // Normally this would go to import screen
                        withAnimation {
                            viewModel.currentRoute = .biometricSetup
                        }
                    }) {
                        Text("Import an existing wallet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
