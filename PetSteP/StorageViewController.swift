//
//  StorageViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class StorageViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var foodTableView: UITableView!
    
    @IBOutlet weak var furnitureTableView: UITableView!
    
    @IBOutlet weak var careTableView: UITableView!
    
    @IBOutlet weak var funTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(scrollView)
        
        let db = Firestore.firestore()
       
        
        db.collection("storeItems").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print("Document Type: \(type(of: document))")
                    
                }

            }
        }

        
        
        
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
