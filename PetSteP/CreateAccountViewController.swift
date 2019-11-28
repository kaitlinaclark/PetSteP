//
//  CreateAccountViewController.swift
//  PetSteP
//
//  Created by Joseph Albert on 11/24/19.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPet: UIPickerView!
   
    let defaults = UserDefaults.standard
    
    //when user presses submit on new account
    @IBAction func submit(_ sender: Any) {
        print("submit button pressed..")
        let db = Firestore.firestore()
        var accoutCreated = false
        //create user account
        Auth.auth().createUser(withEmail: newEmail.text!, password: newPassword.text!) { authResult, error in
            print("creating user")
            print(error as Any)
            //log in user
            Auth.auth().signIn(withEmail: self.newEmail.text!, password: self.newPassword.text!) { [weak self] authResult, error in
                print("logging user in")
                print(error as Any)
                
                //Create a new document with a generated id.
                      if let user = Auth.auth().currentUser{
                                 print("Fetching collection for \(user.uid)")
                                 var ref: DocumentReference? = nil
                                 ref = db.collection("users").addDocument(data: [
                                  "coins": "0",
                                  "username": self!.newEmail.text!,
                                  //UKI HERE IS WHERE WE NEED TO ENTER THE PICKER'S VALUE BELOW FOR PET: ****
                                  "pet" : "testPet",
                                  "totalSteps" : "0",
                                  "userID" : user.uid,
                                 ]) { err in
                                     if let err = err {
                                         print("Error adding document: \(err)")
                                     } else {
                                         print("Document added with ID: \(ref!.documentID)")
                                     }
                                 }
                       }
            }
            
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
