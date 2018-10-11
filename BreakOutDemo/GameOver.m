//
//  GameOver.m
//  BreakOutDemo
//
//  Created by Mircea Popescu on 10/10/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "GameOver.h"
#import "GameScene.h"

@implementation GameOver

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(touches){
        // Create and configure the scene
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = SKSceneScaleModeAspectFit;
        
        
        SKView *skView = (SKView *)self.view;
        
        // Present the scene
        [skView presentScene:scene];
    }
}

@end
