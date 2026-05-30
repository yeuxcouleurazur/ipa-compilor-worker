import SwiftUI

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
