//
//  NsobjectCpp.m
//  QcodeScan
//
//  Created by ios2 on 2019/5/15.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import "NsobjectCpp.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/highgui/ios.h>


@interface NsobjectCpp()<CvVideoCameraDelegate>
{
	__weak UIView *_containtView;
	cv::Mat _currentMat;
}
@property CvVideoCamera *videoCamera;

@end

@implementation NsobjectCpp
{
	cv::CascadeClassifier faceDetector;
}
-(void)loadFaceXml {
	// 添加xml文件
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString* cascadePath = [[NSBundle mainBundle]
								 pathForResource:@"haarcascade_frontalface_alt"
								 ofType:@"xml"];
		self->faceDetector.load([cascadePath UTF8String]);
	});
}
//标记处人脸位置
-(UIImage *)faceDetectorImage:(UIImage *)image
{
	[self loadFaceXml];
	cv::Mat faceImage;
	UIImageToMat(image, faceImage);
	if (!faceImage.empty()) {
		// 转为灰度
		cv::Mat gray;
		cvtColor(faceImage, gray, CV_BGR2GRAY);
		// 检测人脸并储存
		std::vector<cv::Rect>faces;
		faceDetector.detectMultiScale(gray, faces,1.1,2,0|CV_HAAR_SCALE_IMAGE,cv::Size(30,30));
		// 在每个人脸上画一个红色四方形
		for(unsigned int i= 0;i < faces.size();i++) {
			const cv::Rect& face = faces[i];
			cv::Point tl(face.x,face.y);
			cv::Point br = tl + cv::Point(face.width,face.height);
				// 四方形的画法
			/*
			 cv::Scalar的构造函数是
			 cv::Scalar(v1, v2, v3, v4)，
			 前面的三个参数是依次设置BGR的，
			 和RGB相反，
			 第四个参数设置图片的透明度。
			 */
			//rgb 颜色设置线条
			cv::Scalar magenta = cv::Scalar(0xd3, 0x38, 0x3a);
			/*
			 thickness 线条宽度
			 lineType 线条类型
			 rectangle(CV_IN_OUT Mat& img, Point pt1, Point pt2,
			 const Scalar& color, int thickness=1,
			 int lineType=8, int shift=0);
			 */
			//第五个参数是线宽
			cv::rectangle(faceImage, tl, br, magenta, 5, 8, 0);
		}
		UIImage *endImage  = MatToUIImage(faceImage);
		return endImage;
	}
	return nil;
}
-(UIImage *)cvImg:(UIImage *)img
{
	cv::Mat vcImage;
	UIImageToMat(img,vcImage);
	if (!vcImage.empty()) {
		cv::Mat gray;  //声明输出

		// vcImage 输入  gray 输出   CV_RGB2GRAY code码 可选
		cv::cvtColor(vcImage, gray, CV_RGB2GRAY);
		// 应用高斯滤波器去除小的边缘
		cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
		// 计算与画布边缘
		cv::Mat edges;
		cv::Canny(gray, edges, 0, 50);
		// 使用白色填充
		vcImage.setTo(cv::Scalar::all(255));
		//修改边缘颜色
		vcImage.setTo(cv::Scalar(0,128,255,255),edges);

		return  MatToUIImage(vcImage);
	}
	return nil;
}

-(UIImage *)rectImg:(UIImage *)aimg
{

	cv::Mat cvImage,imgContour;

	UIImageToMat(aimg, cvImage);

	cv::cvtColor(cvImage, imgContour, CV_BGR2GRAY);

	cv::blur(imgContour, imgContour, cvSize(5, 5));
	//边缘检测
	Canny(imgContour, imgContour, 100, 20,3);

	return MatToUIImage(imgContour);
/*
	cv::Mat cvImage;
	UIImageToMat(aimg, cvImage);
	cv::Mat imgContour;
	Canny(cvImage, imgContour, 100, 20,3);
	std::vector<std::vector<cv::Point>> contours;
	std::vector<cv::Vec4i> hierarchy;
		// 查找轮廓
	findContours(imgContour, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);
	// 绘制轮廓
	for (int i = 0; i < (int)contours.size(); i++) {

		 void drawContours//绘制轮廓，用于绘制找到的图像轮廓
		 (
		 InputOutputArray image,//要绘制轮廓的图像
		 InputArrayOfArrays contours,//所有输入的轮廓，每个轮廓被保存成一个point向量
		 int contourIdx,//指定要绘制轮廓的编号，如果是负数，则绘制所有的轮廓
		 const Scalar& color,//绘制轮廓所用的颜色
		 int thickness = 1, //绘制轮廓的线的粗细，如果是负数，则轮廓内部被填充
		 int lineType = 8, /绘制轮廓的线的连通性
		 InputArray hierarchy = noArray(),//关于层级的可选参数，只有绘制部分轮廓时才会用到
		 int maxLevel = INT_MAX,//绘制轮廓的最高级别，这个参数只有hierarchy有效的时候才有效
		 //maxLevel=0，绘制与输入轮廓属于同一等级的所有轮廓即输入轮廓和与其相邻的轮廓
		 //maxLevel=1, 绘制与输入轮廓同一等级的所有轮廓与其子节点。
		 //maxLevel=2，绘制与输入轮廓同一等级的所有轮廓与其子节点以及子节点的子节点
		 )


		drawContours(imgContour, contours, 0, cvScalar(255), 1, 8);
	}
	UIImage *dstImage = MatToUIImage(imgContour);
	return dstImage;
*/
}

