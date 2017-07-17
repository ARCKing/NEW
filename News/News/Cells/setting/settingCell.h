//
//  settingCell.h
//  News
//
//  Created by HPmac on 16/5/23.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImgView;
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;

@end
