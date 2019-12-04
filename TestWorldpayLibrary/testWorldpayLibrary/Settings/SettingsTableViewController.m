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
@property (nonatomic, retain) NSArray *settingsItems, *keys, *versions;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic, retain) NSString *clientKey, *serviceKey;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.title = @"Settings";
    
    _settingsItems = @[
                       @{
                           @"label": @"One time Token",
                           @"value": [NSNumber numberWithBool:![[Worldpay sharedInstance] reusable]]
                        },
                        @{
                            @"label": @"Authorisation only",
                            @"value": [NSNumber numberWithBool:[[Worldpay sharedInstance] authorizeOnly]]
                        },
                        @{
                            @"label": @"3D Secure",
                            @"value": @(_delegate.threeDSEnabled)
                        }];
    
    
    [self setKeys];
    [self setVersions];

    UINib *cellNib = [UINib nibWithNibName:@"SettingsCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"settingsCell"];
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    _sections = @[@"Settings", @"API Keys", @"Version"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
    else {
        UITableViewCell *versionCell = [tableView dequeueReusableCellWithIdentifier:@"versionCell"];
        
        if (versionCell == nil) {
            versionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"versionCell"];
        }
        
        NSArray *versions = _versions;

        NSDictionary *item = [versions objectAtIndex:indexPath.row];
        
        versionCell.textLabel.text = [item objectForKey:@"label"];
        versionCell.detailTextLabel.text = [item objectForKey:@"value"];
        cell = versionCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 ) {
        NSString *title = @"Client Key";
        NSString *value = self.clientKey;
        NSString *key = @"clientKey";
        
        if (indexPath.row != 0) {
            title = @"Service Key";
            value = _serviceKey;
            key = @"serviceKey";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:@"Enter your Key"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = value;
            textField.keyboardType = UIKeyboardTypeDefault;
        }];
        
        __weak typeof(alertController) weakAlertController = alertController;
        __weak typeof(self) weak = self;
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                                  
                                                                  NSString *val = [[weakAlertController textFields][0] text];
                                                                  
                                                                  [userDefaults setValue:val forKey:key];
                                                                  [userDefaults synchronize];
                                                                  
                                                                  FMDatabase *database = [DBhandler openDB];
                                                                  [DBhandler deleteAllCards:database];
                                                                  [DBhandler closeDatabase:database];
                                                                  
                                                                  [weak.delegate setKeys];
                                                                  [weak setKeys];
                                                                  [weak.tableView reloadData];
                                                              }];
        [alertController addAction:confirmAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)switchChangedAction:(id)sender {
    UISwitch *switchSetting = sender;
    NSIndexPath *indexPath = [switchSetting.layer valueForKey:@"indexPath"];
    FMDatabase *database = [DBhandler openDB];
    switch (indexPath.row) {
        case 0:
            [DBhandler deleteAllCards:database];
            [[Worldpay sharedInstance] setReusable:!switchSetting.on];
            break;
        case 1:
            [[Worldpay sharedInstance] setAuthorizeOnly:switchSetting.on];
            break;
        case 2:
            _delegate.threeDSEnabled = switchSetting.on;
            break;
        default:
            break;
    }
    
    [DBhandler closeDatabase:database];
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

- (void)setVersions {
    
    _versions = @[
                  @{
                      @"label": @"App Version",
                      @"value": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
                      },
                  @{
                      @"label": @"Build Number",
                      @"value": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
                      }
                  ];
}

@end
