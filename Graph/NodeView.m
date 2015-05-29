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

@end

@implementation NodeView

- (instancetype)initViewForNode:(NodeForURL*)node
{
    self = [super initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
    if (self) {
        self.node = node;
        CAShapeLayer *circle = [CAShapeLayer layer];
        
        circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, NodeSize, NodeSize)cornerRadius:NodeSize].CGPath;
        circle.masksToBounds = NO;
        circle.shadowOffset = CGSizeMake(-5, 10);
        circle.shadowRadius = 5;
        circle.shadowOpacity = 0.5;
        circle.position = CGPointMake(CGRectGetMidX(self.frame)-NodeSize/2,
                                      CGRectGetMidY(self.frame)-NodeSize/2);
        if (node.countURLs > 0 && node.countURLs < 5) {
            circle.fillColor = [[UIColor redColor] CGColor];
        } else if (node.countURLs >= 5 && node.countURLs < 10) {
            circle.fillColor = [[UIColor yellowColor] CGColor];
        } else if (node.countURLs >=10 && node.countURLs < 20) {
            circle.fillColor = [[UIColor orangeColor] CGColor];
        } else if (node.countURLs >=20 && node.countURLs < 30) {
            circle.fillColor = [[UIColor purpleColor] CGColor];
        } else if (node.countURLs >=30 && node.countURLs < 50) {
            circle.fillColor = [[UIColor greenColor] CGColor];
        } else if (node.countURLs >=50 && node.countURLs <100) {
            circle.fillColor = [[UIColor blueColor] CGColor];
        } else if (node.countURLs >= 100 && node.countURLs <200) {
            circle.fillColor = [[UIColor magentaColor] CGColor];
        } else {
            circle.fillColor = [[UIColor cyanColor] CGColor];
        }
        [self.layer addSublayer:circle];
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.urlLabel = label;
    [self.urlLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.urlLabel];
}

- (void)setNode:(NodeForURL *)node
{
    _node = node;
    self.urlLabel.text = [@(node.countURLs) stringValue];//node.url;
}

//- (void)drawRect:(CGRect)rect


@end
