//
//  AppDelegate.swift
//  WindMacSample
//
//  Created by Enno Welbers on 16.08.18.
//  Copyright © 2018 Palasthotel. All rights reserved.
//

import Cocoa
import Wind_mac

protocol DependsOnAppDelegate { }

extension DependsOnAppDelegate where Self: AutomaticDependencyHandling {
    
    var appDelegate:AppDelegate! {
        get {
            return self.component();
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,Component,ForeignSingleton,SimpleResolver,AutomaticDependencyHandling {
    typealias DependencyToken = DependsOnAppDelegate;

    var dependencies: [String : [Component]] = [:];
    static var instance:AppDelegate!;
    
    override init() {
        super.init();
        AppDelegate.instance=self;
        var container = Container();
        AppDelegate.register(in: container);
        try! container.bootstrap();
        NSApplication.shared.Container=container;
    }
    
    static func getForeignInstance() -> Component {
        return AppDelegate.instance;
    }

    public func hello() -> String {
        return "World!";
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

