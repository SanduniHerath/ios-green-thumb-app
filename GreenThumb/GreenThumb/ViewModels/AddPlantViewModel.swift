import SwiftUI
import Combine
import PhotosUI

@MainActor
class AddPlantViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var species: String = ""
    @Published var location: String = "Front garden"
    @Published var potType: String = "Ground"
    @Published var datePlanted: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 14)) ?? Date()
    @Published var notes: String = ""
    @Published var tags: [String] = ["Flowering", "Outdoor", "Fragrant"]
    
    //image state
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    @Published var isUploadingImage: Bool = false
    @Published var uploadError: String? = nil

    
    let locationOptions = ["Front garden", "Back garden", "Balcony", "Living Room", "Kitchen"]
    let potTypeOptions  = ["Ground", "Ceramic Pot", "Plastic Pot", "Terracotta", "Raised Bed"]
    
    //actions
    var onSave: ((PlantModel) -> Void)?
    var onCancel: (() -> Void)?
    
    //load image from photospickeritem
    func loadSelectedImage() {
        guard let item = selectedPhotoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.selectedImage = uiImage
            }
        }
    }
    
    //save the plant to firestore after uploading
    func savePlant() {
        guard !name.isEmpty else { return }
        
        //if user picked an image, upload it first
        if let image = selectedImage {
            isUploadingImage = true
            Task {
                do {
                    let imageURL = try await CloudinaryService.upload(image: image)
                    self.isUploadingImage = false
                    self.createAndSavePlant(imageURL: imageURL)
                } catch {
                    self.isUploadingImage = false
                    self.uploadError = "Image upload failed: \(error.localizedDescription)"
                    print("Cloudinary Upload Error: \(error.localizedDescription)")
                    //still save the plant but without an image
                    self.createAndSavePlant(imageURL: nil)
                }
            }
        } else {
            //no image selected
            createAndSavePlant(imageURL: nil)
        }
    }
    
    private func createAndSavePlant(imageURL: String?) {
        let ageDays = Calendar.current.dateComponents([.day], from: datePlanted, to: Date()).day ?? 0
        let agePenalty = min(Double(ageDays) * 0.10, 30.0)
        let startingHealth = max(65.0, 97.0 - agePenalty)
        
        let newPlant = PlantModel(
            name: name,
            species: species,
            status: .healthy,
            healthScore: startingHealth,
            imageURL: imageURL,
            location: location,
            dateAdded: datePlanted,
            tags: tags,
            isOutdoor: potType == "Ground",
            ageDays: ageDays,
            initialNote: notes
        )
        print("🪴 Saving plant: \(name), health: \(Int(startingHealth))%, image: \(imageURL ?? "none")")
        onSave?(newPlant)
    }

    func addTag() {
        tags.append("New Tag")
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
