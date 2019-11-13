//
//  ViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var pswdField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var spinnerView:UIActivityIndicatorView!
    
    let USRNAME_REGX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    //  let PASS_REGX = "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}$"
    let MIN_PASS_LEN = 4
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        toggleUI(display: false)
        toggleSpinner(display: true)
        if validateUserInput(){
            logIn();
        } // TODO: Display message for invalid input
        
    }
    
    
    
    
    func logIn(){
        
        let email = (usernameField.text)!
        let password = (pswdField.text)!
        
        // Firebase function call to login using email and password
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {return}
            strongSelf.toggleSpinner(display: false)
            
            // Checking whether login was succesful
            if authResult?.user != nil{
                // Login successful
                strongSelf.pushHomeView()
            }else{
                // Login was not successful
                strongSelf.toggleUI(display: true)
                //TODO: Display login message
            }
        }
        
        
    }
    
    
    func toggleUI(display:Bool){
        usernameField.isHidden = !display
        pswdField.isHidden = !display
        loginButton.isHidden = !display
        
    }
    
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
    
    
    
    
    // Function to validate the user input
    func validateUserInput() -> Bool{
        if let username = usernameField.text{
            if let password = pswdField.text{
                if username.range(of: USRNAME_REGX, options: .regularExpression) != nil{
                    if password.count >= MIN_PASS_LEN {
                        return true;
                    }
                }
            }
        }
        
        toggleSpinner(display: false)
        toggleUI(display: true)
        
        return false
        
    }
    
    
    
}

