//
//  StoryboardSupport.swift
//  Wind
//
//  Created by Enno Welbers on 07.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var container = "wind_container";
}

@objc public  class ContainerWrapper:NSObject {
    var Instance:Container?;
    
    override init() {
        super.init();
    }
}


public extension UIApplication {
    var Container:Container? {
        get
        {
            return (objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.Instance;
        }
        set {
            let wrapper = ContainerWrapper();
            wrapper.Instance = newValue;
            objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

public extension UIStoryboard {
    var Container:Container? {
        get
        {
            let myInstance=(objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.Instance;
            guard myInstance != nil else {
                return UIApplication.shared.Container;
            }
            return myInstance;
        }
        set {
            let wrapper = ContainerWrapper();
            wrapper.Instance = newValue;
            objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

/// This class can be added to your storyboard to resolve the view controller as a component.
@objc public class StoryboardResolver : NSObject {
    @IBOutlet var viewController: UIViewController!;
    
    override public func awakeFromNib() {
        if let consumer = viewController as? Component {
            try! viewController.storyboard?.Container?.resolve(for: consumer);
        }
    }
}
