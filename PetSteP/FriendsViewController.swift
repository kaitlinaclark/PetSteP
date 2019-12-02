//
//  FriendsViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var theTableView: UITableView!
    
    var searchResults:[QueryDocumentSnapshot] = []
    var spinnerView:UIActivityIndicatorView!
    var selectedItemIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
        searchBar.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return searchResults.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "myCell"){
            print(searchResults.count)
                    if let nameOfUser = searchResults[indexPath.item].get(FirebaseKeys.NAME_OF_USER) as? String{
                myCell.textLabel?.text = nameOfUser.capitalized
            }
            return myCell
        }else{
            return UITableViewCell(style: .default, reuseIdentifier: "myCell")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Searching...")
        self.searchResults.removeAll()
        if let searchText = searchBar.text{
            if searchText.count > 0{
                getUsersWith(name: searchText.lowercased())
                toggleUI(display: false)
                toggleSpinner(display: true)
            }
        }
    }
    
    func onDoneSearching(){
        toggleSpinner(display: false)
        toggleUI(display: true)
        theTableView.reloadData()
    }
    
    
    
    // Retrives user data from the firestore database
    func getUsersWith(name:String){
        let db = Firestore.firestore()
        
        db.collection(FirebaseKeys.USERS_COLLECTION_NAME)
            .whereField(FirebaseKeys.NAME_OF_USER, isGreaterThanOrEqualTo: name)
            .whereField(FirebaseKeys.NAME_OF_USER, isLessThanOrEqualTo: getNameSearchEndRange(name: name) )
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print(document)
                        var isInvisible = false
                        if let invisible = document.get(FirebaseKeys.INVISIBLE) as? Bool{
                            isInvisible = invisible
                        }
                        
                        if !isInvisible{
                            self.searchResults.append(document)
                        }
                        
                    }
                    self.onDoneSearching()
                }
        }
    }
    
    func getNameSearchEndRange(name:String)->String{
        var retVal = name
       
        let strIndex = retVal.index(retVal.endIndex, offsetBy: -1)
        if let endASCII = retVal[strIndex].asciiValue{
            let c = Character(UnicodeScalar(endASCII + 1))
            retVal = String(retVal.dropLast())
            retVal.append(c)
        }
        return retVal
    }
    
    
    
    
    // Hide all the UI
    func toggleUI(display:Bool){
        theTableView.isHidden = !display
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        selectedItemIndex = indexPath.item
        return true
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
        let friendRoomVC = segue.destination as? FriendRoomViewController
        
        if friendRoomVC != nil {
            friendRoomVC!.userData = searchResults[selectedItemIndex]
            
        }
        
        
     }
    
}
