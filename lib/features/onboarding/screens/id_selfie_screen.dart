import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../services/formation_state.dart';

/// A-12 · Liveness selfie. Top-level route.
/// Front camera capture for face-match against the document. A real
/// production implementation would also run liveness detection (random
/// head turn / blink prompts) — that needs an SDK or ML Kit pipeline.
class IdSelfieScreen extends StatefulWidget {
  const IdSelfieScreen({super.key});

  @override
  State<IdSelfieScreen> createState() => _IdSelfieScreenState();
}

class _IdSelfieScreenState extends State<IdSelfieScreen> {
  CameraController? _controller;
  bool _initialising = true;
  String? _initError;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initialising = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initialising = false;
        _initError =
            'Camera unavailable. ${e.toString().split('\n').first}';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final shot = await c.takePicture();
      if (!mounted) return;
      FormationProvider.read(context).setSelfiePhoto(shot.path);
      context.push('/id-verified');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = 'Capture failed: $e';
        _capturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BackBar(),
            const QHeader(
              title: 'Quick selfie.',
              subtitle:
                  'Companies House requires a biometric face-match against your document. No glasses, good lighting.',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _CameraSurface(
                      initialising: _initialising,
                      error: _initError,
                      controller: _controller,
                    ),
                  ),
                ),
              ),
            ),
            QBottomBar(
              child: QButton(
                label: _capturing ? 'Capturing…' : 'Capture',
                onPressed:
                    (!_capturing && _controller?.value.isInitialized == true)
                        ? _capture
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraSurface extends StatelessWidget {
  final bool initialising;
  final String? error;
  final CameraController? controller;

  const _CameraSurface({
    required this.initialising,
    required this.error,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return ColoredBox(
        color: QPayTokens.cardBase,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: QPayType.statusLine,
            ),
          ),
        ),
      );
    }
    if (initialising || controller == null) {
      return const ColoredBox(
        color: QPayTokens.cardBase,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: QPayTokens.ink3,
            ),
          ),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller!.value.previewSize?.height ?? 1,
        height: controller!.value.previewSize?.width ?? 1,
        child: CameraPreview(controller!),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(QPayTokens.s5, 10, QPayTokens.s6, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
