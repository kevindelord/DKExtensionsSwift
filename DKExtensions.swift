//
//  DKExtensions.swift
//  Kevin Delord
//
//  Created by kevin delord on 24/09/14.
//  Copyright (c) 2015 Kevin Delord. All rights reserved.
//

import Foundation
import CoreTelephony

// MARK: - Debug

func DKLog(verbose: Bool, obj: AnyObject) {
    #if DEBUG
        if (verbose == true) {
            println(obj)
        }
        #else
        // do nothing
    #endif
}

// MARK: - Classes

class PopToRootViewControllerSegue : UIStoryboardSegue {
    override func perform() {
        (self.sourceViewController as? UIViewController)?.navigationController?.popToRootViewControllerAnimated(true)
    }
}

class PopViewControllerSegue : UIStoryboardSegue {
    override func perform() {
        (self.sourceViewController as? UIViewController)?.navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: - Extensions

extension NSError {
    func log() {
        println("Error: \(self) \(self.userInfo!)")
    }
}

extension UIView {
    func roundRect(#radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    class func loadFromNib(name: String!) -> UIView {
        var nib = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil) as [AnyObject]!
        return nib[0] as UIView
    }

    /**
    * creates constraints to adjust the child to match the parents dimensions and position
    */
    func matchParentConstraints() -> [NSLayoutConstraint]{
        if let parent = self.superview? {
            self.setTranslatesAutoresizingMaskIntoConstraints(false)

            var bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: 0)
            var topConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: 0)
            var leftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: parent, attribute: .Left, multiplier: 1, constant: 0)
            var rightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: parent, attribute: .Right, multiplier: 1, constant: 0)

            var new_constaints = [leftConstraint,rightConstraint,topConstraint,bottomConstraint]
            parent.addConstraints(new_constaints)
            return new_constaints
        } else {
            return []
        }
    }
}

extension UIAlertView {
    class func showErrorPopup(error: NSError!) {
        // log error
        error.log()
        // find a valid message to display
        var msg = ""
        if let errorMessage : String = error.userInfo?["error"] as? String {
            msg = errorMessage
        } else if let errorMessage = error.localizedFailureReason {
            msg = errorMessage
        } else if (error.localizedDescription.utf16Count > 0) {
            msg = error.localizedDescription
        }
        // show a popup
        self.showErrorMessage(msg)
    }

    class func showErrorMessage(message: String) {
        UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok").show()
    }
}

extension NSBundle {
    class func entryInPListForKey(key: String) -> String {
        let value = NSBundle.mainBundle().objectForInfoDictionaryKey(key) as? String
        if value == nil {
            NSException(name: "Plist error", reason: "Invalid \(key) in Info.plist file", userInfo: nil).raise()
        }
        return value!
    }
}

extension NSDate {
    func fullDisplayTime() -> String! {
        return "\(self.day()) \(self.monthName()) - \(self.hour()):\(self.minute())"
    }

    func hourDisplayTime() -> String! {
        return "\(self.hour()):\(self.minute())"
    }

    func displayableString() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
}

extension String {

    static func randomNumericString(length: Int) -> NSString {

        let letters : NSString = "0123456789"

        var randomString : NSMutableString = NSMutableString(capacity: length)
        for (var i=0; i < length; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }

    static func randomString(length: Int) -> NSString {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        var randomString : NSMutableString = NSMutableString(capacity: length)
        for (var i=0; i < length; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }

    func isAlphaNumeric() -> Bool {
        let regex = "[A-Z0-9a-z_]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)!
        return predicate.evaluateWithObject(self)
    }
    
    func isUserName() -> Bool {
        let regex = "[äÄüÜöÖßA-Z0-9a-z_\\s-]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)!
        return predicate.evaluateWithObject(self)
    }
    
    //From HockeySDK (see BITHockeyHelper.m -> bit_validateEmail(NSString))
    func isEmail() -> Bool {
        let emailRegex =    "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"" +
                            "(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\" +
                            "x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0" +
                            "-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){" +
                            "3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\" +
                            "x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        var predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)!
        return predicate.evaluateWithObject(self)
    }
    
    func isPhoneNumber() -> Bool {
        let regex = "^00[0-9]{9,13}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)!
        return predicate.evaluateWithObject(self)
    }
    
    //"  this is a text  " -> "this is a text", by removing the leading and ending whitespaces
    func trimWhitespaces() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    // Remove all white spaces and all new lines \n
    func removeAllNewlinesAndIllegalChars() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

extension UIImage {

    class func scaleImage(image: UIImage!, size: CGSize) -> UIImage! {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0,0,size.width,size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        return newImage
    }

    func resizedImageToScreenSize() -> UIImage! {
        var screenSize = UIScreen.mainScreen().bounds as CGRect
        var size = CGSizeMake(0, screenSize.size.height) as CGSize
        var ratio = 0.0 as CGFloat
        if (self.size.height < screenSize.size.height) {
            ratio = screenSize.size.height / self.size.height;
            size.width = self.size.width * ratio;
        } else {
            ratio = self.size.height / screenSize.size.height;
            size.width = self.size.width / ratio;
        }
        return UIImage.scaleImage(self, size: size);
    }
}

extension Array {

    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in enumerate(self) {
            str += "\(item)"
            if idx < self.count-1 {
                str += separator
            }
        }
        return str
    }

    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        if index != nil {
            self.removeAtIndex(index!)
        }
    }
}

extension UIImagePickerControllerSourceType {
    func nameType() -> String {
        switch self {
        case .PhotoLibrary:
            return "PhotoLibrary"
        case .Camera:
            return "Camera"
        case .SavedPhotosAlbum:
            return "SavedPhotosAlbum"
        }
    }
}

extension UILabel {
    //
    // calculating, if size to fit would expand or shrink the label
    // returns true if the label Size is smaller then before
    // will not change the label' Size
    //
    func textFitsWidth() -> Bool {
        var actualSize = self.frame.size
        self.sizeToFit()
        if self.frame.size.width > actualSize.width {
            self.frame.size = actualSize
            return false
        }
        self.frame.size = actualSize
        return true
    }
}

extension NSLocale {
    //
    // this Function will return all localalized Country-Names from ISO - country Code known by this Device
    // localized by the self - Location (like: NSLocale.currentLocale())
    //
    func allCountries() -> [String] {
        return NSLocale.ISOCountryCodes().map({(code: AnyObject) -> String in
            //
            // this seems to crash on Simulator (some) (http://stackoverflow.com/questions/26613011/xcode-6-1-ios-8-1-nslocale-displaynameforkey-nslocaleidentifier-return-nil)
            // it's just in Simulator and i have no idear for a good Workaround
            //
            return self.displayNameForKey(NSLocaleCountryCode, value: code)! as String
            }).sorted({
                //
                // We need to return a SortedArray, we use the Default function to Sort this array
                //
                $0 < $1
            })
    }
}

extension UIDevice {
    //
    // To check if the current Device has a SimCard or not, we will read the Carrier informations
    // if there are no carrier Informations, there is no sim and this function will return false
    //
    // For more informations read Apple Doc's for CTCarrier's mobileCountryCode:
    // From this Doc (https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/CTCarrier/index.html#//apple_ref/occ/instp/CTCarrier/mobileCountryCode):
    //
    // The value for this property is nil if any of the following apply:
    // - There is no SIM card in the device. [...]
    //
    func hasSimCard() -> Bool {
        var networkInfo = CTTelephonyNetworkInfo()
        return (networkInfo.subscriberCellularProvider?.mobileCountryCode? != nil)
    }
}
