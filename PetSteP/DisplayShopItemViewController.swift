//
//  DisplayShopItemViewController.swift
//  PetSteP
//
//  Created by Uki Malla on 11/28/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class DisplayShopItemViewController: UIViewController {
    
    @IBOutlet weak var theImageView: UIImageView!
    
    @IBOutlet weak var noItemsTextField: UITextField!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var outsideView: UIVisualEffectView!
    let CURRENCY_STR = "c"
    @IBOutlet weak var theViewEffect: UIVisualEffectView!
    
    
    
    var theImage:UIImage?
    var itemName:String?
    var itemDocument:QueryDocumentSnapshot?
    var itemPrice:Int = Int(INT_MAX)
    var userCoins = -1
    var itemDescription:String?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoneyFromUser()
        initView()
        
        // Do any additional setup after loading the view.
        

        
        
    }

    
    
    func initView(){
        initBlurView()
        theImageView.image = theImage
        itemNameLabel.text = itemName
        priceLabel.text = "\(itemPrice)\(CURRENCY_STR)"
        if let noItems:Int = Int(noItemsTextField.text!){
            totalPriceLabel.text = "\(itemPrice * noItems)\(CURRENCY_STR)"
        }
        theView.layer.cornerRadius = 10
        theViewEffect.layer.cornerRadius = 10
    }
    
    func initBlurView(){
        outsideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (self.closeViewUsingTap)))

        
    }
    
    

    
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func onNoItemsChanged(_ sender: Any) {
        if let noItems:Int = Int(noItemsTextField.text!){
            totalPriceLabel.text = "\(itemPrice * noItems)\(CURRENCY_STR)"
        }else{
            totalPriceLabel.text = "NaN"
        }
        
    }
    
    func getMoneyFromUser(){
        let db = Firestore.firestore()
        //db.collection
        
        
        // Retrieve user data
        if let user = Auth.auth().currentUser{
            print("Fetching collection for \(user.uid)")
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        if let coins = document.get("coins") as? Int{
                            self.userCoins = coins
                        }
                    }
                }
            }
            
        }
        
        
    }
    
    
    @IBAction func onPressedBuy(_ sender: Any) {
        var alert:UIAlertController? = nil
        
        if let noItems:Int = Int(noItemsTextField.text!){
            let totalPrice = itemPrice * noItems;
            if( userCoins < totalPrice){ // Insufficient Funds
                alert = UIAlertController(title: "Insufficient Funds.", message: "You have only \(userCoins)\(CURRENCY_STR), but you need \(totalPrice)\(CURRENCY_STR).", preferredStyle: .alert)
            }else{
                buyCurrentItem(itemPrice:totalPrice, numItems: noItems)
            }
            
        }else{ // Invalid No. of Items text Field
            alert = UIAlertController(title: "Invalid Number of Items", message: "Please enter a a whole number in the No. of Items field.", preferredStyle: .alert)
        }
        
        if (alert != nil){
            alert!.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert!, animated: true)
        }
        
    }
    
    func buyCurrentItem(itemPrice:Int, numItems:Int){
        addItemToStore(numItems:numItems)
        decreseMoney(decreaseAmount: itemPrice)
        closeView()
    }
    
    @objc func closeViewUsingTap(sender: UITapGestureRecognizer)  {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func closeView()  {
        self.dismiss(animated: true, completion: nil)

    }
    
    
    func addItemToStore(numItems:Int){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        // Getting items attributes from the itemDocument
                        let itemName = self.itemDocument?.get(FirebaseKeys.ITEM_NAME) as? String
                        let itemDescription = self.itemDocument?.get(FirebaseKeys.ITEM_DESCRIPTION) as? String
                        let itemSubtype = self.itemDocument?.get(FirebaseKeys.ITEM_SUBTYPE) as? String
                        let itemType = self.itemDocument?.get(FirebaseKeys.ITEM_TYPE) as? String
                        
                        if(itemName != nil && itemDescription != nil && itemSubtype != nil && itemType != nil){ // If none of the attributes are missing
                            // Getting the user reference in firestore
                            let userRef = db.collection("\(FirebaseKeys.USERS_COLLECTION_NAME)/\(document.documentID)/\(FirebaseKeys.USER_ITEM_COLLECTION_NAME)")
                            
                            // Adding item to the user's storage
                            for _ in 0 ... numItems{
                                userRef.addDocument(
                                    data: [FirebaseKeys.ITEM_NAME : itemName!,
                                           FirebaseKeys.ITEM_TYPE: itemType!,
                                           FirebaseKeys.ITEM_SUBTYPE: itemSubtype!,
                                           FirebaseKeys.ITEM_DESCRIPTION: itemDescription!
                                    ])
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    
    
    func decreseMoney(decreaseAmount:Int){
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
            
            db.collection("users").whereField("userID", isEqualTo: user.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        let userRef = db.collection("users").document("\(document.documentID)")
                        let totalPrice = decreaseAmount
                        userRef.updateData([
                            "coins": FieldValue.increment(Int64(-totalPrice))
                            ])
                    }
                }
            }
        }
        
        
        
    }
    
    
    
    
    
}

