//
//  DisplayStorageItemViewController.swift
//  PetSteP
//
//  Created by Uki Malla on 11/29/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class DisplayStorageItemViewController: UIViewController {
    
    @IBOutlet weak var theImageView: UIImageView!
    
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var utilityLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var outsideView: UIVisualEffectView!
    let CURRENCY_STR = "c"
    @IBOutlet weak var theViewEffect: UIVisualEffectView!
    
    
    
    var theImage:UIImage?
    var itemName:String?
    var itemDocument:QueryDocumentSnapshot?
    var itemUtility:Int = 0
    var itemDescription:String?
    var itemType:String?
    var itemSubType:String?
    
    @IBOutlet weak var utilityTitleLabel: UILabel!
    var FOOD = "food"
    var FURNITURE = "furniture"
    var CARE = "care"
    var FUN = "fun"
    
    let FURNITURE_ACTION_BUTTON_LABEL = "Equip"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView() 
    }
    
    
    
    
    
    func initView(){
        initBlurView()
        print(itemSubType!)
        theImageView.image = theImage
        itemNameLabel.text = itemName
        utilityLabel.text = "\(itemUtility)\(CURRENCY_STR)"
        
        theView.layer.cornerRadius = 10
        theViewEffect.layer.cornerRadius = 10
        
        if itemType == FURNITURE{
            actionButton.setTitle(FURNITURE_ACTION_BUTTON_LABEL, for: .normal) 
            utilityLabel.isHidden = true
            utilityTitleLabel.isHidden = true
            
        }
        
    }
    
    func initBlurView(){
        outsideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (self.closeViewUsingTap)))
        
    }
    
    
    @IBAction func useItem(_ sender: Any) {
        actionButton.isHidden = true
        if itemType != FURNITURE{
            viewAnimation(completionTask: performItemUse)
        }else{
            viewAnimation(completionTask: performItemEquip)
        }
        
    }
    
    
    
    func viewAnimation(completionTask: @escaping ()->Void){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let petAnimVC = storyBoard.instantiateViewController(withIdentifier: "PetAnimationVC")
        petAnimVC.modalPresentationStyle = .fullScreen
         
        let animVC = petAnimVC as? PetAnimationViewController
        
        if animVC != nil {
            animVC!.animationItemName = itemSubType
            animVC!.itemType = itemType
            if itemType == FURNITURE {
                animVC!.isAnimated = false
            } else {
                animVC!.isAnimated = true
            }
            present(animVC!, animated: true, completion: completionTask)
        } else {
            print("PetAnimationVC load error")
        }
        
        //present(petAnimVC, animated: true, completion: completionTask)
    }
    
    func performItemEquip(){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        // Getting items attributes from the itemDocument
                        if self.itemDocument != nil{
                            let docRef = db.collection(FirebaseKeys.USERS_COLLECTION_NAME).document(document.documentID)
                            let itemPosition = self.itemDocument!.get(FirebaseKeys.ITEM_POSITION) as? String
                            if itemPosition != nil && self.itemSubType != nil{
                                print("Equiping Item")
                                docRef.updateData([itemPosition!: self.itemSubType! ]){ err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                                }
                            }else{
                                print(itemPosition)
                                print(self.itemSubType)
                            }
                        }
                    }
                }
                
            }
            
        }
        initTimer(equip: true)
    }
    
    
    
    
    func performItemUse(){
        applyItem()
        removeItemFromStorage()
        
    }
    
    
    
    func applyItem(){
        let levelKey = getLevelFirestoreKey()
        let timestampKey = getTimestampFirestoreKey()
        updateStats(levelKey: levelKey, timestampKey: timestampKey)
        initTimer(equip: false)
    }
    
    func initTimer(equip: Bool){
        var time = PetGlobals.ANIM_DURATION
        if equip {
            time = 1.5
        }
        Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire()
    {
        closeView() // Closing the animation view
        closeView() // Closing self
    }
    
    
    
    func removeItemFromStorage(){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        // Getting items attributes from the itemDocument
                        if self.itemDocument != nil{
                            let docRef = db.collection("\(FirebaseKeys.USERS_COLLECTION_NAME)/\(document.documentID)/\(FirebaseKeys.USER_ITEM_COLLECTION_NAME)").document(self.itemDocument!.documentID)
                            docRef.delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                }
                            }
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    
    
    
    func calcCurrentLevel(last:Timestamp, level:Double) -> Double{
        let NUM_SEC_IN_HOURS:Double = 60 * 60
        let curTime = TimeInterval(NSDate().timeIntervalSince1970)
        let lastTime = TimeInterval(last.seconds)
        let deltaTInHours = (curTime - lastTime) / NUM_SEC_IN_HOURS
        let decay = PetGlobals.DECAY_RATE_PER_HOUR * deltaTInHours
        
        var currentLevel = (Double(level) - decay)
        
        if currentLevel < 0{
            currentLevel = 0
        }
        
        return currentLevel
    }
    
    
    
    func updateStats(levelKey:String, timestampKey:String){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            db.collection(FirebaseKeys.USERS_COLLECTION_NAME).whereField(FirebaseKeys.USER_ID, isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        if let pet = document.get(FirebaseKeys.PET) as? [String:AnyObject]{
                            // Fetching pet stats data
                            let level = pet[levelKey] as? Double
                            let last = pet[timestampKey] as? Timestamp
                            
                            if (last != nil && level != nil){
                                let currentLevel = self.calcCurrentLevel(last: last!, level: level!)
                                var newLevel = currentLevel + Double(self.itemUtility) * PetGlobals.LEVEL_PER_UTIL
                                print("new level\(newLevel)")
                                if (newLevel > PetGlobals.MAX_LEVEL){
                                    newLevel = 100
                                }
                                
                                let docRef = db.collection(FirebaseKeys.USERS_COLLECTION_NAME).document(document.documentID)
                                docRef.updateData([
                                    "\(FirebaseKeys.PET).\(levelKey)" : newLevel,
                                    "\(FirebaseKeys.PET).\(timestampKey)" : FieldValue.serverTimestamp()
                                    
                                    ])
                            }else{
                                print("this")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    func getLevelFirestoreKey() -> String{
        switch itemType {
        case FOOD:
            return FirebaseKeys.FOOD_LEVEL
        case CARE:
            return FirebaseKeys.HYGIENE_LEVEL
        case FUN:
            return FirebaseKeys.HAPPINESS_LEVEL
        default:
            return FirebaseKeys.HAPPINESS_LEVEL
        }
    }
    
    func getTimestampFirestoreKey() -> String{
        switch itemType {
        case FOOD:
            return FirebaseKeys.LAST_FED
        case CARE:
            return FirebaseKeys.LAST_CARE
        case FUN:
            return FirebaseKeys.LAST_PLAYED
        default:
            return FirebaseKeys.LAST_PLAYED
        }
    }
    
    
    
    
    
    
    
    
    @objc func closeViewUsingTap(sender: UITapGestureRecognizer)  {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func closeView()  {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        let petAnimVC = segue.destination as? PetAnimationViewController
        
        if petAnimVC != nil {
            petAnimVC!.animationItemName = itemSubType
            
        }
        
        
    }
    
    
}






