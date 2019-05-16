//
//  QrCodeScanViewController.m
//  QcodeScan
//
//  Created by ios2 on 2019/5/13.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import "QrCodeScanViewController.h"

#import <ImageIO/ImageIO.h>
#import "ScanRunView.h"
#import "NsobjectCpp.h"

@interface QrCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate> {
	AVCaptureSession *_session;
	AVCaptureVideoPreviewLayer *_layer;
	CGFloat _lastBrightnessValue;
	AVCaptureDevice  *_device;
	CGRect _cropRect;      //可以扫描的位置
	ScanRunView *_scanView;
	UILabel * _titleLable;
	UIView *_focusView;//对焦View
	UIImageView *_bgImgView;
	NsobjectCpp *_cpp;
}
//缩放参数
@property(nonatomic,assign)CGFloat currentZoomFactor;
@property(nonatomic,assign)CGFloat maxZoomFactor;
@property(nonatomic,assign)CGFloat minZoomFactor;

@end

@implementation QrCodeScanViewController


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_session startRunning];
	_scanView.runAnimation = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
		[_session stopRunning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
		_cpp = [[NsobjectCpp alloc]init];
	self.view.backgroundColor = [UIColor blackColor];
	self.maxZoomFactor = 6.0;
	self.minZoomFactor = 1.0;
	self.currentZoomFactor = 1.0;
	CGSize scaleSize = (CGSize){
		CGRectGetWidth([UIScreen mainScreen].bounds) - 20*2,
		300.0
	};
	if ([self isPhoneX]) {
		_cropRect = (CGRect){20,44+44 + 150,scaleSize};
	}else{
		_cropRect = (CGRect){20,20+44 + 90,scaleSize};
	}

	CGFloat x =  CGRectGetMidX(_cropRect);
	CGFloat y =  CGRectGetMidY(_cropRect);
	ScanRunView *scanView = [ScanRunView new];
	scanView.rect_color = [UIColor redColor];
	scanView.lineHeight = 30;
	scanView.bounds = CGRectMake(0, 0, 250, 250);
	scanView.center = (CGPoint){x,y};
	scanView.scanLineRunType = ScanLineTopType;
	[self.view addSubview:scanView];
	_scanView = scanView;

	[self initScan];
	if (_device) {
		[self addMoreGesture];
	}
	UILabel *titleLable = [UILabel new];
	titleLable.text = @"扫一扫";
	[self.view addSubview:titleLable];
	_titleLable = titleLable;
	_titleLable.textAlignment = NSTextAlignmentCenter;
	_titleLable.font = [UIFont systemFontOfSize:18.0];
	_titleLable.textColor = [UIColor whiteColor];
	_bgImgView = [UIImageView new];
	_bgImgView.frame = self.view.bounds;
	[self.view addSubview:_bgImgView];
}
-(UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}
-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
    CGRect frame =  CGRectZero;
	frame.origin.x = 0;
	frame.origin.y = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);
	frame.size.height = 44;
	frame.size.width = CGRectGetWidth(self.view.bounds);
	_titleLable.frame = frame;
}

