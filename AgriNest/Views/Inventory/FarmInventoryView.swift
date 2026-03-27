import SwiftUI

struct FarmInventoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddItem = false
    @State private var selectedCategory: InventoryCategory?

    private var filteredItems: [InventoryItem] {
        if let category = selectedCategory {
            return appState.inventoryItems.filter { $0.category == category }
        }
        return appState.inventoryItems
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Category tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                withAnimation { selectedCategory = nil }
                            }
                            ForEach(InventoryCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation { selectedCategory = category }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if filteredItems.isEmpty {
                        EmptyStateView(
                            icon: "shippingbox",
                            title: "No Items",
                            subtitle: "Add inventory items to track your farm supplies."
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredItems) { item in
                            InventoryItemRow(item: item, onDelete: {
                                withAnimation { appState.deleteInventoryItem(item) }
                            }, onUpdate: { updated in
                                appState.updateInventoryItem(updated)
                            })
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Farm Inventory")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddItem = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddInventoryItemView()
                .environmentObject(appState)
        }
    }
}

struct InventoryItemRow: View {
    let item: InventoryItem
    let onDelete: () -> Void
    let onUpdate: (InventoryItem) -> Void
    @State private var showEdit = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 20))
                .foregroundColor(item.isLowStock ? AppColors.alertRed : AppColors.plantGreen)
                .frame(width: 40, height: 40)
                .background((item.isLowStock ? AppColors.alertRed : AppColors.plantGreen).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Text(item.category.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.5))
                    if item.isLowStock {
                        Text("Low Stock")
                            .font(AppFonts.captionBold)
                            .foregroundColor(AppColors.alertRed)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(item.quantity)) \(item.unit)")
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(item.isLowStock ? AppColors.alertRed : .white)

                HStack(spacing: 4) {
                    Button(action: {
                        var updated = item
                        updated.quantity = max(0, updated.quantity - 1)
                        onUpdate(updated)
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Button(action: {
                        var updated = item
                        updated.quantity += 1
                        onUpdate(updated)
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(AppColors.plantGreen)
                    }
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.alertRed.opacity(0.4))
            }
        }
        .padding(12)
        .glassCard()
    }
}

// MARK: - Add Inventory Item
struct AddInventoryItemView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var category: InventoryCategory = .feed
    @State private var quantity = ""
    @State private var unit = "kg"
    @State private var lowStockThreshold = ""

    let units = ["kg", "lbs", "bags", "bottles", "liters", "pieces", "boxes"]

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Inventory Item")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Item Name", text: $name, icon: "shippingbox")
                        GlassTextField(placeholder: "Quantity", text: $quantity, icon: "number")
                            .keyboardType(.decimalPad)
                        GlassTextField(placeholder: "Low Stock Alert Threshold", text: $lowStockThreshold, icon: "exclamationmark.triangle")
                            .keyboardType(.decimalPad)

                        // Unit picker
                        HStack(spacing: 12) {
                            Image(systemName: "ruler")
                                .foregroundColor(.white.opacity(0.6))
                            Picker("Unit", selection: $unit) {
                                ForEach(units, id: \.self) { u in
                                    Text(u).tag(u)
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

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 8) {
                                ForEach(InventoryCategory.allCases, id: \.self) { cat in
                                    Button(action: {
                                        withAnimation { category = cat }
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 14))
                                            Text(cat.rawValue)
                                                .font(AppFonts.small)
                                        }
                                        .foregroundColor(category == cat ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(category == cat ? AppColors.plantGreen.opacity(0.3) : Color.white.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Item", icon: "plus") {
                        guard !name.isEmpty, let qty = Double(quantity) else { return }
                        let item = InventoryItem(
                            name: name,
                            category: category,
                            quantity: qty,
                            unit: unit,
                            purchaseDate: Date(),
                            lowStockThreshold: Double(lowStockThreshold) ?? 10
                        )
                        appState.addInventoryItem(item)
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
