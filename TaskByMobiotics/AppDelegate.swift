//
//  AppDelegate.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import UIKit
import CoreData
import GoogleSignIn

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var initialViewController : UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseHelper.initFirebase()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.clientID = "506216991397-58vi5vsvviva6jpl7rtqs1k0k6grlo68.apps.googleusercontent.com"
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let signIn = GIDSignIn.sharedInstance()
        if (signIn!.hasPreviousSignIn()) {
            signIn!.restorePreviousSignIn()
            self.initialViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        } else {
            self.initialViewController = storyboard.instantiateViewController(withIdentifier: "EntryScreenViewController")
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DataPersistenceService.saveContext()
    }
}

//AppDelegate class confirming to the GIDSignInDelegate protocol
@available(iOS 13.0, *)
extension AppDelegate : GIDSignInDelegate  {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("User email: \(user.profile.email ?? "No email found")")
    }
}

