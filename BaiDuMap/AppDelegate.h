//
//  AppDelegate.h
//  BaiDuMap
//
//  Created by 俊海贾 on 16/10/10.
//  Copyright © 2016年 aohuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *navigationController;
    BMKMapManager* _mapManager;
}
@property (strong, nonatomic) UIWindow *window;


@end

