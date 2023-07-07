//
//  LoginViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 21/04/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?

    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
        
        guard let image = UIImage(named: "AppIcon") else{
            return
        }
                
        imageView.image = image
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    /// Add error message and display popup message
    func validEntry() -> Bool {
        /**
         - Returns:  Boolean
         
         Reference: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
         **/
        func isValidEmailTextField(_ emailTextField: UITextField) -> Bool {
            /**
             Check if the email text field is valid
             */
            if let email = emailTextField.text {
                // regular expression for email format
                let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

                let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                return emailPredicate.evaluate(with: email)
            }
            return false
        }
        
        var errorMessage: String = ""
        if !isValidEmailTextField(emailTextField) {
            errorMessage += "\nInvalid email"
        }
        
        if passwordTextField.text == "" || passwordTextField.text!.count < 6{
            errorMessage += "\nInvalid password\nPassword must have at least 6 characters"
        }
        
        if errorMessage != "" {
            displayMessage(title: "Invalid Entry", message: errorMessage)
            return false
        } else {
            return true
        }
    }
    
    /// Function for sign up button to sign up user with the textfield given
    @IBAction func signUpButton(_ sender: Any) {
        if self.validEntry() {
            databaseController!.createNewUser(email: emailTextField.text!, password: passwordTextField.text!) {
                if self.databaseController!.successfulSignUp {
                    self.displayMessage(title: "Successful User Creation", message: "Welcome!")
                    // reset successfulSignUp switch
                    self.databaseController!.successfulSignUp = false
                } else {
                    self.displayMessage(title: "Sign Up Error", message: "Email might be already in use")
                }
            }
        }
    }
    
    /// Login Function that sign in user with database controller
    @IBAction func loginButton(_ sender: Any) {
        if self.validEntry() {
            databaseController!.signInUser(email: emailTextField.text!, password: passwordTextField.text!) {
                if self.authController?.currentUser == nil {
                    // unsuccessful login
                    self.displayMessage(title: "Login Error", message: "Check email and password entry")
                } else {
                    self.displayMessage(title: "Successful Login", message: "Welcome Back!")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStateListener = authController?.addStateDidChangeListener { auth, user in
            
            // Check if user is nil to determine whether user is signed in or not
            if user != nil {
                
                //reset all listeners from database controller
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.databaseController?.setupCurrencyListener()
                self.databaseController?.setupExpenseListener()
                self.databaseController?.setupWishlistListener()
                self.databaseController?.setupRecordListener()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "loginSegue" {
            let destinationVC = segue.destination
            // hides the back button to prevent user navigate the previous users
            destinationVC.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    

}
