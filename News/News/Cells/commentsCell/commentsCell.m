//
//  commentsCell.m
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "commentsCell.h"

@implementation commentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.PerSonImgView.layer.cornerRadius=20;
    self.PerSonImgView.layer.masksToBounds=YES;
    
    
    self.CommentBtn.layer.borderColor=[UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1].CGColor;
    self.CommentBtn.layer.borderWidth=0.5;
    self.CommentBtn.layer.masksToBounds=YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
