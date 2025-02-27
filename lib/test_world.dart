import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

class TestWorld extends FlameGame {
  late AnimationImageTest animationImageTest;
  @override
  Future<void> onLoad() async {
    // add(AnimationRectangle());

    animationImageTest = AnimationImageTest(
      sprite: await loadSprite('enemy.png'),
      position: size / 4,
    );
    add(animationImageTest);
  }
}

// 기본 도형으로 잘린 효과 구현
class AnimationRectangle extends PositionComponent {
  double lineWidth = 0; // 빨간 선 길이
  final double maxLineWidth = 100; // 빨간 선 최종 길이
  final double speed = 40; // 선이 증가하는 속도
  bool isSplitting = false; // 분리 여부
  double splitOffset = 0; // 네모가 분리될 때 양쪽으로 벌어지는 정도
  final double splitSpeed = 50; // 분리 속도

  AnimationRectangle() {
    size = Vector2(100, 100); // 사각형 크기
    position = Vector2(150, 200); // 초기 위치
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.blue;
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    if (!isSplitting) {
      // 1️⃣ 처음에는 하나의 네모 + 중앙의 빨간 선
      canvas.drawRect(size.toRect(), paint);
      canvas.drawLine(
          Offset(size.x / 2, 0), Offset(size.x / 2, lineWidth), linePaint);
    } else {
      // 2️⃣ 점점 나눠지는 네모 (왼쪽 / 오른쪽)
      Rect leftHalf = Rect.fromLTWH(-splitOffset, 0, size.x / 2, size.y);
      Rect rightHalf =
          Rect.fromLTWH(size.x / 2 + splitOffset, 0, size.x / 2, size.y);

      canvas.drawRect(leftHalf, paint);
      canvas.drawRect(rightHalf, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isSplitting) {
      // 선이 다 그려질 때까지 증가
      if (lineWidth < maxLineWidth) {
        lineWidth += speed * dt;
      } else {
        // 다 그려지면 분리 시작!
        isSplitting = true;
      }
    } else {
      // 네모가 천천히 좌우로 벌어짐
      if (splitOffset < size.x / 2) {
        splitOffset += splitSpeed * dt;
      }
    }
  }
}

class AnimationImageTest extends SpriteComponent {
  double lineWidth = 0; // 빨간 선 길이
  final double maxLineWidth = 100; // 빨간 선 최종 길이
  final double speed = 40; // 선이 증가하는 속도
  bool isSplitting = false; // 분리 여부
  double splitOffset = 0; // 이미지가 분리될 때 양쪽으로 벌어지는 정도
  final double splitSpeed = 50; // 분리 속도
  final double gap = 10; // 이미지 사이 간격

  AnimationImageTest({required Sprite sprite, required Vector2 position})
      : super(
            sprite: sprite,
            size: Vector2(100, 100),
            position: position,
            paint: Paint()
              ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final srcSize = sprite!.srcSize;
    final image = sprite!.image;

    // 빨간 선을 그리기 위해
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    // **ColorFilter를 사용하여 이미지 위에 파란색을 덧씌우기**
    final blueFilter =
        ColorFilter.mode(Colors.blue, BlendMode.srcATop); // 파란색 덧씌우기

    // 파란색 필터를 적용해서 이미지 그리기
    final bluePaint = Paint()..colorFilter = blueFilter;

    // 빨간 선 그리기
    if (!isSplitting) {
      canvas.drawLine(
        Offset(size.x / 2, 0),
        Offset(size.x / 2, lineWidth),
        paint,
      );
    } else {
      // 이미지가 분리되어 왼쪽과 오른쪽으로 벌어짐
      Rect leftTarget = Rect.fromLTWH(
          position.x - splitOffset - gap, position.y, size.x / 2, size.y);
      Rect rightTarget = Rect.fromLTWH(
          position.x + splitOffset + gap, position.y, size.x / 2, size.y);

      // 왼쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(leftTarget); // 왼쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, srcSize.x / 2, srcSize.y),
        leftTarget,
        bluePaint,
      );
      canvas.restore(); // 캔버스 복원

      // 오른쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(rightTarget); // 오른쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(srcSize.x / 2, 0, srcSize.x / 2, srcSize.y),
        rightTarget,
        bluePaint,
      );
      canvas.restore(); // 캔버스 복원
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 선이 그려지는 모션
    if (!isSplitting) {
      if (lineWidth < maxLineWidth) {
        lineWidth += speed * dt;
      } else {
        isSplitting = true; // 선이 다 그려지면 분리 애니메이션 시작
      }
    } else {
      // 이미지가 좌우로 벌어짐
      if (splitOffset < size.x / 2) {
        splitOffset += splitSpeed * dt;
      }
    }
  }
}
