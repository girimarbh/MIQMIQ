
import UIKit
import MSAL

/// 😃 A View Controller that will respond to the events of the Storyboard.

class LoginViewController : UIViewController, UITextFieldDelegate, URLSessionDelegate , WKUIDelegate , WKNavigationDelegate {
    
    // Update the below to your client ID you received in the portal. The below is for running the demo only
    let kClientID = "ab812076-9b1d-4401-871e-288d2234facb"
    
    // Additional variables for Auth and Graph API
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    let kScopes: [String] = ["https://graph.microsoft.com/user.read"]
    let kAuthority = "https://login.microsoftonline.com/1a6dbb80-5290-4fd1-a938-0ad7795dfd7a"
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?

    var loggingText: UITextView!
    var signOutButton: UIButton!
    var callGraphButton: UIButton!
    
    
    lazy var webView: WKWebView = {
        let wv = WKWebView()
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    @IBOutlet weak var nextButton: UIButton?
    
    
    

    /**
        Setup public client application in viewDidLoad
    */

    override func viewDidLoad() {
        
        super.viewDidLoad()
//        view.addSubview(webView)
//            NSLayoutConstraint.activate([
//                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                webView.topAnchor.constraint(equalTo: view.topAnchor),
//                webView.rightAnchor.constraint(equalTo: view.rightAnchor),
//                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//

       // initUI()
        
        do {
            try self.initMSAL()
        } catch let error {
           // self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        
        perform(#selector(callGraphAPINEW), with: nil, afterDelay: 0.5)
        
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        // perform(#selector(callGraphAPINEW), with: nil, afterDelay: 0.5)
       // self.updateSignOutButton(enabled: !self.accessToken.isEmpty)
    }
    @objc func anAction(){
        
        print("next is pressed")
        let Storyboard  = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = Storyboard.instantiateViewController(withIdentifier: "one")
        
        self.present(vc , animated: true , completion: nil)

    }
}


// MARK: Initialization

extension LoginViewController {
    
    /**
     
     Initialize a MSALPublicClientApplication with a given clientID and authority
     
     - clientId:            The clientID of your application, you should get this from the app portal.
     - redirectUri:         A redirect URI of your application, you should get this from the app portal.
     If nil, MSAL will create one by default. i.e./ msauth.<bundleID>://auth
     - authority:           A URL indicating a directory that MSAL can use to obtain tokens. In Azure AD
     it is of the form https://<instance/<tenant>, where <instance> is the
     directory host (e.g. https://login.microsoftonline.com) and <tenant> is a
     identifier within the directory itself (e.g. a domain associated to the
     tenant, such as contoso.onmicrosoft.com, or the GUID representing the
     TenantID property of the directory)
     - error                The error that occurred creating the application object, if any, if you're
     not interested in the specific error pass in nil.
     */
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
           // self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
        
        
    // self.webViewParamaters?.webviewType = MSALWebviewType.wkWebView
    // self.webViewParamaters?.customWebview = webView
        
        
        
        
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
        
    
    }
}


// MARK: Acquiring and using token

extension LoginViewController {
    
    /**
     This will invoke the authorization flow.
     */
    
    @objc func callGraphAPINEW()  {
        guard let currentAccount = self.currentAccount() else {
                   // We check to see if we have a current logged in account.
                   // If we don't, then we need to sign someone in.
                   acquireTokenInteractively()
                   return
               }
    }
    
    @objc func callGraphAPI(_ sender: UIButton) {
        
        guard let currentAccount = self.currentAccount() else {
            // We check to see if we have a current logged in account.
            // If we don't, then we need to sign someone in.
            acquireTokenInteractively()
            return
        }
        
        acquireTokenSilently(currentAccount)
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount;
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
              //  self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
               // self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
           // self.updateLogging(text: "Access token is \(self.accessToken)")
           // self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
            self.webView.removeFromSuperview()
            
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
             //   self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
               // self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
           // self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
           
           // self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
          
        }
        
    }
    
    /**
     This will invoke the call to the Microsoft Graph API. It uses the
     built in URLSession to create a connection.
     */
    
    func getContentWithToken() {
        
        // Specify the Graph API endpoint
        let url = URL(string: kGraphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
               // self.updateLogging(text: "Couldn't get graph result: \(error)")
                print("Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
               // self.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            
           // self.updateLogging(text: "Result from Graph: \(result))")
            
            print("Result from Graph: \(result)")
            
            
            }.resume()
    }

}


// MARK: Get account and removing cache

extension LoginViewController {
    func currentAccount() -> MSALAccount? {
        
        guard let applicationContext = self.applicationContext else { return nil }
        
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        
        do {
            
            let cachedAccounts = try applicationContext.allAccounts()
            
            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
            
        } catch let error as NSError {
            
         //   self.updateLogging(text: "Didn't find any accounts in cache: \(error)")
        }
        
        return nil
    }
    
    /**
     This action will invoke the remove account APIs to clear the token cache
     to sign out a user from this application.
     */
    @objc func signOut(_ sender: UIButton) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount() else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            try applicationContext.remove(account)
            //self.updateLogging(text: "")
          //  self.updateSignOutButton(enabled: false)
            self.accessToken = ""
            
        } catch let error as NSError {
            
           // self.updateLogging(text: "Received error signing account out: \(error)")
        }
    }
}


// MARK: UI Helpers
extension LoginViewController {
    
    func initUI() {
        // Add call Graph button
        callGraphButton  = UIButton()
        callGraphButton.translatesAutoresizingMaskIntoConstraints = false
        callGraphButton.setTitle("Login", for: .normal)
        callGraphButton.setTitleColor(.blue, for: .normal)
        callGraphButton.addTarget(self, action: #selector(anAction), for: .touchUpInside)
        self.view.addSubview(callGraphButton)
//
        callGraphButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        callGraphButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        callGraphButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        callGraphButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
//////
//////        // Add sign out button
//////        signOutButton = UIButton()
//////        signOutButton.translatesAutoresizingMaskIntoConstraints = false
//////        signOutButton.setTitle("Sign Out", for: .normal)
//////        signOutButton.setTitleColor(.blue, for: .normal)
//////        signOutButton.setTitleColor(.gray, for: .disabled)
//////        signOutButton.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)
//////        self.view.addSubview(signOutButton)
//////
//////        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//////        signOutButton.topAnchor.constraint(equalTo: callGraphButton.bottomAnchor, constant: 10.0).isActive = true
//////        signOutButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
//////        signOutButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
//////
//////        // Add logging textfield
//////        loggingText = UITextView()
//////        loggingText.isUserInteractionEnabled = false
//////        loggingText.translatesAutoresizingMaskIntoConstraints = false
//////
//////        self.view.addSubview(loggingText)
//////
//////        loggingText.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 10.0).isActive = true
//////        loggingText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10.0).isActive = true
//////        loggingText.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 10.0).isActive = true
//////        loggingText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10.0).isActive = true
//////    }
////
//////    func updateLogging(text : String) {
//////
//////
//////
//////        if Thread.isMainThread {
//////            self.loggingText.text = text
//////        } else {
//////            DispatchQueue.main.async {
//////                self.loggingText.text = text
//////            }
//////        }
//////    }
////
//////    func updateSignOutButton(enabled : Bool) {
//////        if Thread.isMainThread {
//////            self.signOutButton.isEnabled = enabled
//////        } else {
//////            DispatchQueue.main.async {
//////                self.signOutButton.isEnabled = enabled
//////            }
//////        }
  }
}
