//
//  UserCell.h
//  
//
//  Created by siyue on 16/5/24.
//
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (nonatomic ,strong)NSDictionary *Dict;
@property (weak, nonatomic) IBOutlet UILabel *NumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ImgView;

@property (weak, nonatomic) IBOutlet UILabel *NameLabel;

@property (weak, nonatomic) IBOutlet UILabel *jifenLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;
@end
