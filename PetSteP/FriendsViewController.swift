//
//  FriendsViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var findFriendSearchBar: UISearchBar!
    
    @IBOutlet weak var requestsTableView: UITableView!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(scrollView)
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
