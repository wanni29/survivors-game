import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/main.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  bool isBlocking = false; // 방어 상태 추가
  bool isKnockback = false; // 넉백 상태 변수 추가
  bool isAttacking = false; // 공격 중인지 확인하는 변수
  late SpriteAnimation attackAnimation;
  late SpriteAnimation blocakAnimation;

  Player({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(70, 70), position: position);

  @override
  Future<void> onLoad() async {
    debugMode = true;

    // 충돌 판정을 위한 히트박스 추가
    add(RectangleHitbox());

    // 공격 애니메이션 불러오기
    final hitSpriteSheet = await gameRef.images.load('hit.png');
    attackAnimation = SpriteAnimation.fromFrameData(
      hitSpriteSheet,
      SpriteAnimationData.variable(
        amount: 10, // 프레임 수 (두 줄에 각 5프레임씩, 총 10프레임)
        stepTimes: List.filled(10, 0.03), // 각 프레임의 stepTime을 동일하게 0.05초로 설정
        textureSize: Vector2(64, 64), // 각 프레임의 크기
        amountPerRow: 5, // 한 줄에 5개의 프레임이 있다
        texturePosition: Vector2(0, 0), // 시트의 시작 위치 (0,0)
        loop: false, // 애니메이션이 반복되도록 설정
      ),
    );

    // 방어 애니메이션 불러오기
    final blockSpriteSheet = await gameRef.images.load('block.png');
    blocakAnimation = SpriteAnimation.fromFrameData(
        blockSpriteSheet,
        SpriteAnimationData.variable(
          amount: 10,
          stepTimes: List.filled(10, 0.03), // 각 프레임의 stepTime을 동일하게 0.05초로 설정
          textureSize: Vector2(64, 64), // 각 프레임의 크기
          amountPerRow: 5, // 한 줄에 5개의 프레임이 있다
          texturePosition: Vector2(0, 128), // 세 번째 줄 시작 위치 (x=0, y=64*2)
          loop: false, // 애니메이션이 반복되도록 설정
        ));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      debugPrint('플레이어가 적과 충돌했어요!');

      if (!isBlocking) {
        isKnockback = true;
        FlameAudio.play('collision.mp3');

        // 방어를 안하고 충돌시 넉백 계산
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
      } else {
        debugPrint(' 방어 성공! ');

        // 방어를 하고 충돌시 넉백 계산
        Vector2 knockbackDirection = (position - other.position).normalized();
        double knockbackDistance = 50.0;

        add(
          MoveEffect.to(position + knockbackDirection * knockbackDistance,
              EffectController(duration: 0.5, curve: Curves.easeOutBack),
              onComplete: () {
            isKnockback = false;
          }),
        );

        block();
      }
    } else {
      log('벽과 충돌했어요 -  player 로직 / ${other.runtimeType.toString()}');
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

    attackComponent.add(RectangleHitbox());

    // 빨간색 반짝임 효과 추가
    attackComponent.add(ColorEffect(
      Colors.red.withOpacity(0.5),
      EffectController(duration: 0.3, alternate: true),
    ));

    gameRef.add(attackComponent);

    // 공격 사운드 (나중에 추가)
    FlameAudio.play('hit.mp3');
  }

  void block() {
    final blockComponent = SpriteAnimationComponent(
      animation: blocakAnimation,
      size: Vector2(120, 120),
      position: position,
      removeOnFinish: true,
    );

    blockComponent.add(CircleHitbox());

    gameRef.add(blockComponent);

    // 방어 사운드
    FlameAudio.play('block.mp3');
  }
}
