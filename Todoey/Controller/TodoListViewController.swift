//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items: Results<Item>?
    var category: Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = category?.color {
            title = category!.name
            guard let navbar = navigationController?.navigationBar else { fatalError("No navbar yet") }
            if let navbarColor = UIColor(hexString: color) {
                navbar.barTintColor = navbarColor
                navbar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
                navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navbarColor, returnFlat: true)]
                searchBar.barTintColor = navbarColor
                searchBar.searchTextField.backgroundColor = .white
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            let percent = CGFloat(indexPath.row)/CGFloat(items!.count)
            if let color = UIColor(hexString: category!.color)?.darken(byPercentage: percent) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            toggleStatus(item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add Data
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text, let parent = self.category {
                self.save(text, parent)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Item Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Save Data
    
    func save(_ title: String, _ parent: Category) {
        do{
            try realm.write {
                let newItem = Item()
                newItem.title = title
                newItem.dateCreated = Date()
                parent.items.append(newItem)
            }
        } catch {
            print("Error saving item: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Update Data
    
    func toggleStatus(_ item: Item) {
        do{
            try realm.write {
                item.done = !item.done
            }
        } catch {
            print("Error updating item status: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Load Data
    
    func loadItems() {
        items = category?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data
    
    override func updateModel(_ index: IndexPath) {
        if let item = items?[index.row] {
            do{
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
        
}

    //MARK: - Search Button

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            items = category?.items.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "title", ascending: true)
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
