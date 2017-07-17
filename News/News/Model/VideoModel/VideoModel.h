//
//  VideoModel.h
//  News
//
//  Created by ZZG on 16/6/12.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "JSONModel.h"

@interface VideoModel : JSONModel


@property (nonatomic ,copy)NSString *caption;
@property (nonatomic ,copy)NSString *cover_pic;
@property (nonatomic ,copy)NSString *user_name;
@property (nonatomic ,copy)NSString *video_id;
@property (nonatomic ,copy)NSString *likes_count;

@property (nonatomic ,copy)NSString *user_avatar;
@property (nonatomic ,copy)NSString *video;
@property (nonatomic ,copy)NSString *link;


//==========
@property (nonatomic ,copy)NSString * ucshare;

@end
