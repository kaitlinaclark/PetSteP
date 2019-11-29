//
//  HomeViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

import CoreMotion



class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var harvestCoinsButton: UIButton!
    
    @IBOutlet weak var feedButton: UIButton!
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var coinsLabel: UILabel!
    
    
    
    
    //NO IMAGE VIEW FOR PET IMAGE YET
    @IBOutlet weak var happyIcon: UIImageView!
    @IBOutlet weak var happyBar: DisplayView!
    
    
    @IBOutlet weak var foodIcon: UIImageView!
    @IBOutlet weak var foodBar: DisplayView!
    
    
    @IBOutlet weak var waterIcon: UIImageView!
    @IBOutlet weak var waterBar: DisplayView!
    
    
    @IBOutlet weak var healthIcon: UIImageView!
    @IBOutlet weak var healthLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    let STEPS_LABEL = "Steps:"
    let COINS_LABEL = "Coins:"
    
    
    
    // For firebase authentication
    var handle:AuthStateDidChangeListenerHandle?
    
    // Firebase user data object
    var userData:QueryDocumentSnapshot?
    
    private let activityManager = CMMotionActivityManager()
    private var pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //set initial values for bars
        happyBar.animateValue(to: CGFloat(0.5))
        happyBar.color = .gray
        
        foodBar.animateValue(to: CGFloat(0.5))
        foodBar.color = .gray
        
        waterBar.animateValue(to: CGFloat(0.5))
        waterBar.color = .gray
        
        initUserDataView()
        //updateStepsIfAvailable()
    }
    
    private let default_steps = 1000;
    func updateStepsIfAvailable() {
        print("attempting to get steps..")
        let db = Firestore.firestore()
        //check if pedometer data is available
        if CMPedometer.isStepCountingAvailable() {
            //get current date (currently gives step for single day)
            let calendar = Calendar.current
            var docID = ""
            //get pedometer data
            pedometer.queryPedometerData(from: calendar.startOfDay(for: Date()), to: Date()) { (data, error) in
                //set label to pedometer value
                self.stepsLabel.text = data?.numberOfSteps.stringValue
                
                //update value in db
                if let user = Auth.auth().currentUser{
                    //get document ID to update value
                   db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                       if let err = err {
                           print("Error getting documents: \(err)")
                       } else {
                           // Loop should run a maximum of one time
                           print(querySnapshot!.documents)
                           for document in querySnapshot!.documents {
                            docID = document.documentID
                           }
                       }
                   }
                    //use document ID to update total steps whenever view is loaded.
                    db.collection("users").document(docID).updateData([
                        "totalSteps" : data?.numberOfSteps.stringValue as Any
                    ])
                
                }
                
                
            }
        } else{
            self.stepsLabel.text = String(default_steps)
        }
  
    }
    
   
    
    // initialize user data in the main menu views
    
    func initUserDataView(){
        getUserDataFromDB()
        
    }
    

    // Views user data. Storing data in user defaults is not necessary since they are automatically cached by firestore
    func viewUserData(){
        print("In user Data!***")
        if userData != nil{
            
            if let coins:Int = userData?.get(FirebaseKeys.COINS) as? Int{
                coinsLabel.text = String("\(COINS_LABEL) \(coins)")
            }
            
            
            if let harvestableSteps:Int = userData?.get(FirebaseKeys.HARVESTABLE_STEPS) as? Int{
                defaults.set(harvestableSteps, forKey: FirebaseKeys.HARVESTABLE_STEPS)
                stepsLabel.text = String("\(STEPS_LABEL) \(harvestableSteps)")
            }
            
            if let totalSteps:Int = userData?.get(FirebaseKeys.COINS) as? Int{
                defaults.set(totalSteps, forKey: FirebaseKeys.TOTAL_STEPS)
            }
            
          
            if let pet = userData?.get(FirebaseKeys.PET) as? [String:AnyObject]{
                if let petName = pet[FirebaseKeys.PET_NAME] as? String{
                    petNameLabel.text = petName
                }
                
                if let petType = pet[FirebaseKeys.PET_TYPE] as? String{
                    print(petType)
                }
                
                //if let lastPlayed = pet[FirebaseKeys.LAST_PLAYED] as? Timestamp{
                //    print(lastPlayed )
                //}
                
                if let lastFed = pet[FirebaseKeys.LAST_FED] as? Timestamp{
                    print(lastFed)
                }
                
            }else{
                print("Couldn't parese pet map")
            }
            
        }else{
            print("User data is nil")
        }
    }
    
    // Retrives user data from the firestore database
    func getUserDataFromDB(){
        let db = Firestore.firestore()
        
        // Retrieve user data
        if let user = Auth.auth().currentUser{
            print("Fetching collection for \(user.uid)")
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
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
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Adding a listener to check if the user is still logged in
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user == nil){
                self.pushLoginView()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if handle != nil{
            Auth.auth().removeStateDidChangeListener(handle!)
        }
        
    }
    
    
    
    @IBAction func onLogoutButtonPressed(_ sender: Any) {
        logoutFromFirebase()
        pushLoginView()
    }
    
    
    // Function to log user out
    func logoutFromFirebase(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // Function to close all current views and open the login view
    func pushLoginView(){
        /* Example Reference:  https://stackoverflow.com/questions/39929592/how-to-push-and-present-to-uiviewcontroller-programmatically-without-segue-in-io */
        
        // Safe Push VC
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? UINavigationController {
            if let navigator = navigationController {     navigator.showDetailViewController(viewController, sender: self)
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
