//
//  CreateAccountViewController.swift
//  PetSteP
//
//  Created by Joseph Albert on 11/24/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPet: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var petLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var spinnerView:UIActivityIndicatorView!
    
    
    let USRNAME_REGX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let MIN_PASS_LEN = 6
    
    var pet = ["Sheep", "Goldfish", "Duck"]
    
    
    //when user presses submit on new account
    @IBAction func submit(_ sender: Any) {
        toggleUI(display: false)
        toggleSpinner(display: true)
        if validateUserInput(){
            attemptRegistration()
        }else{
            toggleSpinner(display: false)
            toggleUI(display: true)
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pet.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pet[row]
    }
    
    // Function to validate the user input
    func validateUserInput() -> Bool{
        if let username = newEmail.text{
            if let password = newPassword.text{
                if username.range(of: USRNAME_REGX, options: .regularExpression) != nil{
                    if password.count >= MIN_PASS_LEN {
                        return true;
                    }else{
                        let alert = UIAlertController(title: "Invalid Password", message: "Please enter a password that is at least \(MIN_PASS_LEN) characters long.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        present(alert, animated:true)
                    }
                }else{
                    let alert = UIAlertController(title: "Invalid Username", message: "Please enter a valid email address to register for an acount.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    present(alert, animated:true)
                }
            }
        }
        
        toggleSpinner(display: false)
        toggleUI(display: true)
        
        return false
        
    }
    
    
    func attemptRegistration(){
        print("submit button pressed..")
        let db = Firestore.firestore()
        //create user account
        Auth.auth().createUser(withEmail: newEmail.text!, password: newPassword.text!) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                
                // Toggeling UIs
                self.toggleSpinner(display: false)
                self.toggleUI(display: true)
                
                /// Displaying the error
                let alert = UIAlertController(title: "Regsitration Error.", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
                //Create a new document with a generated id.
                if let _ = Auth.auth().currentUser{
                    
                    let petObj =  [FirebaseKeys.TYPE             : self.pet[self.newPet.selectedRow(inComponent: 0)],
                                   FirebaseKeys.NAME             : self.pet[self.newPet.selectedRow(inComponent: 0)],
                                   FirebaseKeys.LAST_FED         : FieldValue.serverTimestamp(),
                                   FirebaseKeys.LAST_CARE        : FieldValue.serverTimestamp(),
                                   FirebaseKeys.LAST_PLAYED      : FieldValue.serverTimestamp(),
                                   FirebaseKeys.FOOD_LEVEL       : PetGlobals.MAX_LEVEL,
                                   FirebaseKeys.HYGIENE_LEVEL    : PetGlobals.MAX_LEVEL,
                                   FirebaseKeys.HAPPINESS_LEVEL  : PetGlobals.MAX_LEVEL] as [String : Any]
                    
                    var ref: DocumentReference? = nil
                    ref = db.collection(FirebaseKeys.USERS_COLLECTION_NAME).addDocument(data: [
                        FirebaseKeys.NAME_OF_USER         : self.newUsername.text!,
                        FirebaseKeys.USER_ID              : user.uid,
                        FirebaseKeys.TOTAL_STEPS          : 0,
                        FirebaseKeys.COINS                : 10000,
                        FirebaseKeys.LAST_HARVESTED_AMOUNT: 0,
                        FirebaseKeys.LAST_HARVESTED_DATE  : FieldValue.serverTimestamp(),
                        FirebaseKeys.PET                  : petObj
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            self.pushHomeView()
                        }
                    }
                }
            
        }
        
    }
    
    func pushHomeView(){
        /* Example Reference:  https://stackoverflow.com/questions/39929592/how-to-push-and-present-to-uiviewcontroller-programmatically-without-segue-in-io */
        
        
        
        // Safe Push VC
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? UINavigationController {
            if let navigator = navigationController {
                //                navigator.pushViewController(viewController, animated: true)
                navigator.showDetailViewController(viewController, sender: self)
            }
            
        }
    }
    
    // Hide all the UI
    func toggleUI(display:Bool){
        newEmail.isHidden = !display
        newPassword.isHidden = !display
        newUsername.isHidden = !display
        newPet.isHidden = !display
        
        emailLabel.isHidden = !display
        nameLabel.isHidden = !display
        passwordLabel.isHidden = !display
        petLabel.isHidden = !display
        
        submitButton.isHidden = !display
    }
    
    // Enable/Disable Spinner while registering the user.
    func toggleSpinner(display:Bool){
        if spinnerView == nil{
            spinnerView = UIActivityIndicatorView.init(style: .gray)
            spinnerView.center = view.center
            view.addSubview(spinnerView)
        }
        if display{
            spinnerView.startAnimating()
        }else{
            spinnerView.stopAnimating()
        }
    }
    
    
    
    func initView(){
        newPet.delegate = self
        newPet.dataSource = self
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }
    
}
