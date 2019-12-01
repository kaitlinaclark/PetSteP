//
//  PetDetailsViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore



class PetDetailsViewController: UIViewController {

    @IBOutlet weak var petImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var coinsLabel: UILabel!
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    
    @IBOutlet weak var numberVisitorsLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView!
    
    var userData:QueryDocumentSnapshot?
    
    let AGE_POST_TEXT = " days"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getUserDataFromDB()
        viewUserData()
    }
    
    func viewUserData(){
        print("In user Data!***")
        if userData != nil{
            
            if let totalSteps = userData?.get(FirebaseKeys.TOTAL_STEPS) as? Int{
                stepsLabel.text = String(totalSteps)
            }
            
            
            if let coins = userData?.get(FirebaseKeys.COINS) as? Int{
                coinsLabel.text = String(coins)
            }
            
            if let petBirthday = userData?.get(FirebaseKeys.PET_BIRTHDAY) as? Timestamp{
                ageLabel.text = String(numDaysAlive(birthday:  petBirthday)) + AGE_POST_TEXT
            }
            
            
            if let pet = userData?.get(FirebaseKeys.PET) as? [String:AnyObject]{
                if let petName = pet[FirebaseKeys.NAME] as? String{
                    nameLabel.text = petName
                }
                
                if let petType = pet[FirebaseKeys.TYPE] as? String{
                    petImageView.image = UIImage(named: petType)
                }else{
                    petImageView.image = nil
                }

                
            }else{
                print("Couldn't parese pet map")
            }
            
        }else{
            print("User data is nil")
        }
    }
    
    
    
    
    func numDaysAlive(birthday:Timestamp) -> Int{
        
        let NUM_SEC_IN_HOURS:Double = 60 * 60
        let NUM_HOURS_IN_DAYS = 24
        
        let curTime = TimeInterval(NSDate().timeIntervalSince1970)
        let lastTime = TimeInterval(birthday.seconds)
        let deltaTInHours = (curTime - lastTime) / NUM_SEC_IN_HOURS
        
        return Int(deltaTInHours / Double(NUM_HOURS_IN_DAYS))
    }
    
    
    
    // Retrives user data from the firestore database
    func getUserDataFromDB(){
        let db = Firestore.firestore()
        
        // Retrieve user data
        if let user = Auth.auth().currentUser{
            print("Fetching collection for \(user.uid)")
            db.collection("users").whereField("userID", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    print(querySnapshot!.documents)
                    for document in querySnapshot!.documents {
                        print("doc found.")
                        self.userData = document
                        self.viewUserData()
                    }
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
