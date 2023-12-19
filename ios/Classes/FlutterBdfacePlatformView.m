#import <Foundation/Foundation.h>
#import "FlutterBdfacePlatformView.h"
#import "FlutterBdfaceLivenessView.h"
#import "FlutterBdfaceDetectView.h"

@implementation FlutterBdfacePlatformViewFactory{
    NSObject<FlutterBinaryMessenger>* _messenger;
}



- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
        if (self) {
            _messenger = messenger;
        }
    return self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args { 
    return [[FlutterBdfacePlatformView alloc] initWithFrame:frame
                                viewIdentifier:viewId
                                     arguments:args
                               binaryMessenger:_messenger];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

@end


@implementation FlutterBdfacePlatformView {
    UIView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if(self = [super init]) {
        FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"com.fluttercandies.bdface_collect"
                  binaryMessenger:messenger];
        NSString* type = args[@"type"];
        if([type isEqualToString:@"Liveness"]) {
            FlutterBdfaceLivenessView *faceView = [[FlutterBdfaceLivenessView alloc] initWithFrame:frame channel:channel arguments:args];
            _view = faceView;
        }else if([type isEqualToString:@"Detect"]) {
            FlutterBdfaceDetectView *faceView = [[FlutterBdfaceDetectView alloc] initWithFrame:frame channel:channel arguments:args];
            _view = faceView;
        }else {
            @throw [NSException exceptionWithName:@"type not found" reason:nil userInfo:nil];
        }
        
    }
    return self;
}

- (UIView*)view {
  return _view;
}

@end
