import SwiftUI
import UIKit

struct TokenDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: WalletViewModel
    let token: Token
    
    @State private var selectedTimeRange: String = "1J"
    let timeRanges = ["1H", "1J", "1S", "1M", "YTD", "TOUT"]
    
    // Chart Scrubbing State
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var dragPrice: Double? = nil
    
    // Chart API State
    @State private var apiChartData: [Double] = []
    @State private var isLoadingChart: Bool = false
    @State private var lastDragIndex: Int? = nil
    
    let impactGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#121212").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    
                    priceSection
                    
                    chartSection
                    
                    timeRangeSelector
                    
                    actionButtons
                    
                    chatBanner
                    
                    positionSection
                    
                    perpsSection
                    
                    stakingSection
                    
                    infoSection
                    
                    aboutSection
                    
                    Spacer(minLength: 120) // Space for floating button
                }
                .padding(.bottom, 24)
            }
            .onAppear {
                fetchChartData()
            }
            
            // Sticky Bottom Button
            VStack {
                Spacer()
                Button {
                } label: {
                    Text("Acheter")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "#121212"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#A393FA"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 44, alignment: .leading)
            
            HStack(spacing: 6) {
                tokenIcon
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(token.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        if token.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#8C7AE6"))
                        }
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#1FAD66")) // Kept green consistent
                            .frame(width: 6, height: 6)
                        Text("\(peopleCount) personnes ici")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                } label: {
                    Text("Suivre")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#2C2C2E"))
                        )
                }
                
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Price Section
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            let displayPrice = isDragging && dragPrice != nil ? dragPrice! : token.currentPrice
            
            HStack {
                Text(String(format: "\(viewModel.currency)%.2f", displayPrice))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                if isLoadingChart {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#A393FA")))
                        .padding(.leading, 8)
                }
            }
            
            HStack(spacing: 8) {
                Text(token.formattedChange)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(token.changeColor)
                
                Text(token.formattedChangePercent)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#121212")) // Black text
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(token.change24h >= 0 ? Color(hex: "#1FAD66") : Color(hex: "#FF453A")) // Solid background
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Chart Section
    
    private var normalizedChartData: [CGFloat] {
        guard !apiChartData.isEmpty else {
            return [0.5, 0.5] // Flat line fallback
        }
        let minPrice = apiChartData.min() ?? 0
        let maxPrice = apiChartData.max() ?? 1
        let range = maxPrice - minPrice
        guard range > 0 else { return apiChartData.map { _ in 0.5 } }
        
        return apiChartData.map { CGFloat(($0 - minPrice) / range) * 0.8 + 0.1 } // 10% padding top and bottom
    }
    
    private var chartSection: some View {
        GeometryReader { geometry in
            let currentChartData = normalizedChartData
            
            ZStack(alignment: .leading) {
                // Background Baseline
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(hex: "#2C2C2E"))
                        .frame(height: 1)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundColor(Color(hex: "#4A4A4A"))
                        )
                }
                
                // The Chart Line
                Path { path in
                    let stepX = geometry.size.width / CGFloat(max(1, currentChartData.count - 1))
                    let maxY = geometry.size.height
                    
                    for (index, value) in currentChartData.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = maxY - (value * maxY)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(token.changeColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                // Scrubbing Overlay
                if isDragging {
                    ZStack {
                        // Vertical Line
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: dragLocation.x, y: geometry.size.height / 2)
                        
                        // Dot on the line
                        let stepX = geometry.size.width / CGFloat(max(1, currentChartData.count - 1))
                        let index = max(0, min(currentChartData.count - 1, Int(round(dragLocation.x / stepX))))
                        let dotY = geometry.size.height - (currentChartData[index] * geometry.size.height)
                        
                        Circle()
                            .fill(token.changeColor)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color(hex: "#121212"), lineWidth: 2))
                            .position(x: dragLocation.x, y: dotY)
                        
                        // Time label
                        Text(dragTimeString(for: index))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .position(x: dragLocation.x, y: -20)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragLocation = value.location
                        
                        let stepX = geometry.size.width / CGFloat(max(1, currentChartData.count - 1))
                        let index = max(0, min(currentChartData.count - 1, Int(round(dragLocation.x / stepX))))
                        
                        if lastDragIndex != index {
                            impactGenerator.impactOccurred()
                            lastDragIndex = index
                        }
                        
                        if apiChartData.indices.contains(index) {
                            dragPrice = apiChartData[index]
                        } else {
                            dragPrice = token.currentPrice
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        dragPrice = nil
                        lastDragIndex = nil
                    }
            )
        }
        .frame(height: 200)
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(timeRanges, id: \.self) { range in
                Text(range)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedTimeRange == range ? .white : Color(hex: "#8E8E93"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTimeRange == range ? Color(hex: "#2C2C2E") : Color.clear)
                    )
                    .onTapGesture {
                        if selectedTimeRange != range {
                            withAnimation {
                                selectedTimeRange = range
                            }
                            fetchChartData()
                            impactGenerator.impactOccurred(intensity: 0.8)
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            detailActionButton(icon: "Long", label: "Long", color: "#A393FA", isSystem: false)
            detailActionButton(icon: "Court", label: "Court", color: "#A393FA", isSystem: false)
            detailActionButton(icon: "qrcode", label: "Recevoir", color: "#A393FA")
            detailActionButton(icon: "ellipsis", label: "Plus", color: "#A393FA")
        }
        .padding(.horizontal, 16)
    }
    
    private func textActionButton(label: String, color: String) -> some View {
        Button {
        } label: {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: color))
                .frame(maxWidth: .infinity)
                .frame(height: 76)
                .background(Color(hex: "#1C1C1E"))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
    
    private func detailActionButton(icon: String, label: String, color: String, isSystem: Bool = true) -> some View {
        Button {
        } label: {
            VStack(spacing: 8) {
                if isSystem {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: color))
                } else {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(hex: color))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#EBEBEB"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(Color(hex: "#1C1C1E"))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
    
    // MARK: - Chat Banner
    private var chatBanner: some View {
        HStack {
            HStack(spacing: -8) {
                Circle().fill(Color(hex: "#FF8A65")).frame(width: 24, height: 24)
                Circle().fill(Color(hex: "#4FC3F7")).frame(width: 24, height: 24)
            }
            
            Text("2 dans le chat...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
            
            Button {
            } label: {
                Text("Rejoindre le chat")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#2C2C2E")))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#181818")))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Position Section
    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Position")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Valeur
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Valeur")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text("\(viewModel.currency)\(token.formattedValue)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
                    
                    // Solde
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Solde")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text(token.formattedAmount)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
                }
                
                // 24h Change
                HStack {
                    Text("24 h de changement")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "#8E8E93"))
                    Spacer()
                    Text(token.change24h == 0 ? "\(viewModel.currency)0.00" : token.formattedChange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(token.change24h == 0 ? .white : token.changeColor)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Position Perps
    private var perpsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position perps")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color(hex: "#A393FA").opacity(0.2)).frame(width: 48, height: 48)
                    Image(systemName: "infinity")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#A393FA"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ãƒâ€°changez des perps \(token.symbol)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Multipliez votre P&L jusqu'ÃƒÂ  x20")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
                Spacer()
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Staking Section (Votre enjeu)
    private var stakingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Votre enjeu")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enjeu avec Phantom")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Text("Gagnez")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text("6.07%")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#3DD68C"))
                        Text("par an")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // Dotted curve
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 50))
                    path.addQuadCurve(to: CGPoint(x: 300, y: 0), control: CGPoint(x: 200, y: 50))
                }
                .stroke(Color(hex: "#3DD68C"), style: StrokeStyle(lineWidth: 2, dash: [6]))
                .frame(height: 60)
                .padding(.vertical, 8)
                
                HStack(spacing: 12) {
                    Button {
                    } label: {
                        Text("Plus d'infor...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#2C2C2E")))
                    }
                    Button {
                    } label: {
                        Text("Commencez...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#121212"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#3DD68C")))
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Informations Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Informations")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                infoRow(label: "Nom", value: token.name)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "Symbole", value: token.symbol)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "RÃƒÂ©seau", value: token.name)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "Capitalisation du marchÃƒÂ©", value: token.marketCap)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "Approvisionnement total", value: token.totalSupply)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "Approvisionnement circulaire", value: token.circulatingSupply)
                Divider().background(Color(hex: "#2C2C2E"))
                infoRow(label: "CrÃƒÂ©ÃƒÂ©", value: token.creationDate)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#8E8E93"))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Ãƒâ‚¬ Propos Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ãƒâ‚¬ propos")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(token.aboutText)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#B0B0B0"))
                .lineSpacing(4)
            
            Button {
            } label: {
                Text("Afficher plus")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#A393FA"))
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Utilities
    @ViewBuilder
    private var tokenIcon: some View {
        Group {
            if let urlStr = token.imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: Circle().fill(Color.gray.opacity(0.3))
                    case .success(let image): image.resizable().scaledToFit()
                    case .failure: Image(token.iconName).resizable().scaledToFit()
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Image(token.iconName).resizable().scaledToFit()
            }
        }
        .clipShape(Circle())
    }
    
    private var peopleCount: Int {
        var hasher = Hasher()
        hasher.combine(token.symbol)
        return abs(hasher.finalize()) % 9500 + 120
    }
    
    private func dragTimeString(for index: Int) -> String {
        let count = max(1, apiChartData.count - 1)
        let ratio = Double(index) / Double(count)
        
        let now = Date()
        var dateToFormat = now
        
        switch selectedTimeRange {
        case "1H":
            dateToFormat = now.addingTimeInterval(-3600 * (1.0 - ratio))
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: dateToFormat)
        case "1J":
            dateToFormat = now.addingTimeInterval(-86400 * (1.0 - ratio))
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: dateToFormat)
        case "1S":
            dateToFormat = now.addingTimeInterval(-86400 * 7 * (1.0 - ratio))
            let f = DateFormatter()
            f.dateFormat = "dd MMM"
            return f.string(from: dateToFormat)
        case "1M":
            dateToFormat = now.addingTimeInterval(-86400 * 30 * (1.0 - ratio))
            let f = DateFormatter()
            f.dateFormat = "dd MMM"
            return f.string(from: dateToFormat)
        case "1A":
            dateToFormat = now.addingTimeInterval(-86400 * 365 * (1.0 - ratio))
            let f = DateFormatter()
            f.dateFormat = "MMM yyyy"
            return f.string(from: dateToFormat)
        default:
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: dateToFormat)
        }
    }
    
    // MARK: - API Call
    private func fetchChartData() {
        guard let coinId = token.coinGeckoId else { return }
        isLoadingChart = true
        
        let daysMap: [String: String] = [
            "1H": "0.04", // ~1 hour
            "1J": "1",
            "1S": "7",
            "1M": "30",
            "YTD": "365",
            "TOUT": "max"
        ]
        let days = daysMap[selectedTimeRange] ?? "1"
        
        Task {
            do {
                let data = try await CryptoAPI.fetchChartData(coinId: coinId, days: days)
                DispatchQueue.main.async {
                    self.apiChartData = data
                    self.isLoadingChart = false
                }
            } catch {
                print("Error fetching chart data: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingChart = false
                }
            }
        }
    }
}


