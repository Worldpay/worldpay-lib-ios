//
//  SettingsTableViewController.m
//  testWorldpayLibrary
//
//  Created by Bill Panagiotopoulos on 3/24/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsCell.h"
#import "Worldpay.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "DBhandler.h"

@interface SettingsTableViewController ()<UIAlertViewDelegate>
@property (nonatomic, retain) NSArray *settingsItems, *environmentItems, *developmentKeys, *productionKeys;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic, retain) UIAlertView *keyAlertView;
@property (nonatomic, retain) NSString *developmentClientKey, *developmentServiceKey, *productionClientKey, *productionServiceKey;
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
    
    _environmentItems = @[
                          @{
                              @"label": @"Production",
                              @"checked": @([[Worldpay sharedInstance] WPEnvironment] == WPEnvironmentProduction),
                              @"value": @(WPEnvironmentProduction)
                            },
                          @{
                              @"label": @"Development",
                              @"checked": @([[Worldpay sharedInstance] WPEnvironment] == WPEnvironmentDevelopment),
                              @"value": @(WPEnvironmentDevelopment)
                            }
                           ];
    
    
    [self setKeys];
    
    UINib *cellNib = [UINib nibWithNibName:@"SettingsCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"settingsCell"];
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    _sections = @[@"Settings", @"Environment", @"Development Keys", @"Production Keys"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_delegate.debugMode) {
        return 4;
    } else {
        return 2;
    }
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
    else if (indexPath.section == 1) {
        UITableViewCell *environmentCell = [tableView dequeueReusableCellWithIdentifier:@"environmentCell"];
        
        NSDictionary *item = [_environmentItems objectAtIndex:indexPath.row];
        
        if (environmentCell == nil) {
            environmentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"environmentCell"];
        }
        
        environmentCell.textLabel.text = [item objectForKey:@"label"];
        
        if ([[item objectForKey:@"checked"] boolValue]) {
            environmentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            environmentCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell = environmentCell;
    }
    else if (indexPath.section <= 3) {
        UITableViewCell *keyCell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
        
        if (keyCell == nil) {
            keyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"keyCell"];
        }
        
        NSArray *keys = (indexPath.section == 2) ? _developmentKeys : _productionKeys;
        
        NSDictionary *item = [keys objectAtIndex:indexPath.row];
        
        keyCell.textLabel.text = [item objectForKey:@"label"];
        keyCell.detailTextLabel.text = [item objectForKey:@"value"];
        
        cell = keyCell;
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        for (UITableViewCell *visibleCell in tableView.visibleCells) {
            visibleCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSDictionary *item = [_environmentItems objectAtIndex:indexPath.row];
      
        WPEnvironment newEnvironment = (WPEnvironment)[[item objectForKey:@"value"] intValue];
        if (newEnvironment != [[Worldpay sharedInstance] WPEnvironment]) {
          FMDatabase *database = [DBhandler openDB];
          [DBhandler deleteAllCards:database];
          [DBhandler closeDatabase:database];
        }
        [[Worldpay sharedInstance] setWPEnvironment:newEnvironment];
      
        [_delegate setKeys];
    }
    else if (indexPath.section <= 3) {
        _keyAlertView = [[UIAlertView alloc] initWithTitle:@"Key" message:@"Enter your Key" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        _keyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        NSString *key = nil;
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                key = _developmentClientKey;
                [_keyAlertView.layer setValue:@"developmentClientKey" forKey:@"key"];
            } else {
                key = _developmentServiceKey;
                [_keyAlertView.layer setValue:@"developmentServiceKey" forKey:@"key"];
            }
            
        } else {
            if (indexPath.row == 0) {
                key = _productionClientKey;
                [_keyAlertView.layer setValue:@"productionClientKey" forKey:@"key"];
            } else {
                key = _productionServiceKey;
                [_keyAlertView.layer setValue:@"productionServiceKey" forKey:@"key"];
            }
        }
        
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
    
    _developmentClientKey = [userDefaults valueForKey:@"developmentClientKey"];
    _developmentServiceKey = [userDefaults valueForKey:@"developmentServiceKey"];
    _productionClientKey = [userDefaults valueForKey:@"productionClientKey"];
    _productionServiceKey = [userDefaults valueForKey:@"productionServiceKey"];
    
    _developmentKeys = @[
                         @{
                             @"label": @"Client Key",
                             @"value": _developmentClientKey
                             },
                         @{
                             @"label": @"Service Key",
                             @"value": _developmentServiceKey
                             }
                         ];
    
    _productionKeys = @[
                        @{
                            @"label": @"Client Key",
                            @"value": _productionClientKey
                            },
                        @{
                            @"label": @"Service Key",
                            @"value": _productionServiceKey
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
    
      [_delegate setKeys];
      [self setKeys];
      [self.tableView reloadData];
    }
}



@end
