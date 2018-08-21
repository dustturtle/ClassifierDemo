//
//  ViewController.h
//  NukeDetector
//
//  Created by GuanZhenwei on 2018/5/28.
//  Copyright © 2018年 GuanZhenwei. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline void dispatch_async_main(void (^block)())
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


@interface ViewController : UIViewController


@end

