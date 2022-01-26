//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Aliaksandr Rauko on 25.01.22.
//

import UIKit
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
        save(context: context)
        }
    }
    
    func saveNewTask(taskName: String, context: NSManagedObjectContext) {
        
        let task = Task(context: context)
        task.name = taskName
        
        var taskList = fetchData(for: context)
        taskList.append(task)
        save(context: context)
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
        let taskList = fetchData(for: context)
        context.delete(taskList[index])
        save(context: context)
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
