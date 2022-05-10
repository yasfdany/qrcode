import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef CaptureCallback = Function(String data);

enum CaptureTorchMode { on, off }

class QRCaptureController {
  late MethodChannel _methodChannel;
  CaptureCallback? _capture;

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('plugins/qr_capture/method_$id');
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onCaptured') {
        if (call.arguments != null) {
          if (_capture != null) _capture!(call.arguments.toString());
        }
      }
    });
  }

  void pause() {
    _methodChannel.invokeMethod('pause');
  }

  void resume() {
    _methodChannel.invokeMethod('resume');
  }

  void onCapture(CaptureCallback? capture) {
    _capture = capture;
  }

  set torchMode(CaptureTorchMode mode) {
    var isOn = mode == CaptureTorchMode.on;
    _methodChannel.invokeMethod('setTorchMode', isOn);
  }
}

class QRCaptureView extends StatefulWidget {
  final QRCaptureController controller;
  const QRCaptureView({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QRCaptureViewState();
  }
}

class QRCaptureViewState extends State<QRCaptureView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'plugins/qr_capture_view',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    } else {
      return AndroidView(
        viewType: 'plugins/qr_capture_view',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    }
  }
}
