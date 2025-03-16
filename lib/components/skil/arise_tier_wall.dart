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
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.white,
        );

  final bool shouldAddMoreWalls;
  final String underTier;
  bool collisionLeft = false;
  bool collisionRight = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = true;
    add(RectangleHitbox()..collisionType = CollisionType.passive);

    final gameWidth = gameRef.size.x;

    // 벽의 좌표와 크기 로그 출력
    log('벽의 위치: ${position}, 벽의 크기: ${size}');

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
    if (other is Player) {
      log('충돌발생! 위치 : $intersectionPoints');
      // 벽과 충돌 시, 이동 방향을 0으로 설정하여 이동을 막음

      // 왼쪽 벽에 충돌 여부 확인
      if (intersectionPoints.any((point) => point.x <= 550)) {
        collisionLeft = true; // 왼쪽 벽에 충돌 시
        log('충돌 로직 시작 - 왼쪽 벽에 충돌 => 왼쪽으로 이동 불가능!');
      }
      // 오른쪽 벽에 충돌 여부 확인
      final gameWidth = gameRef.size.x;
      if (intersectionPoints.any((point) => point.x >= gameWidth - size.x)) {
        collisionRight = true; // 오른쪽 벽에 충돌 시
        log('충돌 로직 시작 - 오른쪽 벽에 충돌 => 오른쪽으로 이동 불가능!');
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {
      collisionLeft = false; // 충돌이 끝났을 때 왼쪽 충돌 해제
      collisionRight = false; // 충돌이 끝났을 때 오른쪽 충돌 해제
      log('충돌 해제 발생! ${other.position}');

      // 여기서 플레이어의 위치를 체크해보고, 벽에서 벗어났는지 확인
      if (other.position.x > 550) {
        collisionLeft = false;
      }
      if (other.position.x < 930) {
        collisionRight = false;
      }

      log('collisionLeft -> $collisionLeft, collisionRight -> $collisionRight');
    }
    super.onCollisionEnd(other);
  }
}

class UnderTier extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  final String underTier;
  bool isCollidingWithWall = false; // 벽과 충돌 여부를 추적하는 변수

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
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }
}
