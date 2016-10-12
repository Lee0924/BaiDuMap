//
//  ViewController.m
//  BaiDuMap
//
//  Created by 俊海贾 on 16/10/10.
//  Copyright © 2016年 aohuan. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import <BaiduMapAPI/BMKLocationService.h>//定位

/*
 BMKMapViewDelegate百度地图基本显示
 BMKLocationServiceDelegate 定位
 */
@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    BMKMapView* mapView;
    BMKLocationService *locServer;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-0)];
//    self.view = mapView;
    [self.view addSubview:mapView];
    
    /*定位需要注意的地方
     1.先初始化呢LocationServer
     2.写上delegate
     3.实现delegate下面
     */
    locServer = [[BMKLocationService alloc] init];
    locServer.delegate = self;
    
    
    
    UIButton *locationBtn = [[UIButton alloc] init];
    locationBtn.frame = CGRectMake(10, mapView.frame.size.height-30, 28, 28);
    [locationBtn addTarget:self action:@selector(locationCLick) forControlEvents:UIControlEventTouchUpInside];
    locationBtn.backgroundColor = [UIColor clearColor];
    [locationBtn setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:locationBtn];
    
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark LocationClick
-(void)locationCLick
{
    [locServer startUserLocationService];
    mapView.showsUserLocation = NO;
    /*
     这设置的是定位的状态，还有其他几种定位方式
     BMKUserTrackingModeFollowWithHeading //罗盘状态
     BMKUserTrackingModeFollow  //跟随状态
     BMKUserTrackingModeNone //普通状态
     */
    mapView.userTrackingMode = BMKUserTrackingModeNone;
    mapView.showsUserLocation = YES;
}
#pragma mark-------------------------------------------- 定位 -------------------------------------------------------------------
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"开始定位");
}
/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"停止定为");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败");
}
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [mapView updateLocationData:userLocation];
    //    NSLog(@"位置在  %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
//    [self getCity:userLocation.location];
    [mapView updateLocationData:userLocation];
}
-(void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
     locServer.delegate = self;//定位
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
     locServer.delegate = self;//定位
    mapView.delegate = nil; // 不用时，置nil
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
