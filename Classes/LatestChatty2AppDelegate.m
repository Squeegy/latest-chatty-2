//
//    LatestChatty2AppDelegate.m
//    LatestChatty2
//
//    Created by Alex Wayne on 3/16/09.
//    Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "LatestChatty2AppDelegate.h"
#import "StringTemplate.h"
#import "Mod.h"
#import "NoContentController.h"

@implementation LatestChatty2AppDelegate

@synthesize window;
@synthesize navigationController, contentNavigationController, slideOutViewController;

+ (LatestChatty2AppDelegate*)delegate {
    return (LatestChatty2AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)setupInterfaceForPhoneWithOptions:(NSDictionary *)launchOptions
{    
    if (![self reloadSavedState]) {
        // Add the root view controller
        RootViewController *viewController = [RootViewController controllerWithNib];
        [navigationController pushViewController:viewController animated:NO];
    }
    
    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"message_id"]) {
        // Tapped a messge push's view button
        MessagesViewController *viewController = [MessagesViewController controllerWithNib];
        [navigationController pushViewController:viewController animated:NO];
    }
    
    // Style the navigation bar
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    // Configure and show the window
    window.backgroundColor = [UIColor blackColor];
    
    [window addSubview:navigationController.view];    
}

- (void)setupInterfaceForPadWithOptions:(NSDictionary *)launchOptions
{
    self.contentNavigationController = [UINavigationController controllerWithRootController:[NoContentController controllerWithNib]];
    contentNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    contentNavigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    
    if (![self reloadSavedState]) {
        // Add the root view controller
        [navigationController pushViewController:[RootViewController controllerWithNib] animated:NO];
    }
    
    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"message_id"]) {
        // Tapped a messge push's view button
        MessagesViewController *viewController = [MessagesViewController controllerWithNib];
        [navigationController pushViewController:viewController animated:NO];
    }
    
    self.slideOutViewController =  [SlideOutViewController controllerWithNib];
    [slideOutViewController addNavigationController:navigationController contentNavigationController:contentNavigationController];
    [slideOutViewController.view setFrame:CGRectMake(0,    20,    768, 1004)];
    [window addSubview:slideOutViewController.view];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastSaveDate = [defaults objectForKey:@"savedStateDate"];
    
    // Register for Push
    if ([defaults boolForKey:@"push.messages"]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    // If forget history is on or it's been 8 hours since the last opening, then we don't care about the saved state.
    if ([defaults boolForKey:@"forgetHistory"] || [lastSaveDate timeIntervalSinceNow] < -8*60*60) {
        [defaults removeObjectForKey:@"savedState"];
    }        
    
    if ([self isPadDevice]) {
        [self setupInterfaceForPadWithOptions:launchOptions];
    } else {
        [self setupInterfaceForPhoneWithOptions:launchOptions];
    }

      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];    
    
    [window makeKeyAndVisible];

    // Settings defaults
    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",                           @"username",
                                     @"",                           @"password",
                                     @"shackapi.stonedonkey.com",   @"server",
                                     [NSNumber numberWithBool:YES], @"landscape",
                                     [NSNumber numberWithBool:YES], @"embedYoutube",
                                     [NSNumber numberWithBool:NO],  @"push.messages",
                                     [NSNumber numberWithBool:YES], @"postCategory.informative",
                                     [NSNumber numberWithBool:YES], @"postCategory.offtopic",
                                     [NSNumber numberWithBool:YES], @"postCategory.stupid",
                                     [NSNumber numberWithBool:YES], @"postCategory.political",
                                     [NSNumber numberWithBool:NO],  @"postCategory.nws",
                                     [NSNumber numberWithInt:0],    @"lastRefresh",
                                     [NSMutableArray array],        @"pinnedPosts",
                                     nil];
    [defaults registerDefaults:defaultSettings];

    if([defaults boolForKey:@"modTools"]==YES){
        //Mods need cookies
        //
        NSString *usernameString = [[defaults stringForKey:@"username"] stringByEscapingURL];
        NSString *passwordString = [[defaults stringForKey:@"password"] stringByEscapingURL];
        NSString *requestBody = [NSString stringWithFormat:@"email=%@&password=%@&login=login", usernameString, passwordString];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

        [request setURL:[NSURL URLWithString:@"http://www.shacknews.com"]];
        [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
        [request setHTTPMethod:@"POST"];
        [NSURLConnection connectionWithRequest:request delegate:nil];    
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([userInfo objectForKey:@"message_id"]) {
        [UIAlertView showWithTitle:@"Incoming Message"
                           message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                          delegate:self
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:@"View", nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        MessagesViewController *viewController = [[MessagesViewController alloc] init];
        [navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[[Model class] urlStringWithPath:@"/devices"]]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [[deviceToken description] stringByReplacingOccurrencesOfRegex:@"<|>" withString:@""];
    NSString *usernameString = [[defaults stringForKey:@"username"] stringByEscapingURL];
    NSString *passwordString = [[defaults stringForKey:@"password"] stringByEscapingURL];
    NSString *requestBody = [NSString stringWithFormat:@"token=%@&username=%@&password=%@", pushToken, usernameString, passwordString];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
}


- (NSURLCredential *)userCredential {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    return [NSURLCredential credentialWithUser:[defaults objectForKey:@"username"]
                                      password:[defaults objectForKey:@"password"]
                                   persistence:NSURLCredentialPersistenceNone];
}

- (id)viewControllerForURL:(NSURL *)url {
    NSString *uri = [url absoluteString];
    UIViewController *viewController = nil;
    
    if ([uri isMatchedByRegex:@"shacknews\\.com/laryn\\.x\\?id=\\d+"]) {
        NSUInteger targetThreadId = [[uri stringByMatching:@"shacknews\\.com/laryn\\.x\\?id=(\\d+)" capture:1] intValue];
        viewController = [[[ThreadViewController alloc] initWithThreadId:targetThreadId] autorelease];
    } else if ([uri isMatchedByRegex:@"shacknews\\.com/laryn\\.x\\?story=\\d+"]) {
        NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/laryn\\.x\\?story=(\\d+)" capture:1] intValue];
        viewController = [[[ChattyViewController alloc] initWithStoryId:targetStoryId] autorelease];
    } else
        if ([uri isMatchedByRegex:@"shacknews\\.com/chatty\\?id=\\d+"]) {
            NSUInteger targetThreadId = [[uri stringByMatching:@"shacknews\\.com/chatty\\?id=(\\d+)" capture:1] intValue];
            viewController = [[[ThreadViewController alloc] initWithThreadId:targetThreadId] autorelease];
        } else if ([uri isMatchedByRegex:@"shacknews\\.com/chatty\\?story=\\d+"]) {
            NSUInteger targetStoryId = [[uri stringByMatching:@"shacknews\\.com/chatty\\?story=(\\d+)" capture:1] intValue];
            viewController = [[[ChattyViewController alloc] initWithStoryId:targetStoryId] autorelease];
        }
    //else if ([[uri lowercaseString] isMatchedByRegex:@"\\.(png|jpg)$"]) {
//        viewController = [ImageViewController controllerWithURL:url];
//    }
    
    return viewController;
}


- (BOOL)reloadSavedState {
    @try {
        // Find saved state
        NSData *savedState = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedState"];
        
        if (savedState) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedState"];
            NSArray *controllerDictionaries = [NSKeyedUnarchiver unarchiveObjectWithData:savedState];
            
            // Create a dictionary to convert controller type strings to class objects
            NSMutableDictionary *controllerClassLookup = [NSMutableDictionary dictionary];
            [controllerClassLookup setObject:[RootViewController class]        forKey:@"Root"];
            [controllerClassLookup setObject:[StoriesViewController class] forKey:@"Stories"];
            [controllerClassLookup setObject:[StoryViewController class]     forKey:@"Story"];
            [controllerClassLookup setObject:[ChattyViewController class]    forKey:@"Chatty"];
            [controllerClassLookup setObject:[ThreadViewController class]    forKey:@"Thread"];
            [controllerClassLookup setObject:[BrowserViewController class] forKey:@"Browser"];
            
            for (NSDictionary *dictionary in controllerDictionaries) {
                // find the right controller class
                NSString *controllerName = [dictionary objectForKey:@"type"];
                Class class = [controllerClassLookup objectForKey:controllerName];
                
                if (class) {
                    id viewController = [[class alloc] initWithStateDictionary:dictionary];
                    [navigationController pushViewController:viewController animated:NO];
                    [viewController release];
                } else {
                    NSLog(@"No known view controller for the type: %@", controllerName);
                    return NO;
                }
            }
        } else {
            return NO;
        }
        
    }
    @catch (NSException *e) {
        // Something went wrong restoring state, so just start over.
        navigationController.viewControllers = nil;
        return NO;
    }
    
    return YES;
}

- (BOOL)isPadDevice {
    return CGRectGetMaxX([[UIScreen mainScreen] bounds]) > 480;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSMutableArray *savedControllers = [NSMutableArray array];
    for (id viewController in [navigationController viewControllers]) {
        BOOL hasState = [viewController respondsToSelector:@selector(stateDictionary)];
        BOOL hasLoading = [viewController respondsToSelector:@selector(loading)];
        BOOL isDoneLoading = hasLoading && ![viewController loading];
        
        if (hasState && (isDoneLoading || !hasLoading))
            [savedControllers addObject:[viewController stateDictionary]];
    }
    
    NSData *state = [NSKeyedArchiver archivedDataWithRootObject:savedControllers];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:state forKey:@"savedState"];
    [defaults setObject:[NSDate date] forKey:@"savedStateDate"];
    [defaults synchronize];
    
    //'logout' essentially
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* shackCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://www.shacknews.com"]];
    for (NSHTTPCookie* cookie in shackCookies) {
     NSLog(@"Name: %@ : Value: %@", cookie.name, cookie.value); 
     [cookies deleteCookie:cookie];
    }
}


- (void)dealloc {
    self.navigationController = nil;
    self.window = nil;
    self.contentNavigationController = nil;
    self.slideOutViewController = nil;
    [super dealloc];
}

@end
