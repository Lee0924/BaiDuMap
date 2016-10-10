//
//  ViewController.m
//  BaiDuMap
//
//  Created by 俊海贾 on 16/10/10.
//  Copyright © 2016年 aohuan. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI/BMapKit.h>
@interface ViewController ()<BMKMapViewDelegate>
{
    BMKMapView* mapView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.view = mapView;
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
