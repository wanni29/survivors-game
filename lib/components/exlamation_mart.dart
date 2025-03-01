import 'dart:ui';

import 'package:flame/components.dart';

class ExclamationMark extends TextComponent {
  bool isVisible;

  ExclamationMark({
    required String text,
    required Vector2 position,
    required TextPaint textRenderer,
    this.isVisible = false,
  }) : super(
          text: text,
          position: position,
          textRenderer: textRenderer,
        );

  @override
  void render(Canvas canvas) {
    if (isVisible) {
      super.render(canvas); // isVisible이 true일 때만 그리기
    }
  }
}
