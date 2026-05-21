import 'package:flutter/material.dart';

class SwipeDeleteTransaction extends StatefulWidget {
  const SwipeDeleteTransaction({
    super.key,
    required this.child,
    required this.onDelete,
  });

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<SwipeDeleteTransaction> createState() => _SwipeDeleteTransactionState();
}

class _SwipeDeleteTransactionState extends State<SwipeDeleteTransaction>
    with SingleTickerProviderStateMixin {
  static const _borderRadius = BorderRadius.all(Radius.circular(20));
  static const _dragSlop = 12.0;

  late final AnimationController _spring;
  double _offset = 0;
  Offset? _pointerStart;
  bool _horizontalDrag = false;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  Future<void> _animateTo(double target) async {
    final begin = _offset;
    final animation = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(parent: _spring, curve: Curves.elasticOut),
    );
    void tick() => setState(() => _offset = animation.value);
    animation.addListener(tick);
    _spring.value = 0;
    await _spring.forward(from: 0);
    animation.removeListener(tick);
    if (!mounted) return;
    setState(() => _offset = target);
    _spring.reset();
  }

  Future<void> _onDragEnd(double deleteWidth) async {
    if (_offset < -deleteWidth * 0.45) {
      await _animateTo(-deleteWidth);
      widget.onDelete();
      if (mounted) setState(() => _offset = 0);
    } else {
      await _animateTo(0);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _spring.stop();
    _pointerStart = event.position;
    _horizontalDrag = false;
  }

  void _onPointerMove(PointerMoveEvent event, double deleteWidth) {
    final start = _pointerStart;
    if (start == null) return;

    if (!_horizontalDrag) {
      final total = event.position - start;
      if (total.dx.abs() <= _dragSlop && total.dy.abs() <= _dragSlop) {
        return;
      }
      if (total.dx.abs() > total.dy.abs()) {
        _horizontalDrag = true;
      } else {
        _pointerStart = null;
        return;
      }
    }

    setState(() {
      _offset = (_offset + event.delta.dx).clamp(-deleteWidth, 0.0);
    });
  }

  Future<void> _onPointerUp(PointerUpEvent event, double deleteWidth) async {
    if (_horizontalDrag) {
      await _onDragEnd(deleteWidth);
    }
    _pointerStart = null;
    _horizontalDrag = false;
  }

  void _onPointerCancel(PointerCancelEvent event, double deleteWidth) {
    if (_horizontalDrag) {
      _animateTo(0);
    }
    _pointerStart = null;
    _horizontalDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    final deleteWidth = MediaQuery.sizeOf(context).width * 0.35;
    final offset = _offset.clamp(-deleteWidth, 0.0);
    final revealWidth = (-offset).clamp(0.0, deleteWidth);
    final errorColor = Theme.of(context).colorScheme.error;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: (event) => _onPointerMove(event, deleteWidth),
      onPointerUp: (event) => _onPointerUp(event, deleteWidth),
      onPointerCancel: (event) => _onPointerCancel(event, deleteWidth),
      child: ClipRRect(
        borderRadius: _borderRadius,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (revealWidth > 0)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: revealWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: errorColor,
                    borderRadius: _borderRadius,
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(offset, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
