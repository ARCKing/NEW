//
//  TitleView.m
//  News
//
//  Created by ZZG on 16/6/11.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "TitleView.h"
#import "HotCell.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)


@interface TitleView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,strong)NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;

@end

@implementation TitleView


-(void)awakeFromNib
{
    
    self.HeightLayout.constant=0.5;
    self.CollectionView.delegate=self;
    self.CollectionView.dataSource=self;
    
    [self.CollectionView registerNib:[UINib nibWithNibName:@"HotCell" bundle:nil] forCellWithReuseIdentifier:@"HotCell"];
    self.CollectionView.backgroundColor=[UIColor clearColor];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HotCell *Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCell" forIndexPath:indexPath];
    
    Cell.TitleLabel.text=self.dataSource[indexPath.item];
    
    return Cell;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth/5-10, 40);
}

//触发协议方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.Delegate respondsToSelector:@selector(didSelectedCategorynum:AndTitle:)]) {
        [self.Delegate didSelectedCategorynum:indexPath.item AndTitle:self.dataSource[indexPath.item]];
    }
}


#pragma mark--getter&setter

-(NSMutableArray *)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
        [_dataSource addObject:@"推荐"];
        [_dataSource addObject:@"段子"];
        [_dataSource addObject:@"搞笑"];
        [_dataSource addObject:@"猎奇"];
        [_dataSource addObject:@"生活"];
        [_dataSource addObject:@"美女"];
        [_dataSource addObject:@"励志"];
        [_dataSource addObject:@"养生"];
        [_dataSource addObject:@"美食"];
        [_dataSource addObject:@"旅游"];
        [_dataSource addObject:@"财经"];
        [_dataSource addObject:@"情感"];
        [_dataSource addObject:@"职场"];
        [_dataSource addObject:@"育儿"];
        [_dataSource addObject:@"星座"];
        [_dataSource addObject:@"新闻"];
    }
    return _dataSource;
}


@end
