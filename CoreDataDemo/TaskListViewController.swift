//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let storageManager = StorageManager.shared
    private let cellID = "task"
    private var taskList: [Task] = []
    
    // MARK: - Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = storageManager.fetchData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAddTaskAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func save(task: String) {
        guard let newTask = storageManager.save(task) else { return }
        taskList.append(newTask)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
}

// MARK: - Extensions

// MARK: - Alert Controllers
extension TaskListViewController {
    private func showAddTaskAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task: task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        present(alert, animated: true)
    }
    
    private func showEditTaskAlert(
        with title: String,
        and message: String,
        for task: Task,
        at indexPath: IndexPath
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            guard let newTaskTitle = alert.textFields?.first?.text, !newTaskTitle.isEmpty else { return }
            self.storageManager.edit(changeTitleOf: task, to: newTaskTitle)
            let indexPaths = [indexPath]
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = task.title ?? ""
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        let taskToRemove = taskList[indexPath.row]
        taskList.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        self.storageManager.delete(taskToRemove)
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            let task = taskList[indexPath.row]
            showEditTaskAlert(
                with: "Edit Task",
                and: "Change existing task",
                for: task,
                at: indexPath
            )
            tableView.deselectRow(at: indexPath, animated: true)
        }
}
