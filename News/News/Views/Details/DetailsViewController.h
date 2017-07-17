//
//  DetailsViewController.h
//  
//
//  Created by siyue on 16/5/21.
//
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface DetailsViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic ,copy)NSString *DetailID;

@property (nonatomic ,copy)NSString *Title;
 

@end
