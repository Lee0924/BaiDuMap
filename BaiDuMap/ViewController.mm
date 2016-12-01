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
#import "UIImage+Rotate.h"

#import "BaiDuView.h"


//屏幕的高度
#define HeightScreen [UIScreen mainScreen].bounds.size.height
//屏幕的宽度
#define WidthScreen [UIScreen mainScreen].bounds.size.width

//图片路径
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

/*
 BMKMapViewDelegate百度地图基本显示
 BMKLocationServiceDelegate 定位
 */
@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKBusLineSearchDelegate,BMKPoiSearchDelegate,BaiDuViewDelegate>
{
    BaiDuView *baiduV;
    UIView *grayView;//灰色蒙层
    UIButton *btn;
    
    BMKMapView* mapView;
    BMKLocationService *locServer;
    
    BMKPoiSearch* poisearch;
    BMKBusLineSearch* buslinesearch;
    
    UILabel *myLocationLab;
    
    int currentIndex;
    NSMutableArray* _busPoiArray;//站点
    NSString *cityS;//城市
    NSString *busS;//公交
    
}
@end
@interface BusLineAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘
    int _degree;
}
@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation BusLineAnnotation
@synthesize type = _type;
@synthesize degree = _degree;
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
    
    
    /*定位按钮*/
    UIButton *locationBtn = [[UIButton alloc] init];
    locationBtn.frame = CGRectMake(10, mapView.frame.size.height-30, 28, 28);
    [locationBtn addTarget:self action:@selector(locationCLick) forControlEvents:UIControlEventTouchUpInside];
    locationBtn.backgroundColor = [UIColor clearColor];
    [locationBtn setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    [self.view addSubview:locationBtn];
    
    /*显示我所在的地理位置信息*/
    myLocationLab = [[UILabel alloc] init];
    myLocationLab.frame = CGRectMake(0, 40, self.view.bounds.size.width, 20);
    myLocationLab.font = [UIFont systemFontOfSize:14];
    myLocationLab.backgroundColor = [UIColor clearColor];
    myLocationLab.textColor = [UIColor blackColor];
    myLocationLab.alpha = 0.8;
    [self.view addSubview:myLocationLab];
    
    //比例尺位置
    mapView.mapScaleBarPosition = CGPointMake(10, HeightScreen - 30);
    mapView.showMapScaleBar = YES;//比例尺
    
    
    /**POI检索-公交搜索*/
    poisearch = [[BMKPoiSearch alloc]init];
    poisearch.delegate = self;
    
    buslinesearch = [[BMKBusLineSearch alloc]init];
    buslinesearch.delegate = self;
    currentIndex = -1;
    _busPoiArray = [[NSMutableArray alloc]init];
    
    btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(WidthScreen-50, HeightScreen-50, 40, 40);
    [btn setImage:[UIImage imageNamed:@"jfsc_jfdd"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WidthScreen, HeightScreen)];
    grayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    grayView.hidden = YES;
    grayView.userInteractionEnabled = YES;
    [self.view addSubview:grayView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenView)];
    [grayView addGestureRecognizer:tap];
    /**隐藏的VIWE*/
    baiduV = [[BaiDuView alloc] init];
    baiduV.delegate = self;
    baiduV.frame = CGRectMake(0, -200, WidthScreen, 200);
    baiduV.backgroundColor = [UIColor whiteColor];
    //    baiduV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:baiduV];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark 显示隐藏是View
-(void)showView
{
    grayView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        baiduV.frame = CGRectMake(0, 0, WidthScreen, 200);
    }];
}
#pragma mark 隐藏view
-(void)hiddenView
{
    [UIView animateWithDuration:0.5 animations:^{
        baiduV.frame = CGRectMake(0, -200, WidthScreen, 200);
    }];
    grayView.hidden = YES;
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
    mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
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
    [self getCity:userLocation.location];
    [mapView updateLocationData:userLocation];
}

