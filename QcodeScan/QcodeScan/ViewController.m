//
//  ViewController.m
//  QcodeScan
//
//  Created by ios2 on 2019/5/13.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import "ViewController.h"
#import "QrCodeScanViewController.h"

//@interface  People: NSObject
//
//@property (nonatomic, copy) NSString *name;
//@property (nonatomic, assign) BOOL sex;
//@property (nonatomic, assign) double height;
//@property (nonatomic, assign) int age;
//@end
//@implementation People
//@end

#import <GLKit/GLKit.h>
#import "NsobjectCpp.h"

@interface ViewController ()
{
	NsobjectCpp *cpp;
}
@end

@implementation ViewController


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[cpp start];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[cpp stop];
}
-(void)saveImg:(id)sender
{
	[cpp saveImage];
}

-(void)changeType:(UIButton *)btn
{
	cpp.type = btn.tag;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];

//	UIImage *img = [UIImage imageNamed:@"dongman"];
	cpp = [[NsobjectCpp alloc]init];
//	UIImage *img2 =  [cpp rectImg:img];
	self.view.contentMode = UIViewContentModeScaleAspectFit;
//	self.view.layer.contents = (id)img2.CGImage;
	UIView *v = [UIView new];
	v.frame = self.view.bounds;
	[self.view addSubview:v];
	[cpp cvCamara:v];


	UIButton *savebtn = [UIButton buttonWithType:UIButtonTypeCustom];
	savebtn.backgroundColor = [UIColor redColor];
	savebtn.layer.cornerRadius = 30;
	[self.view addSubview:savebtn];
	[savebtn addTarget:self action:@selector(saveImg:) forControlEvents:UIControlEventTouchUpInside];
	CGRect f =  savebtn.frame;
	f.size = CGSizeMake(60, 60);
	f.origin.y = CGRectGetHeight(self.view.frame) - 120;
	savebtn.frame = f;
	CGPoint p = savebtn.center;
	p.x  = CGRectGetWidth(self.view.bounds)/2.0;
	savebtn.center = p;
	NSString *title[4] = {@"正常",@"黑白",@"轮廓",@"HSV"};
	CGFloat w = (CGRectGetWidth(self.view.bounds) - 5* 10)/4;
	UIButton *lastBtn = nil;
	for (int i = 0; i< 4; i++) {
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setTitle:title[i] forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		btn.backgroundColor = [UIColor yellowColor];
		btn.tag = i;
		CGRect f =  savebtn.frame;
		f.size = CGSizeMake(w, 30);
		f.origin.y = CGRectGetHeight(self.view.frame) - 40;
		if (lastBtn) {
			CGRect lf = lastBtn.frame;
			f.origin.x = CGRectGetMaxX(lf) + 10;
		}else{
			f.origin.x = 10;
		}
		lastBtn = btn;
		btn.frame = f;
		[btn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:btn];
	}


	/** 集合排序：*/
//	NSArray *names = @[@"夏侯惇", @"貂蝉", @"诸葛亮", @"张三", @"李四", @"流火绯瞳", @"流火", @"李白", @"张飞", @"韩信", @"范冰冰", @"赵丽颖"];
//	NSArray *ages = @[@30, @38, @46, @34, @31, @27, @15, @22, @77, @35, @28, @59];
//	NSArray *heights = @[@170, @163, @180, @165, @163, @176, @174, @183, @186, @178, @167, @160];
//
//	NSMutableArray *peoples = [NSMutableArray arrayWithCapacity:names.count];
//	for (int i = 0; i<names.count; i++) {
//		People *pe = [[People alloc]init];
//		pe.name = names[i];
//
//		for (int i = 0; i<100000; i++) {
//			[peoples addObject:pe];
//			pe.age =arc4random()%80;
//			pe.height = arc4random()%2000;
//		}
//	}
//	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
//	[peoples sortUsingDescriptors:@[sort]];
//	for (People *p in peoples) {
//		NSLog(@"升序的结果 : %d 岁  %@\n\n ",p.age,p.name);
//	}
	//降序排序
//	NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
//	[peoples sortUsingDescriptors:@[sort2]];
//	for (People *p in peoples) {
//		NSLog(@"降序的结果 : %d 岁  %@ ",p.age,p.name);
//	}
//	NSSortDescriptor * sort3 = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
//	NSSortDescriptor * sort4 = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:NO];
//	NSInteger line1 =  [[NSDate date]timeIntervalSince1970]*1000;
//	[peoples sortUsingDescriptors:@[sort3,sort4]];
//	NSInteger line2 =  [[NSDate date]timeIntervalSince1970]*1000;
//	NSLog(@"函数执行时间差: | %ld",line2 - line1);
//	for (People *p in peoples) {
//		NSLog(@"age 降序 height 升序 的结果 : %d 岁  %f  %@ ",p.age,p.height,p.name);
//	}

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	QrCodeScanViewController *vc = [[QrCodeScanViewController alloc]init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)shareWithURL:(id)model {
	NSArray *activityItems = @[model];
	UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
	[self presentViewController:activityController animated:YES completion:nil];
	activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
		if (completed) {
			NSLog(@"completed"); //分享 成功
		} else  {
			NSLog(@"cancled"); //分享 取消
		}
	};
}

@end
