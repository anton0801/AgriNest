import SwiftUI

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showCreateAccount = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)

                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(AppColors.plantGreen)
                            .scaleEffect(appeared ? 1 : 0.5)

                        Text("Angri Nest")
                            .font(AppFonts.header(32))
                            .foregroundColor(.white)

                        Text("Welcome back, farmer!")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 20)

                    // Form
                    VStack(spacing: 16) {
                        GlassTextField(placeholder: "Email", text: $email, icon: "envelope")
                            .keyboardType(.emailAddress)

                        GlassTextField(placeholder: "Password", text: $password, isSecure: true, icon: "lock")
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)

                    if showError {
                        Text(errorMessage)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.alertRed)
                            .padding(.horizontal, 24)
                    }

                    // Sign In button
                    VStack(spacing: 12) {
                        GlassButton(title: isLoading ? "Signing In..." : "Sign In", icon: "arrow.right") {
                            signIn()
                        }
                        .disabled(isLoading)

                        Button(action: { showCreateAccount = true }) {
                            Text("Create Account")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(AppColors.peach)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.peach.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppColors.peach.opacity(0.3), lineWidth: 1)
                                )
                        }

                        // Sign in with Apple placeholder (visual)
                        Button(action: {
                            // Sign in with Apple — uses same quick sign-in flow
                            quickSignIn()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sign in with Apple")
                                    .font(AppFonts.bodySemibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 40)

                    Button(action: {
                        // Reset password flow - for demo, just show a message
                        errorMessage = "Password reset instructions sent to your email."
                        showError = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showError = false
                        }
                    }) {
                        Text("Forgot password?")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 8)

                    Spacer().frame(height: 40)
                }
            }
        }
        .sheet(isPresented: $showCreateAccount) {
            CreateAccountView()
                .environmentObject(appState)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func signIn() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            showError = true
            return
        }
        showError = false
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            let success = appState.signIn(email: email, password: password)
            if !success {
                errorMessage = "Invalid credentials. Try creating an account."
                showError = true
            }
        }
    }

    private func quickSignIn() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if appState.currentUser.fullName.isEmpty {
                appState.currentUser.fullName = "Farmer"
                appState.currentUser.farmName = "My Farm"
            }
            appState.isAuthenticated = true
            isLoading = false
        }
    }
}
