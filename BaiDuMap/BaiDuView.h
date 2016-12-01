//
//  BaiDuView.h
//  BaiDuMap
//
//  Created by 俊海贾 on 2016/11/29.
//  Copyright © 2016年 aohuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaiDuViewDelegate <NSObject>

-(void)searchBusClick:(UIButton *)btn andCity:(NSString *)cityStr andBus:(NSString *)busStr;

@end
@interface BaiDuView : UIView

@property (nonatomic, strong) UIButton *busPOIBtn;//公交检索
@property (nonatomic, strong) UITextField *cityTextF;
@property (nonatomic, strong) UILabel *lab1;
@property (nonatomic, strong) UITextField *busTextF;
@property (nonatomic, strong) UIButton *searchBtnUp;//上行
@property (nonatomic, strong) UIButton *searchBtnDown;//下行

@property (nonatomic, strong) id<BaiDuViewDelegate>delegate;
@end
