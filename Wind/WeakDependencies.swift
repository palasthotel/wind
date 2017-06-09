//
//  WeakDependencies.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

public protocol WeakDependencyAware:Component {
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void;
}

public class WeakReference {
    weak var Instance:Component?;
    
    init(pointingAt component:Component) {
        Instance = component;
    }
}

public protocol AutomaticWeakDependencyHandling:AutomaticDependencyHandling,WeakDependencyAware {
    var weakDependencies:[String:WeakReference] {get set}
}

public extension AutomaticWeakDependencyHandling {
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void {
        weakDependencies[String(describing:dependency)] = WeakReference(pointingAt:object);
    }
    
    func weakComponent<T>() -> T? {
        return weakDependencies[String(describing:T.self)]?.Instance as? T;
    }
}

