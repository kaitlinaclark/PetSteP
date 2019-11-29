//
//  ShoppingViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ShoppingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var coinsImg: UIImageView! //32x32 image
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var sectionBar: UISegmentedControl!
    
    
    
    var foodList:[QueryDocumentSnapshot] = []
    var furnitureList:[QueryDocumentSnapshot] = []
    var careList:[QueryDocumentSnapshot] = []
    var funList:[QueryDocumentSnapshot] = []
    
    var FOOD = "food"
    var FURNITURE = "furniture"
    var CARE = "care"
    var FUN = "fun"
    var sectionsList:[String] = []
    
    let TITLE_HEIGHT = CGFloat(40)
    let CELL_HEIGHT = CGFloat(130)
    let CELL_WIDTH = CGFloat(90)
    
    var itemSelected:Int = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shop"
        
        // Do any additional setup after loading the view.
        setupCollectionView()
        getAllShopItems()
        getMoneyFromUser()
        
        
        
        
    }
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        print(sectionBar.selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    func getCurrentItemsList() -> [QueryDocumentSnapshot]{
        switch sectionsList[sectionBar.selectedSegmentIndex] {
        case FOOD:
            return foodList
        case FURNITURE:
            return furnitureList
        case CARE:
            return careList
        case FUN:
            return funList
        default:
            return foodList
        }
    }
    
    
    // Function to get all items from the firebase and store them in their respective lists
    func getAllShopItems(){
        sectionsList = [FOOD, FURNITURE, CARE, FUN]
        
        
        let db = Firestore.firestore()
        
        // Reteriving all the documents from "storeItems" collection
        db.collection("storeItems").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.addToItemsList(document: document)
                }
                self.collectionView.reloadData()
            }
        }
        
        
        
    }
    
    
    
 
    
    func getMoneyFromUser(){
        let db = Firestore.firestore()
        //db.collection
        
        // Retrieve user data
        if let user = Auth.auth().currentUser{
            print("Fetching collection for \(user.uid)")
            db.collection("users").whereField("userID", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Loop should run a maximum of one time
                    for document in querySnapshot!.documents {
                        if let coins = document.get("coins") as? Int{
                            self.coinsLabel.text = "Coins: \(coins)"
                        }
                    }
                }
            }
            
        }
    }
    
    
    // Function to assing add a document to its respective items list
    func addToItemsList(document: QueryDocumentSnapshot){
        if let itemType = document.get("type") as? String{
            switch itemType{
            case FOOD:
                foodList.append(document)
                return
            case FURNITURE:
                furnitureList.append(document)
                return
            case CARE:
                careList.append(document)
                return
            case FUN:
                funList.append(document)
                return
            default:
                return
            }
            
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return getCurrentItemsList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath)
        
        let TEXT_PADDING = CGFloat(10)
        let IMAGE_PADDING = CGFloat(10)
        let IMAGE_WIDTH = CGFloat(64)
        let IMAGE_HEIGHT = CGFloat(64)
        
        let NUM_LINES = 2
        let LABEL_FONT_SIZE = CGFloat(11)
        let MSG_FONT_SIZE = CGFloat(10)
        let NO_IMG_MSG = "No Image Available"
        
        
        myCell.backgroundColor = UIColor.clear
        
        // Removing all the subviews from myCell.contentView
        if myCell.contentView.subviews.count > 0{
            for subView in myCell.contentView.subviews{
                subView.removeFromSuperview()
            }
        }
        
        // Creating the Ttile and Image Frames
        let labelFrame = CGRect(x: CGFloat(TEXT_PADDING/2), y: CELL_HEIGHT - TITLE_HEIGHT, width: CELL_WIDTH - TEXT_PADDING, height: TITLE_HEIGHT)
        let itemImageFrame = CGRect(x: CGFloat(0), y: CGFloat(IMAGE_PADDING), width: IMAGE_WIDTH, height: IMAGE_HEIGHT)

        
        // Creating UIViews for the image and title
        let titleLabel = UILabel(frame: labelFrame)
        let itemImage = UIImageView(frame: itemImageFrame)
        
        // Setting up titleLabel
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = NUM_LINES
        titleLabel.font = UIFont.boldSystemFont(ofSize: LABEL_FONT_SIZE)
        titleLabel.textAlignment = NSTextAlignment.center
        
        // Setting up itemImage
        itemImage.center.x = myCell.contentView.center.x

        
        
        // Getting itemName
        let itemName = getCurrentItemsList()[indexPath.item].get("name") as? String
        let itemSubType = getCurrentItemsList()[indexPath.item].get("subtype") as? String
        
        // Setting title
        if itemName != nil{
            titleLabel.text = itemName
            
        }
        
        // Setting itemSubtype
        
        if itemSubType != nil{

            if let image = UIImage(named: itemSubType!){
                
                itemImage.image = image
                if image.size.width > image.size.height {
                    itemImage.contentMode = UIView.ContentMode.scaleAspectFit
                } else {
                    itemImage.contentMode = UIView.ContentMode.scaleAspectFill
                }
            }else{
                let message = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CELL_WIDTH, height: CELL_HEIGHT))
                message.center = myCell.contentView.center
                message.text = NO_IMG_MSG
                message.textColor = UIColor.gray
                message.numberOfLines = NUM_LINES
                message.font = UIFont.boldSystemFont(ofSize: MSG_FONT_SIZE)
                message.textAlignment = NSTextAlignment.center
                
                myCell.contentView.addSubview(message)
            }
        }
        myCell.contentView.addSubview(titleLabel)
        myCell.contentView.addSubview(itemImage)
        return myCell

    }
    
    @IBAction func onSectionBarChanged(_ sender: Any) {
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        itemSelected = indexPath.item
        
        return true
    }
    
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
        let displayShopItemViewController = segue.destination as? DisplayShopItemViewController
        
        if displayShopItemViewController != nil {
            
            // Getting itemName
            let itemName = getCurrentItemsList()[itemSelected].get("name") as? String
            let itemSubType = getCurrentItemsList()[itemSelected].get("subtype") as? String
            let price = getCurrentItemsList()[itemSelected].get("price") as? Int

            let itemDocument = getCurrentItemsList()[itemSelected]
            
            if itemDocument != nil{
                displayShopItemViewController!.itemDocument = itemDocument
            }
            
            if itemSubType != nil{
                displayShopItemViewController!.theImage = UIImage(named: itemSubType!)
            }
            
            if itemName != nil{
                displayShopItemViewController!.itemName = itemName
            }
            
            if price != nil{
                displayShopItemViewController!.itemPrice = price!
            }
            
            
        }
        
     }
    
    
    
    
    
    
    
    
    
}
