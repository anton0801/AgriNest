import SwiftUI

struct FarmCalendarView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDate = Date()
    @State private var showAddEvent = false
    @State private var currentMonth = Date()

    private var calendar: Calendar { Calendar.current }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        return range.compactMap { day -> Date? in
            var dc = components
            dc.day = day
            return calendar.date(from: dc)
        }
    }

    private var firstWeekday: Int {
        guard let first = daysInMonth.first else { return 0 }
        return (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7
    }

    private var eventsForSelectedDate: [CalendarEvent] {
        appState.events(for: selectedDate)
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Month navigation
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(8)
                        }
                        Spacer()
                        Text(monthString)
                            .font(AppFonts.h2)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)

                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                            Text(day)
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)

                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(0..<firstWeekday, id: \.self) { _ in
                            Text("")
                                .frame(height: 36)
                        }

                        ForEach(daysInMonth, id: \.self) { date in
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(date)
                            let hasEvents = !appState.events(for: date).isEmpty

                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(AppFonts.bodyRegular)
                                        .foregroundColor(isSelected ? .white : isToday ? AppColors.peach : .white.opacity(0.7))
                                    if hasEvents {
                                        Circle()
                                            .fill(AppColors.peach)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(isSelected ? AppColors.plantGreen.opacity(0.4) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    // Events for selected date
                    SectionHeader(title: "Events for \(formatDate(selectedDate))")
                        .padding(.horizontal)

                    if eventsForSelectedDate.isEmpty {
                        Text("No events")
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white.opacity(0.4))
                            .padding()
                    } else {
                        ForEach(eventsForSelectedDate) { event in
                            EventRow(event: event, onDelete: {
                                appState.deleteEvent(event)
                            })
                        }
                        .padding(.horizontal)
                    }

                    // Upcoming events
                    let upcoming = appState.calendarEvents
                        .filter { $0.date >= Date() }
                        .sorted { $0.date < $1.date }
                        .prefix(5)

                    if !upcoming.isEmpty {
                        SectionHeader(title: "Upcoming")
                            .padding(.horizontal)

                        ForEach(Array(upcoming)) { event in
                            EventRow(event: event, onDelete: {
                                appState.deleteEvent(event)
                            })
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Farm Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddEvent = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventView(selectedDate: selectedDate)
                .environmentObject(appState)
        }
    }

    private func changeMonth(by value: Int) {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) ?? currentMonth
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

struct EventRow: View {
    let event: CalendarEvent
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.eventType.icon)
                .foregroundColor(event.eventType.color)
                .frame(width: 32, height: 32)
                .background(event.eventType.color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Text(event.eventType.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.5))
                    Text(event.date, style: .date)
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.alertRed.opacity(0.5))
            }
        }
        .padding(12)
        .glassCard()
    }
}

// MARK: - Add Event
struct AddEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    var selectedDate: Date
    @State private var title = ""
    @State private var date: Date
    @State private var eventType: EventType = .custom
    @State private var notes = ""

    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _date = State(initialValue: selectedDate)
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Event")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Event Title", text: $title, icon: "calendar")

                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(.white)
                            .accentColor(AppColors.peach)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Event type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Type")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(EventType.allCases, id: \.self) { type in
                                        Button(action: {
                                            withAnimation { eventType = type }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: type.icon)
                                                    .font(.system(size: 12))
                                                Text(type.rawValue)
                                                    .font(AppFonts.caption)
                                            }
                                            .foregroundColor(eventType == type ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(eventType == type ? type.color.opacity(0.3) : Color.white.opacity(0.1))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }

                        GlassTextField(placeholder: "Notes (optional)", text: $notes, icon: "note.text")
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Event", icon: "plus") {
                        guard !title.isEmpty else { return }
                        let event = CalendarEvent(
                            title: title,
                            date: date,
                            eventType: eventType,
                            notes: notes
                        )
                        appState.addEvent(event)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.horizontal, 24)

                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
