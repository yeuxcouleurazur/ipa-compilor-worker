import SwiftUI

struct CollectiblesView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    let mockNFTs: [MockNFT] = [
        MockNFT(name: "Ghost #1337", collection: "Ghost Gang", color1: "#AB9FF2", color2: "#7C5CFC", emoji: "👻"),
        MockNFT(name: "Phantom Ape #42", collection: "Phantom Apes", color1: "#F7931A", color2: "#FF6B35", emoji: "🦍"),
        MockNFT(name: "Crypto Punk #8899", collection: "CryptoPunks", color1: "#3DD68C", color2: "#14F195", emoji: "🤖"),
        MockNFT(name: "DeGod #2201", collection: "DeGods", color1: "#627EEA", color2: "#9945FF", emoji: "🏛️"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Text("Collectibles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {} label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                if mockNFTs.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("🖼️")
                            .font(.system(size: 56))
                        Text("No collectibles yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                        Text("Your NFTs and digital collectibles\nwill appear here")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#4A4A4A"))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(mockNFTs) { nft in
                                NFTCardView(nft: nft)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
}

struct MockNFT: Identifiable {
    let id = UUID()
    let name: String
    let collection: String
    let color1: String
    let color2: String
    let emoji: String
}

struct NFTCardView: View {
    let nft: MockNFT
    @State private var pressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // NFT Art Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: nft.color1), Color(hex: nft.color2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)

                VStack(spacing: 4) {
                    Text(nft.emoji)
                        .font(.system(size: 48))
                    Text("DEMO")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(nft.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(nft.collection)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#232323"))
        )
        .scaleEffect(pressed ? 0.96 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { isPressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                pressed = isPressing
            }
        }, perform: {})
    }
}
