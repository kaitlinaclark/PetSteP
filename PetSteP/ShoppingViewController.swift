//
//  ShoppingViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit

class ShoppingViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var purchaseButton: UIButton!
    
    
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var coinsImg: UIImageView! //32x32 image
    
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var furnitureButton: UIButton!
    @IBOutlet weak var careButton: UIButton!
    @IBOutlet weak var funButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
