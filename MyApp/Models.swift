import SwiftUI
import Combine

// MARK: - Models

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

    var formattedValue: String {
        if valueUSD == 0 { return "$0.00" }
        if valueUSD < 0.01 { return "<$0.01" }
        return String(format: "$%,.2f", valueUSD)
    }

    var formattedAmount: String {
        if amount == 0 { return "0 \(symbol)" }
        if amount < 0.001 {
            return String(format: "< 0.001 \(symbol)")
        }
        if amount >= 1000 {
            return String(format: "%.5f \(symbol)", amount)
        }
        return String(format: "%.5g \(symbol)", amount)
    }

    var formattedChange: String {
        let prefix = change24h >= 0 ? "+" : ""
        if abs(change24h) < 0.01 { return change24h >= 0 ? "+<$0.01" : "-<$0.01" }
        return "\(prefix)\(String(format: "$%,.2f", change24h))"
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
    @Published var isRefreshing: Bool = false
    @Published var showDemoOverlay: Bool = true

    @Published var tokens: [Token] = [
        Token(
            name: "Bitcoin",
            symbol: "BTC",
            amount: 21.36523,
            valueUSD: 1_463_454.16,
            change24h: -14_190.84,
            changePercent24h: -0.96,
            iconName: "bitcoin",
            color: Color(hex: "#F7931A"),
            isVerified: true
        ),
        Token(
            name: "Solana",
            symbol: "SOL",
            amount: 2523.91040,
            valueUSD: 212_588.97,
            change24h: -7_487.02,
            changePercent24h: -3.40,
            iconName: "solana",
            color: Color(hex: "#9945FF"),
            isVerified: true
        ),
        Token(
            name: "Ethereum",
            symbol: "ETH",
            amount: 35.00000,
            valueUSD: 69_342.70,
            change24h: -1_071.27,
            changePercent24h: -1.52,
            iconName: "ethereum",
            color: Color(hex: "#627EEA"),
            isVerified: true
        ),
        Token(
            name: "Monad",
            symbol: "MON",
            amount: 0,
            valueUSD: 0.00,
            change24h: 0.00,
            changePercent24h: 0.00,
            iconName: "monad",
            color: Color(hex: "#836EF9"),
            isVerified: true
        ),
        Token(
            name: "USDC",
            symbol: "USDC",
            amount: 0,
            valueUSD: 0.00,
            change24h: 0.00,
            changePercent24h: 0.00,
            iconName: "usdc",
            color: Color(hex: "#2775CA"),
            isVerified: true
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
        String(format: "$%,.2f", totalBalance)
    }

    var formattedChange: String {
        let prefix = change24h >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "$%,.2f", change24h))"
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
