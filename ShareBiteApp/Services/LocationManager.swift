//
//  LocationManager.swift
//  ShareBiteApp
//
//  Created by User on 2024-08-20.
//

import FirebaseDatabase


class LocationService {
    private var reference: DatabaseReference
    private  let collectionName = "location"

    init() {
        self.reference = Database.database().reference()
    }

    func addLocation(_ model: Location, completion: @escaping (Result<Void, Error>) -> Void) {
        let newItemKey = reference.child(collectionName).childByAutoId().key
        
        model.locationId = newItemKey
        
        reference.child(collectionName).child(newItemKey!).setValue(model.toMap()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func deleteLocationByDonationID(donationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
       
        reference.child(collectionName)
            .queryOrdered(byChild: "donationId")
            .queryEqual(toValue: donationId)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    if let firstMatch = snapshot.children.allObjects.first as? DataSnapshot,
                       let locationId = firstMatch.key as String? {
                        self.reference.child(self.collectionName).child(locationId).child("locationdeleted").setValue(true) { error, _ in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve location ID."])))
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No location found with the provided donation ID."])))
                }
            } withCancel: { error in
                completion(.failure(error))
            }
    }


    func getLocationByDonationId(uid: String, completion: @escaping (Result<Location, Error>) -> Void) {
      
        reference.child(collectionName).queryOrdered(byChild: "donationId").queryEqual(toValue: uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for childSnapshot in snapshot.children {
                    guard let childSnapshot = childSnapshot as? DataSnapshot,
                          let location = try? childSnapshot.data(as: Location.self) else {
                        print("Error decoding location")
                        continue
                    }
                    completion(.success(location))
                    return
                }
            } else {
                print("Snapshot does not exist")
            }
            
            completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Location not found"])))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    func updateLocation(model: Location, completion: @escaping (Result<Void, Error>) -> Void) {
        model.updatedOn = Utils.getCurrentDatetime()
        
        guard let locationId = model.locationId else {
            completion(.failure(NSError(domain: "UpdateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location ID is missing."])))
            return
        }
        
        reference.child(collectionName).child(locationId).updateChildValues(model.toMapUpdate()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

