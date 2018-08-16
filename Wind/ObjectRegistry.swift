//
//  ObjectRegistry.swift
//  Wind
//
//  Created by Enno Welbers on 16.08.18.
//  Copyright © 2018 Palasthotel. All rights reserved.
//

import Foundation

class ObjectRegistry {
    
    class Entry {
        public weak var Object:Component?
        public weak var Container:Container?
        
        init(object:Component, container:Container) {
            self.Object=object;
            self.Container=container;
        }
    }
    
    private static var objects:[Entry]=[];
    
    public static func container(for object:Component) -> Container? {
        objects = objects.filter({ (entry) -> Bool in
            return entry.Object != nil && entry.Container != nil;
        });
        return objects.first(where: { (entry) -> Bool in
            return entry.Object === object;
        })?.Container;
    }
    
    public static func register(object: Component, for container:Container ) -> Void {
        objects.append(Entry(object: object, container: container));
    }
}
