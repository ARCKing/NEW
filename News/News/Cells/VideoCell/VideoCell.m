//
//  VideoCell.m
//  News
//
//  Created by ZZG on 16/6/12.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "VideoCell.h"
#import "UIImageView+WebCache.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@implementation VideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.jubaoBtn.layer.borderWidth=0.2;
    self.jubaoBtn.layer.borderColor=[UIColor grayColor].CGColor;
    self.jubaoBtn.layer.cornerRadius=4;
    self.jubaoBtn.layer.masksToBounds=YES;
    
    
    self.ImgView.layer.masksToBounds = YES;
    [self.ImgView layer].shadowPath =[UIBezierPath bezierPathWithRect:self.ImgView.bounds].CGPath;
    
    self.PlayBtn.layer.cornerRadius=20;
    self.PlayBtn.layer.masksToBounds=YES;

    self.HeightLayout.constant=0.5;
    self.HeadPImageView.layer.cornerRadius=15;
    self.HeadPImageView.layer.masksToBounds=YES;

    [self.MyView.layer addSublayer:[self shadowAsInverse]];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_model == nil) return;

    [self.HeadPImageView sd_setImageWithURL:[NSURL URLWithString:_model.user_avatar] placeholderImage:nil];
    self.NameLabel.text=_model.user_name;
    self.NumberLabel.text=_model.likes_count;
    self.TitleLabel.text = _model.caption;
}
- (CAGradientLayer *)shadowAsInverse
{
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    CGRect newShadowFrame = CGRectMake(0, 0, kScreenWidth, 70);
    newShadow.frame = newShadowFrame;
    //添加渐变的颜色组合（颜色透明度的改变）
    newShadow.colors = [NSArray arrayWithObjects:
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.7] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.4] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.3] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor],
                        (id)[[[UIColor blackColor] colorWithAlphaComponent:0.0] CGColor],
                        nil];
    return newShadow;
}

@end
