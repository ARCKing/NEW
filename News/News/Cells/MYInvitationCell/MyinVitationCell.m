//
//  MyinVitationCell.m
//  News
//
//  Created by ZZG on 16/6/8.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "MyinVitationCell.h"

@implementation MyinVitationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.ImgView.layer.cornerRadius=25;
    self.ImgView.layer.masksToBounds=YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
