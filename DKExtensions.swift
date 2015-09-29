//
//  DKExtensions.swift
//  Kevin Delord
//
//  Created by kevin delord on 24/09/14.
//  Copyright (c) 2015 Kevin Delord. All rights reserved.
//

import Foundation
import CoreTelephony
import StoreKit

// MARK: - Debug

struct DKLogLevel {
    static var ShouldShowDetailedLogs   : Bool  = false
}

func DKLog(verbose: Bool, _ obj: AnyObject = "", file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
	#if DEBUG
        if (verbose == true) {
			if (DKLogLevel.ShouldShowDetailedLogs == true),
				let className = file.lastPathComponent.componentsSeparatedByString(".").first {
					println(">>> \(line) \(className).\(function) --> \(obj)")
			} else {
				println(obj)
			}
        }
        #else
		// do nothing
	#endif
}

// MARK: - Classes

class PopToRootViewControllerSegue : UIStoryboardSegue {
    override func perform() {
        self.sourceViewController.navigationController?.popToRootViewControllerAnimated(true)
    }
}

class PopViewControllerSegue : UIStoryboardSegue {
    override func perform() {
        self.sourceViewController.navigationController?.popViewControllerAnimated(true)
    }
}

extension SKProduct {
    @available(*, deprecated=0.9, renamed="localizedPrice")
    func localisedPrice() -> String? {
        return self.localizedPrice()
    }

    func localizedPrice() -> String? {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = NSNumberFormatterBehavior.BehaviorDefault
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = self.priceLocale
        return numberFormatter.stringFromNumber(self.price)
    }
}
// MARK: - Additions

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {

    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

// MARK: - Extensions

extension NSDate {
    func isOlderOrEqualThan(year: Int) -> Bool {
        //
        // Check if the selected date is older or equal to the given parameter.
        let bdate = self.midnightDate()
        let dateComponent = NSDateComponents()
        dateComponent.year = -(year)
        let veryOldDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: NSDate.currentDayDate(), options: NSCalendarOptions())
        return (bdate.compare(veryOldDate!) != NSComparisonResult.OrderedDescending)
    }
}

extension NSError {
    func log() {
        print("Error: \(self) \(self.userInfo)")
    }
}

extension UIView {
    func roundRect(radius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    /**
    * Creates gradient view of given size with given colors
    * This function already exist in the DKHelper, but does not work in Swift.
    * The start point has to be -1.0 instead of 0.0 in Obj-C.
    */
    class func gradientLayer(rect: CGRect, topColor: UIColor, bottomColor: UIColor) -> UIView {
        
        let gradientLayerView: UIView = UIView(frame: rect)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientLayerView.bounds
        gradient.colors = [topColor.CGColor, bottomColor.CGColor]
        gradient.startPoint = CGPointMake(0, -1.0)
        gradient.endPoint = CGPointMake(0, 1.0)
        gradientLayerView.layer.insertSublayer(gradient, atIndex: 0)
        return gradientLayerView
    }

}

extension UIAlertView {
    class func showErrorPopup(error: NSError!) {
        // log error
        error.log()
        // find a valid message to display
        var msg = ""
        if let errorMessage : String = error.userInfo["error"] as? String {
            msg = errorMessage
        } else if let errorMessage = error.localizedFailureReason {
            msg = errorMessage
        } else if (error.localizedDescription.characters.count > 0) {
            msg = error.localizedDescription
        }
        // show a popup
        self.showErrorMessage(msg)
    }

    class func showErrorMessage(message: String) {
        UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok").show()
    }

    class func showInfoMessage(title: String, message: String) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok").show()
    }
}

extension String {

    func isUserName() -> Bool {
        let regex = "[äÄüÜöÖßA-Z0-9a-z_\\s-]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluateWithObject(self)
    }
}

extension Array where Element: Equatable {

	mutating func removeObject(item: Element) {
		if let index = self.indexOf(item) {
			self.removeAtIndex(index)
        }
    }
	
	mutating func shuffle() {
		if (self.count < 2) {
			return
		}
		for i in 0..<(self.count - 1) {
			let j = Int(arc4random_uniform(UInt32(self.count - i))) + i
			swap(&self[i], &self[j])
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
        let actualSize = self.frame.size
        self.sizeToFit()
        if self.frame.size.width > actualSize.width {
            self.frame.size = actualSize
            return false
        }
        self.frame.size = actualSize
        return true
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
        return (CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileCountryCode != nil)
    }
}

extension NSNumber {
    //
    // will return a String with the currency for the given Location
    // can be used to display a Pricetag for an in App Product.
    // take SKProduct.price for self
    // and SKProduct.priceLocale for locae.
    func stringWithCurrencyForNumber(locale:NSLocale) -> String? {
        let formatter = NSNumberFormatter()
        formatter.locale = locale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle

        return formatter.stringFromNumber(self)
    }
}
