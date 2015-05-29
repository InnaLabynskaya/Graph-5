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

static NSUInteger NodeSize = 30;

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Graph *graph;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) NSUInteger gestureCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.containerView.frame = CGRectMake(0, 0, 400, 400);
    self.scrollView.contentSize = self.containerView.frame.size;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
    [self.graph breadthFirstSearchFromNode:self.graph.rootNode handler:^(NodeForURL *node) {
        NodeView *nodeView = [self nodeViewForNode:node];
        nodeView.frame = CGRectMake(arc4random()%400, arc4random()%400, NodeSize, NodeSize);
        [self.containerView addSubview:nodeView];
    }];
}

- (NodeView*)nodeViewForNode:(NodeForURL*)node
{
    NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
    nodeView.node = node;
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, NodeSize, NodeSize)cornerRadius:NodeSize].CGPath;
    circle.masksToBounds = NO;
    circle.shadowOffset = CGSizeMake(-5, 10);
    circle.shadowRadius = 5;
    circle.shadowOpacity = 0.5;
    circle.position = CGPointMake(CGRectGetMidX(nodeView.frame)-NodeSize/2,
                                  CGRectGetMidY(nodeView.frame)-NodeSize/2);
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
    [nodeView.layer addSublayer:circle];
    return nodeView;
}

-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
 
        switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>");
            self.gestureCount++;
        } break;

        default: {
        } break;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;//self.containerView;
}

@end
