//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Aliaksandr Rauko on 25.01.22.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
     
    private init() {}
    
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
        saveTask(context: context)
        }
    }
    
    func save(taskName: String, context: NSManagedObjectContext) {
        
        let task = Task(context: context)
        task.name = taskName
        
        var taskList = fetchData(for: context)
        taskList.append(task)
        saveTask(context: context)
    }
    
    func fetchData(for context: NSManagedObjectContext) -> [Task] {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let  taskList = try context.fetch(fetchRequest)
            return taskList
        } catch {
            print("Faild to fetch data", error)
            return []
        }
    }
    
    func deleteTask(at index: Int, for context: NSManagedObjectContext ) {
        var taskList = fetchData(for: context)
        taskList.remove(at: index)
        saveTask(context: context)
    }
    
    private func saveTask(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
