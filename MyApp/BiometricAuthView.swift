import SwiftUI

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
