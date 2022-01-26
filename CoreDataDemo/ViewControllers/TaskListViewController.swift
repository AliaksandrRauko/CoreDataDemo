//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 24.01.2022.
//

import UIKit
import CloudKit

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        taskList = StorageManager.shared.fetchData(for: context)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskList = StorageManager.shared.fetchData(for: context)
        tableView.reloadData()
    }
 
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlertForNewTask(with: "New Task", and: "What do you want to do?")
    }
}

//MARK: - Alert
extension TaskListViewController {
    private func showAlertForNewTask(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            StorageManager.shared.saveNewTask(taskName: task, context: self.context)
            self.taskList = StorageManager.shared.fetchData(for: self.context)

            let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = title
        }
        present(alert, animated: true)
    }
    
    private func showAlertForEditTask(with title: String, and message: String, and index: Int) {
        let task = self.taskList[index]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields?.first
        textField?.text = task.name

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let textField = alert.textFields?.first
            task.name = textField?.text
            StorageManager.shared.save(context: self.context)
            
            self.taskList = StorageManager.shared.fetchData(for: self.context)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

//MARK: - tableView
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "delete") { _, _, _ in
            StorageManager.shared.deleteTask(at: indexPath.row, for: self.context)
            self.taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        let edit = UIContextualAction(style: .destructive, title: "edit") { _, _, _ in
            self.showAlertForEditTask(with: "Edid task",
                                      and: "Do you edit task?",
                                      and: indexPath.row)
            }
        
        edit.image = UIImage(systemName: "pencil")
        edit.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
}
