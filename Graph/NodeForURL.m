//
//  Node.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "NodeForURL.h"

@interface NodeForURL () 

@property (strong, nonatomic, readwrite) NSString *url;
@property (strong, nonatomic, readwrite) NSMutableSet *edges;
@property (nonatomic, readwrite) NSUInteger level;
@end

@implementation NodeForURL

- (instancetype)initWithUrl:(NSString*)url andLevel:(NSUInteger)level
{
    self = [super init];
    if (self) {
        self.wasParsed = NO;
        self.url = url;
        self.edges = [NSMutableSet set];
        self.countURLs = 1;
        self.level = level;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithUrl:nil andLevel:0];
}

- (void)addEdgeToNode:(NodeForURL *)node
{
    [self.edges addObject:node.url];
    node.countURLs++;
}

- (void)removeEdgeToNode:(NodeForURL *)node
{
    [self.edges removeObject:node.url];
}

- (void)removeAllEdges
{
    [self.edges removeAllObjects];
}

@end
