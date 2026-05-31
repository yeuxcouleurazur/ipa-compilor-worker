import SwiftUI
import CoreImage.CIFilterBuiltins

struct ReceiveNetwork: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let symbolIcon: String?
    let initials: String
    let color: Color
}

let receiveNetworks: [ReceiveNetwork] = [
    ReceiveNetwork(name: "Solana", address: "5WebEN...BM8wUn", symbolIcon: "s.square.fill", initials: "S", color: Color(hex: "#14F195")),
    ReceiveNetwork(name: "Ethereum", address: "0x06a6...8B07", symbolIcon: "diamond.fill", initials: "ETH", color: Color(hex: "#627EEA")),
    ReceiveNetwork(name: "Bitcoin", address: "bc1q...8x65", symbolIcon: "bitcoinsign.square.fill", initials: "BTC", color: Color(hex: "#F7931A")),
    ReceiveNetwork(name: "Monad", address: "0x06a6...8B07", symbolIcon: nil, initials: "M", color: Color(hex: "#8A2BE2")),
    ReceiveNetwork(name: "Base", address: "0x06a6...8B07", symbolIcon: "square.fill", initials: "B", color: Color(hex: "#0052FF")),
    ReceiveNetwork(name: "Sui", address: "0x3abf...2ab8", symbolIcon: "drop.fill", initials: "SUI", color: Color(hex: "#4DA2FF")),
    ReceiveNetwork(name: "Polygon", address: "0x06a6...8B07", symbolIcon: "hexagon.fill", initials: "POL", color: Color(hex: "#8247E5")),
    ReceiveNetwork(name: "HyperEVM", address: "0x06a6...8B07", symbolIcon: nil, initials: "H", color: Color(hex: "#FFFFFF"))
]

struct ReceiveView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedNetwork: ReceiveNetwork = receiveNetworks[0]
    @State private var showNetworkSheet = false
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Text("Recevoir")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        // Scan action
                    }) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer().frame(height: 40)
                
                // Network Pill Selector
                Button(action: {
                    showNetworkSheet = true
                }) {
                    HStack(spacing: 8) {
                        ReceiveNetworkIcon(network: selectedNetwork, size: 20)
                        Text(selectedNetwork.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#2C2C2E"))
                    .cornerRadius(20)
                }
                
                Spacer().frame(height: 40)
                
                // QR Code
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .frame(width: 320, height: 320)
                    
                    if let qrImage = generateQRCode(from: selectedNetwork.address) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                    }
                    
                    // Center Logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                        
                        ReceiveNetworkIcon(network: selectedNetwork, size: 50)
                    }
                }
                
                Spacer().frame(height: 30)
                
                // Address
                HStack(spacing: 8) {
                    Text(selectedNetwork.address)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        UIPasteboard.general.string = selectedNetwork.address
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                }
                
                Spacer()
                
                // Bottom Section
                VStack(spacing: 20) {
                    Text("Utilisez pour recevoir des jetons uniquement sur le\nréseau \(selectedNetwork.name).")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "#8E8E93"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            UIPasteboard.general.string = selectedNetwork.address
                        }) {
                            Text("Copier l'adresse")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#2C2C2E"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            // Share action
                        }) {
                            Text("Partager")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#2C2C2E"))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showNetworkSheet) {
            ReceiveNetworkSelectionSheet(selectedNetwork: $selectedNetwork)
        }
        .navigationBarHidden(true)
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

struct ReceiveNetworkSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedNetwork: ReceiveNetwork
    
    var body: some View {
        ZStack {
            Color(hex: "#121212").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Modifier le réseau")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(receiveNetworks) { network in
                            Button(action: {
                                selectedNetwork = network
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    ReceiveNetworkIcon(network: network, size: 48)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(network.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(network.address)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(Color(hex: "#8E8E93"))
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            // Show QR
                                            selectedNetwork = network
                                            dismiss()
                                        }) {
                                            Image(systemName: "qrcode")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: "#8E8E93"))
                                                .frame(width: 36, height: 36)
                                                .background(Color(hex: "#2C2C2E"))
                                                .cornerRadius(8)
                                        }
                                        Button(action: {
                                            UIPasteboard.general.string = network.address
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: "#8E8E93"))
                                                .frame(width: 36, height: 36)
                                                .background(Color(hex: "#2C2C2E"))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color(hex: "#1C1C1E"))
                                .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct ReceiveNetworkIcon: View {
    let network: ReceiveNetwork
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(Color.white)
            if let icon = network.symbolIcon {
                Image(systemName: icon)
                    .font(.system(size: size * 0.6))
                    .foregroundColor(network.color)
            } else {
                Text(network.initials)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(network.color)
            }
        }
        .frame(width: size, height: size)
    }
}
