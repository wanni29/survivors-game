import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/components/player.dart';
import 'package:survivors_game/main.dart';

class AriseTierWall extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  AriseTierWall({
    required this.sprite,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  final Sprite sprite;
  final double screenWidth;
  final double screenHeight;
  final Vector2 wallSize = Vector2(100, 100);
  final double blackWallThickness = 400.0; // 벽의 두께 (400)
  final double padding = 20.0; // 위아래 패딩 설정

  List<SpriteComponent> leftWallImages = [];
  List<SpriteComponent> rightWallImages = [];

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()); // RectangleHitbox 추가

    debugMode = true;

    // 배치 가능한 세로 공간
    double availableHeight = screenHeight - (2 * padding); // 위아래 패딩을 뺀 높이

    // 왼쪽 벽 뒤에 검은색 벽 배치 (두께는 400)
    final leftBlackWall = RectangleComponent(
      size: Vector2(blackWallThickness, screenHeight), // 벽의 두께는 400, 높이는 화면 크기
      position: Vector2(0, 0), // 벽의 시작 위치 (화면 왼쪽 끝에 배치)
      paint: Paint()..color = Color(0xFF000000), // 검은색 벽
    );
    // leftBlackWalls.add(leftBlackWall); // 벽을 리스트에 추가
    leftBlackWall.add(RectangleHitbox()); // 왼쪽 벽에 Hitbox 추가
    add(leftBlackWall); // 게임에 추가

    // 왼쪽 벽에 배치할 8개의 이미지를 준비
    for (var i = 0; i < 8; i++) {
      final playerImage = SpriteComponent()
        ..sprite = sprite // 전달받은 sprite를 사용
        ..size = wallSize
        ..position = Vector2(
            leftBlackWall.position.x + blackWallThickness, // 벽의 끝 부분 뒤에 배치
            padding + i * (availableHeight / 8)); // 세로로 균등 배치, 패딩을 고려
      playerImage.add(RectangleHitbox());
      leftWallImages.add(playerImage);
      add(playerImage); // 게임에 추가
    }

    // 오른쪽 벽 뒤에 검은색 벽 배치 (두께는 400)
    final rightBlackWall = RectangleComponent(
      size: Vector2(blackWallThickness, screenHeight), // 벽의 두께는 400, 높이는 화면 크기
      position: Vector2(screenWidth - blackWallThickness, 0), // 화면 오른쪽 끝에 배치
      paint: Paint()..color = Color(0xFF000000), // 검은색 벽
    );
    rightBlackWall.add(RectangleHitbox()); // 오른쪽 벽에 Hitbox 추가
    // rightBlackWalls.add(rightBlackWall); // 벽을 리스트에 추가
    add(rightBlackWall); // 게임에 추가

    // 오른쪽 벽에 배치할 8개의 이미지를 준비
    for (int i = 0; i < 8; i++) {
      final playerImage = SpriteComponent()
        ..sprite = sprite // 전달받은 sprite를 사용
        ..size = wallSize
        ..position = Vector2(
            rightBlackWall.position.x - wallSize.x, // 벽의 끝 부분 뒤에 배치
            padding + i * (availableHeight / 8)); // 세로로 균등 배치, 패딩을 고려한 위치 계산
      playerImage.add(RectangleHitbox());
      rightWallImages.add(playerImage);
      add(playerImage); // 게임에 추가
    }
  }

  // 20250312 23:45i arise_tier_wall 에서 충돌감지가 되지 않음
  // 샘플링 시작해서 실험 후 재 적용 해볼것
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    log('충돌 시작 시점 로그: ${other.runtimeType.toString()}');
    log('충돌 시작 시점에서의 객체 정보: ${other.toString()}');

    log('충돌 감지 준비 완료: ${other.runtimeType}');

    debugPrint('충돌감지 - arise_tier_wall');
    print('충돌감지 - arise_tier_wall');

    if (other is Player) {
      debugPrint('충돌감지 - arise_tier_wall');
      print('충돌감지 - arise_tier_wall');
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
