import SwiftUI

struct InteractiveLearningView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.learningGradient.ignoresSafeArea()
                GrainTexture().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Courses
                        SectionHeader(title: "Mini-Courses")
                            .padding(.horizontal)

                        ForEach(appState.courses) { course in
                            NavigationLink(destination: CourseDetailView(course: course)) {
                                CourseCard(course: course)
                            }
                        }
                        .padding(.horizontal)

                        // Knowledge Cards
                        SectionHeader(title: "Knowledge Cards") {
                            // Already shows all
                        }
                        .padding(.horizontal)

                        NavigationLink(destination: KnowledgeCardsView()) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppColors.peach)
                                Text("Browse Knowledge Cards")
                                    .font(AppFonts.bodySemibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(SampleCourses.knowledgeCards.count) cards")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(14)
                            .glassCard()
                        }
                        .padding(.horizontal)

                        // Quiz
                        SectionHeader(title: "Test Your Knowledge")
                            .padding(.horizontal)

                        NavigationLink(destination: QuizView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.peach)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Start Quiz")
                                        .font(AppFonts.bodySemibold)
                                        .foregroundColor(.white)
                                    Text("\(SampleCourses.quizQuestions.count) questions about farming")
                                        .font(AppFonts.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "play.fill")
                                    .foregroundColor(AppColors.peach)
                            }
                            .padding(16)
                            .glassMediumCard()
                        }
                        .padding(.horizontal)

                        Spacer().frame(height: 80)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Learning")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CourseCard: View {
    let course: Course
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: course.icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.peach)
                .frame(width: 48, height: 48)
                .background(AppColors.peach.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(course.name)
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(.white)
                Text("\(course.lessonsCount) lessons")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppColors.plantGreen)
                            .frame(width: geo.size.width * course.progress)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            Text("\(Int(course.progress * 100))%")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.plantGreen)
        }
        .padding(14)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Course Detail
struct CourseDetailView: View {
    @EnvironmentObject var appState: AppState
    let course: Course

    private var currentCourse: Course {
        appState.courses.first(where: { $0.id == course.id }) ?? course
    }

    var body: some View {
        ZStack {
            AppColors.learningGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Course header
                    VStack(spacing: 12) {
                        Image(systemName: course.icon)
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.peach)
                        Text(course.name)
                            .font(AppFonts.header(24))
                            .foregroundColor(.white)
                        Text("\(currentCourse.completedLessons)/\(currentCourse.lessonsCount) lessons completed")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 16)

                    // Lessons
                    ForEach(Array(currentCourse.lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink(destination: LessonView(courseId: course.id, lesson: lesson)) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(lesson.isCompleted ? AppColors.plantGreen.opacity(0.3) : Color.white.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                    if lesson.isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(AppColors.plantGreen)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(AppFonts.bodySemibold)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }

                                Text(lesson.title)
                                    .font(AppFonts.bodyRegular)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(14)
                            .glassCard()
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Lesson View
struct LessonView: View {
    @EnvironmentObject var appState: AppState
    let courseId: UUID
    let lesson: Lesson
    @State private var isCompleted = false

    var body: some View {
        ZStack {
            AppColors.learningGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(lesson.title)
                        .font(AppFonts.header(22))
                        .foregroundColor(.white)
                        .padding(.top, 16)

                    Text(lesson.content)
                        .font(AppFonts.bodyLarge)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)

                    if !lesson.isCompleted && !isCompleted {
                        GlassButton(
                            title: "Mark as Completed",
                            icon: "checkmark.circle",
                            gradient: LinearGradient(
                                colors: [AppColors.plantGreen, Color(hex: "5A9E5E")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        ) {
                            appState.completeLesson(courseId: courseId, lessonId: lesson.id)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isCompleted = true
                            }
                        }
                    }

                    if lesson.isCompleted || isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.plantGreen)
                            Text("Lesson Completed!")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(AppColors.plantGreen)
                        }
                        .padding(12)
                        .background(AppColors.plantGreen.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }
}
