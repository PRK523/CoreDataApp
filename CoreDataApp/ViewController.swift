//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Pranoti Kulkarni on 5/24/18.
//  Copyright © 2018 Pranoti Kulkarni. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
    }
    
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "People")

        do{
            people = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        }catch let error as NSError{
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.tag = indexPath.row
        //cell.textLabel?.text = names[indexPath.row]
        //cell.detailTextLabel?.text = dob[indexPath.row]
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let person = people[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String ?? ""
        
        cell.detailTextLabel?.text = "Year of birth: \(person.value(forKey: "year") as? String ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "People")
            
            managedContext.delete(people[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                people = try managedContext.fetch(fetchRequest)
            }catch let error as NSError{
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            self.tableView.reloadData()
        }
    }

    
    @IBAction func addDetails(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Details", message: "Add new name and year of birth", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Type your name"
        }
        
        alert.addTextField { (textfield2) in
            textfield2.placeholder = "Type your year of birth"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textfield = alert.textFields?.first,
                let textfield2 = alert.textFields?[1],
                let name = textfield.text, let year = textfield2.text else {return}
            
            self.save(name: name, year: year)
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }

    func save(name: String, year: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "People", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        person.setValue(year, forKey: "year")
        
        
    
        do{
            
            try managedContext.save()
            
            people.append(person)
            
        }catch let error as NSError{
            
            print("Could not save. \(error), \(error.userInfo)")
        }
    }


}

