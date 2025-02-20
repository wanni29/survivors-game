import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/main.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  bool isKnockback = false; // 넉백 상태 변수 추가

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
      // 충돌시 넉백 효과 구현하기
      debugPrint('플레이어가 적과 충돌했어요!');

      // 넉백 시작 -> 조작 막기
      isKnockback = true;

      // 충돌 효과음
      FlameAudio.play('hit.mp3');

      // 충돌 방향 계산
      Vector2 knockbackDirection = (position - other.position).normalized();

      // 넉백 거리 설정(너무 멀리 튕기지 않도록 조절)
      double knockbackDistance = 100.0;

      // 애니메이션 효과로 넉백이 너무 갑작스럽게 이루어지는것을 막음(자연스럽게!)
      add(
        MoveEffect.to(
            position + knockbackDirection * knockbackDistance, // 목표 위치
            EffectController(
                duration: 0.5, curve: Curves.easeOutBack), // 0.3초 동안 부드럽게 이동
            onComplete: () {
          isKnockback = false; // 넉백 끝 -> 다시 조작 가능
        }),
      );

      // 충돌 및 피격 시 빨간색 화면 깜빡이기
      (gameRef as MyGame).showRedFlash();

      // 체력 감소 함수 호출
      (gameRef as MyGame).decreaseHealth();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
