//
//  SettingsViewController.m
//  LatestChatty2
//
//  Created by Alex Wayne on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "RegexKitLite.h"
#import "LatestChatty2AppDelegate.h"

@implementation SettingsViewController


- (id)initWithNib {
    self = [super initWithNib];
	if (self) {
        usernameField = [[self generateTextFieldWithKey:@"username"] retain];
        usernameField.placeholder = @"Enter Username";
        usernameField.returnKeyType = UIReturnKeyNext;
        usernameField.keyboardType = UIKeyboardTypeEmailAddress;
        
        passwordField = [[self generateTextFieldWithKey:@"password"] retain];
        passwordField.placeholder = @"Enter Password";
        passwordField.secureTextEntry = YES;
        passwordField.returnKeyType = UIReturnKeyDone;
        
        serverField = [[self generateTextFieldWithKey:@"server"] retain];
        serverField.placeholder = @"shackapi.stonedonkey.com";
        serverField.returnKeyType = UIReturnKeyDone;
        serverField.keyboardType = UIKeyboardTypeURL;
        
        picsUsernameField = [[self generateTextFieldWithKey:@"picsUsername"] retain];
        picsUsernameField.placeholder = @"Enter Username";
        picsUsernameField.returnKeyType = UIReturnKeyNext;
        picsUsernameField.keyboardType = UIKeyboardTypeEmailAddress;
        
        picsPasswordField = [[self generateTextFieldWithKey:@"picsPassword"] retain];
        picsPasswordField.placeholder = @"Enter Password";
        picsPasswordField.secureTextEntry = YES;
        picsPasswordField.returnKeyType = UIReturnKeyDone;
        
        
        landscapeSwitch     = [[self generateSwitchWithKey:@"landscape"]     retain];
        youtubeSwitch       = [[self generateSwitchWithKey:@"embedYoutube"]  retain];
        pushMessagesSwitch  = [[self generateSwitchWithKey:@"push.messages"] retain];
        modToolsSwitch      = [[self generateSwitchWithKey:@"modTools"]      retain];
        
        interestingSwitch   = [[self generateSwitchWithKey:@"postCategory.informative"] retain];
        offtopicSwitch      = [[self generateSwitchWithKey:@"postCategory.offtopic"] retain];
        randomSwitch        = [[self generateSwitchWithKey:@"postCategory.stupid"] retain];
        politicsSwitch      = [[self generateSwitchWithKey:@"postCategory.political"] retain];
        nwsSwitch           = [[self generateSwitchWithKey:@"postCategory.nws"] retain];        
    }	
	
	return self;
}

- (id)initWithStateDictionary:(NSDictionary *)dictionary {
	return [self init];
}

- (NSDictionary *)stateDictionary {
	return [NSDictionary dictionaryWithObject:@"Settings" forKey:@"type"];
}

- (UITextField *)generateTextFieldWithKey:(NSString *)key {
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 20)];

	textField.returnKeyType = UIReturnKeyNext;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.delegate = self;
	textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	
	return [textField autorelease];
}

- (UISwitch *)generateSwitchWithKey:(NSString *)key {
	UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
	toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	return [toggle autorelease];
}

- (IBAction)dismiss:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:usernameField.text      forKey:@"username"];
	[defaults setObject:passwordField.text      forKey:@"password"];
    [defaults setObject:picsUsernameField.text  forKey:@"picsUsername"];
    [defaults setObject:picsPasswordField.text  forKey:@"picsPassword"];
	[defaults setBool:landscapeSwitch.on        forKey:@"landscape"];
	[defaults setBool:youtubeSwitch.on          forKey:@"embedYoutube"];
	[defaults setBool:pushMessagesSwitch.on     forKey:@"push.messages"];
    [defaults setBool:modToolsSwitch.on         forKey:@"modTools"];
	
	if (pushMessagesSwitch.on) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
	
    
	NSString *serverAddress = serverField.text;
	serverAddress = [serverAddress stringByReplacingOccurrencesOfRegex:@"^http://" withString:@""];
	serverAddress = [serverAddress stringByReplacingOccurrencesOfRegex:@"/$" withString:@""];
	[defaults setObject:serverAddress forKey:@"server"];
	
	[defaults setBool:interestingSwitch.on forKey:@"postCategory.informative"];
	[defaults setBool:offtopicSwitch.on    forKey:@"postCategory.offtopic"];
	[defaults setBool:randomSwitch.on      forKey:@"postCategory.stupid"];
	[defaults setBool:politicsSwitch.on    forKey:@"postCategory.political"];
	[defaults setBool:nwsSwitch.on         forKey:@"postCategory.nws"];
	
	[defaults synchronize];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	//...
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"landscape"]) return YES;
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField) {
		[passwordField becomeFirstResponder];
	} else if (textField == passwordField) {
		[passwordField resignFirstResponder];
	} else if (textField == serverField) {
		[serverField resignFirstResponder];
	} else if (textField == picsUsernameField) {
        [picsPasswordField becomeFirstResponder];
    } else if (textField == picsPasswordField) {
        [picsPasswordField resignFirstResponder];
    }
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return NO;
}

