import 'dart:developer';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/main.dart';

class AriseTierWallAlive extends RectangleComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  AriseTierWallAlive({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.white,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 게임 화면 크기 가져오기
    double screenWidth = gameRef.size.x;
    double screenHeight = gameRef.size.y;

    // 왼쪽 벽 생성
    final leftWall = AriseTierWallAlive(
      position: Vector2(0, 0), // 화면 왼쪽 끝에 배치
      size: Vector2(50, screenHeight), // 벽의 너비는 50, 높이는 화면 크기
    );
    add(leftWall); // 왼쪽 벽을 게임에 추가

    // 오른쪽 벽 생성
    final rightWall = AriseTierWallAlive(
      position: Vector2(screenWidth - 50, 0), // 화면 오른쪽 끝에 배치
      size: Vector2(50, screenHeight), // 벽의 너비는 50, 높이는 화면 크기
    );
    add(rightWall); // 오른쪽 벽을 게임에 추가

    // 충돌을 위한 Hitbox 추가
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
