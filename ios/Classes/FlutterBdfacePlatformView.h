#ifndef FlutterBdfacePlatformView_h
#define FlutterBdfacePlatformView_h

#import <Flutter/Flutter.h>

@interface FlutterBdfacePlatformViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype _Nonnull )initWithMessenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;
@end

@interface FlutterBdfacePlatformView : NSObject <FlutterPlatformView>

- (instancetype _Nonnull)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;

- (UIView*_Nonnull)view;

@end

#endif /* FlutterBdfacePlatformView_h */
