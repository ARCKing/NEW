//
//  NewsModel.h
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "JSONModel.h"

@interface NewsModel : JSONModel

@property (nonatomic ,copy)NSString *title;
@property (nonatomic ,copy)NSString *addtime;
@property (nonatomic ,strong)NSArray *img;
@property (nonatomic ,copy)NSString *view_count;
@property (nonatomic ,copy)NSString *thumb;
@property (nonatomic ,copy)NSString *NewsID;
@property (nonatomic ,copy)NSString  *is_hot;
@property (nonatomic ,copy)NSString  *is_rec;







@end
