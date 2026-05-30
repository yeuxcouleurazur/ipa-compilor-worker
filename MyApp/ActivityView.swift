import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var selectedFilter: FilterType = .all

    enum FilterType: String, CaseIterable {
        case all = "All"
        case send = "Sent"
        case receive = "Received"
        case swap = "Swapped"
        case buy = "Bought"
    }

    var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all: return viewModel.transactions
        case .send: return viewModel.transactions.filter { $0.type == .send }
        case .receive: return viewModel.transactions.filter { $0.type == .receive }
        case .swap: return viewModel.transactions.filter { $0.type == .swap }
        case .buy: return viewModel.transactions.filter { $0.type == .buy }
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Text("Activity")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedFilter = filter
                                }
                            } label: {
                                Text(filter.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedFilter == filter ? .white : Color(hex: "#6B6B6B"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilter == filter ? Color(hex: "#AB9FF2") : Color(hex: "#2A2A2A"))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if filteredTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "#3A3A3A"))
                        Text("No transactions")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 2) {
                            ForEach(filteredTransactions) { tx in
                                TransactionRowView(transaction: tx)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(transaction.type.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.type.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(transaction.token)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#6B6B6B"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "$%.2f", transaction.valueUSD))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(timeAgo(from: transaction.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#6B6B6B"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#232323"))
        )
    }

    func timeAgo(from date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}