#pragma mark Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
			break;
        case 1:
            return 2;
            break;
			
		case 2:
			return 4;
			break;
			
		case 3:
			return 5;
			break;
			
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Shacknews.com Account";
			break;
        
        case 1:
            return @"ChattyPics.com Account";
            break;
			
		case 2:
			return @"Preferences";
			break;
			
		case 3:
			return @"Post Categories";
			break;
			
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	// username/password/server text entry fields
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.accessoryView = usernameField;
				cell.textLabel.text = @"Username:";
				break;
				
			case 1:
				cell.accessoryView = passwordField;
				cell.textLabel.text = @"Password:";
				break;
				
			case 2:
				cell.accessoryView = serverField;
				cell.textLabel.text = @"API Server:";
				break;
				
		}
	}
    
    // ChattyPics text fields
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.accessoryView = picsUsernameField;
                cell.textLabel.text = @"Username:";
                break;
            
            case 1:
                cell.accessoryView = picsPasswordField;
                cell.textLabel.text = @"Password:";
                break;
        }
    }
	
	// Preference toggles
	if (indexPath.section == 2) {
		switch (indexPath.row) {
			case 0:
				cell.accessoryView = landscapeSwitch;
				cell.textLabel.text = @"Allow Landscape:";
				break;
				
			case 1:
				cell.accessoryView = youtubeSwitch;
				cell.textLabel.text = @"Embed Youtube:";
				break;
				
			case 2:
				cell.accessoryView = pushMessagesSwitch;
				cell.textLabel.text = @"Push Messages:";
				break;
                
			case 3:
				cell.accessoryView = modToolsSwitch;
				cell.textLabel.text = @"Mod Tools:";
				break;
		}
	}
	
	// Post category toggles
	if (indexPath.section == 3) {
		UIView *categoryColor = [[[UIView alloc] initWithFrame:CGRectMake(18, 9, 6, 28)] autorelease];
		[cell addSubview:categoryColor];
		
		switch (indexPath.row) {
			case 0:
				cell.accessoryView = interestingSwitch;
				cell.textLabel.text = @"  Interesting:";
				categoryColor.backgroundColor = [Post colorForPostCategory:@"informative"];
				break;
				
			case 1:
				cell.accessoryView = offtopicSwitch;
				cell.textLabel.text = @"  Off Topic:";
				categoryColor.backgroundColor = [Post colorForPostCategory:@"offtopic"];
				break;
				
			case 2:
				cell.accessoryView = randomSwitch;
				cell.textLabel.text = @"  Stupid:";
				categoryColor.backgroundColor = [Post colorForPostCategory:@"stupid"];
				break;
				
			case 3:
				cell.accessoryView = politicsSwitch;
				cell.textLabel.text = @"  Politics / Religion:";
				categoryColor.backgroundColor = [Post colorForPostCategory:@"political"];
				break;
				
				
			case 4:
				cell.accessoryView = nwsSwitch;
				cell.textLabel.text = @"  NWS:";
				categoryColor.backgroundColor = [Post colorForPostCategory:@"nws"];
				break;
		}
	}
	
	
	return [cell autorelease];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)dealloc {
	[usernameField release];
	[passwordField release];
	[serverField release];
    
    [picsUsernameField release];
    [picsPasswordField release];
	
	[landscapeSwitch release];
	[youtubeSwitch release];
	[pushMessagesSwitch release];
	
	[interestingSwitch release];
	[offtopicSwitch release];
	[randomSwitch release];
	[politicsSwitch release];
	[nwsSwitch release];
	
	
	[super dealloc];
}


@end
