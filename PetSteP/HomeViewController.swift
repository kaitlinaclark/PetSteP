//
//  HomeViewController.swift
//  PetSteP
//
//  Created by Kaitlin Clark on 11/9/19.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var harvestCoinsButton: UIButton!
    
    @IBOutlet weak var feedButton: UIButton!
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var coinsLabel: UILabel!
    
    
    //NO IMAGE VIEW FOR PET IMAGE YET
    
    
    @IBOutlet weak var happyIcon: UIImageView!
    @IBOutlet weak var happyBar: DisplayView!
    
    
    @IBOutlet weak var foodIcon: UIImageView!
    @IBOutlet weak var foodBar: DisplayView!
    
    
    @IBOutlet weak var waterIcon: UIImageView!
    @IBOutlet weak var waterBar: DisplayView!
    
    
    @IBOutlet weak var healthIcon: UIImageView!
    @IBOutlet weak var healthLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set initial values for bars
        happyBar.animateValue(to: CGFloat(0.5))
        happyBar.color = .gray
        
        foodBar.animateValue(to: CGFloat(0.5))
        foodBar.color = .gray
        
        waterBar.animateValue(to: CGFloat(0.5))
        waterBar.color = .gray
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
