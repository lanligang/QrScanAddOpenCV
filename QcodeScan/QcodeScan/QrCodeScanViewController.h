//
//  QrCodeScanViewController.h
//  QcodeScan
//
//  Created by ios2 on 2019/5/13.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QrCodeScanViewController : UIViewController

@end

// =============== 扫描图片 ===============
@interface QrCodeScanViewController (QrImgeScan)

//扫描图片以及Block回执
-(void)scanQrImage:(UIImage *)image
	 andCompletion:(void(^)(id responder))completion;

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end

