//
//  GameViewController.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "GameViewController.h"
#import "ZZWelcomeScene.h"
#import "ZZGameBoardScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    SKScene *scene = [[ZZWelcomeScene alloc] initWithSize:self.view.bounds.size];
	
    SKScene *scene = [[ZZGameBoardScene alloc] initWithSize:self.view.bounds.size];

	// Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    [skView presentScene:scene];
    
#ifdef DEBUG
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
#endif
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
