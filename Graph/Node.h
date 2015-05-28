//
//  Node.h
//  Graph
//
//  Created by Inna Labuns'ka on 28.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Node <NSObject>

@property (strong, nonatomic, readonly) NSMutableSet *edges;
- (void)addEdgeToNode:(id<Node>)node;
- (void)removeEdgeToNode:(id<Node>)node;
- (void)removeAllEdges;

@end
