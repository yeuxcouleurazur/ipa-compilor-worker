import SwiftUI
import Combine

// MARK: - Models

enum AppRoute {
    case welcome
    case biometricSetup
    case mainWallet
}

struct Token: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    var amount: Double
    var valueUSD: Double {
        return amount * currentPrice
    }
    let change24h: Double
    let changePercent24h: Double
    let iconName: String
    let color: Color
    let isVerified: Bool
    var imageUrl: String?
    var rank: Int?
    var coinGeckoId: String?
    var dynamicCurrentPrice: Double?

    // Extended Information
    var currentPrice: Double {
        if let dynPrice = dynamicCurrentPrice { return dynPrice }
        if symbol == "BTC" { return 65430.21 }
        if symbol == "SOL" { return 182.61 }
        if symbol == "USDT" { return 1.00 }
        if symbol == "CLAWD" { return 0.00031 }
        return 1.0
    }
    var marketCapValue: Double?
    var marketCap: String {
        guard let mc = marketCapValue else { return "$47.76B" }
        if mc >= 1_000_000_000 {
            return String(format: "$%.1fB", mc / 1_000_000_000)
        } else if mc >= 1_000_000 {
            return String(format: "$%.0fM", mc / 1_000_000)
        } else if mc >= 1_000 {
            return String(format: "$%.0fK", mc / 1_000)
        }
        return String(format: "$%.0f", mc)
    }
    var totalSupply: String = "627.4M"
    var circulatingSupply: String = "578.45M"
    var creationDate: String = "Mar 16, 2020"
    var aboutText: String = "SOL is the native token of the Solana blockchain. Its technical co-founder, Anatoly Yakovenko, was fed up with blockchains that..."

    var formattedValue: String {
        if valueUSD == 0 { return "$0.00" }
        if valueUSD < 0.01 { return "<$0.01" }
        return String(format: "$%.2f", valueUSD)
    }

    var formattedAmount: String {
        if amount == 0 { return "0 \(symbol)" }
        if amount < 0.001 {
            return "< 0.001 \(symbol)"
        }
        if amount >= 1000 {
            return "\(String(format: "%.5f", amount)) \(symbol)"
        }
        return "\(String(format: "%.5g", amount)) \(symbol)"
    }

    var formattedChangePercent: String {
        let prefix = changePercent24h >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", changePercent24h))%"
    }

    var formattedChange: String {
        let prefix = change24h >= 0 ? "+" : ""
        if abs(change24h) < 0.01 { return change24h >= 0 ? "+<$0.01" : "-<$0.01" }
        return "\(prefix)\(String(format: "$%.2f", change24h))"
    }

    var changeColor: Color {
        change24h >= 0 ? Color(hex: "#3DD68C") : Color(hex: "#FF6464")
    }
}

struct NFT: Identifiable {
    let id = UUID()
    let name: String
    let collection: String
    let imageName: String
    let floorPrice: Double
}

struct Transaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let token: String
    let amount: Double
    let valueUSD: Double
    let date: Date
    let address: String
    let status: String
    let network: String
    let tokenImageUrl: String?

    enum TransactionType {
        case send, receive, swap, buy, interaction
        var icon: String {
            switch self {
            case .send: return "arrow.up.right"
            case .receive: return "arrow.down"
            case .swap: return "arrow.2.squarepath"
            case .buy: return "dollarsign"
            case .interaction: return "checkmark"
            }
        }
        var label: String {
            switch self {
            case .send: return "Envoyé"
            case .receive: return "Reçu"
            case .swap: return "Échangé"
            case .buy: return "Acheté"
            case .interaction: return "Interaction application"
            }
        }
        var color: Color {
            switch self {
            case .send: return Color(hex: "#FF6464")
            case .receive: return Color(hex: "#106941")
            case .swap: return Color(hex: "#AB9FF2")
            case .buy: return Color(hex: "#106941")
            case .interaction: return Color(hex: "#106941")
            }
        }
    }
}

// MARK: - ViewModel

class WalletViewModel: ObservableObject {
    @Published var walletName: String = "Account 1"
    @Published var username: String = "@MisterAzur075"
    @Published var profileEmoji: String = "👻"
    @Published var totalBalance: Double = 0.0
    @Published var change24h: Double = 559.32
    @Published var changePercent24h: Double = 8.71
    @Published var cashBalance: Double = 653.48
    @Published var selectedTab: Tab = .home
    @Published var currentRoute: AppRoute = .welcome
    @Published var isRefreshing: Bool = false
    @Published var showDemoOverlay: Bool = true

