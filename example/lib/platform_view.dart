import 'package:flutter/material.dart';
import 'package:flutter_bdface_collect/flutter_bdface_view.dart';
import 'package:flutter_bdface_collect/model.dart';

class LivenessCustomView extends StatefulWidget {
  const LivenessCustomView({super.key});

  static Future<String?> open(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LivenessCustomView(),
    ));
  }

  @override
  State<LivenessCustomView> createState() => _LivenessCustomViewState();
}

class _LivenessCustomViewState extends State<LivenessCustomView> {
  final _text = ValueNotifier<String>('');
  final _progress = ValueNotifier<double>(0);

  onLivenssData(FaceLivenessResult result) {
    _text.value = result.code?.name ?? 'unknown';

    switch (result.code) {
      case null:
      case LivenessRemindCode.ok:
        Navigator.of(context).pop(result.info?.image?.original);
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final preview = Rect.fromLTWH(0, 0, width, 600);
    final detect = Rect.fromLTWH(64, 120, width - 128, 350);
    return Scaffold(
      appBar: AppBar(title: Text('自定义活体视图')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterBdfaceLivenessView(
            previewRect: preview,
            detectRect: detect,
            onLivenessData: onLivenssData,
            onProgress: (value) {
              _progress.value = value;
              print('progress $value');
            },
          ),
          ColoredRectWidget(rect: preview, color: Colors.blue),
          ColoredRectWidget(rect: detect, color: Colors.yellow),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _text,
                      builder: (context, state, _) {
                        return Text(state);
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _progress,
                      builder: (context, state, _) {
                        return LinearProgressIndicator(value: state);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetectCustomView extends StatefulWidget {
  const DetectCustomView({super.key});
  static Future<String?> open(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetectCustomView(),
    ));
  }

  @override
  State<DetectCustomView> createState() => _DetectCustomViewState();
}

class _DetectCustomViewState extends State<DetectCustomView> {
  final _text = ValueNotifier<String>('');

  void onDetectData(FaceDetectResult result) {
    _text.value = result.code?.name ?? 'unknown';

    switch (result.code) {
      case DetectRemindCode.ok:
        Navigator.of(context).pop(result.info?.image?.original);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final preview = Rect.fromLTWH(0, 0, width, 600);
    final detect = Rect.fromLTWH(64, 120, width - 128, 350);
    return Scaffold(
      appBar: AppBar(title: Text('自定义人脸视图')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterBdfaceDetectView(
            previewRect: preview,
            detectRect: detect,
            onDetectData: onDetectData,
          ),
          ColoredRectWidget(rect: preview, color: Colors.blue),
          ColoredRectWidget(rect: detect, color: Colors.yellow),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder(
                  valueListenable: _text,
                  builder: (context, state, _) {
                    return Text(state);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColoredRectWidget extends StatelessWidget {
  const ColoredRectWidget({
    super.key,
    required this.rect,
    required this.color,
  });
  final Rect rect;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: rect.top,
      left: rect.left,
      width: rect.width,
      height: rect.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
        ),
      ),
    );
  }
}
