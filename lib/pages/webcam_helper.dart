// lib/helpers/webcam_helper.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class WebCamera {
  html.VideoElement? _video;

  /// Inisialisasi webcam dan pasang ke #camera-container
  Future<void> initialize() async {
    final container = html.document.getElementById('camera-container');
    if (container == null) {
      throw Exception("camera-container tidak ditemukan di DOM");
    }

    // Minta akses kamera depan (user)
    final stream = await html.window.navigator.mediaDevices!.getUserMedia({
      'video': {
        'facingMode': 'user', // kamera depan
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      },
      'audio': false,
    });

    final video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..srcObject = stream
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    container.children.clear();
    container.append(video);

    _video = video;

    // Pastikan video benar-benar mulai
    await video.play();
  }

  /// Capture frame dari webcam → Uint8List PNG
  Future<Uint8List> capture() async {
    final video = _video;
    if (video == null || video.videoWidth == 0 || video.videoHeight == 0) {
      throw Exception("Video belum siap untuk di-capture");
    }

    final canvas = html.CanvasElement(
      width: video.videoWidth,
      height: video.videoHeight,
    );
    final ctx = canvas.context2D;

    // gambar frame ke canvas
    ctx.drawImage(video, 0, 0);

    final dataUrl = canvas.toDataUrl("image/png");
    final base64 = dataUrl.split(",").last;

    final binary = html.window.atob(base64);
    final bytes = Uint8List(binary.length);
    for (int i = 0; i < binary.length; i++) {
      bytes[i] = binary.codeUnitAt(i);
    }
    return bytes;
  }

  void dispose() {
    _video?.srcObject?.getTracks().forEach((t) => t.stop());
    _video = null;
  }
}
