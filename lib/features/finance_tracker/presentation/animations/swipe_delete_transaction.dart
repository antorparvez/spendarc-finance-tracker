import 'package:flutter/material.dart';

/// Swipe left to reveal delete action; red background only appears while dragging.
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
  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;
  double _dragOffset = 0;

  static const _deleteRatio = 0.32;
  static const _confirmRatio = 0.42;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  Future<void> _snapTo(double target) async {
    final begin = _dragOffset;
    _snapAnimation = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );

    void listener() {
      if (_snapAnimation != null) {
        setState(() => _dragOffset = _snapAnimation!.value);
      }
    }

    _snapAnimation!.addListener(listener);
    _snapController
      ..stop()
      ..value = 0;
    await _snapController.forward();
    _snapAnimation!.removeListener(listener);
    setState(() => _dragOffset = target);
  }

  @override
  Widget build(BuildContext context) {
    final maxReveal = MediaQuery.sizeOf(context).width * _deleteRatio;
    final reveal = (-_dragOffset).clamp(0.0, maxReveal);
    final slideX = _dragOffset.clamp(-maxReveal, 0.0);
    final errorColor = Theme.of(context).colorScheme.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (reveal > 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: reveal,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(slideX, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                _snapController.stop();
                setState(() {
                  _dragOffset = (_dragOffset + details.delta.dx)
                      .clamp(-maxReveal, 0.0);
                });
              },
              onHorizontalDragEnd: (details) async {
                final velocity = details.primaryVelocity ?? 0;
                final shouldDelete = _dragOffset < -maxReveal * _confirmRatio ||
                    velocity < -400;

                if (shouldDelete) {
                  await _snapTo(-maxReveal);
                  widget.onDelete();
                  if (mounted) setState(() => _dragOffset = 0);
                } else {
                  await _snapTo(0);
                }
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
