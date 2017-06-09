//
//  AppDelegate.swift
//  WindSample
//
//  Created by Enno Welbers on 09.06.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import UIKit
import Wind

protocol AppDelegateDependency {
    
}

extension AppDelegateDependency where Self:AutomaticDependencyHandling {
    var appDelegate:AppDelegate! { get { return component();}}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ForeignSingleton,SimpleResolver,AutomaticWeakDependencyHandling,SecondViewControllerDependency {

    typealias DependencyToken = AppDelegateDependency;
    
    var dependencies: [String : Component] = [:];
    var weakDependencies: [String : WeakReference] = [:];
    
    static var instance:AppDelegate?;
    
    static func getForeignInstance() -> Component {
        return instance!;
    }
    
    override init() {
        super.init()
        AppDelegate.instance = self;
        
        let cnt=Container();
        AppDelegate.register(in: cnt);
        SecondViewController.register(in: cnt);
        
        try! cnt.bootstrap();
        UIApplication.shared.Container = cnt;
    }
    
    var window: UIWindow?

    func message() -> String {
        return "Hello, World!";
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        let instance = self.secondViewController;
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

