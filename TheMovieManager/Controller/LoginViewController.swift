//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
// Refactoring the code with get and post task with the main thread of completion that will avoid us to put the main thread for every handle request we call

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
    //    performSegue(withIdentifier: "completeLogin", sender: nil)
        setLogginIn(true)
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))

    }
    
    @IBAction func loginViaWebsiteTapped() {
       // performSegue(withIdentifier: "completeLogin", sender: nil)
        setLogginIn(true)
        TMDBClient.getRequestToken {(success,error)
        in
           if success {
                // if we have ui element or we want to update it , we have to put it in main thread
                DispatchQueue.main.async {
                    //[:] empty dictionary
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
                }
            }
    }
    }


     func handleRequestTokenResponse(success: Bool, error: Error?)  {
        if success {
        
                print (TMDBClient.Auth.requestToken)
                TMDBClient.loginRequest(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleRequestloginResponse(success:error:))
        }
        else{
            // sign error to localized description which is status message and make sure that localized description is not nill
            showLoginFailure(message: error?.localizedDescription ?? "")
            // print (error)
        }

    }

    func handleRequestloginResponse(success: Bool, error: Error?)  {
    
         // print("success")
            print (TMDBClient.Auth.requestToken)
        if success {
           TMDBClient.sessionIdRequest(completion: handleSessionResponse(success:error:))
        } else {
          // print(error)
            // if there is error with login infrmation enable buttons and show failure
            showLoginFailure(message: error?.localizedDescription ?? "")
            setLogginIn(false)
        }
             }
        
            func handleSessionResponse(success: Bool, error: Error?)  {
                setLogginIn(false)
                if success {
             
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
                }
                else{
                   // print (error)
                    showLoginFailure(message: error?.localizedDescription ?? "")
                }
                
            }
    func setLogginIn(_ loggingIn: Bool)
    {
        // if logginin value = true
        if loggingIn {
            activityIndicator.startAnimating()
        }
        else{
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaWebsiteButton.isEnabled = !loggingIn
    }
    
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
   
}
