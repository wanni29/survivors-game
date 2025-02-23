import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  double maxHealth;
  double currentHealth;

  HealthBar({required this.maxHealth, required this.currentHealth});

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 바탕색 (검은색)
    final backgroundPaint = Paint()..color = Colors.black;
    canvas.drawRect(size.toRect(), backgroundPaint);

    // 체력 바 (빨간색)
    final healthPaint = Paint()..color = Colors.red;
    double healthWidth = (currentHealth / maxHealth) * size.x; // 체력에 따라 줄어드는 너비
    canvas.drawRect(Rect.fromLTWH(0, 0, healthWidth, size.y), healthPaint);
  }

  // 체력을 업데이트하는 메서드
  void updateHealth(double damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
    add(SequenceEffect([
      MoveByEffect(Vector2(2, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(-4, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(2, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(2, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(-4, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(2, 0), EffectController(duration: 0.05)),
    ]));
  }
}
