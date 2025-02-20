import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/main.dart';

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  Enemy({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(50, 65), position: position);

  // 적 이동 속도
  double moveSpeed = 100.0;
  late TimerComponent jumpTimer; // 점프 주기를 관리하는 타이머

  @override
  Future<void> onLoad() async {
    // 적도 히트 박스 추가
    add(RectangleHitbox());

    // 1.5초마다 자동으로 점프 실행 (점프하고 1.5초 대기 후 다시 점프)
    jumpTimer = TimerComponent(
      period: 1.5,
      repeat: true,
      onTick: jumpTowardsPlayer,
    );
    add(jumpTimer);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 플레이어의 위치를 추적하여 이동
    Vector2 direction = (gameRef.player.position - position).normalized();
    position.add(direction * moveSpeed * dt); // 천천히 플레이어에게 이동
  }

  void jumpTowardsPlayer() {
    // 플레이어 방향 계산
    Vector2 playerPos = gameRef.player.position;
    Vector2 jumpDirection = (playerPos - position).normalized(); // 플레이어 방향으로 이동

    // 점프 높이 & 거리 설정
    const double jumpDistance = 100.0; // 플레이어 쪽으로 이동하는 거리
    const double jumpHeight = 50.0; // 점프 높이
    const double jumpDuration = 0.5; // 점프 속도

    Vector2 targetPosition = position + jumpDirection * jumpDistance;

    add(
      MoveEffect.to(
        targetPosition + Vector2(0, -jumpHeight), // 위로 점프하면서 앞으로 이동
        EffectController(duration: jumpDuration, curve: Curves.easeOutBack),
        onComplete: () {
          // 점프 후 착지 (다시 원래 높이로 돌아옴)
          // add(
          //   MoveEffect.to(
          //     targetPosition, // 착지 위치
          //     EffectController(
          //         duration: jumpDuration * 0.8, curve: Curves.easeIn),
          //   ),
          // );
        },
      ),
    );
  }
}
