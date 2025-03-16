import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/components/player.dart';
import 'package:survivors_game/main.dart';

class AriseTierWall extends RectangleComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  AriseTierWall({
    required Vector2 position,
    required Vector2 size,
    required this.underTier,
    this.shouldAddMoreWalls = false,
    this.padding = 20.0, // 기본 패딩 값 추가
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.white,
        );

  final bool shouldAddMoreWalls;
  final String underTier;
  final double padding; // 패딩 값

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = true;
    add(RectangleHitbox()..collisionType = CollisionType.active);

    final gameWidth = gameRef.size.x;
    final gameHeight = gameRef.size.y;
    if (shouldAddMoreWalls) {
      // 화면 오른쪽 끝에 벽 추가
      final rightWall = AriseTierWall(
          position: Vector2(gameWidth - size.x, 0),
          size: size,
          underTier: underTier);

      // 벽에 히트박스를 추가하여 충돌을 감지하도록 설정
      rightWall.add(RectangleHitbox()..collisionType = CollisionType.active);

      gameRef.add(rightWall);
    }

    // 화면 높이에 맞게 8개의 UnderTier 배치 (패딩 고려)
    _addUnderTier(Vector2(position.x + size.x, 0), gameHeight); // 왼쪽 벽 앞
    _addUnderTier(Vector2(gameWidth - size.x - 100, 0), gameHeight); // 오른쪽 벽 앞
  }

  void _addUnderTier(Vector2 startPosition, double gameHeight) {
    // UnderTier의 크기 계산: 세로로 8개가 들어가게 하기 위해
    double underTierHeight = (gameHeight - 2 * padding) / 8; // 패딩을 빼고 나누기

    for (int i = 0; i < 8; i++) {
      // 세로 배치 시, 위 아래에 패딩을 주어 배치
      add(UnderTier(
          position: Vector2(startPosition.x, i * underTierHeight + padding),
          underTier: underTier,
          size: Vector2(100, underTierHeight))); // 세로 크기를 동적으로 설정
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }
}

class UnderTier extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  final String underTier;
  bool isCollidingWithWall = false; // 벽과 충돌 여부를 추적하는 변수

  UnderTier({
    required Vector2 position,
    required this.underTier,
    required Vector2 size, // 동적으로 설정된 크기
  }) : super(
          position: position,
          size: size, // 동적으로 설정된 크기 사용
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(underTier);
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }
}
