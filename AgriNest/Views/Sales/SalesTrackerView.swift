import SwiftUI

struct SalesTrackerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddSale = false
    @State private var selectedProduct: ProductType?

    private var filteredSales: [SaleRecord] {
        if let product = selectedProduct {
            return appState.sales.filter { $0.product == product }
        }
        return appState.sales
    }

    var body: some View {
        ZStack {
            AppColors.analyticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedProduct == nil) {
                                withAnimation { selectedProduct = nil }
                            }
                            ForEach(ProductType.allCases, id: \.self) { product in
                                FilterChip(
                                    title: product.rawValue,
                                    isSelected: selectedProduct == product
                                ) {
                                    withAnimation { selectedProduct = product }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Total
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Sales")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text("$\(String(format: "%.2f", filteredSales.reduce(0) { $0 + $1.total }))")
                                .font(AppFonts.header(24))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("\(filteredSales.count) records")
                            .font(AppFonts.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(16)
                    .glassMediumCard()
                    .padding(.horizontal)

                    if filteredSales.isEmpty {
                        EmptyStateView(
                            icon: "dollarsign.circle",
                            title: "No Sales",
                            subtitle: "Track your farm sales by adding records."
                        )
                        .padding(.top, 20)
                    } else {
                        // Table header
                        HStack {
                            Text("Date")
                                .frame(width: 60, alignment: .leading)
                            Text("Product")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Qty")
                                .frame(width: 40)
                            Text("Price")
                                .frame(width: 50)
                            Text("Total")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .font(AppFonts.captionBold)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 28)

                        ForEach(filteredSales.sorted(by: { $0.date > $1.date })) { sale in
                            SaleRow(sale: sale, onDelete: {
                                withAnimation { appState.deleteSale(sale) }
                            })
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Sales Tracker")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSale = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddSale) {
            AddSaleView()
                .environmentObject(appState)
        }
    }
}

struct SaleRow: View {
    let sale: SaleRecord
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(formatDate(sale.date))
                .frame(width: 60, alignment: .leading)
            Text(sale.product.rawValue)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(Int(sale.quantity))")
                .frame(width: 40)
            Text("$\(String(format: "%.1f", sale.pricePerUnit))")
                .frame(width: 50)
            Text("$\(String(format: "%.0f", sale.total))")
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(AppColors.healthyGreen)
        }
        .font(AppFonts.bodyRegular)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

// MARK: - Add Sale
struct AddSaleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var date = Date()
    @State private var product: ProductType = .eggs
    @State private var quantity = ""
    @State private var pricePerUnit = ""

    var body: some View {
        ZStack {
            AppColors.analyticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Sale")
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

                        // Product type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Product")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(ProductType.allCases, id: \.self) { type in
                                        Button(action: {
                                            withAnimation { product = type }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: type.icon)
                                                    .font(.system(size: 12))
                                                Text(type.rawValue)
                                                    .font(AppFonts.caption)
                                            }
                                            .foregroundColor(product == type ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(product == type ? AppColors.plantGreen.opacity(0.4) : Color.white.opacity(0.1))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }

                        GlassTextField(placeholder: "Quantity", text: $quantity, icon: "number")
                            .keyboardType(.decimalPad)
                        GlassTextField(placeholder: "Price per Unit ($)", text: $pricePerUnit, icon: "dollarsign.circle")
                            .keyboardType(.decimalPad)

                        // Preview
                        if let qty = Double(quantity), let price = Double(pricePerUnit) {
                            HStack {
                                Text("Total:")
                                    .font(AppFonts.bodySemibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$\(String(format: "%.2f", qty * price))")
                                    .font(AppFonts.header(20))
                                    .foregroundColor(AppColors.healthyGreen)
                            }
                            .padding(12)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Sale", icon: "plus") {
                        guard let qty = Double(quantity), let price = Double(pricePerUnit) else { return }
                        let sale = SaleRecord(
                            date: date,
                            product: product,
                            quantity: qty,
                            pricePerUnit: price
                        )
                        appState.addSale(sale)
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
