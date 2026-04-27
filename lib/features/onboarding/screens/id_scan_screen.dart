import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../services/formation_state.dart';

/// A-11 · Scan ID document. Top-level route.
/// Uses the device's rear camera to capture a photo of the document
/// page (passport / DL / BRP). The capture path is stored on
/// [FormationState] for later upload to a verification provider.
/// NFC chip read isn't implemented yet — it requires MRZ OCR + BAC/PACE
/// crypto on top of nfc_manager and is tracked separately.
class IdScanScreen extends StatefulWidget {
  const IdScanScreen({super.key});

  @override
  State<IdScanScreen> createState() => _IdScanScreenState();
}

class _IdScanScreenState extends State<IdScanScreen> {
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
      // Prefer back camera; fall back to first available.
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final controller = CameraController(
        back,
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
      FormationProvider.read(context).setDocumentPhoto(shot.path);
      context.push('/id-selfie');
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
              title: 'Scan your\npassport.',
              subtitle:
                  'Hold the photo page flat in the frame. ECCTA-compliant document capture.',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _CameraSurface(
                    initialising: _initialising,
                    error: _initError,
                    controller: _controller,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.previewSize?.height ?? 1,
            height: controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(controller!),
          ),
        ),
        // Document frame overlay
        Center(
          child: AspectRatio(
            aspectRatio: 1.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
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
