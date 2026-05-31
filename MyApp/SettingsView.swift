import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true
    @State private var showDemoInfo = false
    @State private var showAdminPanel = false

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Nav
                    HStack {
                        Text("Settings")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Profile Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#AB9FF2"), Color(hex: "#7C5CFC")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                            Text(viewModel.profileEmoji)
                                .font(.system(size: 36))
                        }

                        VStack(spacing: 4) {
                            Text(viewModel.walletName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            HStack(spacing: 6) {
                                Text(viewModel.username)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                                Button {} label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#AB9FF2"))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#232323"))
                    )
                    .padding(.horizontal, 16)

                    // Demo Notice
                    Button {
                        showDemoInfo.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "#AB9FF2").opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#AB9FF2"))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Application Démo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Toutes les données sont fictives")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6B6B6B"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#3A3A3A"))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#232323"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color(hex: "#AB9FF2").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Settings Groups
                    VStack(spacing: 12) {
                        settingsGroup(title: "Security", items: [
                            SettingsItem(icon: "faceid", label: "Face ID / Biometric", color: "#3DD68C", hasToggle: true, toggleValue: $biometricEnabled),
                            SettingsItem(icon: "lock.fill", label: "Auto-Lock", color: "#AB9FF2"),
                            SettingsItem(icon: "key.fill", label: "Export Private Key", color: "#FF6464"),
                        ])

                        settingsGroup(title: "Preferences", items: [
                            SettingsItem(icon: "bell.fill", label: "Notifications", color: "#F7931A", hasToggle: true, toggleValue: $notificationsEnabled),
                            SettingsItem(icon: "moon.fill", label: "Dark Mode", color: "#AB9FF2"),
                            SettingsItem(icon: "globe", label: "Language", color: "#627EEA", value: "English"),
                        ])

                        settingsGroup(title: "About", items: [
                            SettingsItem(icon: "doc.text.fill", label: "Privacy Policy", color: "#6B6B6B"),
                            SettingsItem(icon: "shield.fill", label: "Terms of Service", color: "#6B6B6B"),
                            SettingsItem(icon: "star.fill", label: "Rate the App", color: "#F7931A"),
                        ])
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Version
                    HStack {
                        Spacer()
                        Text("GhostWallet Demo v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#3A3A3A"))
                        Spacer()
                    }
                    .padding(.top, 24)
                    
                    // Hidden Admin Button
                    Button {
                        showAdminPanel.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.clear) // Completely hidden
                            .frame(width: 44, height: 44)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .alert("Mode Démo", isPresented: $showDemoInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Cette application est une démonstration uniquement. Aucune vraie cryptomonnaie n'est impliquée. Toutes les données affichées sont fictives à titre d'illustration.")
        }
        .sheet(isPresented: $showAdminPanel) {
            AdminPanelView()
                .environmentObject(viewModel)
        }
    }

    func settingsGroup(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#4A4A4A"))
                .padding(.horizontal, 14)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    settingsRow(item: item)
                    if index < items.count - 1 {
                        Divider()
                            .background(Color(hex: "#2A2A2A"))
                            .padding(.horizontal, 14)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#232323"))
            )
        }
    }

    @ViewBuilder
    func settingsRow(item: SettingsItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: item.color).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: item.color))
            }

            Text(item.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            if item.hasToggle, let binding = item.toggleValue {
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .tint(Color(hex: "#AB9FF2"))
                    .scaleEffect(0.85)
            } else if let value = item.value {
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#6B6B6B"))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#3A3A3A"))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#3A3A3A"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

struct SettingsItem {
    let icon: String
    let label: String
    let color: String
    var hasToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    var value: String? = nil
}

// MARK: - Admin Panel
struct AdminPanelView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var simSelectedTokenId: UUID? = nil
    @State private var simType: Transaction.TransactionType = .receive
    @State private var simAmount: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Global Settings")) {
                    TextField("Username", text: $viewModel.username)
                    TextField("Wallet Name", text: $viewModel.walletName)
                    TextField("Profile Emoji", text: $viewModel.profileEmoji)
                }

                Section(header: Text("Token Balances (Amounts)")) {
                    ForEach($viewModel.tokens) { $token in
                        HStack {
                            Text(token.symbol)
                            Spacer()
                            TextField("Amount", value: $token.amount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: token.amount) { _ in
                                    viewModel.updateBalances()
                                }
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: TokenSearchView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Crypto (CoinGecko)")
                        }
                    }
                }
                
                Section(header: Text("Simulate Transaction")) {
                    if !viewModel.tokens.isEmpty {
                        Picker("Token", selection: Binding(
                            get: { simSelectedTokenId ?? viewModel.tokens.first!.id },
                            set: { simSelectedTokenId = $0 }
                        )) {
                            ForEach(viewModel.tokens) { token in
                                Text(token.symbol).tag(token.id)
                            }
                        }
                    }
                    Picker("Type", selection: $simType) {
                        Text("Receive").tag(Transaction.TransactionType.receive)
                        Text("Send").tag(Transaction.TransactionType.send)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Amount", text: $simAmount)
                        .keyboardType(.decimalPad)
                    
                    Button("Trigger Simulation") {
                        simulateTransaction()
                    }
                    .disabled(simAmount.isEmpty || viewModel.tokens.isEmpty)
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarItems(trailing: Button("Done") {
                viewModel.sortTokens()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func simulateTransaction() {
        guard !viewModel.tokens.isEmpty,
              let amountDouble = Double(simAmount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let targetId = simSelectedTokenId ?? viewModel.tokens.first!.id
        guard let tokenIndex = viewModel.tokens.firstIndex(where: { $0.id == targetId }) else { return }
        
        let token = viewModel.tokens[tokenIndex]
        let usdValue = amountDouble * token.dynamicCurrentPrice
        
        // Add transaction
        let tx = Transaction(
            type: simType,
            token: token.symbol,
            amount: amountDouble,
            valueUSD: usdValue,
            date: Date(),
            address: simType == .send ? "0xSim...ulated" : "0xExt...ernal",
            status: "Réussite",
            network: "Ethereum", // Mock network
            tokenImageUrl: token.imageUrl
        )
        
        viewModel.transactions.insert(tx, at: 0)
        
        // Update balance if needed
        if simType == .receive {
            viewModel.tokens[tokenIndex].amount += amountDouble
        } else if simType == .send {
            viewModel.tokens[tokenIndex].amount = max(0, viewModel.tokens[tokenIndex].amount - amountDouble)
        }
        
        viewModel.updateBalances()
        
        simAmount = ""
        // Optional: show a small alert or haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Token Search View
struct TokenSearchView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var searchResults: [CoinGeckoSearchItem] = []
    @State private var isSearching = false
    @State private var isAdding = false
    @State private var showSuccessAlert = false

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search CoinGecko...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { newValue in
                        performSearch(query: newValue)
                    }
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding()
            
            List(searchResults) { item in
                Button(action: {
                    addToken(item: item)
                }) {
                    HStack {
                        AsyncImage(url: URL(string: item.large)) { phase in
                            switch phase {
                            case .empty:
                                Circle().fill(Color.gray.opacity(0.3))
                            case .success(let image):
                                image.resizable().scaledToFit()
                            case .failure:
                                Circle().fill(Color.gray.opacity(0.3))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.symbol.uppercased())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isAdding)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Add Token")
        .alert("Succès", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Le token a été ajouté à votre portefeuille avec succès !")
        }
        .overlay(
            Group {
                if isAdding {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Fetching Market Data...")
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                    }
                }
            }
        )
    }
    
    private func performSearch(query: String) {
        guard query.count > 1 else {
            searchResults = []
            return
        }
        isSearching = true
        Task {
            do {
                let results = try await CryptoAPI.search(query: query)
                DispatchQueue.main.async {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSearching = false
                }
            }
        }
    }
    
    private func addToken(item: CoinGeckoSearchItem) {
        isAdding = true
        Task {
            let details = await CryptoAPI.fetchSpecificCoin(id: item.id, fallbackItem: item)
            DispatchQueue.main.async {
                if !viewModel.tokens.contains(where: { $0.coinGeckoId == details.id }) {
                    let newToken = Token(
                        name: details.name,
                        symbol: details.symbol.uppercased(),
                        amount: 0.0,
                        change24h: details.price_change_24h ?? 0.0,
                        changePercent24h: details.price_change_percentage_24h ?? 0.0,
                        iconName: "",
                        color: Color(hex: "#106941"),
                        isVerified: true,
                        imageUrl: details.image,
                        rank: Int(details.market_cap_rank ?? 0),
                        coinGeckoId: details.id,
                        dynamicCurrentPrice: details.current_price ?? 0.0,
                        marketCapValue: details.market_cap
                    )
                    viewModel.tokens.append(newToken)
                    viewModel.updateBalances()
                }
                isAdding = false
                showSuccessAlert = true
            }
        }
    }
}
