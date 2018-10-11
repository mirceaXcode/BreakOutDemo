//
//  GameScene.m
//  BreakOutDemo
//
//  Created by Mircea Popescu on 10/10/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "GameScene.h"
#import "GameOver.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    SKSpriteNode *ball1 = [SKSpriteNode spriteNodeWithImageNamed:@"blueball.png"];
    ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball1.size.width/2];
    ball1.physicsBody.dynamic = YES;
    ball1.position = CGPointMake(150, self.size.height/2);
    ball1.physicsBody.friction = 0.0;
    ball1.physicsBody.restitution = 1.0;
    ball1.physicsBody.linearDamping = 0.0;
    ball1.physicsBody.angularDamping = 0.0;
    ball1.physicsBody.allowsRotation = NO;
    ball1.physicsBody.mass = 1.0;
    ball1.physicsBody.velocity = CGVectorMake(200.0, 200.0); // initial velocity
    
    SKSpriteNode *ball2 = [SKSpriteNode spriteNodeWithImageNamed:@"blueball.png"];
    ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball1.size.width/2];
    ball2.physicsBody.dynamic = YES;
    ball2.position = CGPointMake(300, self.size.height/2);
    ball2.physicsBody.friction = 0.0;
    ball2.physicsBody.restitution = 1.0;
    ball2.physicsBody.linearDamping = 0.0;
    ball2.physicsBody.angularDamping = 0.0;
    ball2.physicsBody.allowsRotation = NO;
    ball2.physicsBody.mass = 1.0;
    ball2.physicsBody.velocity = CGVectorMake(200.0, 0.0); // initial velocity
    
    [self addChild:ball1];
    [self addChild:ball2];
    
    CGPoint ball1Anchor = CGPointMake(ball1.position.x, ball1.position.y);
    CGPoint ball2Anchor = CGPointMake(ball2.position.x, ball2.position.y);
    
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:ball1.physicsBody bodyB:ball2.physicsBody anchorA:ball1Anchor anchorB:ball2Anchor];
    
    joint.damping = 0.0;
    joint.frequency = 1.5;
    
    [self.scene.physicsWorld addJoint:joint];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(touches){
        // Create and configure the scene
        GameOver *scene = [GameOver nodeWithFileNamed:@"GameOver"];
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = SKSceneScaleModeAspectFit;
        
        
        SKView *skView = (SKView *)self.view;
        
        // Present the scene
        [skView presentScene:scene];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}
    
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}



@end
