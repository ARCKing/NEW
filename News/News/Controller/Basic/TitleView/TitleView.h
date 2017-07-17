//
//  TitleView.h
//  News
//
//  Created by ZZG on 16/6/11.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

//代理
@protocol TitleCellDelegate <NSObject>

- (void)didSelectedCategorynum:(NSInteger)num  AndTitle:(NSString *)title;

@end


@interface TitleView : UIView

@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;

@property (nonatomic , weak) id<TitleCellDelegate>Delegate;

@end
