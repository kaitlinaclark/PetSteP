//
//  PetAnimationViewController.swift
//  PetSteP
//
//  Created by Uki Malla on 11/29/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

import CoreMotion



class PetAnimationViewController: UIViewController {
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    
    
    
    //NO IMAGE VIEW FOR PET IMAGE YET
    @IBOutlet weak var happinessIcon: UIImageView!
    @IBOutlet weak var happinessBar: DisplayView!
    
    
    @IBOutlet weak var foodIcon: UIImageView!
    @IBOutlet weak var foodBar: DisplayView!
    
    
    @IBOutlet weak var hygieneIcon: UIImageView!
    @IBOutlet weak var hygieneBar: DisplayView!
    
    @IBOutlet weak var healthIcon: UIImageView!
    @IBOutlet weak var healthLabel: UILabel!
    
    var animationItemName:String?
    
    let defaults = UserDefaults.standard
    
    let STEPS_LABEL = "Steps:"
    let COINS_LABEL = "Coins:"
    
    // For firebase authentication
    var handle:AuthStateDidChangeListenerHandle?
    
    // Firebase user data object
    var userData:QueryDocumentSnapshot?
    
    var petType:String?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if animationItemName != nil{
            print("Now using item", animationItemName!)
        }
        
        
        initUserDataView()
    }
    
    
    /* animateItem()
     *
     * animationItemName: String that holds the name of the item that is being used.
     * petType: String that holds the type of the pet the user has.
     */
    func animateItem(){
        // ===== PUT ALL THE CODE FOR ITEM ANIMATION HERE ====
        // you may delete the following print blocks
        
        if animationItemName != nil{
            print("Now using item \(animationItemName!)")
        }
        if petType != nil{
            print("Current pet is a \(petType!)")
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
            
            if let totalSteps:Int = userData?.get(FirebaseKeys.COINS) as? Int{
                defaults.set(totalSteps, forKey: FirebaseKeys.TOTAL_STEPS)
            }
            
            
            if let pet = userData?.get(FirebaseKeys.PET) as? [String:AnyObject]{
                if let petName = pet[FirebaseKeys.NAME] as? String{
                    petNameLabel.text = petName
                }
                
                if let petType = pet[FirebaseKeys.TYPE] as? String{
                    self.petType = petType
                }
                
                // Fetching pet stats data
                let lastPlayed = pet[FirebaseKeys.LAST_PLAYED] as? Timestamp
                let lastFed = pet[FirebaseKeys.LAST_FED] as? Timestamp
                let lastCare = pet[FirebaseKeys.LAST_CARE] as? Timestamp
                let happinessLevel = pet[FirebaseKeys.HAPPINESS_LEVEL] as? Double
                let foodLevel = pet[FirebaseKeys.FOOD_LEVEL] as? Double
                let hygieneLevel = pet[FirebaseKeys.HYGIENE_LEVEL] as? Double
                
                
                // Updating Hygiene Bar
                if (lastCare != nil && hygieneLevel != nil){
                    updateBar(bar: hygieneBar, last: lastCare!, level: hygieneLevel!, color:#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
                }
                
                // Updating Food Bar
                if (lastFed != nil && foodLevel != nil){
                    updateBar(bar: foodBar, last: lastFed!, level: foodLevel!, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
                }
                
                // Updating Happiness Bar
                if(lastPlayed != nil && happinessLevel != nil){
                    updateBar(bar: happinessBar, last: lastPlayed!, level: happinessLevel!, color: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
                }
                
                animateItem()
                
            }else{
                print("Couldn't parese pet map")
            }
            
        }else{
            print("User data is nil")
        }
    }
    
    func updateBar(bar:DisplayView, last:Timestamp, level:Double, color:UIColor){
        let NUM_SEC_IN_HOURS:Double = 60 * 60
        let curTime = TimeInterval(NSDate().timeIntervalSince1970)
        let lastTime = TimeInterval(last.seconds)
        let deltaTInHours = (curTime - lastTime) / NUM_SEC_IN_HOURS
        let decay = PetGlobals.DECAY_RATE_PER_HOUR * deltaTInHours
        
        let currentLevel = (level - decay) / 100
        
        
        
        bar.animateValue(to: CGFloat(currentLevel))
        
        bar.color = color
        
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
    
}



