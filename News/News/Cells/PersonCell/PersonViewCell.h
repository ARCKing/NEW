//
//  PersonViewCell.h
//  News
//
//  Created by ZZG on 16/5/29.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *NumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *PersonImg;

@end
