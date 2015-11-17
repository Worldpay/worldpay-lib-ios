//
//  SettingsTableViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsCell.h"
#import "Worldpay.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "DBhandler.h"

@interface SettingsTableViewController ()<UIAlertViewDelegate>
@property (nonatomic, retain) NSArray *settingsItems, *keys;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic, retain) UIAlertView *keyAlertView;
@property (nonatomic, retain) NSString *clientKey, *serviceKey;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.title = @"Settings";
    
    _settingsItems = @[
                        @{
                            @"label": @"Authorisation only",
                            @"value": [NSNumber numberWithBool:[[Worldpay sharedInstance] authorizeOnly]]
                        },
                        @{
                            @"label": @"3D Secure",
                            @"value": @(_delegate.threeDSEnabled)
                        }];
    
    
    [self setKeys];
    
    UINib *cellNib = [UINib nibWithNibName:@"SettingsCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"settingsCell"];
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    _sections = @[@"Settings", @"API Keys"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        return _settingsItems.count;
    }
    else if (section <= 3) {
        return 2;
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    
    if (indexPath.section == 0) {
        SettingsCell *settingsCell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"
                                                                     forIndexPath:indexPath];
        
        NSDictionary *curSetting = [_settingsItems objectAtIndex:indexPath.row];
        
        settingsCell.settingLabel.text = [curSetting objectForKey:@"label"];
        settingsCell.settingSwitch.on = [[curSetting objectForKey:@"value"] boolValue];
        
        [settingsCell.settingSwitch addTarget:self action:@selector(switchChangedAction:) forControlEvents:UIControlEventValueChanged];
        [settingsCell.settingSwitch.layer setValue:indexPath forKey:@"indexPath"];
        
        settingsCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = settingsCell;
    }
    else if (indexPath.section <= 2) {
        UITableViewCell *keyCell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
        
        if (keyCell == nil) {
            keyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"keyCell"];
        }
        
        NSArray *keys = _keys;
        
        NSDictionary *item = [keys objectAtIndex:indexPath.row];
        
        keyCell.textLabel.text = [item objectForKey:@"label"];
        keyCell.detailTextLabel.text = [item objectForKey:@"value"];
        
        cell = keyCell;
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 ) {
        
        NSString *title = @"Client Key";
        NSString *key = nil;
        
        _keyAlertView = [[UIAlertView alloc] initWithTitle:title message:@"Enter your Key" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        if (indexPath.row == 0) {
            key = _clientKey;
            [_keyAlertView.layer setValue:@"clientKey" forKey:@"key"];

        } else {
            title = @"Service Key";
            key = _serviceKey;
            [_keyAlertView.layer setValue:@"serviceKey" forKey:@"key"];

        }
    
        _keyAlertView.title = title;
        _keyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;

        [[_keyAlertView textFieldAtIndex:0] setText:key];
        [_keyAlertView show];

    }
}

- (IBAction)switchChangedAction:(id)sender {
    UISwitch *switchSetting = sender;
    NSIndexPath *indexPath = [switchSetting.layer valueForKey:@"indexPath"];
    
    switch (indexPath.row) {
        case 0:
            [[Worldpay sharedInstance] setAuthorizeOnly:switchSetting.on];
            break;
        case 1:
            _delegate.threeDSEnabled = switchSetting.on;
            break;
        default:
            break;
    }
}

- (void)setKeys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _clientKey = [userDefaults valueForKey:@"clientKey"];
    _serviceKey = [userDefaults valueForKey:@"serviceKey"];

    
    _keys = @[
                         @{
                             @"label": @"Client Key",
                             @"value": _clientKey
                             },
                         @{
                             @"label": @"Service Key",
                             @"value": _serviceKey
                             }
                         ];
    
    

}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
      UITextField *textField = [alertView textFieldAtIndex:0];
        
      [userDefaults setValue:textField.text forKey:[alertView.layer valueForKey:@"key"]];
      [userDefaults synchronize];
    
      FMDatabase *database = [DBhandler openDB];
      [DBhandler deleteAllCards:database];
      [DBhandler closeDatabase:database];

      [_delegate setKeys];
      [self setKeys];
      [self.tableView reloadData];
    }
}



@end
