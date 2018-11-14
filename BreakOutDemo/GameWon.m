//
//  GameWon.m
//  BreakOutDemo
//
//  Created by Mircea Popescu on 11/13/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "GameWon.h"
#import "GameScene.h"

@implementation GameWon

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(touches){
        
        SKView *skView = (SKView *)self.view;
        [self removeFromParent];
        
        // Create and configure the scene
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
        // Set the scale mode to scale to fit the window
        scene.scaleMode = SKSceneScaleModeAspectFit;
        
        // Present the scene
        [skView presentScene:scene];
    }
}

@end