/*在你的工程添加3个iOS framework :
 CoreVideo.framework,
 AssetsLibrary.framework,
 CoreMedia.framework.*/

-(void)cvCamara:(UIView *)view
{
	_containtView = view;
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:view];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1920x1080;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
		//self.videoCamera.rotateVideo =YES; //设置是旋转
	self.videoCamera.defaultFPS = 60;
}

- (void)processImage:(cv::Mat&)image
{
	if (self.type == 1) {
		cv::cvtColor(image, image, CV_BGR2GRAY);
	}else if (self.type == 2){
		cv::cvtColor(image, image, CV_BGR2GRAY);
		cv::blur(image, image, cvSize(5, 5));
		//边缘检测
		Canny(image, image, 100, 20,3);
	}else if (self.type == 3){
		cv::cvtColor(image, image, CV_BGR2HSV);
	}
	_currentMat = image;
}

-(void)saveImage
{
	UIImage *img =(self.type == 0)?[self MatToUIImage:_currentMat]:MatToUIImage(_currentMat);
	NSData * data = UIImageJPEGRepresentation(img, 0.5);
	UIImage *aimg = [UIImage imageWithData:data];
	UIImageWriteToSavedPhotosAlbum(aimg, self, nil, nil);
}

-(void)checkFace:(cv::Mat&)image
{
	[self loadFaceXml];
	cv::Mat faceImage = image;
	if (!faceImage.empty()) {
			// 转为灰度
		cv::Mat gray;
		cvtColor(faceImage, gray, CV_BGR2GRAY);
			// 检测人脸并储存
		std::vector<cv::Rect>faces;
		faceDetector.detectMultiScale(gray, faces,1.1,2,0|CV_HAAR_SCALE_IMAGE,cv::Size(30,30));
			// 在每个人脸上画一个红色四方形
		for(unsigned int i= 0;i < faces.size();i++) {
			const cv::Rect& face = faces[i];
			cv::Point tl(face.x,face.y);
			cv::Point br = tl + cv::Point(face.width,face.height);
				// 四方形的画法
			/*
			 cv::Scalar的构造函数是
			 cv::Scalar(v1, v2, v3, v4)，
			 前面的三个参数是依次设置BGR的，
			 和RGB相反，
			 第四个参数设置图片的透明度。
			 */
			cv::Scalar magenta = cv::Scalar(0xd3, 0x38, 0x3a);
			/*
			 thickness 线条宽度
			 lineType 线条类型
			 rectangle(CV_IN_OUT Mat& img, Point pt1, Point pt2,
			 const Scalar& color, int thickness=1,
			 int lineType=8, int shift=0);
			 */
			cv::rectangle(faceImage, tl, br, magenta, 5, 8, 0);
		}
	}
}

-(void)stop
{
	[self.videoCamera stop];
}
-(void)start
{
	[self.videoCamera start];
}

-(UIImage *)MatToUIImage:(cv::Mat)mat
{
	cv::cvtColor(mat, mat, CV_BGR2RGB);

	NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
	CGColorSpaceRef colorspace;

	if (mat.elemSize() == 1) {
		colorspace = CGColorSpaceCreateDeviceGray();
	}
	else
	 {
		colorspace = CGColorSpaceCreateDeviceRGB();
	 }

	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

	CGImageRef imageRef = CGImageCreate(mat.cols, mat.rows, 8, 8 *mat.elemSize(), mat.step[0], colorspace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);

	UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorspace);
	return image;
}

@end
