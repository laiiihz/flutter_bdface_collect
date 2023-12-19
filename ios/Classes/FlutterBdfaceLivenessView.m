#import <Foundation/Foundation.h>
#import "FlutterBdfaceLivenessView.h"
#import "FlutterBdfaceBaseView.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "MethodConstants.h"

@implementation FlutterBdfaceLivenessView

- (void)startup{
    [[IDLFaceLivenessManager sharedInstance] startInitial];
}

- (void)shutdown{
    [[IDLFaceLivenessManager sharedInstance] reset];
}

- (void)faceProcesss:(UIImage *)image{
    if(self.hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
        NSMutableDictionary* args = [NSMutableDictionary dictionary];
        [args setValue:[weakSelf convertFaceInfo:faceInfo images:images] forKey:@"info"];
        [args setValue:@(remindCode) forKey:@"code"];
        
        switch (remindCode) {
            case LivenessRemindCodeOK:
                weakSelf.hasFinished = true;
                break;
            case LivenessRemindCodeFaceIdChanged:
            {
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    [weakSelf invokeMethod:OnLivenessProgress arguments:@{@"value": @(0)}];
                }];
                break;
            }
            case LivenessRemindCodeTimeout:
            {
                [[IDLFaceLivenessManager sharedInstance] reset];
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    [weakSelf invokeMethod:OnLivenessProgress arguments:@{@"value": @(0)}];
                }];
                [[weakSelf videoCapture] stopSession];
                break;
            }
            case LivenessRemindCodeSingleLivenessFinished:
            {
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    [weakSelf invokeMethod:OnLivenessProgress arguments:@{@"value": @(numberOfSuccess / numberOfLiveness)}];
                }];
                break;
            }
            default:
                break;
        }
        
        [weakSelf invokeMethod:OnLivenessResult arguments:args];
    }];
}

@end
