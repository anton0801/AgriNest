import SwiftUI

struct FarmPhotoJournalView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddPhoto = false
    @State private var selectedCategory: PhotoCategory?

    private var filteredPhotos: [FarmPhoto] {
        if let category = selectedCategory {
            return appState.farmPhotos.filter { $0.category == category }
        }
        return appState.farmPhotos
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                withAnimation { selectedCategory = nil }
                            }
                            ForEach(PhotoCategory.allCases, id: \.self) { category in
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

                    if filteredPhotos.isEmpty {
                        EmptyStateView(
                            icon: "photo.on.rectangle",
                            title: "No Photos Yet",
                            subtitle: "Start documenting your farm by adding photos."
                        )
                        .padding(.top, 40)
                    } else {
                        // Photo grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(filteredPhotos) { photo in
                                PhotoGridItem(photo: photo, onDelete: {
                                    withAnimation { appState.deleteFarmPhoto(photo) }
                                })
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Photo Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddPhoto = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddPhoto) {
            AddFarmPhotoView()
                .environmentObject(appState)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.plantGreen.opacity(0.4) : Color.white.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PhotoGridItem: View {
    let photo: FarmPhoto
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo placeholder
            ZStack {
                if let data = photo.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 130)
                        .overlay(
                            Image(systemName: photo.category.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(photo.category.rawValue)
                        .font(AppFonts.captionBold)
                        .foregroundColor(AppColors.peach)
                    if !photo.note.isEmpty {
                        Text(photo.note)
                            .font(AppFonts.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    Text(photo.date, style: .date)
                        .font(AppFonts.small)
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.alertRed.opacity(0.5))
                }
            }
        }
        .padding(10)
        .glassCard()
    }
}

// MARK: - Add Farm Photo
struct AddFarmPhotoView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var category: PhotoCategory = .animals
    @State private var note = ""

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Photo")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    // Photo picker
                    Button(action: { showImagePicker = true }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Tap to select photo")
                                    .font(AppFonts.bodyRegular)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .glassMediumCard()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 8) {
                                ForEach(PhotoCategory.allCases, id: \.self) { cat in
                                    Button(action: {
                                        withAnimation { category = cat }
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 16))
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

                        GlassTextField(placeholder: "Add a note (optional)", text: $note, icon: "note.text")
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Save Photo", icon: "checkmark") {
                        let photo = FarmPhoto(
                            imageData: selectedImage?.jpegData(compressionQuality: 0.6),
                            category: category,
                            note: note,
                            date: Date()
                        )
                        appState.addFarmPhoto(photo)
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}