    @Published var tokens: [Token] = [
        Token(
            name: "Solana",
            symbol: "SOL",
            amount: 64.63,
            change24h: 339.73, // arbitrary to make +6.24% work or we just use formatted string
            changePercent24h: 6.24,
            iconName: "solana",
            color: Color(hex: "#9945FF"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png",
            rank: nil,
            coinGeckoId: "solana"
        ),
        Token(
            name: "USDT",
            symbol: "USDT",
            amount: 324.0,
            change24h: 0.0,
            changePercent24h: 0.0,
            iconName: "usdt",
            color: Color(hex: "#26A17B"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/325/large/Tether.png",
            rank: nil,
            coinGeckoId: "tether"
        ),
        Token(
            name: "solanaclawd",
            symbol: "CLAWD",
            amount: 6382.52,
            change24h: 0.02,
            changePercent24h: 8121.66,
            iconName: "clawd",
            color: Color(hex: "#5C2E91"),
            isVerified: false,
            imageUrl: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png", // Will be replaced by local asset or fallback
            rank: nil,
            coinGeckoId: nil
        ),
        Token(
            name: "Bitcoin",
            symbol: "BTC",
            amount: 0.0,
            change24h: 0.0,
            changePercent24h: 0.0,
            iconName: "bitcoin",
            color: Color(hex: "#F7931A"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            rank: nil,
            coinGeckoId: "bitcoin"
        ),
    ]

    init() {
        updateBalances()
        sortTokens()
    }

    func recalculate() {
        updateBalances()
        sortTokens()
    }
    
    func updateBalances() {
        totalBalance = tokens.reduce(0) { $0 + $1.valueUSD }
    }
    
    func sortTokens() {
        tokens.sort { $0.valueUSD > $1.valueUSD }
    }

    @Published var transactions: [Transaction] = [
        Transaction(
            type: .receive,
            token: "ETH",
            amount: 100,
            valueUSD: 202100,
            date: Date(),
            address: "0xd90e...f31b",
            status: "Réussite",
            network: "Ethereum",
            tokenImageUrl: "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png"
        ),
        Transaction(
            type: .interaction,
            token: "",
            amount: 0,
            valueUSD: 0,
            date: Date().addingTimeInterval(-1800),
            address: "Inconnu",
            status: "Réussite",
            network: "Ethereum",
            tokenImageUrl: nil
        ),
        Transaction(
            type: .interaction,
            token: "",
            amount: 0,
            valueUSD: 0,
            date: Date().addingTimeInterval(-3600),
            address: "Inconnu",
            status: "Réussite",
            network: "Solana",
            tokenImageUrl: nil
        ),
        Transaction(
            type: .interaction,
            token: "",
            amount: 0,
            valueUSD: 0,
            date: Date().addingTimeInterval(-86400),
            address: "Inconnu",
            status: "Réussite",
            network: "Solana",
            tokenImageUrl: nil
        )
    ]

    var formattedTotalBalance: String {
        String(format: "$%.2f", totalBalance)
    }

    var formattedChange: String {
        let prefix = change24h >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "$%.2f", change24h))"
    }

    var formattedChangePercent: String {
        let prefix = changePercent24h >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", changePercent24h))%"
    }

    var changeColor: Color {
        change24h >= 0 ? Color(hex: "#3DD68C") : Color(hex: "#FF6464")
    }

    enum Tab: String, CaseIterable {
        case home, wallet, swap, activity, browser

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .wallet: return "creditcard.fill"
            case .swap: return "arrow.left.arrow.right"
            case .activity: return "message.fill"
            case .browser: return "magnifyingglass"
            }
        }
    }

    func refreshBalances() {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isRefreshing = false
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Crypto API

class CryptoAPI {
    struct MarketChartResponse: Decodable {
        let prices: [[Double]]
    }

    static func fetchChartData(coinId: String, days: String) async throws -> [Double] {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart?vs_currency=usd&days=\(days)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad // Respect rate limits
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return generateMockChart(days: days)
            }
            
            let decoded = try JSONDecoder().decode(MarketChartResponse.self, from: data)
            return decoded.prices.compactMap { $0.last }
        } catch {
            print("API Error, using fallback: \(error)")
            return generateMockChart(days: days)
        }
    }
    
    private static func generateMockChart(days: String) -> [Double] {
        var mockData: [Double] = []
        var currentPrice = 100.0
        let points = days == "1" ? 24 : 100 // Simulate points
        for _ in 0..<points {
            let change = Double.random(in: -2.0...2.2)
            currentPrice += change
            mockData.append(currentPrice)
        }
        return mockData
    }
    
    static func search(query: String) async throws -> [CoinGeckoSearchItem] {
        let urlString = "https://api.coingecko.com/api/v3/search?query=\(query)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(CoinGeckoSearchResponse.self, from: data)
        return decoded.coins
    }
    
    static func fetchSpecificCoin(id: String, fallbackItem: CoinGeckoSearchItem) async -> CoinGeckoToken {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(id)"
        guard let url = URL(string: urlString) else { return createFallbackToken(item: fallbackItem) }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return createFallbackToken(item: fallbackItem)
            }
            
            let decoded = try JSONDecoder().decode([CoinGeckoToken].self, from: data)
            if let first = decoded.first {
                return first
            } else {
                return createFallbackToken(item: fallbackItem)
            }
        } catch {
            return createFallbackToken(item: fallbackItem)
        }
    }
    
    private static func createFallbackToken(item: CoinGeckoSearchItem) -> CoinGeckoToken {
        return CoinGeckoToken(
            id: item.id,
            symbol: item.symbol,
            name: item.name,
            image: item.large,
            current_price: Double.random(in: 0.01...1000.0),
            market_cap: Double.random(in: 1_000_000...5_000_000_000),
            price_change_24h: Double.random(in: -5.0...5.0),
            price_change_percentage_24h: Double.random(in: -15.0...15.0),
            market_cap_rank: Double(Int.random(in: 100...5000))
        )
    }
}

