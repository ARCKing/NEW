//
//  News2Cell.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "News2Cell.h"

@implementation News2Cell

- (void)awakeFromNib {
    self.HotLabel.layer.borderColor=[UIColor redColor].CGColor;
    self.HotLabel.layer.borderWidth=0.3;
    self.HotLabel.layer.cornerRadius=2;
    self.HotLabel.layer.masksToBounds=YES;
    
     self.HeightLayout.constant=0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
