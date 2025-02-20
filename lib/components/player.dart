import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/components/enemy.dart';

class Player extends SpriteComponent with CollisionCallbacks {
  Player({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(50, 50), position: position);

  @override
  Future<void> onLoad() async {
    // 충돌 판정을 위한 히트박스 추가
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      debugPrint('플레이어가 적과 충돌했어요!');
      // 충돌 시 로직 (체력감소 구현하기)
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
