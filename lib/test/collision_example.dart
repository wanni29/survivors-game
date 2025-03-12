import 'dart:developer';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CollisionExample extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
  late SamplePlayer player;
  Set<LogicalKeyboardKey> keysPressed = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 추가
    addAll([
      Wall(
        position: Vector2(0, 0),
        size: Vector2(200, size.y),
      ), // 왼쪽 벽
      Wall(
        position: Vector2(size.x - 100, 0),
        size: Vector2(200, size.y),
      ), // 오른쪽 벽
    ]);

    // 플레이어 추가
    player = SamplePlayer(position: Vector2(size.x / 2, size.y / 2));
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.position.add(player.velocity * dt);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.velocity = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      player.velocity.x = -player.speed;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      player.velocity.x = player.speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      player.velocity.y = -player.speed;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      player.velocity.y = player.speed;
    }
    // 반드시 결과값을 반환해야 함
    return KeyEventResult.handled;
  }
}

class SamplePlayer extends CircleComponent with CollisionCallbacks {
  final double speed = 200;
  Vector2 velocity = Vector2.zero();

  SamplePlayer({required Vector2 position})
      : super(
          position: position,
          radius: 20,
          paint: Paint()..color = const Color(0xFFFF0000),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    log('플레이어가 충돌함: ${other.runtimeType.toString()}');
  }
}

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.white,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    log('벽이 충돌을 감지함: ${other.runtimeType.toString()}');
    log('충돌 지점: $intersectionPoints');
  }
}
