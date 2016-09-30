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

struct DKLogSettings {

    static var shouldShowDetailedLogs	: Bool = false
    static var detailedLogFormat		= ">>> :line :className.:function --> :obj"
    static var detailedLogDateFormat	= "yyyy-MM-dd HH:mm:ss.SSS"
	static fileprivate var dateFormatter	: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = DKLogSettings.detailedLogDateFormat
		return formatter
	}
}

func DKLog(_ verbose: Bool, _ obj: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG
        if (verbose == true) {
			if (DKLogSettings.shouldShowDetailedLogs == true),
				let className = NSURL(string: file)?.lastPathComponent?.components(separatedBy: ".").first {

				var logStatement = DKLogSettings.detailedLogFormat.replacingOccurrences(of: ":line", with: "\(line)")
					logStatement = logStatement.replacingOccurrences(of: ":className", with: className)
					logStatement = logStatement.replacingOccurrences(of: ":function", with: function)
					logStatement = logStatement.replacingOccurrences(of: ":obj", with: "\(obj)")

				if (logStatement.contains(":date")) {
					let replacement = DKLogSettings.dateFormatter.string(from: Date())
					logStatement = logStatement.replacingOccurrences(of: ":date", with: "\(replacement)")
					}

					print(logStatement)
			} else {
				print(obj)
			}
        }
	#endif
}

// MARK: - Classes

class PopToRootViewControllerSegue : UIStoryboardSegue {

    override func perform() {
        _ = self.source.navigationController?.popToRootViewController(animated: true)
    }
}

class PopViewControllerSegue : UIStoryboardSegue {

    override func perform() {
        _ = self.source.navigationController?.popViewController(animated: true)
    }
}

extension SKProduct {

    @available(*, deprecated: 0.9, renamed: "localizedPrice")
    func localisedPrice() -> String? {
        return self.localizedPrice()
    }

    func localizedPrice() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = NumberFormatter.Behavior.default
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = self.priceLocale
        return numberFormatter.string(from: self.price)
    }
}

// MARK: - Additions

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

