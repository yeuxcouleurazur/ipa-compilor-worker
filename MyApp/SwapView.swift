import SwiftUI

enum SwapSide {
    case pay
    case receive
}

struct SwapView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @StateObject private var networkManager = NetworkManager()
    
    @State private var payAmount: String = "0"
    @State private var receiveAmount: String = "0"
    @State private var appearAnimation = false
    
    @State private var paySymbol: String = "SOL"
    @State private var receiveSymbol: String = "Phantom"
    
    @State private var showTokenSelection = false
    @State private var selectingSide: SwapSide = .pay
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()
            
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
        .sheet(isPresented: $showTokenSelection) {
            TokenSelectionSheet(
                side: selectingSide,
                selectedTokenSymbol: selectingSide == .pay ? $paySymbol : $receiveSymbol
            )
            .environmentObject(viewModel)
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
                Text("Ãƒâ€°changer")
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
                            .foregroundColor(payAmount == "0" ? Color(hex: "#6B6B6B") : .white)
                        Spacer()
                        tokenSelectorButton(for: paySymbol, side: .pay)
                    }
                    
                    HStack {
                        Spacer()
                        Text("0 \(paySymbol)")
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
                            .foregroundColor(receiveAmount == "0" ? Color(hex: "#6B6B6B") : .white)
                        Spacer()
                        tokenSelectorButton(for: receiveSymbol, side: .receive)
                    }
                    
                    HStack {
                        Spacer()
                        Text(receiveSymbol == "Phantom" ? "\(viewModel.currency)0.00" : "0 \(receiveSymbol)")
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
                let temp = paySymbol
                paySymbol = receiveSymbol
                receiveSymbol = temp
            } label: {
                Image("Swap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private func tokenSelectorButton(for symbol: String, side: SwapSide) -> some View {
        Button {
            selectingSide = side
            showTokenSelection = true
        } label: {
            HStack(spacing: 8) {
                if symbol == "Phantom" {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0FF4F")) // Bright yellow
                            .frame(width: 24, height: 24)
                        Image("PhantomLogo-White")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .frame(width: 14, height: 14)
                    }
                } else if let token = viewModel.tokens.first(where: { $0.symbol == symbol }) {
                    if let urlString = token.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty: Circle().fill(Color(hex: "#2A2A2A"))
                            case .success(let image): image.resizable().scaledToFill()
                            case .failure: Circle().fill(Color(hex: "#2A2A2A"))
                            @unknown default: EmptyView()
                            }
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(token.color)
                            .frame(width: 24, height: 24)
                    }
                } else {
                    Circle().fill(Color.gray).frame(width: 24, height: 24)
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

// MARK: - Token Selection Sheet
struct TokenSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: WalletViewModel
    
    let side: SwapSide
    @Binding var selectedTokenSymbol: String
    
    @State private var searchText = ""
    let networks = ["Solana", "Ethereum", "Bitcoin", "Monad", "Base", "Sui"]
    @State private var selectedNetwork = "Solana"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#121212").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#8E8E93"))
                        TextField("Rechercher", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(Color(hex: "#1C1C1E"))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    // Network Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Spacer().frame(width: 8)
                            ForEach(networks, id: \.self) { network in
                                Button {
                                    selectedNetwork = network
                                } label: {
                                    Text(network)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedNetwork == network ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(selectedNetwork == network ? Color(hex: "#A393FA") : Color(hex: "#1C1C1E"))
                                        )
                                }
                            }
                            Spacer().frame(width: 8)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // Token List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Phantom Row
                            Button {
                                selectedTokenSymbol = "Phantom"
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#E0FF4F")) // Bright yellow
                                            .frame(width: 48, height: 48)
                                        Image("PhantomLogo-White")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.black)
                                            .frame(width: 28, height: 28)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Phantom")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color(hex: "#8E8E93"))
                                        Text("\(viewModel.currency)0.00")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color(hex: "#1C1C1E"))
                                .cornerRadius(16)
                            }
                            
                            Divider().background(Color(hex: "#2A2A2A")).padding(.vertical, 8)
                            
                            // Normal Tokens
                            ForEach(viewModel.tokens) { token in
                                Button {
                                    selectedTokenSymbol = token.symbol
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    tokenSelectionRow(token: token)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(side == .pay ? "Vous payez" : "Vous recevez")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func tokenSelectionRow(token: Token) -> some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = token.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: Circle().fill(Color(hex: "#2A2A2A"))
                        case .success(let image): image.resizable().scaledToFill()
                        case .failure: Circle().fill(Color(hex: "#2A2A2A"))
                        @unknown default: EmptyView()
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(token.color)
                        .frame(width: 48, height: 48)
                }
                
                // Network badge (mock based on name)
                ZStack {
                    Circle().fill(Color.black).frame(width: 18, height: 18)
                    Image("solana")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10)
                }
                .offset(x: 2, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(token.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    if token.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "#A393FA"))
                            .font(.system(size: 14))
                    }
                }
                Text("0 \(token.symbol)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            
            Spacer()
            
            Image(systemName: "info.circle")
                .foregroundColor(Color(hex: "#8E8E93"))
                .font(.system(size: 20))
        }
        .padding(16)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
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
                    Image("solana")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10)
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


