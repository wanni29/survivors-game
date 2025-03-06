import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_camera_tools/flame_camera_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraExample extends FlameGame with HasKeyboardHandlerComponents {
  final player = Example(position: Vector2.all(0), size: Vector2.all(50));
  final someComponent = RectangleComponent(
    position: Vector2.all(200),
    size: Vector2.all(100),
    paint: Paint()..color = Colors.green,
  );

  @override
  FutureOr<void> onLoad() {
    world.add(player);
    world.add(someComponent);

    add(ButtonComponent("Follow", Vector2(20, 20), () {
      camera.smoothFollow(player, stiffness: 2);
    }));

    add(ButtonComponent("Enemy Follow", Vector2(20, 100), () {
      camera.smoothFollow(someComponent, stiffness: 2);
    }));

    add(ButtonComponent("Zoom In", Vector2(20, 180), () {
      camera.zoomTo(2, duration: 1);
    }));

    add(ButtonComponent("Zoom Out", Vector2(20, 260), () {
      camera.zoomTo(1, duration: 1);
    }));

    return super.onLoad();
  }
}

class Example extends RectangleComponent with KeyboardHandler {
  Example({super.position, super.size})
      : super(paint: Paint()..color = Colors.red);

  Set<LogicalKeyboardKey> _keys = {};
  final double _movementSpeed = 300;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keys = keysPressed;
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = Vector2.zero();

    if (_keys.contains(LogicalKeyboardKey.keyW)) {
      direction.y = -1;
    }
    if (_keys.contains(LogicalKeyboardKey.keyA)) {
      direction.x = -1;
    }
    if (_keys.contains(LogicalKeyboardKey.keyS)) {
      direction.y = 1;
    }
    if (_keys.contains(LogicalKeyboardKey.keyD)) {
      direction.x = 1;
    }

    if (!direction.isZero()) {
      direction.normalize();
      position += direction * _movementSpeed * dt;
    }
  }
}

class ButtonComponent extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onTap;

  ButtonComponent(this.text, Vector2 position, this.onTap) {
    this.position = position;
    size = Vector2(120, 50);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
          (size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
