//
//  RGMSprite.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMSprite.h"

@interface RGMSprite ()
@property (nonatomic, strong) GLKBaseEffect *effect;
@end

@implementation RGMSprite {
    GLuint _vbo;
    GLKTextureInfo *_textureInfo;
}

- (id)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _effect = [[GLKBaseEffect alloc] init];
        
        glGenVertexArraysOES(1, &_vbo);
        glBindVertexArrayOES(_vbo);
        GLKVector2 vertices[] = {
            GLKVector2Make(0, 0),
            GLKVector2Make(1, 0),
            GLKVector2Make(1, 1),
            GLKVector2Make(0, 1),
        };
        glVertexPointer(1, GL_VERTEX_ARRAY, 0, &vertices);
        
        [self setImage:image];
    }
    
    return self;
}

- (void)render
{
    _effect.texture2d0.name = _textureInfo.name;
    _effect.texture2d0.target = _textureInfo.target;
    
    glBindVertexArrayOES(_vbo);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)setImage:(UIImage *)image
{
    NSError *error;
    _textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:@{GLKTextureLoaderApplyPremultiplication: @YES, GLKTextureLoaderOriginBottomLeft: @YES} error:&error];
    if (!_textureInfo) {
        NSLog(@"error loading texture: %@", error);
    }
}

@end
