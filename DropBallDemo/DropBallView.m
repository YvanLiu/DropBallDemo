//
//  DropBallView.m
//  DropBallDemo
//
//  Created by 柳玉峰 on 2017/4/7.
//  Copyright © 2017年 柳玉峰. All rights reserved.
//

#import "DropBallView.h"
#import <CoreMotion/CoreMotion.h>

@interface DropBallView ()

@property (strong, nonatomic) UIImageView *bottleView;              // 瓶身
@property (strong, nonatomic) UIImageView *bottleCapView;           // 瓶盖
@property (strong, nonatomic) UIView      *bottleView_t;            // 真正的瓶身
@property (strong, nonatomic) UIGravityBehavior     *gravity;       // 重力感应
@property (strong, nonatomic) UICollisionBehavior   *collision;     // 碰撞行为
@property (strong, nonatomic) UIDynamicItemBehavior *dynamic;       // 动态行为
@property (strong, nonatomic) UIDynamicAnimator     *animator;
@property (strong, nonatomic) CMMotionManager *motion;

@property (assign, nonatomic) NSInteger width;                      // 宽
@property (assign, nonatomic) NSInteger height;                     // 高


@end

@implementation DropBallView

static float bindH = 0.40f; // 瓶盖高度和DropBallView高度的比例
static float bindW = 0.54f; // 瓶盖的宽高比

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.width  = frame.size.width;
        self.height = frame.size.height;
        
        // 瓶盖
        self.bottleCapView = [[UIImageView alloc]init];
        self.bottleCapView.frame = CGRectMake(0, 0, self.height*bindH*bindW, self.height*bindH);
        self.bottleCapView.image = [UIImage imageNamed:@"bottleCap"];
        [self addSubview:self.bottleCapView];
        // 瓶盖是斜口的，但效果是先打开瓶子再掉入小球，所以要先把瓶子盖上
        CGAffineTransform endAngle = CGAffineTransformMakeRotation(M_PI/3.05);  // 角度是一点点试的
        self.bottleCapView.layer.anchorPoint = CGPointMake(0.4,1);// 围绕点
        self.bottleCapView.layer.position = CGPointMake(10, self.width+0.5);// 位置
        self.bottleCapView.transform = endAngle;
        
        // 瓶身
        self.bottleView = [[UIImageView alloc]init];
        self.bottleView.frame = CGRectMake(0, self.height*bindH-10, self.width, self.height - self.height*bindH+10);
        self.bottleView.image = [UIImage imageNamed:@"bottle"];
        [self addSubview:self.bottleView];
        
        // 瓶子的图前面有一块阴影，掉入豆子的时候不能掉到阴影外面，所以加一个正确的瓶身的View
        // 去掉透明部分真横的瓶身
        self.bottleView_t = [[UIView alloc]init];
        self.bottleView_t.frame = CGRectMake(self.bottleView.frame.size.width/8+5, 20,self.bottleView.frame.size.width-self.bottleView.frame.size.width/8-5 , self.bottleView.frame.size.height-20);
        [self.bottleView addSubview:self.bottleView_t];
        // 添加重力感应
        self.gravity   = [[UIGravityBehavior alloc]init];
        // 调价碰撞行为
        self.collision = [[UICollisionBehavior alloc]init];
        // 添加动态行为
        self.dynamic   = [[UIDynamicItemBehavior alloc]init];
        self.animator  = [[UIDynamicAnimator alloc]initWithReferenceView:self.bottleView_t];
        self.collision.translatesReferenceBoundsIntoBoundary = YES;
        self.dynamic.elasticity = 0.5;
        self.dynamic.allowsRotation = YES;

        [self.animator addBehavior:self.gravity];
        [self.animator addBehavior:self.collision];
        [self.animator addBehavior:self.dynamic];
        
        // 打开瓶盖
        [self openBottleCap];
    }
    return self;
}

#pragma mark - 打开瓶盖

- (void)openBottleCap {
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(0);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.bottleCapView.layer.anchorPoint = CGPointMake(1,1);//围绕点
        self.bottleCapView.layer.position = CGPointMake(self.height*bindH*bindW, self.height*bindH);//位置
        self.bottleCapView.transform = endAngle;
        
    } completion:^(BOOL finished) {
        [self dropBeans];
    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
}

#pragma mark - 掉入豆子

- (void)dropBeans {
    [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSInteger width_t = self.bottleView_t.frame.size.width;
        // 给豆子一个随机的掉入角度
        UIImageView *beanView =[[UIImageView alloc] initWithFrame:CGRectMake(5 + arc4random()%(width_t-width_t/5-10),0, self.bottleView_t.frame.size.width/5-2,self.bottleView_t.frame.size.width/5-2)];
        beanView.image = [UIImage imageNamed:@"bean"];
        [self.bottleView_t addSubview:beanView];
        
        [self.gravity addItem:beanView]; //加重力
        [self.collision addItem:beanView]; //加边界
        [self.dynamic addItem:beanView]; //加弹性
        
        if (self.bottleView_t.subviews.count>20) {
            [timer invalidate];
            [self closeBottleCap];
        }
    }];
    
}

#pragma mark - 关闭瓶盖

- (void)closeBottleCap {
    
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(M_PI/3.05);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.bottleCapView.layer.anchorPoint = CGPointMake(0.4,1);//围绕点
        self.bottleCapView.layer.position = CGPointMake(10, self.width+0.5);//位置
        self.bottleCapView.transform = endAngle;
    } completion:^(BOOL finished) {
        
        // 给豆子加入重力效果
        self.motion=[[CMMotionManager alloc] init];
        [self.motion startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            self.gravity.gravityDirection=CGVectorMake(accelerometerData.acceleration.x, -accelerometerData.acceleration.y);
            
        }];
    }];
   
    
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
