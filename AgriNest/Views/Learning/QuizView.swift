import SwiftUI

struct QuizView: View {
    @Environment(\.presentationMode) var presentationMode
    let questions = SampleCourses.quizQuestions.shuffled()
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    @State private var correctCount = 0
    @State private var isFinished = false
    @State private var animateOption = false

    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var body: some View {
        ZStack {
            AppColors.learningGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            if isFinished {
                quizResultView
            } else if !questions.isEmpty {
                quizQuestionView
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Question View
    private var quizQuestionView: some View {
        VStack(spacing: 20) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.peach)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)

            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            // Question
            Text(questions[currentIndex].question)
                .font(AppFonts.header(22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Options
            VStack(spacing: 12) {
                ForEach(0..<questions[currentIndex].options.count, id: \.self) { index in
                    Button(action: {
                        guard selectedAnswer == nil else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedAnswer = index
                            if index == questions[currentIndex].correctIndex {
                                correctCount += 1
                            }
                            showExplanation = true
                        }
                    }) {
                        HStack {
                            Text(questions[currentIndex].options[index])
                                .font(AppFonts.bodyRegular)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if let selected = selectedAnswer {
                                if index == questions[currentIndex].correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.healthyGreen)
                                } else if index == selected {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.alertRed)
                                }
                            }
                        }
                        .padding(14)
                        .background(optionBackground(index: index))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(optionBorder(index: index), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedAnswer != nil)
                }
            }
            .padding(.horizontal)

            // Explanation
            if showExplanation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(AppFonts.captionBold)
                        .foregroundColor(.white.opacity(0.6))
                    Text(questions[currentIndex].explanation)
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(3)
                }
                .padding(14)
                .glassMediumCard()
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))

                GlassButton(
                    title: currentIndex < questions.count - 1 ? "Next Question" : "See Results",
                    icon: "arrow.right"
                ) {
                    if currentIndex < questions.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentIndex += 1
                            selectedAnswer = nil
                            showExplanation = false
                        }
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isFinished = true
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer().frame(height: 20)
        }
    }

    // MARK: - Result View
    private var quizResultView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: correctCount > questions.count / 2 ? "star.fill" : "arrow.counterclockwise")
                .font(.system(size: 64))
                .foregroundColor(correctCount > questions.count / 2 ? AppColors.peach : .white.opacity(0.5))

            Text("Quiz Complete!")
                .font(AppFonts.header(28))
                .foregroundColor(.white)

            Text("\(correctCount) out of \(questions.count) correct")
                .font(AppFonts.bodyLarge)
                .foregroundColor(.white.opacity(0.7))

            // Score display
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(correctCount) / CGFloat(max(questions.count, 1)))
                    .stroke(
                        correctCount > questions.count / 2 ? AppColors.plantGreen : AppColors.peach,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(Double(correctCount) / Double(max(questions.count, 1)) * 100))%")
                    .font(AppFonts.header(28))
                    .foregroundColor(.white)
            }

            Spacer()

            GlassButton(title: "Try Again", icon: "arrow.counterclockwise") {
                withAnimation {
                    currentIndex = 0
                    selectedAnswer = nil
                    showExplanation = false
                    correctCount = 0
                    isFinished = false
                }
            }
            .padding(.horizontal, 40)

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Helpers
    private func optionBackground(index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.1)
        }
        if index == questions[currentIndex].correctIndex {
            return AppColors.healthyGreen.opacity(0.2)
        }
        if index == selected {
            return AppColors.alertRed.opacity(0.2)
        }
        return Color.white.opacity(0.05)
    }

    private func optionBorder(index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.2)
        }
        if index == questions[currentIndex].correctIndex {
            return AppColors.healthyGreen.opacity(0.5)
        }
        if index == selected {
            return AppColors.alertRed.opacity(0.5)
        }
        return Color.white.opacity(0.1)
    }
}
