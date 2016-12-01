//
//  BaiDuView.m
//  BaiDuMap
//
//  Created by 俊海贾 on 2016/11/29.
//  Copyright © 2016年 aohuan. All rights reserved.
//

#import "BaiDuView.h"

@implementation BaiDuView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _busPOIBtn = [[UIButton alloc] init];
        _busPOIBtn.frame = CGRectMake(10, 30, 60, 15);
        [_busPOIBtn setTitle:@"公交检索" forState:UIControlStateNormal];
//        [_busPOIBtn addTarget:self action:@selector(busPOIClick:) forControlEvents:UIControlEventTouchUpInside];
        [_busPOIBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _busPOIBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_busPOIBtn];
        
        _cityTextF = [[UITextField alloc] initWithFrame:CGRectMake(10, _busPOIBtn.frame.origin.y+CGRectGetHeight(_busPOIBtn.frame)+10, 40, 15)];
        _cityTextF.text = @"天津";
        _cityTextF.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _cityTextF.layer.borderWidth = 0.8;
        _cityTextF.layer.masksToBounds = YES;
        _cityTextF.font = [UIFont systemFontOfSize:13];
        [self addSubview:_cityTextF];
        
        _lab1 = [[UILabel alloc] init];
        _lab1.frame = CGRectMake(_cityTextF.frame.origin.x+CGRectGetWidth(_cityTextF.frame), _cityTextF.frame.origin.y, 60, 15);
        _lab1.text = @"市内查找";
        _lab1.font = [UIFont systemFontOfSize:13];
        [self addSubview:_lab1];
        
        _busTextF = [[UITextField alloc] initWithFrame:CGRectMake(_lab1.frame.origin.x+CGRectGetWidth(_lab1.frame)+10, _lab1.frame.origin.y, 40, 15)];
        _busTextF.text= @"832";
        _busTextF.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _busTextF.layer.borderWidth = 0.8;
        _busTextF.layer.masksToBounds = YES;
        _busTextF.font = [UIFont systemFontOfSize:13];
        [self addSubview:_busTextF];
        
        _searchBtnUp = [[UIButton alloc] init];
        _searchBtnUp.frame = CGRectMake(_busTextF.frame.origin.x+CGRectGetWidth(_busTextF.frame), _busTextF.frame.origin.y, 50, 15);
        [_searchBtnUp setTitle:@"上行" forState:UIControlStateNormal];
        [_searchBtnUp addTarget:self action:@selector(busPOIClick:) forControlEvents:UIControlEventTouchUpInside];
        _searchBtnUp.tag = 10;
        _searchBtnUp.titleLabel.font = [UIFont systemFontOfSize:13];
        [_searchBtnUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_searchBtnUp];
        
        
        _searchBtnDown = [[UIButton alloc] init];
        _searchBtnDown.frame = CGRectMake(_searchBtnUp.frame.origin.x+CGRectGetWidth(_searchBtnUp.frame)+10, _busTextF.frame.origin.y, 50, 15);
        [_searchBtnDown setTitle:@"下行" forState:UIControlStateNormal];
        [_searchBtnDown addTarget:self action:@selector(busPOIClick:) forControlEvents:UIControlEventTouchUpInside];
        _searchBtnDown.tag = 11;
        _searchBtnDown.titleLabel.font = [UIFont systemFontOfSize:13];
        [_searchBtnDown setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_searchBtnDown];
    }
    return self;
    
}
-(void)busPOIClick:(UIButton *)btn
{
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(searchBusClick:andCity:andBus:)]) {
        [self.delegate searchBusClick:btn andCity:self.cityTextF.text andBus:_busTextF.text];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
