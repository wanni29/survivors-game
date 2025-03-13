import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/main.dart';

class AriseTierWall extends RectangleComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  AriseTierWall({
    required Vector2 position,
    required Vector2 size,
    required this.underTier,
    this.shouladAddMoreWalls = false,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.white,
        );

  final bool shouladAddMoreWalls;
  final String underTier;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);

    final gameWidth = gameRef.size.x;

    if (shouladAddMoreWalls) {
      // 화면 오른쪽 끝에 벽 추가
      final gameWidth = gameRef.size.x; // 게임 화면의 너비
      add(AriseTierWall(
          position: Vector2(gameWidth - size.x, 0),
          size: size,
          underTier: underTier));
    }

    // 왼쪽과 오른쪽 벽 앞에 플레이어 8개 세로로 나열
    _addUnderTier(Vector2(position.x + size.x, 0)); // 왼쪽 벽 앞
    _addUnderTier(Vector2(gameWidth - size.x - 100, 0)); // 오른쪽 벽 앞
  }

  void _addUnderTier(Vector2 startPosition) {
    for (int i = 0; i < 8; i++) {
      add(UnderTier(
          position: Vector2(startPosition.x, i * 100.0), underTier: underTier));
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    log('충돌 지점: $intersectionPoints - AriseTierWall Collision here!');
  }
}

class UnderTier extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  final String underTier;

  UnderTier({
    required Vector2 position,
    required this.underTier,
  }) : super(
          position: position,
          size: Vector2(100, 100), // 플레이어 크기
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(underTier);
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    log('충돌 지점: $intersectionPoints - UnderTier Collision here!');
  }
}
