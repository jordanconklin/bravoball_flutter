import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Animation;

/// Drop-in replacement for RiveAnimation.asset (Rive 0.14+ API).
/// Loads a Rive asset and displays it with the new RiveWidget API.
class RiveAssetWidget extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final Widget? placeholder;
  final List<String>? stateMachines;

  const RiveAssetWidget({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.stateMachines,
  });

  @override
  State<RiveAssetWidget> createState() => _RiveAssetWidgetState();
}

class _RiveAssetWidgetState extends State<RiveAssetWidget> {
  File? _file;
  RiveWidgetController? _controller;
  bool _loaded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await File.asset(widget.assetPath, riveFactory: Factory.rive);
      if (mounted && file != null) {
        _file = file;
        _controller = widget.stateMachines != null &&
                widget.stateMachines!.isNotEmpty
            ? RiveWidgetController(
                file,
                stateMachineSelector: StateMachineSelector.byName(
                    widget.stateMachines!.first),
              )
            : RiveWidgetController(file);
        setState(() => _loaded = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Fit _boxFitToFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return Fit.contain;
      case BoxFit.cover:
        return Fit.cover;
      case BoxFit.fill:
        return Fit.fill;
      case BoxFit.fitWidth:
        return Fit.fitWidth;
      case BoxFit.fitHeight:
        return Fit.fitHeight;
      case BoxFit.none:
        return Fit.none;
      case BoxFit.scaleDown:
        return Fit.scaleDown;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    if (!_loaded || _controller == null) {
      return widget.placeholder ?? const Center(child: SizedBox.shrink());
    }
    return RiveWidget(
      controller: _controller!,
      fit: _boxFitToFit(widget.fit),
    );
  }
}
