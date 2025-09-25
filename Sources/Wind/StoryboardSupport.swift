//
//  StoryboardSupport.swift
//  Wind
//
//  Created by Enno Welbers on 07.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
typealias Application = UIApplication
typealias Storyboard = UIStoryboard
typealias ViewController = UIViewController
#elseif os(OSX)
import AppKit
typealias Application = NSApplication
typealias Storyboard = NSStoryboard
typealias ViewController = NSViewController
#endif



private struct AssociatedKeys {
	nonisolated(unsafe) static var container = "wind_container"
}

@objc public class ContainerWrapper: NSObject {
	var instance: Container?
	
	override init() {
		super.init()
	}
}


public extension Application {
	var container: Container? {
		get {
			return (objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.instance
		}
		set {
			let wrapper = ContainerWrapper()
			wrapper.instance = newValue
			objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

public extension Storyboard {
	var container: Container? {
		get {
			let myInstance = (objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.instance
			
			guard myInstance != nil else {
				return Application.shared.container
			}
			
			return myInstance
		}
		set {
			let wrapper = ContainerWrapper()
			wrapper.instance = newValue
			objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

/// This class can be added to your storyboard to resolve the view controller as a component.
@objc public class StoryboardResolver: NSObject {
	@IBOutlet var viewController: ViewController!
	
	public override func awakeFromNib() {
		if let consumer = viewController as? Component {
			try! viewController.storyboard?.container?.resolve(for: consumer)
		}
	}
}