- (void)initScan {
	BOOL canScan = [self requestAuth];
	if (!canScan) {
		return;
	}
	//获取摄像设备
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	_device = device;
	 if ([device lockForConfiguration:nil]) {
			 //使用自动对焦
		 if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
			 [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		 }
			 //自动曝光
		 if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
			 [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
		 }
		 [device unlockForConfiguration];
	 }

	//创建输入流
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
		//创建输出流
	AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];

	//设置代理 在主线程里刷新
	[output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

	//设置光感代理输出
	AVCaptureVideoDataOutput *respondOutput = [[AVCaptureVideoDataOutput alloc] init];
	[respondOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	//初始化链接对象
	if (_session) {
		[_session stopRunning];
	}
	_session = [[AVCaptureSession alloc] init];
	//设置扫描有效区域
	CGSize size = self.view.bounds.size;
	CGRect cropRect = _cropRect;
	CGFloat point_w = 1920.;
	CGFloat point_h = 1080.;
	//高质量采集率
	if (@available(iOS 9.0,*)) {
		//使用超大输出来满足极小二维码 扫描 ==========
		if ([_session canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
			[_session setSessionPreset:AVCaptureSessionPreset3840x2160];
			point_w = 3840.;
			point_h = 2160.;
		}else{
			if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
				[_session setSessionPreset:AVCaptureSessionPreset1920x1080];
			}else{
				if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
					[_session setSessionPreset:AVCaptureSessionPreset1280x720];
					point_w = 1280.;
					point_h = 720.;
				}
			}
		}
	}else{
		if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
			[_session setSessionPreset:AVCaptureSessionPreset1920x1080];
		}else{
			if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
				[_session setSessionPreset:AVCaptureSessionPreset1280x720];
				point_w = 1280.;
				point_h = 720.;
			}
		}
	}

	//https://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/

	CGFloat p1 = size.height/size.width;
	CGFloat p2 = point_w/point_h;  //使用了 1080p \ 2160p 的图像输出
	if (p1 < p2) {
		CGFloat fixHeight = size.width * point_w / point_h;
		CGFloat fixPadding = (fixHeight - size.height)/2;
		output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
										   cropRect.origin.x/size.width,
										   cropRect.size.height/fixHeight,
										   cropRect.size.width/size.width);
	} else {
		CGFloat fixWidth = size.height * point_h / point_w;
		CGFloat fixPadding = (fixWidth - size.width)/2;
		output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
										   (cropRect.origin.x + fixPadding)/fixWidth,
										   cropRect.size.height/size.height,
										   cropRect.size.width/fixWidth);
	}

	if ([_session canAddInput:input]) [_session addInput:input];
	if ([_session canAddOutput:output]) [_session addOutput:output];
	if ([_session canAddOutput:respondOutput]) [_session addOutput:respondOutput];
	 [_session commitConfiguration];

	//设置扫码支持的编码格式
	output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code];

	_layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	_layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	_layer.frame = self.view.frame;
	[self.view.layer insertSublayer:_layer atIndex:0];

	// ================ 使用黑色区域 ================
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointZero];
	[path addLineToPoint:_scanView.frame.origin];
	[path addLineToPoint:CGPointMake(CGRectGetMaxX(_scanView.frame), _scanView.frame.origin.y)];
	[path addLineToPoint:CGPointMake(CGRectGetMaxX(_scanView.frame), CGRectGetMaxY(_scanView.frame))];
	[path addLineToPoint:CGPointMake(_scanView.frame.origin.x, CGRectGetMaxY(_scanView.frame))];
	[path addLineToPoint:_scanView.frame.origin];
	[path addLineToPoint:CGPointZero];
	[path addLineToPoint:CGPointMake(0, CGRectGetHeight(self.view.frame))];
	[path addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
	[path addLineToPoint:CGPointMake(CGRectGetWidth(self.view.frame), 0)];
	[path addLineToPoint:CGPointZero];
	[path closePath];
	CAShapeLayer *rectLayer = [CAShapeLayer layer];
	rectLayer.path = path.CGPath;
	rectLayer.fillColor = [[UIColor blackColor]colorWithAlphaComponent:0.4].CGColor;
	[_layer addSublayer:rectLayer];
}
//添加缩放手势&双击手势
-(void)addMoreGesture {
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(zoomChangePinchGestureRecognizerClick:)];
	pinch.delegate = self;
	[self.view addGestureRecognizer:pinch];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scaleTapAction:)];
	tap.numberOfTapsRequired = 2;
	[self.view addGestureRecognizer:tap];
}
//双击手势 ---------- 缩放到最大或最小
-(void)scaleTapAction:(UITapGestureRecognizer *)tap {
	/**
	 图像的视觉线性缩放
	 rampToVideoZoomFactor:(CGFloat)factor withRate:(float)rate
	 factor 缩放的大小
	 rate 缩放的速率
	 [_device  rampToVideoZoomFactor:4.0 withRate:8];
	 */
	if (tap.state == UIGestureRecognizerStateEnded) {
		if (!_session.isRunning) return;
		NSError *error = nil;
		if ([_device lockForConfiguration:&error] ) {
			if (_device.videoZoomFactor < self.maxZoomFactor) {
				[_device  rampToVideoZoomFactor:self.maxZoomFactor withRate:8];
			}else{
				[_device  rampToVideoZoomFactor:self.minZoomFactor withRate:8];
			}
			[_device unlockForConfiguration];
		}
	}
}
//捏合之前记录当前焦距 -------- 视频缩放因子
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
		self.currentZoomFactor = _device.videoZoomFactor;
	}
	return YES;
}
//捏合手势 缩放焦距-- 视频缩放因子
- (void)zoomChangePinchGestureRecognizerClick:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
	if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
		pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		if (!_session.isRunning) return;
		CGFloat currentZoomFactor = self.currentZoomFactor*pinchGestureRecognizer.scale;
		if (currentZoomFactor < self.maxZoomFactor &&
			currentZoomFactor > self.minZoomFactor){
			NSError *error = nil;
			if ([_device lockForConfiguration:&error] ) {
				_device.videoZoomFactor = currentZoomFactor;
				[_device unlockForConfiguration];
			}
			else {
				NSLog( @"Could not lock device for configuration: %@", error );
			}
		}
	 }
}
//感光元件进行输出 ------------------------ 光线强度代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

	CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
	CFRelease(metadataDict);
	NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
	// 该值在 -5~12 之间
	float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
	if ((_lastBrightnessValue>0 && brightnessValue>0) ||
		(_lastBrightnessValue<=0 && brightnessValue<=0)) {
		return;
	}
	//光线变暗直接打开 关闭则使用按钮点击关闭
	if (brightnessValue < -1) {
		[self switchTorch:YES];
	}
	_lastBrightnessValue = brightnessValue;
}
//扫描结果出现 ============
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	if (metadataObjects.count > 0) {
		[_session stopRunning];
		
		AVMetadataMachineReadableCodeObject *metaDataObject = [metadataObjects objectAtIndex:0];
		[self switchTorch:NO];
		NSString *stringValue = metaDataObject.stringValue;
		//结果 ===========
		NSLog(@"输出扫描结果: |%@",stringValue);
		[self playSound];

	}
}
- (void)switchTorch:(BOOL)on
{
	//更换按钮状态

   //	_torchBtn.selected = on;

   //	_tipLabel.text = [NSString stringWithFormat:@"轻触%@", on?@"关闭":@"照亮"];

	//====================== 开或者关都直接返回 ======================
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ([device hasTorch]) {
		if (on) {
			//调用led闪光灯
			[device lockForConfiguration:nil];
			[device setTorchMode: AVCaptureTorchModeOn];
		} else {
				//关闭闪光灯
			if (device.torchMode == AVCaptureTorchModeOn) {
				[device setTorchMode: AVCaptureTorchModeOff];
			}
		}
	}
}
#pragma mark - scan request auth
- (BOOL)requestAuth {
	AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (status == AVAuthorizationStatusDenied) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请在设置->隐私中允许该软件访问摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
		__weak typeof(self)ws = self;
		UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
			[ws openSystemSetting];
		}];
		[alert addAction:action];
		[self presentViewController:alert animated:YES completion:nil];
		return NO;
	}
	if (status == AVAuthorizationStatusRestricted) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"设备不支持" preferredStyle:(UIAlertControllerStyleAlert)];
		UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
		}];
		[alert addAction:action];
		[self presentViewController:alert animated:YES completion:nil];
		return NO;
	}
	if (![UIImagePickerController isSourceTypeAvailable:
		  UIImagePickerControllerSourceTypeCamera]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"模拟器不支持该功能" preferredStyle:(UIAlertControllerStyleAlert)];
		UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
		}];
		[alert addAction:action];
		[self presentViewController:alert animated:YES completion:nil];
		return NO;
	}
	return YES;
}

