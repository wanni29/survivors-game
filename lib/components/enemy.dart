import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:survivors_game/components/exlamation_mart.dart';
import 'package:survivors_game/main.dart';
import 'dart:ui' as ui;

class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  Enemy({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(100, 100), position: position);

  double moveSpeed = 100.0; // 적 이동 속도
  late TimerComponent jumpTimer; // 점프 주기를 관리하는 타이머
  bool isKnockback = false;
  Vector2 knockbackDirection = Vector2.zero(); // 넉백 방향
  double knockbackStrength = 350.0; // 넉백 강도

  late ExclamationMark exclamationMark;
  late ExclamationMark questionMark;
  bool isHit = false; // 피격 상태 여부

  // 적이 죽는 애니메이션과 관련된 변수
  double lineWidth = 0;
  final double maxLineWidth = 90;
  final double speed = 80;
  double splitOffset = 0;
  bool isFocusing = false;
  bool isSplitting = false;
  bool isDrawingLine = false; // 빨간 선을 그리는 중인지 여부
  final double splitSpeed = 50;
  final double gap = 10;

  bool canMove = true; // 적이 움직일 수 있는지 여부

  @override
  Future<void> onLoad() async {
    debugMode = true;

    // 적도 히트 박스 추가
    add(RectangleHitbox());

    // 1.5초마다 자동으로 점프 실행 (점프하고 1.5초 대기 후 다시 점프)
    jumpTimer = TimerComponent(
      period: 1.5,
      repeat: true,
      onTick: jumpTowardsPlayer,
    );
    add(jumpTimer);

    // 빨간 느낌표 추가 (기본적으로 숨겨져 있음)
    exclamationMark = ExclamationMark(
      text: '!',
      position: Vector2(-15, -50),
      textRenderer: TextPaint(
        style: GoogleFonts.notoSans(
          fontSize: 50,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      ),
    );
    add(exclamationMark);
    exclamationMark.isVisible = false;

    questionMark = ExclamationMark(
      text: '?',
      position: Vector2(-15, -50),
      textRenderer: TextPaint(
        style: GoogleFonts.notoSans(
          fontSize: 50,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      ),
    );
    add(questionMark);
    questionMark.isVisible = false;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other.runtimeType.toString() == 'SpriteAnimationComponent') {
      Vector2 knockbackDirection = (position - other.position).normalized();
      applyKnockback(knockbackDirection);
    } else {
      // log('벽과 충돌했어요 ! - enemy 로직 / ${other.runtimeType.toString()}');
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 빨간 선 그리기 로직
    if (isDrawingLine) {
      isFocusing = true;
      if (lineWidth < maxLineWidth) {
        lineWidth += speed * dt;
      } else {
        // 선이 다 그려지면 분리 애니메이션 시작
        isSplitting = true;
        isDrawingLine = false;
      }
    }

    if (isSplitting) {
      if (splitOffset < size.x / 2) {
        splitOffset += splitSpeed * dt;
      }
    }

    if (isKnockback) {
      // 넉백 상태일 때, 넉백 방향으로 이동
      position.add(knockbackDirection * knockbackStrength * dt);

      // 넉백 시간이 지나면 넉백 상태 해제
      Future.delayed(Duration(milliseconds: 200), () {
        isKnockback = false; // 넉백 종료
      });
    } else if (!isSplitting && canMove) {
      // 플레이어의 위치를 추적하여 이동
      Vector2 direction = (gameRef.player.position - position).normalized();
      position.add(direction * moveSpeed * dt); // 천천히 플레이어에게 이동
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isSplitting) {
      super.render(canvas);
    }

    final srcSize = sprite!.srcSize;
    final image = sprite!.image;

    // 빨간선
    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    // 이미지에 빨간선 그리기
    final imageRed = Paint()
      ..colorFilter = ColorFilter.mode(Colors.red, BlendMode.srcATop);

    if (isDrawingLine) {
      // 빨간선 그리기
      canvas.drawLine(
        Offset(size.x / 2, 0), // 시작점
        Offset(size.x / 2, lineWidth), // 끝점
        paintRed,
      );
    } else if (isSplitting) {
      // 이미지가 분리되어 왼쪽과 오른쪽으로 벌어진다.
      Rect leftTarget =
          Rect.fromLTWH(gap - splitOffset - gap, 0, size.x / 2, size.y);

      Rect rightTarget =
          Rect.fromLTWH(gap + splitOffset + gap, 0, size.x / 2, size.y);

      // 왼쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(leftTarget); // 왼쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, srcSize.x / 2, srcSize.y),
        leftTarget,
        imageRed,
      );
      canvas.restore(); // 캔버스 복원

      // 오른쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(rightTarget); // 오른쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(srcSize.x / 2, 0, srcSize.x / 2, srcSize.y),
        rightTarget,
        imageRed,
      );
      canvas.restore(); // 캔버스 복원
    }
  }

  // 적의 이동기
  void jumpTowardsPlayer() {
    if (canMove) {
      // 플레이어 방향 계산
      Vector2 playerPos = gameRef.player.position;
      Vector2 jumpDirection =
          (playerPos - position).normalized(); // 플레이어 방향으로 이동

      // 점프 높이 & 거리 설정
      const double jumpDistance = 100.0; // 플레이어 쪽으로 이동하는 거리
      const double jumpHeight = 50.0; // 점프 높이
      const double jumpDuration = 0.5; // 점프 속도

      Vector2 targetPosition = position + jumpDirection * jumpDistance;

      add(
        MoveEffect.to(
          targetPosition + Vector2(0, -jumpHeight), // 위로 점프하면서 앞으로 이동
          EffectController(duration: jumpDuration, curve: Curves.easeOutBack),
          onComplete: () {},
        ),
      );
    }
  }

// 적의 넉백 당했을시 로직
  void applyKnockback(Vector2 direction) {
    isKnockback = true;
    knockbackDirection = direction.normalized(); // 방향을 정규화

    // 플레이어가 공격중일때
    if (gameRef.player.isAttacking) {
      // gameRef.enemyHit(20);

      // 테스팅용
      gameRef.enemyHit(100);

      // 피격시 빨간 느낌표 표시
      exclamationMark.isVisible = true;

      // 일정 시간 후 느낌표 숨기기
      Future.delayed(Duration(seconds: 1), () {
        exclamationMark.isVisible = false;
      });
    } else if (gameRef.player.isBlocking) {
      gameRef.enemyHit(0);

      // 피격시 빨간 느낌표 표시
      questionMark.isVisible = true;

      // 일정 시간 후 느낌표 숨기기
      Future.delayed(Duration(seconds: 1), () {
        questionMark.isVisible = false;
      });
    }

    add(
      SequenceEffect([
        // 넉백 이동 효과
        MoveByEffect(Vector2(6, 0), EffectController(duration: 0.04)),
        MoveByEffect(Vector2(-12, 0), EffectController(duration: 0.04)),
        MoveByEffect(Vector2(10, 0), EffectController(duration: 0.04)),
        MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.04)),
        MoveByEffect(Vector2(6, 0), EffectController(duration: 0.04)),
        MoveByEffect(Vector2(-4, 0), EffectController(duration: 0.04)),
      ]),
    );

    // 넉백 상태 해제는 SequenceEffect의 마지막에 처리
    Future.delayed(Duration(milliseconds: 200), () {
      isKnockback = false; // 넉백 종료
    });
  }
}
