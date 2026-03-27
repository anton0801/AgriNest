import SwiftUI

struct FarmProfitView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod = 0 // 0=month, 1=quarter, 2=year
    @State private var showAddExpense = false

    private var periodLabel: String {
        switch selectedPeriod {
        case 0: return "This Month"
        case 1: return "This Quarter"
        case 2: return "This Year"
        default: return "This Month"
        }
    }

    private var filteredSales: [SaleRecord] {
        filterByPeriod(appState.sales.map { ($0.date, $0) }).map { $0.1 }
    }

    private var filteredExpenses: [ExpenseRecord] {
        filterByPeriod(appState.expenses.map { ($0.date, $0) }).map { $0.1 }
    }

    private var revenue: Double {
        filteredSales.reduce(0) { $0 + $1.total }
    }

    private var expenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var profit: Double {
        revenue - expenses
    }

    private var profitMargin: Double {
        guard revenue > 0 else { return 0 }
        return (profit / revenue) * 100
    }

    var body: some View {
        ZStack {
            AppColors.analyticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Period picker
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Month").tag(0)
                        Text("Quarter").tag(1)
                        Text("Year").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Main stats
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ProfitStatCard(
                                title: "Revenue",
                                value: "$\(String(format: "%.0f", revenue))",
                                color: AppColors.healthyGreen,
                                icon: "arrow.up"
                            )
                            ProfitStatCard(
                                title: "Expenses",
                                value: "$\(String(format: "%.0f", expenses))",
                                color: AppColors.alertRed,
                                icon: "arrow.down"
                            )
                        }

                        HStack(spacing: 12) {
                            ProfitStatCard(
                                title: "Net Profit",
                                value: "$\(String(format: "%.0f", profit))",
                                color: profit >= 0 ? AppColors.healthyGreen : AppColors.alertRed,
                                icon: profit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis"
                            )
                            ProfitStatCard(
                                title: "Margin",
                                value: "\(String(format: "%.1f", profitMargin))%",
                                color: profitMargin >= 0 ? AppColors.peach : AppColors.alertRed,
                                icon: "percent"
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Monthly chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Revenue vs Expenses")
                            .font(AppFonts.bodySemibold)
                            .foregroundColor(.white)

                        if revenue == 0 && expenses == 0 {
                            Text("No data for \(periodLabel.lowercased())")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.4))
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                        } else {
                            HStack(alignment: .bottom, spacing: 20) {
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.healthyGreen)
                                        .frame(width: 40, height: max(CGFloat(revenue / max(revenue + expenses, 1)) * 120, 4))
                                    Text("Revenue")
                                        .font(AppFonts.small)
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.alertRed.opacity(0.7))
                                        .frame(width: 40, height: max(CGFloat(expenses / max(revenue + expenses, 1)) * 120, 4))
                                    Text("Expenses")
                                        .font(AppFonts.small)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                        }
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal)

                    // Expense records
                    SectionHeader(title: "Expenses", actionTitle: "+ Add") {
                        showAddExpense = true
                    }
                    .padding(.horizontal)

                    if appState.expenses.isEmpty {
                        Text("No expenses recorded")
                            .font(AppFonts.caption)
                            .foregroundColor(.white.opacity(0.4))
                            .padding()
                    } else {
                        ForEach(appState.expenses.sorted(by: { $0.date > $1.date }).prefix(10)) { expense in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(expense.category)
                                        .font(AppFonts.bodySemibold)
                                        .foregroundColor(.white)
                                    Text(expense.date, style: .date)
                                        .font(AppFonts.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Text("-$\(String(format: "%.0f", expense.amount))")
                                    .font(AppFonts.bodySemibold)
                                    .foregroundColor(AppColors.alertRed)

                                Button(action: {
                                    withAnimation { appState.deleteExpense(expense) }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.alertRed.opacity(0.4))
                                }
                            }
                            .padding(12)
                            .glassCard()
                            .padding(.horizontal)
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Farm Profit")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
                .environmentObject(appState)
        }
    }

    private func filterByPeriod<T>(_ items: [(Date, T)]) -> [(Date, T)] {
        let calendar = Calendar.current
        let now = Date()
        return items.filter { item in
            switch selectedPeriod {
            case 0: return calendar.isDate(item.0, equalTo: now, toGranularity: .month)
            case 1: return calendar.isDate(item.0, equalTo: now, toGranularity: .quarter)
            case 2: return calendar.isDate(item.0, equalTo: now, toGranularity: .year)
            default: return true
            }
        }
    }
}

struct ProfitStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            Text(value)
                .font(AppFonts.body(20, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard()
    }
}

// MARK: - Add Expense
struct AddExpenseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var date = Date()
    @State private var category = "Feed"
    @State private var amount = ""
    @State private var notes = ""

    let categories = ["Feed", "Fertilizer", "Medicine", "Equipment", "Labor", "Utilities", "Transport", "Other"]

    var body: some View {
        ZStack {
            AppColors.analyticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Expense")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 14) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .foregroundColor(.white)
                            .accentColor(AppColors.peach)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { cat in
                                        Button(action: {
                                            withAnimation { category = cat }
                                        }) {
                                            Text(cat)
                                                .font(AppFonts.caption)
                                                .foregroundColor(category == cat ? .white : .white.opacity(0.5))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(category == cat ? AppColors.peach.opacity(0.4) : Color.white.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }

                        GlassTextField(placeholder: "Amount ($)", text: $amount, icon: "dollarsign.circle")
                            .keyboardType(.decimalPad)
                        GlassTextField(placeholder: "Notes (optional)", text: $notes, icon: "note.text")
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Expense", icon: "plus") {
                        guard let amt = Double(amount) else { return }
                        let expense = ExpenseRecord(
                            date: date,
                            category: category,
                            amount: amt,
                            notes: notes
                        )
                        appState.addExpense(expense)
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
