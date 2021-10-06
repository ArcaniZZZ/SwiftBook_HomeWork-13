//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Arcani on 06.10.2021.
//

import CoreData

class StorageManager {
    
    // MARK: - Public Properties
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext
    
    // MARK: - Initializers
    private init() {
        context = persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Public Methods
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
        return taskList
    }
    
    func save(_ taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        task.title = taskName
        return task
    }
    
    func delete(_ task: Task) {
        context.delete(task)
    }
    
    func edit(changeTitleOf task: Task, to newTitle: String) {
        task.title = newTitle
    }
}
