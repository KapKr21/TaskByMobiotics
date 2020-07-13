//
//  FirebaseHelper.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import Firebase
import Foundation

// A class for all firebase related code.
public class FirebaseHelper {
    
    public static func initFirebase() {
        FirebaseApp.configure()
    }
}
