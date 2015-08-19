//
//  SXMainViewController.m
//  85 - 网易滑动分页
//
//  Created by 董 尚先 on 15-1-31.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXMainViewController.h"
#import "SXTableViewController.h"
#import "SXWeatherView.h"
#import "SXWeatherDetailVC.h"
#import "SXTitleLable.h"
#import "UIView+Frame.h"
#import "SXHTTPManager.h"
#import "SXWeatherModel.h"
#import "MJExtension.h"

@interface SXMainViewController ()<UIScrollViewDelegate>

/** 标题栏 */
@property (weak, nonatomic) IBOutlet UIScrollView *smallScrollView;

/** 下面的内容栏 */
@property (weak, nonatomic) IBOutlet UIScrollView *bigScrollView;
@property(nonatomic,strong) SXTitleLable *oldTitleLable;
@property (nonatomic,assign) CGFloat beginOffsetX;

/** 新闻接口的数组 */
@property(nonatomic,strong) NSArray *arrayLists;
@property(nonatomic,assign,getter=isWeatherShow)BOOL weatherShow;
@property(nonatomic,strong)SXWeatherView *weatherView;
@property(nonatomic,strong)UIImageView *tran;
@property(nonatomic,strong)SXWeatherModel *weatherModel;

@property(nonatomic,strong)UIButton *rightItem;

@end

@implementation SXMainViewController

#pragma mark - ******************** 懒加载
- (NSArray *)arrayLists
{
    if (_arrayLists == nil) {
        _arrayLists = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NewsURLs.plist" ofType:nil]];
    }
    return _arrayLists;
}

#pragma mark - ******************** 页面首次加载
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.bigScrollView.delegate = self;
    
    [self addController];
    [self addLable];
    
    CGFloat contentX = self.childViewControllers.count * [UIScreen mainScreen].bounds.size.width;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.bigScrollView.bounds;
    [self.bigScrollView addSubview:vc.view];
    SXTitleLable *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    
   
    UIButton *rightItem = [[UIButton alloc]init];
    self.rightItem = rightItem;
    UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
    [win addSubview:rightItem];
    rightItem.y = 30;
    rightItem.width = 20;
    rightItem.height = 20;
    [rightItem addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    rightItem.x = [UIScreen mainScreen].bounds.size.width - rightItem.width - 15;
    NSLog(@"%@",NSStringFromCGRect(rightItem.frame));
    [rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
    
    [self sendWeatherRequest];
}

- (void)rightItemClick{

    if (self.isWeatherShow) {
        

        self.weatherView.hidden = YES;
        self.tran.hidden = YES;
        [UIView animateWithDuration:0.1 animations:^{
            self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, M_1_PI * 5);
            
        } completion:^(BOOL finished) {
            [self.rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
        }];
    }else{
        
        [self.rightItem setImage:[UIImage imageNamed:@"223"] forState:UIControlStateNormal];
        self.weatherView.hidden = NO;
        self.tran.hidden = NO;
        [self.weatherView addAnimate];
        [UIView animateWithDuration:0.2 animations:^{
            self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, -M_1_PI * 6);
            
        } completion:^(BOOL finished) {

            [UIView animateWithDuration:0.1 animations:^{
                self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, M_1_PI );
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    self.weatherShow = !self.isWeatherShow;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.rightItem.hidden = NO;
    self.rightItem.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.rightItem.alpha = 1;
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - ******************** 添加方法

/** 添加子控制器 */
- (void)addController
{
    SXTableViewController *vc1 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc1.title = @"头条";
    vc1.urlString = self.arrayLists[0][@"urlString"];
    [self addChildViewController:vc1];
    SXTableViewController *vc2 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc2.title = @"NBA";
    vc2.urlString = self.arrayLists[1][@"urlString"];
    [self addChildViewController:vc2];
    SXTableViewController *vc3 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc3.title = @"手机";
    vc3.urlString = self.arrayLists[2][@"urlString"];
    [self addChildViewController:vc3];
    SXTableViewController *vc4 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc4.title = @"移动互联";
    vc4.urlString = self.arrayLists[3][@"urlString"];
    [self addChildViewController:vc4];
    SXTableViewController *vc8 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc8.title = @"娱乐";
    vc8.urlString = self.arrayLists[4][@"urlString"];
    [self addChildViewController:vc8];
    SXTableViewController *vc5 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc5.title = @"时尚";
    vc5.urlString = self.arrayLists[5][@"urlString"];
    [self addChildViewController:vc5];
    SXTableViewController *vc6 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc6.title = @"电影";
    vc6.urlString = self.arrayLists[6][@"urlString"];
    [self addChildViewController:vc6];
    SXTableViewController *vc7 = [[UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc7.title = @"科技";
    vc7.urlString = self.arrayLists[7][@"urlString"];
    [self addChildViewController:vc7];
}

/** 添加标题栏 */
- (void)addLable
{
    for (int i = 0; i < 8; i++) {
        CGFloat lblW = 70;
        CGFloat lblH = 40;
        CGFloat lblY = 0;
        CGFloat lblX = i * lblW;
        SXTitleLable *lbl1 = [[SXTitleLable alloc]init];
        UIViewController *vc = self.childViewControllers[i];
        lbl1.text =vc.title;
        lbl1.frame = CGRectMake(lblX, lblY, lblW, lblH);
        lbl1.font = [UIFont fontWithName:@"HYQiHei" size:19];
        [self.smallScrollView addSubview:lbl1];
        lbl1.tag = i;
        lbl1.userInteractionEnabled = YES;
        
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
    }
    self.smallScrollView.contentSize = CGSizeMake(70 * 8, 0);
    
}

/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
    SXTitleLable *titlelable = (SXTitleLable *)recognizer.view;
    
    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
   
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    [self.bigScrollView setContentOffset:offset animated:YES];
    
    
}

#pragma mark - ******************** scrollView代理方法

/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    
    // 滚动标题栏
    SXTitleLable *titleLable = (SXTitleLable *)self.smallScrollView.subviews[index];
    
    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
    
    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }
    
    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    SXTableViewController *newsVc = self.childViewControllers[index];
    newsVc.index = index;
    
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            SXTitleLable *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.0;
        }
    }];
    
    if (newsVc.view.superview) return;
    
    newsVc.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:newsVc.view];
}

