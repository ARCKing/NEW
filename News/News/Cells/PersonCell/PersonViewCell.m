//
//  PersonViewCell.m
//  News
//
//  Created by ZZG on 16/5/29.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "PersonViewCell.h"

@implementation PersonViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.PersonImg.layer.cornerRadius=20;
    self.PersonImg.layer.masksToBounds=YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
