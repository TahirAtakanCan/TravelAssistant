//
//  ListViewController.swift
//  TravelAssistant
//
//  Created by Tahir Atakan Can on 1.11.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self , action: #selector(addButtonClicked))
        
        
        // tableview ayarları
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
    }
    
    
    func getData(){
        // önce verileri temizlememiz gerekiyor
        self.titleArray.removeAll(keepingCapacity: false)
        self.idArray.removeAll(keepingCapacity: false)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    tableView.reloadData()
                    
                }
            }
            
            
        }catch{
            print("error")
        }
        
        
    }
    
    
    
    
    
    @objc func addButtonClicked() {
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    

}
