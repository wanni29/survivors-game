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
  bool isAttacking = false; // 공격 중인지 확인하는 변수
  late SpriteAnimation attackAnimation;

  Player({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(50, 50), position: position);

  @override
  Future<void> onLoad() async {
    // 충돌 판정을 위한 히트박스 추가
    add(RectangleHitbox());

    // 공격 애니메이션 불러오기 (2줄짜리 이미지 대응)
    final spriteSheet = await gameRef.images.load('hit.png');

    attackAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.variable(
        amount: 10, // 프레임 수 (두 줄에 각 5프레임씩, 총 10프레임)
        stepTimes: List.filled(10, 0.03), // 각 프레임의 stepTime을 동일하게 0.05초로 설정
        textureSize: Vector2(64, 64), // 각 프레임의 크기
        amountPerRow: 5, // 한 줄에 5개의 프레임이 있다
        texturePosition: Vector2(0, 0), // 시트의 시작 위치 (0,0)
        loop: false, // 애니메이션이 반복되도록 설정
      ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      debugPrint('플레이어가 적과 충돌했어요!');
      isKnockback = true;
      FlameAudio.play('hit.mp3');

      Vector2 knockbackDirection = (position - other.position).normalized();
      double knockbackDistance = 100.0;

      add(
        MoveEffect.to(position + knockbackDirection * knockbackDistance,
            EffectController(duration: 0.5, curve: Curves.easeOutBack),
            onComplete: () {
          isKnockback = false;
        }),
      );

      (gameRef as MyGame).showRedFlash();
      (gameRef as MyGame).decreaseHealth();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void attack() {
    final attackComponent = SpriteAnimationComponent(
      animation: attackAnimation,
      size: Vector2(120, 120), // 공격 애니메이션 크기 조정
      position: position + Vector2(-35, -50), // 플레이어 위치 기준으로 배치
      removeOnFinish: true, // 애니메이션이 끝나면 삭제
    );

    // 빨간색 반짝임 효과 추가
    attackComponent.add(ColorEffect(
      Colors.red.withOpacity(0.5),
      EffectController(duration: 0.3, alternate: true),
    ));

    gameRef.add(attackComponent);

    // 공격 사운드 (나중에 추가)
    // FlameAudio.play('attack.mp3');
  }
}
