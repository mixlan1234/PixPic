//
//  ValidationService.swift
//  P-effect
//
//  Created by Illya on 1/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ValidationService: NSObject {
    
    class func valdateUserName(userName: String, completion: (Bool) -> ()) {
        if !userNameContainsOnlyLetters(userName) {
            completion(false)
            return
        }
        
        if userName.characters.count < Constants.Validation.MinUserName &&
            userName.characters.count > Constants.Validation.MaxUserName {
                AlertService.simpleAlert(Constants.Validation.WrongLenght)
                completion (false)
                return
        }
        
        let query = PFUser.query()?.whereKey("username", equalTo: userName)
        query?.getFirstObjectInBackgroundWithBlock { object, error in
            if object != nil {
                AlertService.simpleAlert(Constants.Validation.AlreadyExist)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    class func needToUpdateVersion(completion: (Bool) -> ()){
        var effectsVersion = EffectsVersion()
        let query = EffectsVersion.query()
        let queryFromLockal = EffectsVersion.query()
        queryFromLockal?.fromLocalDatastore()
        
        query?.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) in
            if error != nil {
                print("Error: \(error!) \(error!.userInfo)")
                completion(false)
                return
            } else {
                if let object = object {
                    effectsVersion = object as! EffectsVersion
                    queryFromLockal?.getFirstObjectInBackgroundWithBlock { (localObject: PFObject?, error: NSError?) in
                        if error != nil {
                            print("Error: \(error!) \(error!.userInfo)")
                            completion(true)
                            return
                        }
                        if let localObject = localObject {
                            if effectsVersion.version > (localObject as! EffectsVersion).version {
                                completion(true)
                            } else {
                                completion (false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private class func userNameContainsOnlyLetters(userName: String) -> Bool {
        if userName.characters.first == Constants.Validation.WhiteSpace {
            AlertService.simpleAlert(Constants.Validation.SpaceInBegining)
            return false
        }
        let invalidCharacterSet = NSCharacterSet(charactersInString: Constants.Validation.CharacterSet).invertedSet
        if let containsInvalidSymbols = userName.rangeOfCharacterFromSet(invalidCharacterSet) {
            AlertService.simpleAlert(Constants.Validation.NumbersAndSymbolsInUsername)
            return false
        } else {
            var previousChar = Constants.Validation.WhiteSpace as Character
            for char in userName.characters {
                if previousChar == Constants.Validation.WhiteSpace && char == Constants.Validation.WhiteSpace {
                    AlertService.simpleAlert(Constants.Validation.TwoSpacesInRow)
                    return false
                }
                previousChar = char
            }
            if userName.characters.last == Constants.Validation.WhiteSpace {
                AlertService.simpleAlert(Constants.Validation.SpaceInEnd)
                return false
            }
        }
        
        return true
    }
    
    
}
