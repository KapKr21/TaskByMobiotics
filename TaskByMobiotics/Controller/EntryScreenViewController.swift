//
//  ViewController.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import UIKit
import GoogleSignIn

class EntryScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func signInToGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        self.signInToGoogle()
    }
}

//ViewController confirming to the GIDSignInDelegate protocol
extension EntryScreenViewController : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainScreenViewController
            self.present(mainVC, animated: true, completion: nil)
        }
    }
    
    func signIn(_ signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
      self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(_ signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
      self.dismiss(animated: true, completion: nil)
    }
}



