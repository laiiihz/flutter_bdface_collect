//
//  FlutterBdfaceBaseView.h
//  Pods
//
//  Created by 赖鸿展 on 2023/12/18.
//

#ifndef FlutterBdfaceBaseView_h
#define FlutterBdfaceBaseView_h
#import <UIKit/UIKit.h>
#import "Flutter/Flutter.h"
#import "BDFaceVideoCaptureDevice.h"
#import "IDLFaceSDK/IDLFaceSDK.h"

@interface FlutterBdfaceBaseView : UIView

@property (nonatomic, readwrite, retain) UIImageView *displayImageView;
@property (nonatomic, readwrite, retain) BDFaceVideoCaptureDevice *videoCapture;
// flutter平台通道
@property (nonatomic, readwrite, retain) FlutterMethodChannel* channel;
// 预览框
@property (nonatomic, readwrite, assign) CGRect previewRect;
// 检测框
@property (nonatomic, readwrite, assign) CGRect detectRect;
// 结束标记
@property (nonatomic, readwrite, assign) BOOL hasFinished;

- (instancetype) initWithFrame:(CGRect)frame channel:(FlutterMethodChannel *)channel arguments:(NSDictionary *)args;
- (void) startup;
- (void) shutdown;
- (void) faceProcesss:(UIImage *)image;
- (void) invokeMethod:(NSString *)method arguments:(NSDictionary *)arguments;
- (NSDictionary *) convertFaceInfo:(FaceInfo *)info images:(NSDictionary *)images;
@end

#endif /* FlutterBdfaceBaseView_h */
