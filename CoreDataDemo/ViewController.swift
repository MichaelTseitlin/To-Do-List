//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 12/04/2019.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks = [Task]()
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createStyleOfController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.font = UIFont(name: "Noteworthy-Bold", size: 18)
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editNotesAction = UITableViewRowAction(style: .default, title: "Edit") { _, indexPath in self.editAction(indexPath)
        }
        
        let deleteNotesAction = UITableViewRowAction(style: .default, title: "Delete") { _, indexPath in self.deleteAction(indexPath)
        }
        
        editNotesAction.backgroundColor = .blue
        
        return [deleteNotesAction, editNotesAction]
    }
}

extension ViewController {
    
    private func createStyleOfController() {
        
        //Цвет фона приложения
        view.backgroundColor = UIColor(displayP3Red: 240/255,
                                       green: 230/255,
                                       blue: 159/255,
                                       alpha: 1)
        
        //Цвет контролерра
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 97/255,
                                                                   green: 56/255,
                                                                   blue: 34/255,
                                                                   alpha: 1)
        
        //Имя заголовка
        title = "Список задач"
        
        //Шрифт заголовка
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Noteworthy-Bold", size: 22) as Any]
        
        //Цвет заголовка
        navigationController?.navigationBar.tintColor = .white
        
        //Устанавливаем правую кнопку с картинкой
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addNewTask))
    }
    
    
    private func editAction(_ indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Edit Task", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            
            let managedContext = self.appDelegate.persistentContainer.viewContext
            
            guard let textField = alert.textFields?.first else { return }
            
            let task = self.tasks[indexPath.row]
            
            task.name = textField.text
            
            do {
                try managedContext.save()
            } catch let error {
                print("Failed to save task", error.localizedDescription)
            }
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    private func deleteAction(_ indexPath: IndexPath) {
        
        let managedContext = self.appDelegate.persistentContainer.viewContext
        
        managedContext.delete(self.tasks[indexPath.row])
        
        self.tasks.remove(at: indexPath.row)
        
        do {
            try managedContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    
    @objc private func addNewTask() {
        
        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let task = alert.textFields?.first?.text, task.isEmpty == false else { return }
            
            self.saveData(task)
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func saveData(_ taskName: String) {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        
        let task = NSManagedObject(entity: entity, insertInto: managedContext) as! Task
        
        task.name = taskName
        
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error {
            print("Failed to save task", error.localizedDescription)
        }
    }
    
}

