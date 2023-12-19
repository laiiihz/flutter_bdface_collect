import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bdface_collect/constants.dart';
import 'package:flutter_bdface_collect/model.dart';

final _channel = MethodChannel('com.fluttercandies.bdface_collect');
const String _viewType = 'com.fluttercandies.bdface_collect/view';

enum FlutterBdfaceType {
  liveness('Liveness'),
  detect('Detect'),
  ;

  const FlutterBdfaceType(this.rawValue);
  final String rawValue;
}

abstract class FLutterBdfaceViewInterface extends StatelessWidget {
  const FLutterBdfaceViewInterface({
    super.key,
    required this.previewRect,
    required this.detectRect,
    required this.type,
  });

  final Rect previewRect;
  final Rect detectRect;
  final FlutterBdfaceType type;

  Map<String, dynamic> get _creationParams {
    return {
      'px': previewRect.left,
      'py': previewRect.top,
      'pw': previewRect.width,
      'ph': previewRect.height,
      'dx': detectRect.left,
      'dy': detectRect.top,
      'dw': detectRect.width,
      'dh': detectRect.height,
      'type': type.rawValue,
    };
  }
}

class FlutterBdfacePlatformView extends FLutterBdfaceViewInterface {
  const FlutterBdfacePlatformView({
    super.key,
    required super.previewRect,
    required super.detectRect,
    required super.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return FlutterBdfaceUIKitView(
          previewRect: previewRect,
          detectRect: detectRect,
          type: type,
        );
      case TargetPlatform.android:
      // TODO(laiiihz): implement android platform view
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnimplementedError(
            'Platform:[${Platform.operatingSystem} not implemented.]');
    }
  }
}

class FlutterBdfaceUIKitView extends FLutterBdfaceViewInterface {
  const FlutterBdfaceUIKitView({
    super.key,
    required super.previewRect,
    required super.detectRect,
    required super.type,
  });

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: _viewType,
      layoutDirection: Directionality.of(context),
      creationParams: _creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class FlutterBdfaceLivenessView extends StatefulWidget {
  const FlutterBdfaceLivenessView({
    super.key,
    required this.previewRect,
    required this.detectRect,
    required this.onLivenessData,
    required this.onProgress,
  });

  final Rect previewRect;
  final Rect detectRect;

  /// 检测结果回调
  final void Function(FaceLivenessResult data) onLivenessData;

  /// 检测进度回调 0.0~1.0
  final ValueChanged<double> onProgress;

  @override
  State<FlutterBdfaceLivenessView> createState() =>
      _FlutterBdfaceLivenessViewState();
}

class _FlutterBdfaceLivenessViewState extends State<FlutterBdfaceLivenessView> {
  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (!mounted) return;
      switch (call.method) {
        case MethodConstants.OnLivenessResult:
          final result = FaceLivenessResult.fromJson(call.arguments);
          widget.onLivenessData(result);
        case MethodConstants.OnLivenessProgress:
          final double value = call.arguments['value'] ?? 0.0;
          widget.onProgress(value);
        default:
      }
    });
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBdfacePlatformView(
      previewRect: widget.previewRect,
      detectRect: widget.detectRect,
      type: FlutterBdfaceType.liveness,
    );
  }
}

class FlutterBdfaceDetectView extends StatefulWidget {
  const FlutterBdfaceDetectView({
    super.key,
    required this.previewRect,
    required this.detectRect,
    required this.onDetectData,
  });

  final Rect previewRect;
  final Rect detectRect;

  /// 检测结果回调
  final void Function(FaceDetectResult data) onDetectData;

  @override
  State<FlutterBdfaceDetectView> createState() =>
      _FlutterBdfaceDetectViewState();
}

class _FlutterBdfaceDetectViewState extends State<FlutterBdfaceDetectView> {
  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (!mounted) return;

      switch (call.method) {
        case MethodConstants.OnDetectResult:
          final result = FaceDetectResult.fromJson(call.arguments);
          widget.onDetectData(result);
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBdfacePlatformView(
      previewRect: widget.previewRect,
      detectRect: widget.detectRect,
      type: FlutterBdfaceType.detect,
    );
  }
}
