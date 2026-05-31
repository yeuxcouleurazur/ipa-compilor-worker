import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var viewModel: WalletViewModel
    @State private var selectedTransaction: Transaction?
    
    // Group transactions by date categories
    var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        var today: [Transaction] = []
        var yesterday: [Transaction] = []
        var older: [Transaction] = []
        
        for tx in viewModel.transactions.sorted(by: { $0.date > $1.date }) {
            if calendar.isDateInToday(tx.date) {
                today.append(tx)
            } else if calendar.isDateInYesterday(tx.date) {
                yesterday.append(tx)
            } else {
                older.append(tx)
            }
        }
        
        var groups: [(String, [Transaction])] = []
        if !today.isEmpty { groups.append(("Aujourd'hui", today)) }
        if !yesterday.isEmpty { groups.append(("Hier", yesterday)) }
        if !older.isEmpty { groups.append(("Plus ancien", older)) }
        return groups
    }

    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Text("Activité récente")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#EBEBEB"))
                    }
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "#EBEBEB"))
                    }
                    .padding(.leading, 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)

                if viewModel.transactions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "#3A3A3A"))
                        Text("Aucune activité")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#6B6B6B"))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(groupedTransactions, id: \.0) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.0)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#A0A0A0"))
                                    
                                    VStack(spacing: 8) {
                                        ForEach(group.1) { tx in
                                            Button {
                                                selectedTransaction = tx
                                            } label: {
                                                TransactionRowView(transaction: tx)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(item: $selectedTransaction) { tx in
            TransactionDetailSheet(transaction: tx)
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack(alignment: .bottomTrailing) {
                if let urlString = transaction.tokenImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: Circle().fill(Color(hex: "#2A2A2A"))
                        case .success(let image): image.resizable().scaledToFill()
                        case .failure: Circle().fill(Color(hex: "#2A2A2A"))
                        @unknown default: EmptyView()
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .background(Circle().fill(.white).frame(width: 46, height: 46))
                } else if transaction.type == .interaction {
                    Circle()
                        .fill(Color(hex: "#23A67A"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#121212"))
                        )
                }
                
                if transaction.type != .interaction {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#AB9FF2"))
                            .frame(width: 18, height: 18)
                        Image(systemName: transaction.type.icon)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#121212"))
                    }
                    .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                let subtitle = transaction.type == .interaction ? "Inconnu" : "Depuis \(transaction.address)"
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }

            Spacer()

            if transaction.type != .interaction {
                let sign = transaction.type == .send ? "-" : "+"
                Text("\(sign)\(formatAmount(transaction.amount)) \(transaction.token)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(transaction.type.color)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1C1C1E"))
        )
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

struct TransactionDetailSheet: View {
    let transaction: Transaction
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Text(transaction.type.label)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#EBEBEB"))
                    }
                }
                .padding(20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Icon & Amount
                        VStack(spacing: 12) {
                            ZStack(alignment: .bottomTrailing) {
                                if let urlString = transaction.tokenImageUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty: Circle().fill(Color(hex: "#2A2A2A"))
                                        case .success(let image): image.resizable().scaledToFill()
                                        case .failure: Circle().fill(Color(hex: "#2A2A2A"))
                                        @unknown default: EmptyView()
                                        }
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .background(Circle().fill(.white).frame(width: 84, height: 84))
                                } else {
                                    Circle()
                                        .fill(Color(hex: "#23A67A"))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(Color(hex: "#121212"))
                                        )
                                }
                                
                                if transaction.type != .interaction {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#AB9FF2"))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: transaction.type.icon)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(hex: "#121212"))
                                    }
                                    .offset(x: 2, y: 2)
                                }
                            }
                            
                            if transaction.type != .interaction {
                                let sign = transaction.type == .send ? "-" : "+"
                                Text("\(sign)\(formatAmount(transaction.amount)) \(transaction.token)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(transaction.type.color)
                            }
                        }
                        .padding(.top, 16)
                        
                        // Details Card
                        VStack(spacing: 0) {
                            detailRow(title: "Date", value: formatDate(transaction.date))
                            Divider().background(Color(hex: "#2A2A2A"))
                            detailRow(title: "Statut", value: transaction.status, valueColor: Color(hex: "#23A67A"))
                            Divider().background(Color(hex: "#2A2A2A"))
                            if transaction.type != .interaction {
                                detailRow(title: transaction.type == .send ? "À" : "De", value: transaction.address, showCopy: true)
                                Divider().background(Color(hex: "#2A2A2A"))
                            }
                            detailRow(title: "Réseau", value: transaction.network, isBold: true)
                        }
                        .background(Color(hex: "#1C1C1E"))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                }
                
                // Bottom Button
                Button {
                } label: {
                    Text("Voir dans l'explorateur")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#121212"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#AB9FF2"))
                        .cornerRadius(12)
                }
                .padding(20)
            }
        }
    }
    
    private func detailRow(title: String, value: String, valueColor: Color = .white, isBold: Bool = false, showCopy: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8E8E93"))
            Spacer()
            HStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 14, weight: isBold ? .bold : .regular))
                    .foregroundColor(valueColor)
                if showCopy {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'à' h:mm a"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).replacingOccurrences(of: "AM", with: "am").replacingOccurrences(of: "PM", with: "pm")
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
