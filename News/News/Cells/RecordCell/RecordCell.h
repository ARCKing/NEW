//
//  RecordCell.h
//  News
//
//  Created by ZZG on 16/6/22.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordModel.h"

@interface RecordCell : UITableViewCell

@property (strong, nonatomic)RecordModel *model;
@property (weak, nonatomic) IBOutlet UIView *Myview;
@property (weak, nonatomic) IBOutlet UIView *VIEW;

@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *RefundLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImgView;


@end
