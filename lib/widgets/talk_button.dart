import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TalkButton extends StatefulWidget {
  final bool isListening;
  final bool isDisabled;
  final VoidCallback onPressed;

  const TalkButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
    this.isDisabled = false,
  });

  @override
  State<TalkButton> createState() => _TalkButtonState();
}

class _TalkButtonState extends State<TalkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TalkButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !old.isListening) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isListening) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isDisabled
        ? Colors.grey.shade800
        : widget.isListening
            ? AppTheme.error
            : AppTheme.accent;

    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _scale.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.isDisabled
                    ? []
                    : [
                        BoxShadow(
                          color: bgColor.withValues(
                            alpha: widget.isListening ? _glow.value : 0.4,
                          ),
                          blurRadius: widget.isListening ? 24 : 12,
                          spreadRadius: widget.isListening ? 4 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isListening ? Icons.mic : Icons.mic_none_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isListening ? 'Listening...' : 'Talk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
