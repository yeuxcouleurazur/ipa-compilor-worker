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
    let amount: Double
    let valueUSD: Double
    let change24h: Double
    let changePercent24h: Double
    let iconName: String
    let color: Color
    let isVerified: Bool
    var imageUrl: String?
    var rank: Int?

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

    enum TransactionType {
        case send, receive, swap, buy
        var icon: String {
            switch self {
            case .send: return "arrow.up.right"
            case .receive: return "arrow.down.left"
            case .swap: return "arrow.2.squarepath"
            case .buy: return "dollarsign"
            }
        }
        var label: String {
            switch self {
            case .send: return "Sent"
            case .receive: return "Received"
            case .swap: return "Swapped"
            case .buy: return "Bought"
            }
        }
        var color: Color {
            switch self {
            case .send: return Color(hex: "#FF6464")
            case .receive: return Color(hex: "#3DD68C")
            case .swap: return Color(hex: "#AB9FF2")
            case .buy: return Color(hex: "#3DD68C")
            }
        }
    }
}

// MARK: - ViewModel

class WalletViewModel: ObservableObject {
    @Published var walletName: String = "GhostWallet"
    @Published var walletAddress: String = "7xKp...mR9f"
    @Published var totalBalance: Double = 1_745_385.83
    @Published var change24h: Double = -22_749.13
    @Published var changePercent24h: Double = -1.30
    @Published var cashBalance: Double = 0.00
    @Published var selectedTab: Tab = .home
    @Published var currentRoute: AppRoute = .welcome
    @Published var isRefreshing: Bool = false
    @Published var showDemoOverlay: Bool = true

    @Published var tokens: [Token] = [
        Token(
            name: "Just a chill guy",
            symbol: "CHILLGUY",
            amount: 0,
            valueUSD: 0.33,
            change24h: 0.03,
            changePercent24h: 9.81,
            iconName: "chillguy",
            color: Color(hex: "#A8D8B9"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/36209/large/chillguy.jpeg",
            rank: 1
        ),
        Token(
            name: "Goatseus Maximus",
            symbol: "GOAT",
            amount: 0,
            valueUSD: 0.85,
            change24h: 0.02,
            changePercent24h: 2.34,
            iconName: "goat",
            color: Color(hex: "#FFD700"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/35882/large/goat.png",
            rank: 2
        ),
        Token(
            name: "zerebro",
            symbol: "ZEREBRO",
            amount: 0,
            valueUSD: 0.48,
            change24h: 0.03,
            changePercent24h: 5.72,
            iconName: "zerebro",
            color: Color(hex: "#8A2BE2"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/36021/large/zerebro.png",
            rank: 3
        ),
        Token(
            name: "dogwifhat",
            symbol: "$WIF",
            amount: 0,
            valueUSD: 3.11,
            change24h: -0.05,
            changePercent24h: -1.72,
            iconName: "wif",
            color: Color(hex: "#D2B48C"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/33566/large/dogwifhat.jpg",
            rank: 4
        ),
        Token(
            name: "Bonk",
            symbol: "Bonk",
            amount: 0,
            valueUSD: 0.00004855,
            change24h: 0.000001,
            changePercent24h: 2.13,
            iconName: "bonk",
            color: Color(hex: "#FF8C00"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/28600/large/bonk.jpg",
            rank: 5
        ),
        Token(
            name: "POPCAT",
            symbol: "POPCAT",
            amount: 0,
            valueUSD: 1.47,
            change24h: 0.07,
            changePercent24h: 4.65,
            iconName: "popcat",
            color: Color(hex: "#FFC0CB"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/28741/large/popcat.png",
            rank: 6
        ),
        Token(
            name: "Peanut the Squirrel",
            symbol: "Pnut",
            amount: 0,
            valueUSD: 1.11,
            change24h: -0.03,
            changePercent24h: -2.31,
            iconName: "pnut",
            color: Color(hex: "#A0522D"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/32585/large/pnut.png",
            rank: 7
        ),
        Token(
            name: "FWOG",
            symbol: "FWOG",
            amount: 0,
            valueUSD: 0.41,
            change24h: 0.01,
            changePercent24h: 2.95,
            iconName: "fwog",
            color: Color(hex: "#228B22"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/35161/large/fwog.png",
            rank: 8
        ),
        Token(
            name: "cat in a dogs world",
            symbol: "MEW",
            amount: 0,
            valueUSD: 0.009715,
            change24h: 0.0001,
            changePercent24h: 1.05,
            iconName: "mew",
            color: Color(hex: "#FFE4E1"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/35071/large/mew.png",
            rank: 9
        ),
        Token(
            name: "Bitcoin",
            symbol: "BTC",
            amount: 47.0,
            valueUSD: 3_707_454.00,
            change24h: 160_450.64,
            changePercent24h: 4.33,
            iconName: "bitcoin",
            color: Color(hex: "#F7931A"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            rank: 10
        ),
        Token(
            name: "Ethereum",
            symbol: "ETH",
            amount: 0.0,
            valueUSD: 0.0,
            change24h: 0.0,
            changePercent24h: 0.0,
            iconName: "ethereum",
            color: Color(hex: "#627EEA"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
            rank: 11
        ),
        Token(
            name: "Solana",
            symbol: "SOL",
            amount: 0.0,
            valueUSD: 0.0,
            change24h: 0.0,
            changePercent24h: 0.0,
            iconName: "solana",
            color: Color(hex: "#9945FF"),
            isVerified: true,
            imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png",
            rank: 12
        )
    ]

    @Published var transactions: [Transaction] = [
        Transaction(
            type: .receive,
            token: "BTC",
            amount: 1.5,
            valueUSD: 102_000,
            date: Date().addingTimeInterval(-3600),
            address: "3Fv8...kL2m"
        ),
        Transaction(
            type: .send,
            token: "SOL",
            amount: 50,
            valueUSD: 4_200,
            date: Date().addingTimeInterval(-86400),
            address: "9pKr...nT4j"
        ),
        Transaction(
            type: .swap,
            token: "ETH → SOL",
            amount: 2,
            valueUSD: 3_960,
            date: Date().addingTimeInterval(-172800),
            address: ""
        ),
        Transaction(
            type: .buy,
            token: "BTC",
            amount: 0.25,
            valueUSD: 17_000,
            date: Date().addingTimeInterval(-259200),
            address: ""
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
        case home, activity, swap, collectibles, settings

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .activity: return "clock.fill"
            case .swap: return "arrow.2.squarepath"
            case .collectibles: return "square.grid.2x2.fill"
            case .settings: return "person.fill"
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
