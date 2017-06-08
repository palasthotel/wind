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

@objc class ContainerWrapper:NSObject {
    var Instance:Container?;
    
    override init() {
        super.init();
    }
}


extension UIApplication {
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

extension UIStoryboard {
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
