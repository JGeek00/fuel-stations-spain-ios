import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    private let storeURL: URL
    private let groupId = Config.groupId
    
    // Maximum number of retries to prevent infinite loops
    private let maxRetries = 1
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FuelStationsSpain")
        
        guard let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)?.appendingPathComponent("FuelStationsSpain.sqlite") else {
            fatalError("Unable to get shared store URL.")
        }
        self.storeURL = sharedStoreURL
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.persistentStoreDescriptions.first!.url = storeURL
        }
        
        loadPersistentStores(retryCount: maxRetries)
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private func loadPersistentStores(retryCount: Int) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Failed to load persistent store: \(error.localizedDescription)")
                
                if retryCount > 0 {
                    // Attempt to delete the corrupted store
                    let fileManager = FileManager.default
                    do {
                        if fileManager.fileExists(atPath: self.storeURL.path) {
                            try fileManager.removeItem(at: self.storeURL)
                            
                            // Retry loading the persistent store after deletion
                            self.loadPersistentStores(retryCount: retryCount - 1)
                            return
                        }
                    } catch {
                    }
                }
                
                // If all retries fail, handle the error appropriately
                fatalError("Unresolved error loading persistent stores: \(error)")
            }
        }
    }
}
