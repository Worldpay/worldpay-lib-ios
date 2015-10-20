//
//  SettingsCell.h
//  testWorldpayLibrary
//
//  Created by Bill Panagiotopoulos on 3/24/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@end
