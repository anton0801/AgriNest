import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var fullName = ""
    @State private var farmName = ""
    @State private var country = "United States"
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedFarmType: FarmType = .mixed
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(AppFonts.header(28))
                            .foregroundColor(.white)
                        Text("Set up your farm profile")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 40)

                    // Form fields
                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Full Name", text: $fullName, icon: "person")
                        GlassTextField(placeholder: "Farm Name", text: $farmName, icon: "house")

                        // Country picker
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 20)
                            Picker("Country", selection: $country) {
                                ForEach(availableCountries, id: \.self) { c in
                                    Text(c).tag(c)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )

                        GlassTextField(placeholder: "Email", text: $email, icon: "envelope")
                            .keyboardType(.emailAddress)
                        GlassTextField(placeholder: "Password", text: $password, isSecure: true, icon: "lock")
                        GlassTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, icon: "lock.fill")
                    }
                    .padding(.horizontal, 24)

                    // Farm type selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Farm Type")
                            .font(AppFonts.bodySemibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(FarmType.allCases, id: \.self) { type in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedFarmType = type
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 16))
                                        Text(type.rawValue)
                                            .font(AppFonts.bodySemibold)
                                    }
                                    .foregroundColor(selectedFarmType == type ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedFarmType == type ? AppColors.plantGreen.opacity(0.4) : Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedFarmType == type ? AppColors.plantGreen : Color.white.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                                    .scaleEffect(selectedFarmType == type ? 1.02 : 1.0)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    if showError {
                        Text(errorMessage)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.alertRed)
                            .padding(.horizontal, 24)
                    }

                    // Create Account button
                    GlassButton(title: isLoading ? "Creating..." : "Create Account", icon: "person.badge.plus") {
                        createAccount()
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Already have an account? Sign In")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func createAccount() {
        // Validation
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            showError = true
            return
        }
        guard !farmName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your farm name."
            showError = true
            return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, email.contains("@") else {
            errorMessage = "Please enter a valid email."
            showError = true
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            showError = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showError = true
            return
        }

        showError = false
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = FarmUser(
                fullName: fullName,
                farmName: farmName,
                country: country,
                email: email,
                farmType: selectedFarmType,
                registrationDate: Date()
            )
            appState.createAccount(user: user)
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
