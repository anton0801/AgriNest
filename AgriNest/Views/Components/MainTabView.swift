import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    NavigationView {
                        PoultryManagerView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case 2:
                    NavigationView {
                        PhotoDiagnosticsView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case 3:
                    InteractiveLearningView()
                case 4:
                    ProfileView()
                default:
                    DashboardView()
                }
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, filledIcon: String, title: String)] = [
        ("house", "house.fill", "Home"),
        ("bird", "bird.fill", "Poultry"),
        ("camera.viewfinder", "camera.viewfinder", "Diagnostics"),
        ("book", "book.fill", "Learning"),
        ("person", "person.fill", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == index ? tabs[index].filledIcon : tabs[index].icon)
                            .font(.system(size: index == 2 ? 22 : 18))
                            .foregroundColor(selectedTab == index ? AppColors.peach : .white.opacity(0.4))
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)

                        Text(tabs[index].title)
                            .font(AppFonts.small)
                            .foregroundColor(selectedTab == index ? AppColors.peach : .white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Rectangle()
                    .fill(Color(hex: "1A3A1A").opacity(0.85))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}
