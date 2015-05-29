//
//  Graph.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "Graph.h"
#import "TFHpple.h"

@interface Graph()

@property (strong, nonatomic, readwrite) NSMutableDictionary *nodes;
@property (nonatomic, strong, readwrite) NSString *rootUrl;
@property (nonatomic, strong, readwrite) NodeForURL *rootNode;

@end

@implementation Graph

- (instancetype)initGraphWithRootLink:(NSString*)rootUrl;
{
    self = [super init];
    if (self) {
        self.nodes = [NSMutableDictionary dictionary];
        NSURL *url = [NSURL URLWithString:rootUrl];
        self.rootUrl = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
        self.rootNode = [[NodeForURL alloc] initWithUrl:@"/"];
        [self addNode:self.rootNode];
    }
    return self;
}

- (instancetype)init
{
    return [self initGraphWithRootLink:nil];
}

- (void)addNode:(NodeForURL *)node
{
    if (node && node.url) {
        [self.nodes setObject:node forKey:node.url];
    }
}

- (NodeForURL*)nodeForUrl:(NSString*)url
{
    return [self.nodes objectForKey:url];
}

- (void)breadthFirstSearchFromNode:(NodeForURL*)node handler:(void(^)(NodeForURL* node))handler
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSLog(@"Breath-first-search STARTS");
    NSMutableSet *visitedNodes = [NSMutableSet set];
    NSMutableArray *queue = [NSMutableArray arrayWithObject:node];
  
    while (queue.count > 0) {
        NodeForURL *currentNode = queue.firstObject;
        
        [self parseNode:currentNode];
       dispatch_async(dispatch_get_main_queue(), ^{
           handler(node);
       });
        [visitedNodes addObject:currentNode];
        [queue removeObject:currentNode];
        for (NSString *nodeUrl in currentNode.edges) {
            NodeForURL *newNode = [self nodeForUrl:nodeUrl];
            if (newNode && ![visitedNodes containsObject:newNode] && ![queue containsObject:newNode]) {
                [queue addObject:newNode];
            } 
        }
    }
    });
}

- (void)parseNode:(NodeForURL *)node
{
    if (node.wasParsed) {
        return;
    }
    NSLog(@"%@", node.url);
    NSString *fullUrl = [self.rootUrl stringByAppendingString:node.url];
    NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:fullUrl]];
    if (dataFromURL) {
        TFHpple *parser = [TFHpple hppleWithHTMLData:dataFromURL];
        
        NSString *XpathQueryString = @"//a[@href and starts-with(@href, \"/\") = 1]";
        NSArray *nodesFromUrl = [parser searchWithXPathQuery:XpathQueryString];
        for (TFHppleElement *element in nodesFromUrl) {
            NSString *url = [element objectForKey:@"href"];
            NSRange range;
            range = [url rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                url = [url substringToIndex:range.location];
            }
            range = [url rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                url = [url substringToIndex:range.location];
            }
            url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NodeForURL *nextNode = [self nodeForUrl:url];
            if (!nextNode) {
                nextNode = [[NodeForURL alloc] initWithUrl:url];
            }
            [self addNode:nextNode];
            [node addEdgeToNode:nextNode];
        }
        node.wasParsed = YES;
    }
}

@end
