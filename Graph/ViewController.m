//
//  ViewController.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "ViewController.h"
#import "NodeView.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

static NSUInteger const NodeSize = 30;
static NSUInteger const NodeDistance = 5;

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Graph *graph;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) NSUInteger gestureCount;
@property (nonatomic) BOOL buildInProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gestureCount = 0;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNodesView];
}

- (void)updateNodesView
{
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    Node *rootNode = self.graph.rootNode;
    
    NSArray *firstGeneration = [self.graph firstGenerationFromNode:rootNode];
    NSMutableArray *secondGenerationMutableArray = [NSMutableArray array];
    NSArray *secondGenerationFiltered = [NSArray array];
    
    if (!firstGeneration.count) {
        [self.containerView setFrame:self.view.frame];
        [self.scrollView setContentSize:self.view.frame.size];
        NodeView *rootNodeView = [[NodeView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, NodeSize, NodeSize)];
        rootNodeView.node = rootNode;
        rootNodeView.layer.cornerRadius = rootNodeView.bounds.size.width/2;
        rootNodeView.layer.masksToBounds = YES;
        [self.containerView addSubview:rootNodeView];
    } else {
        NSInteger FirstCircleCount = 20;
        const float DeltaRaius = 40;
        float firstCircleRadius = [self circleRadiusForNodeCount:FirstCircleCount];
        
        NSInteger nodesCount = firstGeneration.count;
        NSInteger workNodesCount = nodesCount - FirstCircleCount;
        float workRadius = firstCircleRadius;
        NSUInteger circles = 1;
        while (workNodesCount > 0) {
            workRadius += DeltaRaius;
            workNodesCount -= [self nodesCountForRadius:workRadius];
            circles ++;
        }
        
        double dAlpha = 2 * M_PI / nodesCount;
        double alpha = 0;
        NSUInteger xCenter = workRadius + NodeSize/2;
        NSUInteger yCenter = workRadius + NodeSize/2;
        
        [self.containerView setFrame:CGRectMake(0, 0, 10*workRadius + NodeSize, 10*workRadius + NodeSize)];
        [self.scrollView setContentSize:CGSizeMake(10*workRadius + NodeSize, 10*workRadius + NodeSize)];
        NodeView *nodeViewFirst = [[NodeView alloc] initWithFrame:CGRectMake(xCenter, yCenter, NodeSize, NodeSize)];
        nodeViewFirst.node = rootNode;
        nodeViewFirst.layer.cornerRadius = nodeViewFirst.bounds.size.width/2;
        nodeViewFirst.layer.masksToBounds = YES;
        [self.containerView addSubview:nodeViewFirst];
        
        NSUInteger circleIndex = 0;
        for (Node *node in firstGeneration) {
            float r = (firstCircleRadius + DeltaRaius * circleIndex);
            int x = xCenter + r * cos(alpha);
            int y = yCenter + r * sin(alpha);
            alpha += dAlpha;
            circleIndex = (circleIndex + 1) % circles;
            NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(x, y, 0.8 * NodeSize, 0.8 * NodeSize)];
            nodeView.node = node;
            nodeView.layer.cornerRadius = nodeView.bounds.size.width/2;
            nodeView.layer.masksToBounds = YES;
            NSArray *secondGeneration = [self.graph firstGenerationFromNode:node];
            
            nodeView.alpha = 0.8;
            CALayer *shadowLayer = nodeView.layer;
            shadowLayer.shadowOffset = CGSizeMake(1, 1);
            shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
            shadowLayer.shadowRadius = 4.0f;
            shadowLayer.shadowOpacity = 0.80f;
            shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowLayer.bounds] CGPath];
            UITapGestureRecognizer *nodeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapNodeView:)];
            [nodeView addGestureRecognizer:nodeFingerTap];
            [self.containerView addSubview:nodeView];
            //            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(xCenter-r + NodeSize/2, yCenter + NodeSize/2, r, 1)];
//            lineView.backgroundColor = [UIColor blackColor];
//            lineView.transform = CGAffineTransformMakeRotation(0 + alpha);
//            [self.containerView addSubview:lineView];
            [secondGenerationMutableArray addObjectsFromArray:secondGeneration];
            NSMutableSet *visited = [NSMutableSet setWithObject:nodeView.node.url];
            secondGenerationFiltered = [secondGenerationMutableArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.url in %@)", visited]];

            }
       
        }
    
    NSInteger thirdCircleCount = 100;
    const float DeltaRaius = 40;
    float thirdCircleRadius = [self circleRadiusForNodeCount:thirdCircleCount];
    
    NSInteger nodesCount = secondGenerationFiltered.count;
    NSInteger workNodesCount = nodesCount - thirdCircleCount;
    float workRadius = thirdCircleRadius;
    NSUInteger circles = 1;
    while (workNodesCount > 0) {
        workRadius += DeltaRaius;
        workNodesCount -= [self nodesCountForRadius:workRadius];
        circles ++;
    }
    
    double dAlpha = 2 * M_PI / nodesCount;
    double alpha = 0;
    NSUInteger xCenter = workRadius + NodeSize/2;
    NSUInteger yCenter = workRadius + NodeSize/2;
    NSUInteger circleIndex = 0;

        for (Node *secondGener in secondGenerationFiltered) {
        float r = (thirdCircleRadius + DeltaRaius * circleIndex);
        int x = xCenter + r * cos(alpha);
        int y = yCenter + r * sin(alpha);
        alpha += dAlpha;
        circleIndex = (circleIndex + 1) % circles;
        NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(x, y, 0.7 * NodeSize, 0.7 * NodeSize)];
        nodeView.node = secondGener;
        [self.containerView addSubview:nodeView];
        nodeView.alpha = 0.4;
        

    }
    
//    __block int x = 10;
//    __block int y = 20;
//    [self.graph.nodes enumerateKeysAndObjectsUsingBlock:^(NSString *url, Node *node, BOOL *stop) {
//        NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
//        nodeView.node = node;
//        [self.containerView addSubview:nodeView];
////        for(int k = 0; k < nodeView.node.countURLs;k++) {
////            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(x + 30, y + 15, 30, 1)];
////            lineView.backgroundColor = [UIColor blackColor];
////            lineView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0 - k));
////            [self.containerView addSubview:lineView];
////        }
//        UITapGestureRecognizer *nodeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapNodeView:)];
//        
//       
//        [nodeView addGestureRecognizer:nodeFingerTap];
//        
//        x += 40;
//        if (x > 280 ) {
//            x = 290;
//            y += 40;
//
//        }
//    }];
//    [self.scrollView setContentSize:CGSizeMake(350, y + 50)];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Line tap was here: %@", recognizer.view);
}
- (void)handleSingleTapNodeView:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Node tap happened: x = %@, y = %@", @(recognizer.view.center.x), @(recognizer.view.center.y));
}

- (float)circleRadiusForNodeCount:(NSUInteger)nodeCount
{
    return 0.5 * M_1_PI * nodeCount * (NodeSize + NodeDistance);
}

- (NSUInteger)nodesCountForRadius:(float)radius
{
    return 2 * M_PI * radius / (NodeSize + NodeDistance);
}

-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
 
        switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>");
            self.gestureCount++;
            [self asyncBuildNextGeneration];
        } break;

        default: {
        } break;
    }
}

- (void)asyncBuildNextGeneration
{
    if (self.gestureCount > 0 && !self.buildInProgress) {
        self.buildInProgress = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.graph buildNextGeneration];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gestureCount--;
                self.buildInProgress = NO;
                [self updateNodesView];
                [self asyncBuildNextGeneration];
            });
        });
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;//self.containerView;
}

@end
