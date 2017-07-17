//
//  NewsCell.h
//  
//
//  Created by siyue on 16/5/20.
//
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayoput;

@property (weak, nonatomic) IBOutlet UIImageView *FirstImgView;

@property (weak, nonatomic) IBOutlet UIImageView *SecondImgview;

@property (weak, nonatomic) IBOutlet UIImageView *ThirdImgView;

@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *NumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *HotLabel;

@property (weak, nonatomic) IBOutlet UIView *Myview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;


@end
