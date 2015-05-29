//
//  NodeView.m
//  Graph
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "NodeView.h"

@interface NodeView()

@property (nonatomic, weak) UILabel *urlLabel;
@property (nonatomic, strong) LineView *neighboursLineView;

@end

@implementation NodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
