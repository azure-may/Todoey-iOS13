//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Azure May Burmeister on 3/20/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
//    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row].name
        cell.textLabel?.text = category
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.category = categories[indexPath.row]
        }
    }
    
    //MARK: - Save Data
    
    func save(_ category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving new category: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Add Data
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text {
                let newCategory = Category()
                newCategory.name = text
                self.categories.append(newCategory)
                self.save(newCategory)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Load Data
    
//    func loadCategories(_ request: NSFetchRequest<Category> = Category.fetchRequest()) {
//        do {
//            categories = try context.fetch(request)
//        } catch {
//            print("Error fetching categories: \(error)")
//        }
//        tableView.reloadData()
//    }
    
    //MARK: - Delete Data

}
