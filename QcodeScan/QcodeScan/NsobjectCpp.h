//
//  NsobjectCpp.h
//  QcodeScan
//
//  Created by ios2 on 2019/5/15.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NsobjectCpp : NSObject

// 0 是正常 1 是灰色 2 是 边界
@property(nonatomic,assign)NSInteger type;

//存储图片
-(void)saveImage;
-(UIImage *)faceDetectorImage:(UIImage *)image;

-(UIImage *)cvImg:(UIImage *)img;

-(UIImage *)rectImg:(UIImage *)aimg;

-(void)cvCamara:(UIView *)view;

-(void)stop;
-(void)start;


@end
