//
//  commentsCell.h
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commentsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *PerSonImgView;
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *CommentBtn;

@end
