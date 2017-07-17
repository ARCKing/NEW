//
//  RecordCell.m
//  News
//
//  Created by ZZG on 16/6/22.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "RecordCell.h"

@implementation RecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_model == nil) return;
    self.VIEW.backgroundColor=[UIColor colorWithRed:126/255.0f green:203/255.0f blue:50/255.0f alpha:1];
    
    if ([_model.bank_name isEqualToString:@"alipay"]) {
        self.VIEW.backgroundColor=[UIColor colorWithRed:105/255.0f green:168/255.0f blue:236/255.0f alpha:1];
    }
    self.Myview.layer.cornerRadius=5;
    self.Myview.layer.borderColor=self.VIEW.backgroundColor.CGColor;
    self.Myview.layer.borderWidth=1;
    self.Myview.layer.masksToBounds=YES;

}


@end
