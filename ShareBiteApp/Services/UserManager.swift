//
//  UserManager.swift
//  ShareBiteApp
//
//  Created by User on 2024-06-19.
//

import Foundation
import FirebaseDatabase
import Firebase

class UserManager : ObservableObject{
    
    private let database = Database.database().reference();
  //  private let sessionManager = SessionManager()
    private let _collection = "users";
    func registerUser(_user: Users){
        let itemRef = database.child(_collection).child(_user.id)
        itemRef.setValue(["userid" : _user.id,"username": _user.username,"email": _user.email,
                          "mobilenumber": _user.mobilenumber,"profiledeleted": _user.profiledeleted,"notification": _user.notification,
                          "createdon" : _user.createdon.timeIntervalSinceNow
                         ]);
    }
    func fetchUserByUserID(withID id: String, completion: @escaping (SessionUsers?) -> Void) {
        let usersRef = database.child("users")
        
        usersRef.child(id)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    print("Snapshot exists: \(snapshot)")
                    
                    if let userData = snapshot.value as? [String: Any] {
                        print("data parse started")
                       
                        let username = userData["username"] as? String ?? ""
                        let email = userData["email"] as? String ?? ""
                        let notification = userData["notification"] as? Bool ?? true
                        
                       
                        let user = SessionUsers(id: id,
                                                username: username,
                                                email: email,
                                                notification: notification)
                        
                        completion(user)
                    } else {
                        print("Failed to parse user data for id: \(id)")
                        completion(nil)
                    }
                } else {
                    print("No user found for id: \(id)")
                    completion(nil)
                }
            }
    }

    func deleteProfile() {
        if let user = Auth.auth().currentUser {
            let userId = user.uid
            let ref = Database.database().reference().child(_collection).child(userId)
            
            ref.child("profiledeleted").setValue(true) { error, _ in
                if let error = error {
                    print("Error updating profile deleted status: \(error.localizedDescription)")
                } else {
                    print("Profile deleted status updated successfully.")
                    user.delete { error in
                        if let error = error {
                            print("Error deleting user: \(error.localizedDescription)")
                        } else {
                            print("User deleted successfully.")
                            
                        }
                    }
                }
            }
        } else {
            print("User ID not available.")
        }
    }

    func notificationSetting(notification : Bool) {
        if let user = Auth.auth().currentUser {
            let userId = user.uid
            let ref = Database.database().reference().child(_collection).child(userId)
            
            ref.child("notification").setValue(notification) { error, _ in
                if let error = error {
                    print("Error updating notification status: \(error.localizedDescription)")
                } else {
                    print("notification setting updated successfully.")
                    SessionManager.shared.updateNotificationSetting(notification: notification)
                }
            }
        } else {
            print("User ID not available.")
        }
    }

    
}
