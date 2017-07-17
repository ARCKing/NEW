//
//  News2Cell.h
//  
//
//  Created by siyue on 16/5/20.
//
//

#import <UIKit/UIKit.h>

@interface News2Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLAyout;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *Timelabel;
@property (weak, nonatomic) IBOutlet UILabel *NumberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *Imgview;
@property (weak, nonatomic) IBOutlet UILabel *HotLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;

@end
