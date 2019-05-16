//
//  ScanRunView.m
//  QcodeScan
//
//  Created by ios2 on 2019/5/14.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import "ScanRunView.h"

@implementation ScanRunView{
	CADisplayLink *_timer;
	CGFloat _pointY;
	CGFloat _speed;
}

-(instancetype)initWithFrame:(CGRect)frame
{
	self =  [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_lineHeight = 30;
		_timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTime)];
		[_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		[_timer setPaused:YES];
		_speed = 4;
		_pointY =  30;
	}
	return self;
}
-(void)onTime {
	_pointY += _speed;
	if (_pointY>(CGRectGetHeight(self.bounds) - 20)||(_pointY <20)) {
		if (_scanLineRunType == ScanLineDefaultType) {
			_speed = -_speed;
		}else{
			_pointY = 20;
		}
	}
	[self setNeedsDisplay];
}
-(void)setScanLineRunType:(ScanLineRunType)scanLineRunType
{
	_scanLineRunType = scanLineRunType;
	if (scanLineRunType == ScanLineTopType) {
		_speed = 4;
	}
}
-(void)setRect_color:(UIColor *)rect_color {
	_rect_color = rect_color;
	[self setNeedsDisplay];
}
-(void)setLineHeight:(CGFloat)lineHeight
{
	_lineHeight = lineHeight;
	[self setNeedsLayout];
}

-(void)setRunAnimation:(BOOL)runAnimation
{
	_runAnimation = runAnimation;
	[_timer setPaused:!_runAnimation];
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
	if (!newSuperview) {
		[_timer setPaused:YES];
		[_timer invalidate];
		_timer = nil;
		_runAnimation = NO;
	}
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIBezierPath *linePath = [UIBezierPath bezierPath];
	[linePath moveToPoint:CGPointMake(CGRectGetWidth(rect)/6, _pointY)];
	[linePath addQuadCurveToPoint:CGPointMake(CGRectGetWidth(rect)/6 * 5.0, _pointY) controlPoint:CGPointMake(CGRectGetWidth(rect)/2, _pointY -4)];
	UIColor *drawColor0 = _rect_color?_rect_color:[UIColor redColor];
	[[drawColor0 colorWithAlphaComponent:0.8] set];
	[linePath addQuadCurveToPoint:CGPointMake(CGRectGetWidth(rect)/6, _pointY) controlPoint:CGPointMake(CGRectGetWidth(rect)/2, _pointY +4)];
	[linePath fill];

	CGFloat lineH =_lineHeight;
	for (int i = 0; i< 4; i++) {
		UIBezierPath *p;
		if (i==0) {
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(0, lineH)];
			[path addLineToPoint:CGPointMake(0, 0)];
			[path addLineToPoint:CGPointMake(lineH, 0)];
			p = path;
		}else if(i==1){
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(CGRectGetWidth(rect) - lineH, 0)];
			[path addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0)];
			[path addLineToPoint:CGPointMake(CGRectGetWidth(rect), lineH)];
			p = path;
		}else if(i==2){
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect)-lineH)];
			[path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
			[path addLineToPoint:CGPointMake(CGRectGetWidth(rect) - lineH, CGRectGetHeight(rect))];
			p = path;
		}else if(i==3){
			UIBezierPath *path = [UIBezierPath bezierPath];
			[path moveToPoint:CGPointMake(lineH, CGRectGetHeight(rect))];
			[path addLineToPoint:CGPointMake(0, CGRectGetHeight(rect))];
			[path addLineToPoint:CGPointMake(0, CGRectGetHeight(rect)-lineH)];
			p = path;
		}
		UIColor *drawColor = _rect_color?_rect_color:[UIColor redColor];
		[drawColor setStroke];
		[[UIColor clearColor]setFill];
		[p setLineWidth:4.0];
		[p setLineCapStyle:kCGLineCapRound];
		[p fill];
		[p stroke];

	}
}


@end
