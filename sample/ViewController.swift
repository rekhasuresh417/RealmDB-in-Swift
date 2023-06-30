//
//  ViewController.swift
//  sample
//
//  Created by PQC India iMac-2 on 27/06/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var personData: [Example] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getJson() { (json) in
                print(json)
                self.saveLoginData(data: json)
            }

    }

    func getJson(completion: @escaping (Example)-> ()) {
        let urlString = "https://jsonplaceholder.typicode.com/todos/1"
        if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url) {data, res, err in
            guard let data = data else {return print("error with data")}
            let decoder = JSONDecoder()
            guard let json: Example = try? decoder.decode(Example.self, from: data) else {return print("error with json")}
            completion(json)
          }.resume()
        }
    }
    
    public func saveLoginData(data: Example) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
        
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(data.id, forKey: "id")
        newUser.setValue(data.title, forKey: "title")
        
        do {
          try context.save()
            getData()
         } catch {
          print("Error saving")
        }
    }
   
    func getData() {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        
        do {
            let result = try context.fetch(request)
            personData = []
            for data in result as! [NSManagedObject] {
                let model = Example(id: data.value(forKey: "id") as! Int,
                                    title: data.value(forKey: "title") as! String)
                personData.append(model)
            }
            print(personData)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        } catch {
            print("Failed")
        }
    }
    
    func deleteData(id: Int) {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: ["\(id)"])

        do {
            let fetchedResults = try context.fetch(fetchRequest)
            if let personToDelete = fetchedResults.first {
                // Delete the managed object
                context.delete(personToDelete)
                
                // Save changes to Core Data
                try context.save()
                DispatchQueue.main.async {
                    self.getData()
                }
            }
        } catch {
            // Handle fetch or save error
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.idLabel.text = "\(personData[indexPath.row].id)"
        cell.titleLabel.text = personData[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteData(id: self.personData[indexPath.row].id)
        }
    }
}

class CustomTableViewCell: UITableViewCell {
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
}
