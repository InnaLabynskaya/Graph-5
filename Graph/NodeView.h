//
//  NodeView.h
//  Graph
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeForURL.h"
#import "LineView.h"

@interface NodeView : UIView

@property (nonatomic, strong) NodeForURL *node;
@property (nonatomic) NSUInteger currentLevel;

- (instancetype)initViewForNode:(NodeForURL*)node;
- (void)upDateWithModel;

@end
