#import <Foundation/Foundation.h>
#import "FlutterBdfaceBaseView.h"
#import "BDFaceVideoCaptureDevice.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
@interface FlutterBdfaceBaseView() <CaptureDataOutputProtocol>

@end

@implementation FlutterBdfaceBaseView


- (instancetype)initWithFrame:(CGRect)frame channel:(FlutterMethodChannel *)channel arguments:(NSDictionary *)args{
    self = [super initWithFrame:frame];
    if (self) {
        self.channel = channel;
        [self commonSetup:args];
    }
    return self;
}

- (void)commonSetup:(NSDictionary *)args{
    // 设置预览框
    NSNumber* px = args[@"px"];
    NSNumber* py = args[@"py"];
    NSNumber* pw = args[@"pw"];
    NSNumber* ph = args[@"ph"];
    self.previewRect = CGRectMake([px doubleValue], [py doubleValue], [pw doubleValue], [ph doubleValue]);
    
    // 设置检测框
    NSNumber* dx = args[@"dx"];
    NSNumber* dy = args[@"dy"];
    NSNumber* dw = args[@"dw"];
    NSNumber* dh = args[@"dh"];
    self.detectRect = CGRectMake([dx doubleValue], [dy doubleValue], [dw doubleValue], [dh doubleValue]);
    
    // 初始化
    [[FaceSDKManager sharedInstance] initCollect];
    [self startup];
    
    //添加 相机视图
    self.videoCapture = [[BDFaceVideoCaptureDevice alloc] init];
    self.videoCapture.delegate = self;
    self.videoCapture.runningStatus = YES;
    self.displayImageView = [[UIImageView alloc] init];
    self.displayImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.displayImageView];
    
    // 移步后台启动相机
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.videoCapture startSession];
    });
}

- (void)dealloc{
    [self.videoCapture stopSession];
    self.videoCapture.runningStatus = NO;
    self.videoCapture.delegate = nil;
    [self shutdown];
}

- (void)startup{
    
}

- (void)shutdown{
    
}

- (void)captureError {
    
}

- (void)invokeMethod:(NSString *)method arguments:(NSDictionary *)arguments{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.channel invokeMethod:method arguments:arguments];
    });
}

- (void)captureOutputSampleBuffer:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.displayImageView.image = image;
    });
    [self faceProcesss:image];
}

- (void)faceProcesss:(UIImage *)image {
    
}
- (NSDictionary *)convertFaceInfo:(FaceInfo *)info images:(NSDictionary *)images{
    if(info == nil && images == nil) return nil;
    NSMutableDictionary* faceInfoDict = [NSMutableDictionary dictionary];
    CGRect faceRect = info.faceRect;
    [faceInfoDict setValue:@{
        @"x": @(faceRect.origin.x),
        @"y": @(faceRect.origin.y),
        @"width": @(faceRect.size.width),
        @"height": @(faceRect.size.height)
    } forKey:@"faceRect"];
    
    FaceCropImageInfo *bestImage;
    if (images[@"image"] != nil && [images[@"image"] count] != 0) {
        bestImage = images[@"image"][0];
    }else {
        bestImage = info.cropImageInfo;
    }
    
    if(bestImage != nil) {
        NSString* original = bestImage.originalImageEncryptStr;
        NSString* crop = bestImage.cropImageWithBlackEncryptStr;
        [faceInfoDict setValue:@{
            @"original": original == nil ?[NSNull null]: original,
            @"crop": crop == nil ?[NSNull null]: crop
        } forKey:@"image"];
    }

    return faceInfoDict;
}

// 在布局时更新宽高
- (void)layoutSubviews {
    self.displayImageView.frame = self.frame;
}

@end