//获取当前城市
- (void)getCity:(CLLocation*)location{
    
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark * placemark = [placemarks objectAtIndex:0];
        if (placemark.subLocality != nil) {
            
            NSString * mapCityName = placemark.locality;//城市
            NSString * mapAreaName = placemark.subLocality;//区
            NSString * mapThoroughfare = placemark.thoroughfare;//街道
            NSString *mapCity=[NSString stringWithFormat:@"%@-%@-%@",mapCityName,mapAreaName,mapThoroughfare];
//            NSLog(@"%@--%@--%@",mapCityName,mapAreaName,mapThoroughfare);
            myLocationLab.text = mapCity;

        }
    }];
}
#pragma mark 公交搜索----------------------------------------
-(void)searchBusClick:(UIButton *)btn andCity:(NSString *)cityStr andBus:(NSString *)busStr
{
    cityS = cityStr;
    busS = busStr;
//    [locServer stopUserLocationService];//关闭定位
   
    if (btn.tag == 10) {
        [_busPoiArray removeAllObjects];//-------------------！！！！！这里数组一定要移除掉，不然再次查询别的公交路线的时候无法找到
        BMKCitySearchOption *city = [[BMKCitySearchOption alloc] init];
        city.pageCapacity = 10;
        city.pageIndex = 0;
        city.city= cityS;
        city.keyword = busS;
        NSLog(@"111城市---%@--%@公交",cityS,busS);
        BOOL flag = [poisearch poiSearchInCity:city];
        if(flag)
        {
            NSLog(@"城市内检索发送成功");
        }
        else
        {
            NSLog(@"城市内检索发送失败");
        }
    }
    else if (btn.tag == 11)
    {
        
        
        if (_busPoiArray.count > 0) {
            if (++currentIndex >= _busPoiArray.count) {
                currentIndex -= _busPoiArray.count;
            }
            NSString* strKey = ((BMKPoiInfo*) [_busPoiArray objectAtIndex:currentIndex]).uid;
            BMKBusLineSearchOption *buslineSearchOption = [[BMKBusLineSearchOption alloc]init];
            buslineSearchOption.city= cityS;
            buslineSearchOption.busLineUid= strKey;
            
            BOOL flag = [buslinesearch busLineSearch:buslineSearchOption];
            if(flag)
            {
                NSLog(@"busline检索发送成功");
            }
            else
            {
                NSLog(@"busline检索发送失败");
            }
        }
        else {
            BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
            citySearchOption.pageIndex = 0;
            citySearchOption.pageCapacity = 10;
            citySearchOption.city= cityS;
            citySearchOption.keyword = busS;
            
            NSLog(@"111城市---%@--%@公交",cityS,busS);
            BOOL flag = [poisearch poiSearchInCity:citySearchOption];
            if(flag)
            {
                NSLog(@"城市内检索发送成功");
            }
            else
            {
                NSLog(@"城市内检索发送失败");
            }
            
        }
        
    }
}
#pragma mark implement BMKSearchDelegate---2
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKPoiInfo* poi = nil;
        BOOL findBusline = NO;
        for (int i = 0; i < result.poiInfoList.count; i++) {
            poi = [result.poiInfoList objectAtIndex:i];
            if (poi.epoitype == 2 || poi.epoitype == 4) {///POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路
                findBusline = YES;
                [_busPoiArray addObject:poi];
            }
        }
        //开始bueline详情搜索
        if(findBusline)
        {
            currentIndex = 0;
            NSString* strKey = ((BMKPoiInfo*) [_busPoiArray objectAtIndex:currentIndex]).uid;
            BMKBusLineSearchOption *buslineSearchOption = [[BMKBusLineSearchOption alloc]init];
            buslineSearchOption.city= cityS;
            buslineSearchOption.busLineUid= strKey;
            BOOL flag = [buslinesearch busLineSearch:buslineSearchOption];
            if(flag)
            {
                NSLog(@"busline检索发送成功");
            }
            else
            {
                NSLog(@"busline检索发送失败");
            }
            
        }
    }
    else
    {
        NSLog(@"错误=======%u",error);
    }
//     [_busPoiArray removeAllObjects];
}

#pragma mark ---3
- (void)onGetBusDetailResult:(BMKBusLineSearch*)searcher result:(BMKBusLineResult*)busLineResult errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSArray* array = [NSArray arrayWithArray:mapView.annotations];
        [mapView removeAnnotations:array];
        array = [NSArray arrayWithArray:mapView.overlays];
        [mapView removeOverlays:array];
        if (error == BMK_SEARCH_NO_ERROR) {
            
            BusLineAnnotation* item = [[BusLineAnnotation alloc]init];
            
            //站点信息
            int size = 0;
            size = busLineResult.busStations.count;
            for (int j = 0; j < size; j++) {
                BMKBusStation* station = [busLineResult.busStations objectAtIndex:j];
                item = [[BusLineAnnotation alloc]init];
                item.coordinate = station.location;
                item.title = station.title;
                item.type = 2;
                [mapView addAnnotation:item];
            }
            
            
            //路段信息
            int index = 0;
            //累加index为下面声明数组temppoints时用
            for (int j = 0; j < busLineResult.busSteps.count; j++) {
                BMKBusStep* step = [busLineResult.busSteps objectAtIndex:j];
                index += step.pointsCount;
            }
            //直角坐标划线
            
            BMKMapPoint * temppoints = new BMKMapPoint[index];
            int k=0;
            for (int i = 0; i < busLineResult.busSteps.count; i++) {
                BMKBusStep* step = [busLineResult.busSteps objectAtIndex:i];
                for (int j = 0; j < step.pointsCount; j++) {
                    BMKMapPoint pointarray;
                    pointarray.x = step.points[j].x;
                    pointarray.y = step.points[j].y;
                    temppoints[k] = pointarray;
                    k++;
                }
            }
            
            
            BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:index];
            [mapView addOverlay:polyLine];
            delete[] temppoints;
            
            BMKBusStation* start = [busLineResult.busStations objectAtIndex:0];
            [mapView setCenterCoordinate:start.location animated:YES];
            
        }
    }
    else {
        NSLog(@"抱歉，未找到结果===%u",error);
    }
}
#pragma mark -----4---设置路线颜色
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

#pragma mark imeplement BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BusLineAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(BusLineAnnotation*)annotation];
    }
    return nil;
}


- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(BusLineAnnotation*)routeAnnotation
{
    //这里是设置的图片
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        default:
            break;
    }
    
    return view;
}
#pragma mark 站点图片
/*
 这里的图片路径必须一样  不然公交路线站点图片不会显示
 */
- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
    locServer.delegate = self;//定位
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    buslinesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
    locServer.delegate = self;//定位
    mapView.delegate = nil; // 不用时，置nil
    buslinesearch.delegate = nil;//
}


- (void)dealloc {
    if (poisearch != nil) {
        poisearch = nil;
    }
    if (buslinesearch!= nil) {
        buslinesearch = nil;
    }
    
    if (mapView) {
        mapView = nil;
    }
    if (_busPoiArray) {
        _busPoiArray = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
