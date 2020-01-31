//
//  WeakDependencies.swift
//  Wind
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import Foundation

/// If your component depends on a foreign instantiated object,
/// it needs to be aware of weak dependencies.
/// If you don't want to think about it, simply conform to AutomaticWeakDependencyHandling.
public protocol WeakDependencyAware:Component {
    /// Components handed in via this function are not allowed to be
    /// strongly referenced.
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void;
}

/// WeakReference is used to store weak references to foreign instantiated components.
/// you should almost never use it directly.
public class WeakReference {
    public weak var Instance:Component?;
    
    public init(pointingAt component:Component) {
        Instance = component;
    }
}

public protocol AutomaticWeakDependencyHandling:AutomaticDependencyHandling,WeakDependencyAware {
    var weakDependencies:[String:[WeakReference]] {get set}
}

public extension AutomaticWeakDependencyHandling {
    func fill(dependency:Any.Type, weaklyWith object:Component) -> Void {
        let key=String(describing:dependency);
        if(weakDependencies[key] == nil) {
            weakDependencies[key] = [];
        }
        weakDependencies[key]?.append(WeakReference(pointingAt:object));
    }
    
    func weakComponent<T>() -> T? {
        let options = weakDependencies[String(describing:T.self)];
        guard let possibleoptions = options else {
            return nil;
        }
        return possibleoptions.filter({$0.Instance != nil}).first?.Instance as? T;
    }
    
    func weakComponents<T>() -> [T] {
        let options = weakDependencies[String(describing:T.self)];
        guard let possibleoptions = options else {
            return [];
        }
        let living = possibleoptions.filter({$0.Instance != nil}).map({$0.Instance! as! T});
        return living;
    }
}

