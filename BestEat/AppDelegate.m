//
//  AppDelegate.m
//  BestEat
//
//  Created by Syren, Franck on 11/4/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // init Google API
    [GMSServices provideAPIKey:@"AIzaSyCWvv_mLz1A1NGo3SgJ4I78ZoebjQNtFPw"];
    
    // init Foursquare API
    [Foursquare2 setupFoursquareWithClientId:@"EK0SRIKPUVIQVSWFZAP2GOVLJXTNF4LYP4E2KTVH2BMFXX1K"
                                      secret:@"FK344YSLMOUJLHD52VGLG0WZ3ZB2KO3GQ2EFJN1OHCZH2TPK"
                                 callbackURL:@"BestEat://foursquare"];
    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *controller = (ViewController *)[sb instantiateInitialViewController];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window.rootViewController = nc;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {

}




@end
