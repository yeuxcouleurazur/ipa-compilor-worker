import SwiftUI

struct CollectiblesView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea() // Matching the very dark background
            
            VStack(alignment: .leading, spacing: 32) {
                // MARK: - Header
                HStack(spacing: 12) {
                    // Profile Icon
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
                        Text("Espèces")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // MARK: - Balance & Card
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Solde")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text("$0.00")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Shiny Card Graphic
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#E0C3FC"), Color(hex: "#F9F047"), Color(hex: "#FF9A9E"), Color(hex: "#8EC5FC")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.8), Color.clear, Color.clear, Color.white.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blendMode(.overlay)
                            )
                        
                        // Ghost Logo
                        Image(systemName: "ghost.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#2B2859"))
                            .position(x: 18, y: 16)
                        
                        // Visa Text
                        Text("VISA")
                            .font(.system(size: 10, weight: .heavy, design: .default))
                            .italic()
                            .foregroundColor(Color(hex: "#1A1F71"))
                            .position(x: 74, y: 46)
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Add Cash Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Ajouter des espèces")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    // Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Overlapping Icons
                        HStack(spacing: -14) {
                            // Shiba mock
                            Circle()
                                .fill(Color(hex: "#F3BA2F")) 
                                .frame(width: 44, height: 44)
                                .overlay(Text("🐶").font(.system(size: 20)))
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 3))
                                .zIndex(3)
                            
                            // USDC mock
                            Circle()
                                .fill(Color(hex: "#2775CA"))
                                .frame(width: 44, height: 44)
                                .overlay(Text("$").font(.system(size: 20, weight: .bold)).foregroundColor(.white))
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 3))
                                .zIndex(2)
                            
                            // Solana mock
                            Circle()
                                .fill(Color(hex: "#14F195"))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    LinearGradient(colors: [Color(hex: "#9945FF"), Color(hex: "#14F195")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .clipShape(Circle())
                                )
                                .overlay(
                                    Text("S")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .italic()
                                        .foregroundColor(.white)
                                )
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 3))
                                .zIndex(1)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Vente rapide de cryptomonnaies")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color(hex: "#EBEBEB"))
                            
                            Text("Instantané • Aucuns frais sur les stablecoins")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(hex: "#8E8E93"))
                        }
                        
                        Text("Aucun jeton à vendre")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#252525"))
                            )
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(hex: "#1C1C1E"))
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
}
