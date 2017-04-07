//
//  ViewController.m
//  DropBallDemo
//
//  Created by 柳玉峰 on 2017/4/7.
//  Copyright © 2017年 柳玉峰. All rights reserved.
//

#import "ViewController.h"
#import "DropBallView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BLACK_COLOR;
    
    DropBallView *dropView = [[DropBallView alloc]initWithFrame:CGRectMake(0, 0, 250*0.43, 250)];
    dropView.center = self.view.center;
    [self.view addSubview:dropView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
