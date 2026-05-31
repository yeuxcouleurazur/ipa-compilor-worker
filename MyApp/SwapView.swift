import SwiftUI

struct SwapView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @StateObject private var networkManager = NetworkManager()
    
    @State private var payAmount: String = "0"
    @State private var receiveAmount: String = "0"
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                    
                    filterPills
                        .padding(.bottom, 24)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                    
                    swapCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                    
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section(header: stickyTabsHeader) {
                            if networkManager.isLoadingTokens && networkManager.memeCoins.isEmpty {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#A393FA")))
                                    .padding(.top, 40)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(networkManager.memeCoins.enumerated()), id: \.element.id) { index, token in
                                        NavigationLink(destination: TokenDetailView(token: token)) {
                                            SwapTokenRowView(token: token, rank: index + 1)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .opacity(appearAnimation ? 1 : 0)
                                        .offset(y: appearAnimation ? 0 : 20)
                                        .animation(
                                            .easeOut(duration: 0.5).delay(Double(index) * 0.05 + 0.3),
                                            value: appearAnimation
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100) // Tab bar padding
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            networkManager.fetchMemeCoins()
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFB09C")) // Peach background
                    .frame(width: 44, height: 44)
                Text(viewModel.profileEmoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.username)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#8E8E93"))
                Text("Échanger")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button {
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Filter Pills
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Spacer().frame(width: 4)
                pillButton(icon: "sparkles", text: "Featured")
                pillButton(icon: "clock.arrow.circlepath", text: "Top Volume")
                pillButton(icon: "arrow.up", text: "Top Gainers")
                Spacer().frame(width: 4)
            }
        }
    }
    
    private func pillButton(icon: String, text: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#A393FA"))
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(hex: "#1C1C1E"))
            .clipShape(Capsule())
        }
    }
    
    // MARK: - Swap Card
    private var swapCard: some View {
        ZStack {
            VStack(spacing: 4) {
                // Pay Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vous payez")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#8E8E93"))
                    
                    HStack {
                        Text(payAmount)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "#4A4A4A"))
                        Spacer()
                        tokenSelector(icon: "solana", symbol: "SOL", isSystem: false, imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png")
                    }
                    
                    HStack {
                        Spacer()
                        Text("0 SOL")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                }
                .padding(16)
                .background(Color(hex: "#1C1C1E"))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                // Receive Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vous recevez")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#8E8E93"))
                    
                    HStack {
                        Text(receiveAmount)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "#4A4A4A"))
                        Spacer()
                        tokenSelector(icon: "usdt", symbol: "USDT", isSystem: false, imageUrl: "https://assets.coingecko.com/coins/images/325/large/Tether.png")
                    }
                    
                    HStack {
                        Spacer()
                        Text("0 USDT")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                }
                .padding(16)
                .background(Color(hex: "#1C1C1E"))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            // Swap Arrow Button
            Button {
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#A393FA"))
                        .frame(width: 44, height: 44)
                    PhantomSwapIcon()
                        .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func tokenSelector(icon: String, symbol: String, isSystem: Bool, imageUrl: String? = nil) -> some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color(hex: "#2A2A2A"))
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Circle().fill(Color(hex: "#2A2A2A"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                } else if isSystem {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                } else {
                    if icon == "solana" {
                        Image(systemName: "s.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#14F195"))
                    } else if icon == "usdt" {
                        Image(systemName: "t.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#26A17B"))
                    } else {
                        Image(systemName: icon)
                            .foregroundColor(.white)
                    }
                }
                Text(symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color(hex: "#A393FA"))
                    .font(.system(size: 14))
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: "#8E8E93"))
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#2C2C2E"))
            .clipShape(Capsule())
        }
    }
    
    // MARK: - Sticky Tabs Header
    private var stickyTabsHeader: some View {
        VStack(spacing: 16) {
            // Jetons / Perps
            HStack(spacing: 16) {
                Text("Jetons")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Perps")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#5C5C5E"))
                Spacer()
            }
            
            // Sub-filters
            HStack(spacing: 8) {
                filterDropdown(text: "Rang")
                filterDropdown(text: "Solana")
                filterDropdown(text: "24 h")
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.black)
    }
    
    private func filterDropdown(text: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#1C1C1E"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - SwapTokenRowView
struct SwapTokenRowView: View {
    let token: Token
    let rank: Int
    
    var body: some View {
        HStack(spacing: 14) {
            // Rank
            rankBadge
                .frame(width: 24)
            
            // Token Image with Solana overlay
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = token.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color(hex: "#2A2A2A"))
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Circle().fill(Color(hex: "#2A2A2A"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Circle().fill(token.color)
                        .frame(width: 44, height: 44)
                }
                
                // Mini Solana Badge
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 16, height: 16)
                    Image(systemName: "s.circle.fill")
                        .foregroundColor(Color(hex: "#14F195"))
                        .font(.system(size: 14))
                }
                .offset(x: 2, y: 2)
            }
            
            // Ticker & Market Cap
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(token.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    if token.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "#A393FA"))
                            .font(.system(size: 12))
                    }
                }
                Text(token.marketCap + " MC")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            
            Spacer()
            
            // Price & Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(token.formattedValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(token.formattedChangePercent)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(token.changeColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var rankBadge: some View {
        if rank == 1 {
            ZStack {
                Circle().fill(Color(hex: "#FFD700"))
                    .frame(width: 20, height: 20)
                Text("1")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
        } else if rank == 2 {
            ZStack {
                Circle().fill(Color(hex: "#E0E0E0"))
                    .frame(width: 20, height: 20)
                Text("2")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
        } else if rank == 3 {
            ZStack {
                Circle().fill(Color(hex: "#CD7F32")) // Bronze
                    .frame(width: 20, height: 20)
                Text("3")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
        } else {
            Text("\(rank)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#8E8E93"))
        }
    }
}
