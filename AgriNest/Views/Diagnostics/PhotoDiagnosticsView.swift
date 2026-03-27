import SwiftUI

struct PhotoDiagnosticsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showResult = false
    @State private var currentResult: DiagnosticResult?
    @State private var isAnalyzing = false
    @State private var analysisProgress: CGFloat = 0

    var body: some View {
        ZStack {
            AppColors.diagnosticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Scan area
                    Button(action: { showImagePicker = true }) {
                        VStack(spacing: 16) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Tap to scan plant or animal")
                                        .font(AppFonts.bodyRegular)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                            }
                        }
                        .glassMediumCard()
                    }
                    .buttonStyle(PlainButtonStyle())

                    if isAnalyzing {
                        VStack(spacing: 12) {
                            Text("Analyzing...")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(.white)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.peach)
                                        .frame(width: geo.size.width * analysisProgress)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal)
                    }

                    // Result card
                    if let result = currentResult, showResult {
                        DiagnosticResultCard(result: result)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Analyze button
                    if selectedImage != nil && !isAnalyzing && !showResult {
                        GlassButton(
                            title: "Analyze Photo",
                            icon: "wand.and.stars",
                            gradient: LinearGradient(
                                colors: [Color(hex: "3F3F7A"), Color(hex: "5A5A9E")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        ) {
                            analyzePhoto()
                        }
                        .padding(.horizontal)
                    }

                    if showResult {
                        Button(action: {
                            selectedImage = nil
                            showResult = false
                            currentResult = nil
                        }) {
                            Text("Scan Another")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(AppColors.peach)
                        }
                    }

                    // History
                    if !appState.diagnosticResults.isEmpty {
                        SectionHeader(title: "Scan History")
                            .padding(.horizontal)

                        ForEach(appState.diagnosticResults) { result in
                            DiagnosticHistoryRow(result: result)
                                .padding(.horizontal)
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Photo Diagnostics")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    private func analyzePhoto() {
        isAnalyzing = true
        analysisProgress = 0
        showResult = false

        // Simulate analysis progress
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            withAnimation(.linear(duration: 0.05)) {
                analysisProgress += 0.04
            }
            if analysisProgress >= 1.0 {
                timer.invalidate()
                isAnalyzing = false

                let sample = SampleDiagnostics.randomResult()
                let result = DiagnosticResult(
                    date: Date(),
                    photoData: selectedImage?.jpegData(compressionQuality: 0.5),
                    diagnosisName: sample.name,
                    symptoms: sample.symptoms,
                    recommendations: sample.recommendations,
                    status: sample.status,
                    category: sample.category
                )
                currentResult = result
                appState.addDiagnosticResult(result)

                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showResult = true
                }
            }
        }
    }
}

struct DiagnosticResultCard: View {
    let result: DiagnosticResult

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(result.diagnosisName)
                    .font(AppFonts.h2)
                    .foregroundColor(.white)
                Spacer()
                StatusChip(text: result.status.rawValue, status: result.status)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Symptoms")
                    .font(AppFonts.captionBold)
                    .foregroundColor(.white.opacity(0.6))
                Text(result.symptoms)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.9))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recommendations")
                    .font(AppFonts.captionBold)
                    .foregroundColor(.white.opacity(0.6))
                Text(result.recommendations)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(16)
        .glassMediumCard()
    }
}

struct DiagnosticHistoryRow: View {
    let result: DiagnosticResult

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.category == .animal ? "hare" : "leaf")
                .font(.system(size: 18))
                .foregroundColor(result.status.color)
                .frame(width: 36, height: 36)
                .background(result.status.backgroundColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(result.diagnosisName)
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(.white)
                Text(result.date, style: .date)
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            StatusChip(text: result.status.rawValue, status: result.status)
        }
        .padding(12)
        .glassCard()
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
