/* Copyright (c) 2012, Todd Pickell
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY TODD PICKELL ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL BERND ROSSTAUSCHER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  GGCAppDelegate.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCAppDelegate.h"

#import "IIViewDeckController.h"
#import "GGCPunchViewController.h"
#import "GGCFirstViewController.h"
#import "GGCSecondViewController.h"


@implementation GGCAppDelegate

@synthesize window = _window;
@synthesize punchVC = _punchVC;
@synthesize firstVC = _firstVC;
@synthesize secondVC = _secondVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"4b4e8a904763818917de01b7c76985f2_OTg3MzcyMDEyLTA2LTEwIDE5OjQ0OjQ2LjAyNTkxMg"];
    
    //stuff for viewDeck
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"alloc window");
    
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"NewStoryboard" bundle:nil];
    NSLog(@"got storyboard");
    
    _punchVC = [stb instantiateViewControllerWithIdentifier:@"punch"];
    _firstVC = [stb instantiateViewControllerWithIdentifier:@"specials"];
    _secondVC = [stb instantiateViewControllerWithIdentifier:@"coffees"];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:_punchVC
                                                                                    leftViewController:_firstVC
                                                                                   rightViewController:_secondVC];
    NSLog(@"added vc's to new deck controller");
    deckController.rightLedge = 10;
    deckController.leftLedge = 10;
    
    self.window.rootViewController = deckController;
    NSLog(@"set deck controller as root view controller");
    [self.window makeKeyAndVisible];
    NSLog(@"make window key and visible");
    //end stuff for viewDeck
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [TestFlight passCheckpoint:@"APP_DID_ENTER_BACKGROUND"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [TestFlight passCheckpoint:@"APP_WILL_TREMINATE"];
}



@end
