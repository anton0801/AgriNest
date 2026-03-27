import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.showSplash {
                SplashView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                appState.showSplash = false
                            }
                        }
                    }
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if !appState.isAuthenticated {
                SignInView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.showSplash)
        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: appState.isAuthenticated)
    }
}