func + <K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {

    var map = Dictionary<K, V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

// MARK: - Extensions

extension RawRepresentable where RawValue == Int {
	static var allCases: [Self] {
		// Create array to store all found cases
		var cases = [Self]()
		// Use 0 as start index
		var index = 0
		// Try to create a case for every following integer index until no case is created. If no one is created,
		while let _case = self.init(rawValue: index) {
			cases.append(_case)
			index += 1
		}
		return cases
	}
}

extension NSError {

    func log() {
        print("Error: \(self) \(self.userInfo)")
    }
}

extension UIView {

    func roundRect(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    /**
     Add a subview to the current object if the given one is not nil.

     - parameter view: Optional UIView object. Will not be added if nil.
     */
    func addSubview(safe view: UIView?) {
        if let _view = view {
            self.addSubview(_view)
        }
    }

	/**
	Creates gradient view of given size with given colors
	This function already exist in the DKHelper, but does not work in Swift.
	The start point has to be -1.0 instead of 0.0 in Obj-C.

	- parameter rect:        The rect for the new gradient view.
	- parameter topColor:    The top color.
	- parameter bottomColor: the bottom color.

	- returns: gradient view
	*/
    class func gradientLayer(_ rect: CGRect, topColor: UIColor, bottomColor: UIColor) -> UIView {

        let gradientLayerView = UIView(frame: rect)
        let gradient = CAGradientLayer()
        gradient.frame = gradientLayerView.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
		gradient.startPoint = CGPoint(x: 0, y: -1.0)
		gradient.endPoint = CGPoint(x: 0, y: 1.0)
        gradientLayerView.layer.insertSublayer(gradient, at: 0)
        return gradientLayerView
    }

}

@available(iOS, obsoleted: 8.0, message: "use UIAlertController instead.")
extension UIAlertView {

	@available(iOS, renamed: "UIAlertController.showErrorPopup", message: "use UIAlertController instead.")
	class func showErrorPopup(_ error: NSError?) {
		// Log error
		error?.log()
		// Find a valid message to display
		var msg : String? = nil
		if let errorMessage : String = error?.userInfo["error"] as? String {
			msg = errorMessage
		} else if let errorMessage = error?.localizedFailureReason {
			msg = errorMessage
		} else if let errorMessage = error?.localizedDescription , (errorMessage.characters.count > 0) {
			msg = errorMessage
		}
		// Show a popup
		if let _msg = msg {
			self.showErrorMessage(_msg)
		}
	}

	@available(iOS, renamed: "UIAlertController.showErrorMessage", message: "use UIAlertController instead.")
	class func showErrorMessage(_ message: String) {
		self.showInfoMessage("Error", message: message)
	}

	@available(iOS, renamed: "UIAlertController.showInfoMessage", message: "use UIAlertController instead.")
	class func showInfoMessage(_ title: String, message: String) {
		UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
	}
}

@available(iOS 8.0, *)
extension UIAlertController {
	class func showErrorPopup(_ error: NSError?, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		// Log error
		error?.log()
		// Find a valid message to display
		var msg : String? = nil
		if let errorMessage : String = error?.userInfo["error"] as? String {
			msg = errorMessage
		} else if let errorMessage = error?.localizedFailureReason {
			msg = errorMessage
		} else if let errorMessage = error?.localizedDescription , (errorMessage.characters.isEmpty == false) {
			msg = errorMessage
		}
		// Show a popup
		if let _msg = msg {
			self.showErrorMessage(_msg, presentingViewController: presentingViewController)
		}
	}

	class func showErrorMessage(_ message: String, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		self.showInfoMessage("Error", message: message, presentingViewController: presentingViewController)
	}

	class func showInfoMessage(_ title: String, message: String, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		presentingViewController?.present(ac, animated: true, completion: nil)
	}
}

extension String {

	/**
	* Return a dictionary containing the key/values of the received
	*/
	var urlArguments : [String : String] {
		var params = [String : String]()
		for param in self.components(separatedBy: "&") {
			let elts = param.components(separatedBy: "=")
			if (elts.count == 2),
				let
				key = elts.first,
				let value = elts.last {
					params[key] = value
			}
		}
		return params
	}

    func isUserName() -> Bool {
        let regex = "[äÄüÜöÖßA-Z0-9a-z_\\s-]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}

extension Dictionary {

	mutating func removeValues<T>(of type: T.Type) {
		let keysToRemove = Array(self.keys).filter {
            self[$0] is T
        }
		for key in keysToRemove {
			self.removeValue(forKey: key)
		}
	}
}

extension Array where Element: Equatable {

	mutating func remove(object item: Element) {
		if let index = self.index(of: item) {
			self.remove(at: index)
		}
	}
}

extension Array {

	var shuffled: [Element] {
		var elements = self
		for index in 0..<elements.count {
			let newIndex = Int(arc4random_uniform(UInt32(elements.count-index))) + index
			if (index != newIndex) { // Check if you are not trying to swap an element with itself
				swap(&elements[index], &elements[newIndex])
			}
		}
		return elements
	}

	mutating func shuffle() {
		self = self.shuffled
	}

	func group(of num:Int) -> [[Element]] {
		var result = [[Element]]()
		if (num > 0) {
			for i in 0...((count / num) - 1) {
				var tempArray = [Element]()
				for index in 0...(num - 1) {
					tempArray.append(self[index + ( i * num)])
				}
				result.append(tempArray)
			}
		}
		return result
	}

	/*
	* Bounds-checked ("safe") index lookup for Arrays.
	* Example usage:
	* let foo = [0,1,2][safe: 1]	|	foo = (Int?) 1
	* let bar = [0,1,2][safe: 10]	|	bar = (Int?) nil
	*/
	subscript (safe index: Int) -> Element? {
		return ((self.indices ~= index) ? self[index] : nil)
	}
}

extension UIImagePickerControllerSourceType {

    func nameType() -> String {
        switch self {
        case .photoLibrary:
            return "PhotoLibrary"
        case .camera:
            return "Camera"
        case .savedPhotosAlbum:
            return "SavedPhotosAlbum"
        }
    }
}

extension UILabel {

    /**
     Calculates if size to fit would expand or shrink the label.

     Will not change the size of the label.

     - returns: true if the label Size is smaller than before
     */
	func textFitsWidth() -> Bool {
		let actualSize = self.frame.size
		self.sizeToFit()
		if (self.frame.size.width > actualSize.width) {
			self.frame.size = actualSize
			return false
		}
		self.frame.size = actualSize
		return true
	}

	/**
	Transforms the given text by replacing all characters with the passed replacement ("●" by default).

	- parameter originalText: Text to secure and to set to the current label
	- parameter replacementText: String to set as secure character (default is "●")
	*/
	func setSecureText(from originalText: String?, replacementText: String = "●") {
		if let _originalText = originalText {
			var secureString = ""
			for _ in 0..<_originalText.characters.count {
				secureString += replacementText
			}
			self.text = secureString
		}
	}
}

extension UIDevice {

    /**
    To check if the current Device has a SimCard or not, we will read the Carrier informations
	If there are no carrier Informations, there is no sim and this function will return false

	For more informations read Apple Doc's for CTCarrier's mobileCountryCode:
	From this Doc:
    https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/CTCarrier/index.html#//apple_ref/occ/instp/CTCarrier/mobileCountryCode

	The value for this property is nil if any of the following apply:
	- There is no SIM card in the device. [...]

     - returns: true if the current device has a SIM card.
     */
    func hasSimCard() -> Bool {
        return (CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileCountryCode != nil)
    }
}

extension NSNumber {

    // Will return a String with the currency for the given Location
    // Can be used to display a Pricetag for an in App Product.
    // Take SKProduct.price for self
    // And SKProduct.priceLocale for locale.
    func stringWithCurrency(for locale:Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
        formatter.numberStyle = NumberFormatter.Style.currency

        return formatter.string(from: self)
    }
}

extension UIApplication {

	/// Boolean value indicating whether the current application is running on a simulator or not.
	static var isRunningOnSimulator : Bool {
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			return true
		#else
			return false
		#endif
	}
}

extension Int {

	// Will return a random number between the given range:
	// E.g : let randomNumber = randoInt.randomNumber(4...8)
	static func random(in range: Range<Int>) -> Int {
		let min = range.lowerBound
		let max = range.upperBound
		return Int(arc4random_uniform(UInt32(max - min))) + min
	}
}

protocol OptionalType {
	associatedtype Wrapped
	
	func map<U>(f: (Wrapped) throws -> U) rethrows -> U?
}

extension Sequence where Iterator.Element: OptionalType {
	
	func withoutOptionals() -> [Iterator.Element.Wrapped] {
		var result: [Iterator.Element.Wrapped] = []
		for element in self {
			if let element = element.map(f: { $0 }) {
				result.append(element)
			}
		}
		return result
	}
}

extension URL {

	enum URLConstructionError: Error {
		case unableToConstruct
	}

	func add(path component: String) -> URL? {
		return self.appendingPathComponent(component)
	}

	func add(parameters parameterArray: [String: AnyObject]) throws -> URL {
		if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {

			var queryItems = (urlComponents.queryItems ?? [URLQueryItem]())

			for (key, value) in parameterArray {
				queryItems.append(URLQueryItem(name: key, value: "\(value)"))
			}

			urlComponents.queryItems = queryItems

			if let url = urlComponents.url {
				return url
			}
		}

		throw URLConstructionError.unableToConstruct
	}
}
