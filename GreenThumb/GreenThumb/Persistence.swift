import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        
        let plantEntity = NSEntityDescription()
        plantEntity.name = "CachedPlant"
        plantEntity.managedObjectClassName = "CachedPlant"
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        
        let speciesAttr = NSAttributeDescription()
        speciesAttr.name = "species"
        speciesAttr.attributeType = .stringAttributeType
        
        let userIdAttr = NSAttributeDescription()
        userIdAttr.name = "userId"
        userIdAttr.attributeType = .stringAttributeType
        
        let imageURLAttr = NSAttributeDescription()
        imageURLAttr.name = "imageURL"
        imageURLAttr.attributeType = .stringAttributeType
        
        plantEntity.properties = [idAttr, nameAttr, speciesAttr, userIdAttr, imageURLAttr]
        
        //create the model
        let model = NSManagedObjectModel()
        model.entities = [plantEntity]
        
        //setup the container
        container = NSPersistentContainer(name: "GreenThumbModel", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data: Changes saved successfully!")
            } catch {
                print("Core Data: Save error: \(error.localizedDescription)")
            }
        }
    }
}

@objc(CachedPlant)
public class CachedPlant: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var species: String?
    @NSManaged public var userId: String?
    @NSManaged public var imageURL: String?
}

