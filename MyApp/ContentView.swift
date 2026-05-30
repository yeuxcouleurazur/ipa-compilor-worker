import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WalletViewModel()

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            TabView(selection: $viewModel.selectedTab) {
                HomeView()
                    .environmentObject(viewModel)
                    .tag(WalletViewModel.Tab.home)

                ActivityView()
                    .environmentObject(viewModel)
                    .tag(WalletViewModel.Tab.activity)

                SwapView()
                    .environmentObject(viewModel)
                    .tag(WalletViewModel.Tab.swap)

                CollectiblesView()
                    .environmentObject(viewModel)
                    .tag(WalletViewModel.Tab.collectibles)

                SettingsView()
                    .environmentObject(viewModel)
                    .tag(WalletViewModel.Tab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $viewModel.selectedTab)
            }

            // Demo Overlay Banner
            if viewModel.showDemoOverlay {
                DemoBanner(isVisible: $viewModel.showDemoOverlay)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: WalletViewModel.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WalletViewModel.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: selectedTab == tab ? .bold : .regular))
                            .foregroundColor(selectedTab == tab ? .white : Color(hex: "#6B6B6B"))
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color(hex: "#1A1A1A"))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(hex: "#2A2A2A")),
                    alignment: .top
                )
        )
    }
}

// MARK: - Demo Banner

struct DemoBanner: View {
    @Binding var isVisible: Bool
    @State private var appear = false

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "#AB9FF2"))
                    .font(.system(size: 14))

                Text("⚡ DEMO MODE — Données fictives à titre d'illustration")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#AB9FF2"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#2A1F4A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(hex: "#AB9FF2").opacity(0.4), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .offset(y: appear ? 0 : -60)
            .opacity(appear ? 1 : 0)

            Spacer()
        }
        .padding(.top, 56)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                appear = true
            }
        }
    }
}
