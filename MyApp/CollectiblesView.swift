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
                        
                        // Extract first letter of username
                        let initial = viewModel.username.count > 1 ? String(viewModel.username.dropFirst().prefix(1)).uppercased() : "U"
                        
                        Text(initial)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.white)
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
                    
                    // Holographic Card Image
                    Image("PhantomCard")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
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
                        HStack(spacing: -10) {
                            Image("bonk")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 2))
                                .zIndex(3)
                                
                            Image("usdc")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 2))
                                .zIndex(2)
                                
                            Image("solana")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "#1C1C1E"), lineWidth: 2))
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
