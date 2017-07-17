//
//  CommentModel.h
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "JSONModel.h"

@interface CommentModel : JSONModel

@property (nonatomic ,copy)NSString *user_name;
@property (nonatomic ,copy)NSString *user_avatar;
@property (nonatomic ,copy)NSString *message;
@property (nonatomic ,copy)NSString *created_at;
@property (nonatomic ,copy)NSString *post_id;


@end
