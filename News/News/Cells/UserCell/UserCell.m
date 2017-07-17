//
//  UserCell.m
//  
//
//  Created by siyue on 16/5/24.
//
//

#import "UserCell.h"

@implementation UserCell

- (void)awakeFromNib {
    
    self.ImgView.layer.cornerRadius=18;
    self.ImgView.layer.masksToBounds=YES;
    
     self.HeightLayout.constant=0.5;
}


@end