// MARK: - API Models

struct CoinGeckoSearchResponse: Codable {
    let coins: [CoinGeckoSearchItem]
}

struct CoinGeckoSearchItem: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let large: String // Thumbnail/Image URL
}

struct CoinGeckoToken: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double?
    let market_cap: Double?
    let price_change_24h: Double?
    let price_change_percentage_24h: Double?
    let market_cap_rank: Double?
}

struct PolymarketEvent: Codable {
    let id: String
    let title: String
    let image: String?
    let volume: Double?
}

struct PredictionModel: Identifiable {
    let id = UUID()
    let title: String
    let image: String?
    let volumeText: String
}

class NetworkManager: ObservableObject {
    @Published var memeCoins: [Token] = []
    @Published var predictions: [PredictionModel] = []
    @Published var isLoadingTokens: Bool = false
    @Published var isLoadingPredictions: Bool = false
    
    func fetchMemeCoins() {
        isLoadingTokens = true
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&category=meme-token&order=market_cap_desc&per_page=15&page=1"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { DispatchQueue.main.async { self?.isLoadingTokens = false } }
            guard let data = data, error == nil else {
                print("Error fetching meme coins: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([CoinGeckoToken].self, from: data)
                let tokens = decoded.map { coin in
                        Token(
                        name: coin.name,
                        symbol: coin.symbol.uppercased(),
                        amount: 0.0,
                        change24h: coin.price_change_24h ?? 0.0,
                        changePercent24h: coin.price_change_percentage_24h ?? 0.0,
                        iconName: "",
                        color: .clear,
                        isVerified: true,
                        imageUrl: coin.image,
                        rank: nil,
                        coinGeckoId: coin.id,
                        marketCapValue: coin.market_cap
                    )
                }
                DispatchQueue.main.async {
                    self?.memeCoins = tokens
                }
            } catch {
                print("Error decoding meme coins: \(error)")
            }
        }.resume()
    }
    
    func fetchPredictions() {
        isLoadingPredictions = true
        let urlString = "https://gamma-api.polymarket.com/events?limit=10&active=true&closed=false"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { DispatchQueue.main.async { self?.isLoadingPredictions = false } }
            guard let data = data, error == nil else { return }
            
            do {
                let decoded = try JSONDecoder().decode([PolymarketEvent].self, from: data)
                let predictionsList = decoded.map { event in
                    PredictionModel(
                        title: event.title,
                        image: event.image,
                        volumeText: event.volume != nil ? String(format: "$%.1fM vol", event.volume! / 1_000_000) : "$1.2M vol"
                    )
                }
                DispatchQueue.main.async {
                    self?.predictions = predictionsList
                }
            } catch {
                print("Error decoding predictions: \(error)")
            }
        }.resume()
    }
}

// MARK: - Shared UI Components
import SwiftUI

struct CryptoIconSmall: View {
    let symbol: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#2A2A2A"))
            Text(symbol.prefix(1).uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 20, height: 20)
    }
}
