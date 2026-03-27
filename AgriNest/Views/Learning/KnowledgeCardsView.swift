import SwiftUI

struct KnowledgeCardsView: View {
    let cards = SampleCourses.knowledgeCards
    @State private var expandedCardId: UUID?

    var body: some View {
        ZStack {
            AppColors.learningGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(cards) { card in
                        KnowledgeCardView(
                            card: card,
                            isExpanded: expandedCardId == card.id,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    if expandedCardId == card.id {
                                        expandedCardId = nil
                                    } else {
                                        expandedCardId = card.id
                                    }
                                }
                            }
                        )
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Knowledge Cards")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct KnowledgeCardView: View {
    let card: KnowledgeCard
    let isExpanded: Bool
    let onTap: () -> Void

    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: card.icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.peach)
                        .frame(width: 44, height: 44)
                        .background(AppColors.peach.opacity(0.15))
                        .clipShape(Circle())

                    Text(card.title)
                        .font(AppFonts.bodySemibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.4))
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(card.explanation)
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(4)

                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppColors.peach)
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            Text(card.practicalTip)
                                .font(AppFonts.bodyRegular)
                                .foregroundColor(AppColors.peach)
                                .lineSpacing(3)
                        }
                        .padding(12)
                        .background(AppColors.peach.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .glassCard(opacity: isExpanded ? 0.22 : 0.15)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }
}
