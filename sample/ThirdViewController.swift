//
//  ThirdViewController.swift
//  sample
//
//  Created by PQC India iMac-2 on 30/06/23.
//

import UIKit
import RealmSwift

class ThirdViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var personData: [PersonDetails] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    func setupUI() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    func fetchData(){
        do {
            let realm = try Realm()
            let persons = realm.objects(PersonDetails.self)
            for person in persons {
                personData.append(person)
            }
            print("success", personData)
        } catch {
            print("Error fetch")
        }
    }

}

extension ThirdViewController: UITableViewDataSource, UITableViewDelegate{
    //MARK - Tableview Delegate and Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.layer.cornerRadius = 05
        let avatar = cell.contentView.viewWithTag(1) as! UIImageView
        let name = cell.contentView.viewWithTag(2) as! UILabel
        let email = cell.contentView.viewWithTag(3) as! UILabel
        let id = cell.contentView.viewWithTag(4) as! UILabel
        
        let mainView = cell.contentView.viewWithTag(5)!
        mainView.layer.cornerRadius = 5.0
        if let data = personData[indexPath.row].avatar{
            avatar.image = UIImage(data: data)
        }
        name.text = personData[indexPath.row].firstName
        email.text = personData[indexPath.row].email
        id.text = personData[indexPath.row].userId
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
