//
//  ViewController.swift
//  MIQAnalytics
//
//  Created by Girish on 19/11/19.
//  Copyright © 2019 Girish. All rights reserved.
//

import UIKit
import MicrosoftAzureMobile


let kRedirectUri = "MIQAnalytics"


class ViewController: UIViewController {
    
   
   
    let client = MSClient(applicationURLString: "https://login.microsoftonline.com/1a6dbb80-5290-4fd1-a938-0ad7795dfd7a")


    override func viewDidLoad() {
        super.viewDidLoad()
       perform(#selector(login), with: nil, afterDelay: 0.5)
       //
        //login()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    @objc func login() {
            let loginBlock: MSClientLoginBlock = {(user, error) -> Void in
            if (error != nil) {
                print("Error: \(error?.localizedDescription)")
            }
            else {
                self.client.currentUser = user
                print("User logged in: \(user?.userId)")
                let Storyboard  = UIStoryboard(name: "Main", bundle: nil)
                let vc = Storyboard.instantiateViewController(withIdentifier: "one")
                self.present(vc , animated: true , completion: nil)

            }
        }

        
        
        
       client.login(withProvider:"windowsazureactivedirectory", urlScheme: kRedirectUri, controller: self, animated: true, completion: {(user, error) -> Void in

         print("enetred block")
           if (error != nil) {
               print("Error: \(error?.localizedDescription)")
           }
           else {
               self.client.currentUser = user
               print("User logged in: \(user?.userId)")
               let Storyboard  = UIStoryboard(name: "Main", bundle: nil)
               let vc = Storyboard.instantiateViewController(withIdentifier: "one")
               self.present(vc , animated: true , completion: nil)

           }
       })



//       client.login(withProvider: "windowsazureactivedirectory", token: ["username": "mpddashboard@hotmail.com", "password":"Mpd123!@#"], completion: {(user, error) -> Void in
//
//        print("enetred block")
//          if (error != nil) {
//              print("Error: \(error?.localizedDescription)")
//          }
//          else {
//              self.client.currentUser = user
//              print("User logged in: \(user?.userId)")
//              let Storyboard  = UIStoryboard(name: "Main", bundle: nil)
//              let vc = Storyboard.instantiateViewController(withIdentifier: "one")
//              self.present(vc , animated: true , completion: nil)
//
//          }
//      })
//




    }

//    func authenticate(parent: UIViewController, completion: (MSUser?, NSError?) -> Void) {
//      
//        let authority = "https://login.microsoftonline.com/1a6dbb80-5290-4fd1-a938-0ad7795dfd7a"
//        let resourceId = "INSERT-RESOURCE-ID-HERE"
//        let clientId = "ab812076-9b1d-4401-871e-288d2234facb"
//        let redirectUri = NSURL(string: "msauth.com.wipro.MIQAnalytics://auth")
//        var error: AutoreleasingUnsafeMutablePointer<ADAuthenticationError?>? = nil
//        let authContext = ADAuthenticationContext(authority: authority, error: error)
//        authContext?.parentController = parent
//        ADAuthenticationSettings.sharedInstance().enableFullScreen = true
//        
//        authContext?.acquireTokenSilent(withResource: resourceId, clientId: clientId, redirectUri: redirectUri as URL?, completionBlock: { (result) in
//            if result.status != AD_SUCCEEDED {
//                completion(nil, result.error)
//            }
//            else {
//                let payload: [String: String] = ["access_token": result.tokenCacheStoreItem.accessToken]
//                client.loginWithProvider("aad", token: payload, completion: completion)
//            }
//        })
//        }

        
}

