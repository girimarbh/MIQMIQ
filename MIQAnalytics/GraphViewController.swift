//
//  GraphViewController.swift
//  MIQAnalytics
//
//  Created by Girish on 19/11/19.
//  Copyright © 2019 Girish. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!


    override func viewDidLoad() {
            super.viewDidLoad()

            if revealViewController() != nil {
    //            revealViewController().rearViewRevealWidth = 62
                menuButton.target = revealViewController()
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))

                revealViewController().rightViewRevealWidth = 150
                //extraButton.target = revealViewController()
              //  extraButton.action = "rightRevealToggle:"

                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                
            
            }
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
