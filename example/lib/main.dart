import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bdface_collect/flutter_bdface_collect.dart';
import 'package:flutter_bdface_collect/model.dart';
import 'package:flutter_bdface_collect_example/platform_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人脸识别测试',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? imageBytes;

  void msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(label: 'OK', onPressed: () {}),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("人脸识别测试")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: imageBytes == null
                  ? const Text('未开始初始化')
                  : Image.memory(imageBytes!),
            ),
          ),
          SafeArea(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FutureBuilder(
                  future: FlutterBdfaceCollect.instance.version,
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      onPressed: null,
                      child: Text('SDK ${snapshot.data}'),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: _initialize,
                  child: Text('初始化'),
                ),
                ElevatedButton.icon(
                  onPressed: _faceCollect,
                  icon: Icon(Icons.face),
                  label: Text('原生视图'),
                ),
                ElevatedButton.icon(
                  onPressed: _livenessCollect,
                  icon: Icon(Icons.view_comfortable_rounded),
                  label: Text('自定义活体视图'),
                ),
                ElevatedButton.icon(
                  onPressed: _detectCollect,
                  icon: Icon(Icons.view_comfortable_rounded),
                  label: Text('自定义检测视图'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initialize() async {
    late String licenseId;
    if (Platform.isAndroid) {
      licenseId = 'flutter_bdface_collect_example-face-android';
    } else if (Platform.isIOS) {
      licenseId = 'flutter_bdface_collect_example-face-ios';
    }
    var err = await FlutterBdfaceCollect.instance.init(licenseId);
    if (err != null) {
      msg('百度人脸采集初始化失败:$err');
    } else {
      msg('百度人脸采集初始化成功');
    }

    final targetTypes = List<LivenessType>.from(LivenessType.all)..shuffle();
    await FlutterBdfaceCollect.instance
        .updateOption(FaceConfig(livenessTypes: targetTypes.toSet()));
  }

  Future<void> _faceCollect() async {
    var livenessTypeList = LivenessType.all.sublist(3);
    var config = FaceConfig(livenessTypes: Set.from(livenessTypeList));
    CollectResult res = await FlutterBdfaceCollect.instance.collect(config);
    print(
        "百度人脸采集结果：error:${res.error} imageSrcBase64 isEmpty:${res.imageSrcBase64.isEmpty}");
    if (res.imageSrcBase64.isEmpty) return setState(() => imageBytes = null);
    setState(() => imageBytes = base64Decode(res.imageSrcBase64));
  }

  Future<void> _livenessCollect() async {
    final data = await LivenessCustomView.open(context);
    setState(() {
      imageBytes = data == null ? null : base64Decode(data);
    });
  }

  Future<void> _detectCollect() async {
    final data = await DetectCustomView.open(context);
    setState(() {
      imageBytes = data == null ? null : base64Decode(data);
    });
  }
}
