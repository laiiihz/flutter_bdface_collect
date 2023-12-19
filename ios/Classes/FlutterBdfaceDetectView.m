#import <Foundation/Foundation.h>
#import "FlutterBdfaceDetectView.h"
#import "FlutterBdfaceBaseView.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "MethodConstants.h"

@implementation FlutterBdfaceDetectView

- (void)startup{
    [[IDLFaceDetectionManager sharedInstance] startInitial];
}

- (void)shutdown{
    [[IDLFaceDetectionManager sharedInstance] reset];
}

- (void)faceProcesss:(UIImage *)image{
    if(self.hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[IDLFaceDetectionManager sharedInstance] detectStratrgyWithNormalImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(FaceInfo *faceinfo, NSDictionary *images, DetectRemindCode remindCode) {
        NSMutableDictionary* args = [NSMutableDictionary dictionary];
        [args setValue:[weakSelf convertFaceInfo:faceinfo images:images] forKey:@"info"];
        [args setValue:@(remindCode) forKey:@"code"];
        
        switch (remindCode) {
            case DetectRemindCodeOK:{
                weakSelf.hasFinished = true;
                break;
            }
            case DetectRemindCodeTimeout:
            {
                [[IDLFaceDetectionManager sharedInstance] reset];
                [[weakSelf videoCapture] stopSession];
                break;
            }
            default:
                break;
        }
        [weakSelf invokeMethod:OnDetectResult arguments:args];
    }];
}

@end
