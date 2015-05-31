//
//  NodeView.m
//  Graph
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "NodeView.h"
static NSUInteger NodeSize = 30;

@interface NodeView()

@property (nonatomic, weak) UILabel *urlLabel;
@property (nonatomic, strong) LineView *neighboursLineView;
@property (strong, nonatomic) CAShapeLayer *circle;

@end

@implementation NodeView

- (instancetype)initViewForNode:(NodeForURL*)node
{
    self = [super initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
    if (self) {
        [self initShape];
        self.node = node;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initShape];
    }
    return self;
}

- (void)initShape
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    self.circle = circle;
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, NodeSize, NodeSize)cornerRadius:NodeSize].CGPath;
    circle.masksToBounds = NO;
    circle.shadowOffset = CGSizeMake(-5, 10);
    circle.shadowRadius = 5;
    circle.shadowOpacity = 0.5;
    circle.position = CGPointMake(CGRectGetMidX(self.frame)-NodeSize/2,
                                  CGRectGetMidY(self.frame)-NodeSize/2);
    [self.layer addSublayer:circle];
}

- (void)upDateWithModel
{
    if (self.node.level < self.currentLevel) {
        self.alpha = 0;
    } else {
        if (self.node.countURLs > 0 && self.node.countURLs < 5) {
            self.circle.fillColor = [[UIColor redColor] CGColor];
        } else if (self.node.countURLs >= 5 && self.node.countURLs < 10) {
            self.circle.fillColor = [[UIColor yellowColor] CGColor];
        } else if (self.node.countURLs >=10 && self.node.countURLs < 20) {
            self.circle.fillColor = [[UIColor orangeColor] CGColor];
        } else if (self.node.countURLs >=20 && self.node.countURLs < 30) {
            self.circle.fillColor = [[UIColor purpleColor] CGColor];
        } else if (self.node.countURLs >=30 && self.node.countURLs < 50) {
            self.circle.fillColor = [[UIColor greenColor] CGColor];
        } else if (self.node.countURLs >=50 && self.node.countURLs <100) {
            self.circle.fillColor = [[UIColor blueColor] CGColor];
        } else if (self.node.countURLs >= 100 && self.node.countURLs <200) {
            self.circle.fillColor = [[UIColor magentaColor] CGColor];
        } else {
            self.circle.fillColor = [[UIColor cyanColor] CGColor];
        }
        self.alpha = 1.0/(self.node.level - self.currentLevel + 1.0);
    }
}

- (void)setNode:(NodeForURL *)node
{
    _node = node;
    [self upDateWithModel];
}

- (void)setCurrentLevel:(NSUInteger)currentLevel
{
    _currentLevel = currentLevel;
    [self upDateWithModel];
}

//- (void)drawRect:(CGRect)rect


@end
