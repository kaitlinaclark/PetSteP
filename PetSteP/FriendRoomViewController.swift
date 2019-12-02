//
//  FriendRoomViewController.swift
//  PetSteP
//
//  Created by Uki Malla on 12/1/19.
//

import UIKit
import FirebaseFirestore

class FriendRoomViewController: UIViewController {
    
    var userData:QueryDocumentSnapshot?
    
    @IBOutlet weak var totalStepsLabel: UILabel!
    @IBOutlet weak var daysAliveLabel: UILabel!
    
    @IBOutlet weak var table: UIImageView!
    @IBOutlet weak var frame: UIImageView!
    @IBOutlet weak var lamp: UIImageView!
    @IBOutlet weak var carpet: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var happinessBar: DisplayView!
    @IBOutlet weak var foodBar: DisplayView!
    @IBOutlet weak var hygieneBar: DisplayView!
    
    
    @IBOutlet weak var healthLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView!
    
    let TOTAL_STEPS_PRE_TEXT = "Total Steps: "
    let DAYS_ALIVE_PRE_TEXT = "Days Alive: "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
    }
    
    
    func initView(){
        if userData == nil{
            navigationController?.popViewController(animated: true)
        }else{
            viewUserData()
            incrementNumVisiters()
        }
    }
    
    func incrementNumVisiters(){
        let db = Firestore.firestore()
        let incrementAmount = 1
        
        let docRef = db.collection(FirebaseKeys.USERS_COLLECTION_NAME).document(userData!.documentID)
        docRef.updateData([FirebaseKeys.NUMBER_OF_VISITS : FieldValue.increment(Int64(incrementAmount))])
    
        
    }
    
    
    func viewUserData(){
        print("In user Data!***")
        if userData != nil{
            
            if let totalSteps = userData?.get(FirebaseKeys.TOTAL_STEPS) as? Int{
                totalStepsLabel.text = TOTAL_STEPS_PRE_TEXT + String(totalSteps)
            }
            
            if let petBirthday = userData?.get(FirebaseKeys.PET_BIRTHDAY) as? Timestamp{
                daysAliveLabel.text = DAYS_ALIVE_PRE_TEXT + String(numDaysAlive(birthday:  petBirthday))
            }

            if let lampPosition = userData?.get(FirebaseKeys.LAMP_POSITION) as? String{
                lamp.image = UIImage(named: lampPosition)
            }else{
                lamp.image = nil
            }
            
            if let carpetPosition = userData?.get(FirebaseKeys.CARPET_POSITION) as? String{
                carpet.image = UIImage(named: carpetPosition)
            }else{
                carpet.image = nil
            }
            
            if let framePosition = userData?.get(FirebaseKeys.FRAME_POSITION) as? String{
                frame.image = UIImage(named: framePosition)
            }else{
                frame.image = nil
            }
            
            if let tablePosition = userData?.get(FirebaseKeys.TABLE_POSITION) as? String{
                table.image = UIImage(named: tablePosition)
            }else{
                table.image = nil
            }
            
            
            if let pet = userData?.get(FirebaseKeys.PET) as? [String:AnyObject]{
                if let petName = pet[FirebaseKeys.NAME] as? String{
                    petNameLabel.text = petName.capitalized
                }
                
                if let petType = pet[FirebaseKeys.TYPE] as? String{
                    petImageView.image = UIImage(named: petType)
                }else{
                    petImageView.image = nil
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
                
                let totalLevel = happinessBar.value + hygieneBar.value +  foodBar.value

                
                // Checking the health of the pet
                if (Double(totalLevel) < PetGlobals.SICK_TOTAL_LEVEL_THRESHOLD || Double(happinessBar.value) < PetGlobals.SINGLE_LEVEL_THRESHOLD || Double(hygieneBar.value) < PetGlobals.SINGLE_LEVEL_THRESHOLD || Double(foodBar.value) < PetGlobals.SINGLE_LEVEL_THRESHOLD){
                    sickRoutine()
                }else{
                    happyRoutine()
                }

                
                
            }else{
                print("Couldn't parese pet map")
            }
            
        }else{
            print("User data is nil")
        }
    }
    
    // Put all the sick procedures here
    func sickRoutine(){
        healthLabel.text = PetGlobals.PET_SICK
    }
    
    
    // Put all the happy procedures here
    func happyRoutine(){
        healthLabel.text = PetGlobals.PET_HEALTHY
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
    
    func numDaysAlive(birthday:Timestamp) -> Int{
        
        let NUM_SEC_IN_HOURS:Double = 60 * 60
        let NUM_HOURS_IN_DAYS = 24
        
        let curTime = TimeInterval(NSDate().timeIntervalSince1970)
        let lastTime = TimeInterval(birthday.seconds)
        let deltaTInHours = (curTime - lastTime) / NUM_SEC_IN_HOURS
        
        return Int(deltaTInHours / Double(NUM_HOURS_IN_DAYS))
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
