//
//  SettingsViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var visibilitySwitch: UISwitch!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var retypePassword: UITextField!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var aboutGameText: UITextView!
    @IBOutlet weak var passwordView: UIView!
    
    
    var spinnerView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSwitch()
        updateEmailLabel()

        // Do any additional setup after loading the view.
    }
    
    let USRNAME_REGX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    //  let PASS_REGX = "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}$"
    let MIN_PASS_LEN = 6
    
    
    @IBAction func onPressChangePassword(_ sender: Any) {
        
        
        if validateUserInput(){
            toggleUI(display: false)
            toggleSpinner(display: true)
            reAuthenticate()
        }
        
    }
    
    func updateSwitch(){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            db.collection(FirebaseKeys.USERS_COLLECTION_NAME).whereField(FirebaseKeys.USER_ID, isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        var isInvisible = false
                        if let invisible = document.get(FirebaseKeys.INVISIBLE) as? Bool{
                            isInvisible = invisible
                        }
                        print(isInvisible)
                        self.visibilitySwitch.setOn(isInvisible, animated: true)
                    }
                }
            }
        }
    }
    
    
    // Retrives user data from the firestore database
    func updateEmailLabel(){
        if let email = Auth.auth().currentUser?.email{
            emailLabel.text = email
        }else{
            emailLabel.text = "Invalid Login"
        }
        
    }
    
    
    func reAuthenticate(){
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: emailLabel.text!, password: oldPassword.text!)
        
        // Prompt the user to re-provide their sign-in credentials
        user?.reauthenticate(with: credential){ [weak self] authResult, error in
            guard let strongSelf = self else {return}
            if let error = error{ // Possibly error in old-password
                let alert = UIAlertController(title: "Error Changing Password!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                strongSelf.present(alert, animated: true)
                
                strongSelf.toggleUI(display: true)
                strongSelf.toggleSpinner(display: false)
                
            }else{ //
                Auth.auth().currentUser?.updatePassword(to: strongSelf.newPassword.text!) { (error) in
                    if let error = error{ // Possible error in new password
                        let alert = UIAlertController(title: "Error Changing Password!", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        strongSelf.present(alert, animated: true)
                    }else{
                        let alert = UIAlertController(title: "Password Changed!", message: "Your password was successfully changed.", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        strongSelf.present(alert, animated: true)
                    }
                }
                strongSelf.toggleUI(display: true)
                strongSelf.toggleSpinner(display: false)
                
            }
            
            
        }
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        
        let invisibility:Bool = visibilitySwitch.isOn
        togggleInvisibility(isInvisible: invisibility)
        
    }
    
    func togggleInvisibility(isInvisible: Bool){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            
            db.collection(FirebaseKeys.USERS_COLLECTION_NAME).whereField(FirebaseKeys.USER_ID, isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        let userRef = db.collection("users").document("\(document.documentID)")
                        userRef.updateData([
                            FirebaseKeys.INVISIBLE : isInvisible
                            ])
                    }
                }
            }
        }
    }
    
    // Hide all the UI
    func toggleUI(display:Bool){
        newPassword.isHidden = !display
        retypePassword.isHidden = !display
        oldPassword.isHidden = !display
        changePasswordButton.isHidden = !display
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
    
    
    
    
    
    
    // Function to validate the user input
    func validateUserInput() -> Bool{
        if let username = emailLabel.text{
            if let password = newPassword.text{
                if newPassword.text! == retypePassword.text!{
                    if username.range(of: USRNAME_REGX, options: .regularExpression) != nil{
                        if password.count >= MIN_PASS_LEN {
                            return true;
                        }else{
                            let alert = UIAlertController(title: "Invalid Password", message: "Please enter a password that is at least \(MIN_PASS_LEN) characters long.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            present(alert, animated:true)
                        }
                    }else{
                        let alert = UIAlertController(title: "Invalid Username", message: "Please enter the email address that you used to register for an acount.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        present(alert, animated:true)
                    }
                }else{
                    let alert = UIAlertController(title: "Invalid Password", message: "Please make sure you re-typed the same password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    present(alert, animated:true)
                }
            }
        }
        
        
        return false
    }
    
}