/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    SXTitleLable *labelLeft = self.smallScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.smallScrollView.subviews.count) {
        SXTitleLable *labelRight = self.smallScrollView.subviews[rightIndex];
        labelRight.scale = scaleRight;
    }
    
}

- (void)addWeather{
    SXWeatherView *weatherView = [SXWeatherView view];
    weatherView.weatherModel = self.weatherModel;
    self.weatherView = weatherView;
    weatherView.alpha = 0.9;
    UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
    [win addSubview:weatherView];
    
    UIImageView *tran = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"224"]];
    self.tran = tran;
    tran.width = 7;
    tran.height = 7;
    tran.y = 57;
    tran.x = [UIScreen mainScreen].bounds.size.width - 33;
    [win addSubview:tran];
    
    weatherView.frame = [UIScreen mainScreen].bounds;
    weatherView.y = 64;
    weatherView.height -= 64;
    self.weatherView.hidden = YES;
    self.tran.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushWeatherDetail) name:@"pushWeatherDetail" object:nil];
}

- (void)sendWeatherRequest
{
    NSString *url = @"http://c.3g.163.com/nc/weather/5YyX5LqsfOWMl%2BS6rA%3D%3D.html";
    [[SXHTTPManager manager]GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
       SXWeatherModel *weatherModel = [SXWeatherModel objectWithKeyValues:responseObject];
        self.weatherModel = weatherModel;
        [self addWeather];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure %@",error);
    }];
}


- (IBAction)rightItemClick:(UIBarButtonItem *)sender {
    if (self.isWeatherShow) {
        self.weatherView.hidden = YES;
    }else{

        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"223.png"];
        
        
        self.weatherView.hidden = NO;
        [self.weatherView addAnimate];
    }
    self.weatherShow = !self.isWeatherShow;
}

- (void)pushWeatherDetail
{
    self.weatherShow = NO;
    self.rightItem.hidden = YES;
    self.rightItem.transform = CGAffineTransformIdentity;
    [self.rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
    SXWeatherDetailVC *wdvc = [[SXWeatherDetailVC alloc]init];
    wdvc.weatherModel = self.weatherModel;
    [self.navigationController pushViewController:wdvc animated:YES];
    [UIView animateWithDuration:0.1 animations:^{
        self.weatherView.alpha = 0;
    } completion:^(BOOL finished) {
        self.weatherView.alpha = 0.9;
        self.weatherView.hidden = YES;
        self.tran.hidden = YES;
    }];
}

@end
