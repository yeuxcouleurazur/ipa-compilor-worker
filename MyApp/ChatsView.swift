import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    
    // Mock Data for Trending
    let trendingCards = [
        [
            ChatToken(name: "ROLANDO", mc: "$768K MC", users: 36, image: "person.circle.fill", color: "#E03C31"),
            ChatToken(name: "EROSION", mc: "$245K MC", users: 17, image: "globe", color: "#2775CA"),
            ChatToken(name: "SPCX", mc: "$7.7M MC", users: 15, image: "xmark.circle.fill", color: "#FFFFFF")
        ],
        [
            ChatToken(name: "BULL", mc: "$3.5M MC", users: 14, image: "hare.fill", color: "#B37A4C"),
            ChatToken(name: "$HACHI", mc: "$2.8M MC", users: 8, image: "pawprint.fill", color: "#F3BA2F"),
            ChatToken(name: "10m", mc: "$276K MC", users: 7, image: "circle.circle.fill", color: "#A393FA")
        ],
        [
            ChatToken(name: "SHIKOKU", mc: "$1.1M MC", users: 4, image: "pawprint.fill", color: "#F3BA2F"),
            ChatToken(name: "SOL", mc: "$48B MC", users: 4, image: "s.circle.fill", color: "#14F195"),
            ChatToken(name: "BTCBANK", mc: "$289K MC", users: 1, image: "bitcoinsign.circle.fill", color: "#F7931A")
        ]
    ]
    
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
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    Spacer().frame(width: 4)
                                    ForEach(0..<trendingCards.count, id: \.self) { index in
                                        TrendingCardView(tokens: trendingCards[index])
                                    }
                                    Spacer().frame(width: 4)
                                }
                            }
                        }
                        
                        // MARK: - Récent
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Récent")
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
                                
                                Text("Aucuns chats à afficher pour le moment.")
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
    }
}

struct ChatToken: Identifiable {
    let id = UUID()
    let name: String
    let mc: String
    let users: Int
    let image: String
    let color: String
}

struct TrendingCardView: View {
    let tokens: [ChatToken]
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(tokens) { token in
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2A2A2A"))
                            .frame(width: 44, height: 44)
                        Image(systemName: token.image)
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: token.color))
                    }
                    
                    // Texts
                    VStack(alignment: .leading, spacing: 4) {
                        Text(token.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(token.mc)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    
                    Spacer()
                    
                    // Users count
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text("\(token.users)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.85) // 85% of screen width
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(24)
    }
}
