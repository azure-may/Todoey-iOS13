//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Azure May Burmeister on 3/20/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>? 

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navbar = navigationController?.navigationBar else { fatalError("No navbar yet") }
        navbar.barTintColor = UIColor(hexString: "1D9BF6")
        navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "FFFFFF")!]
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            if let color = UIColor(hexString: category.color) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.category = categories?[indexPath.row]
        }
    }
    
    //MARK: - Add Data
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text {
                let newCategory = Category()
                newCategory.name = text
                newCategory.color = UIColor.randomFlat().hexValue()
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
    
    //MARK: - Load Data
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data
    
    override func updateModel(_ index: IndexPath) {
        if let category = categories?[index.row] {
            do{
                try realm.write {
                    realm.delete(category.items)
                    realm.delete(category)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
}
