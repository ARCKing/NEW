//
//  VideoCell.h
//  News
//
//  Created by ZZG on 16/6/12.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface VideoCell : UITableViewCell

@property (strong, nonatomic)VideoModel *model;
@property (weak, nonatomic) IBOutlet UIView *MyView;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;

@property (weak, nonatomic) IBOutlet UIButton *PlayBtn;


@property (weak, nonatomic) IBOutlet UIImageView *HeadPImageView;

@property (weak, nonatomic) IBOutlet UILabel *NameLabel;

@property (weak, nonatomic) IBOutlet UIButton *ShareBtn;

@property (weak, nonatomic) IBOutlet UILabel *NumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *LoveBtn;
@property (weak, nonatomic) IBOutlet UIButton *TapPlayBtn;

@property (weak, nonatomic) IBOutlet UIButton *jubaoBtn;

@end