#pragma mark —————— 跳转设置 ——————
-(void)openSystemSetting {
	if (@available(iOS 10.0,*)) {
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
		}];
	}else{
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}
}


#pragma mark —————— 播放 ——————— 嘀声
-(void)playSound {
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	NSString *path = [[NSBundle mainBundle ] pathForResource:@"sucessVoce" ofType:@"mp3"];
	if (!path) return;
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
	// 添加有结果的声音
	AudioServicesPlaySystemSound (soundID);
}

- (BOOL)isPhoneX {
	BOOL iPhoneX = NO;
	if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
		//判断是否是手机
		return iPhoneX;
	}
	if (@available(iOS 11.0, *)) {
		UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
		if (mainWindow.safeAreaInsets.bottom > 0.0) {
			iPhoneX = YES;
		}
	}
	return iPhoneX;
}
//焦点调节和曝光率
- (void)focusAtPoint:(CGPoint)point {
		//点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
	CGSize size = self.view.bounds.size;
	CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
	NSError *error;
	if ([_device lockForConfiguration:&error]) {
			//对焦模式和对焦点
		if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
			[_device setFocusPointOfInterest:focusPoint];
			[_device setFocusMode:AVCaptureFocusModeAutoFocus];
		}
			//曝光模式和曝光点
		if ([_device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
			[_device setExposurePointOfInterest:focusPoint];
			[_device setExposureMode:AVCaptureExposureModeAutoExpose];
		}
		[_device unlockForConfiguration];
		if (!_focusView) {
			_focusView = [UIView new];
			_focusView.layer.borderColor = [UIColor yellowColor].CGColor;
			_focusView.layer.borderWidth = 1.0;
			_focusView.layer.bounds = CGRectMake(0, 0, 50, 50);
			[self.view addSubview:_focusView];
		}
			//设置对焦动画
		_focusView.center = point;
		_focusView.hidden = NO;
		[UIView animateWithDuration:0.3 animations:^{
			self->_focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
		}completion:^(BOOL finished) {
			[UIView animateWithDuration:0.5 animations:^{
				self->_focusView.transform = CGAffineTransformIdentity;
			} completion:^(BOOL finished) {
				self->_focusView.hidden = YES;
			}];
		}];
	}
}

@end


@implementation QrCodeScanViewController (QrImgeScan)

-(void)scanQrImage:(UIImage *)image
	 andCompletion:(void(^)(id responder))completion {
	image = [self imageByInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) withColor:[UIColor lightGrayColor] withImage:image];
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
	NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
	if (features.count >= 1) {
		CIQRCodeFeature *feature = [features objectAtIndex:0];
		NSString *msg = feature.messageString;
		//扫描二维码
		if (completion) {
			completion(msg);
		}
	}
}

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color withImage:(UIImage *)image
{
	CGSize size = image.size;
	size.width -= insets.left + insets.right;
	size.height -= insets.top + insets.bottom;
	if (size.width <= 0 || size.height <= 0) {
		return nil;
	}
	CGRect rect = CGRectMake(-insets.left, -insets.top, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (color) {
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
		CGPathAddRect(path, NULL, rect);
		CGContextAddPath(context, path);
		CGContextEOFillPath(context);
		CGPathRelease(path);
	}
	[image drawInRect:rect];
	UIImage *insetEdgedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return insetEdgedImage;
}


@end


