import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

class AnimationImage extends SpriteComponent {
  // 빨간선 길이
  double lineWidth = 0;

  // 빨간선 최종 길이
  final double maxLineWidth = 100;

  // 선이 증가하는 속도
  final double speed = 40;

  // 이미지가 분리될 때 양쪽으로 벌어지는 정도
  double splitOffset = 0;

  // 분리 여부
  bool isSplitting = false;

  // 분리 속도
  final double splitSpeed = 50;

  // 이미지 사이 간격
  final double gap = 10;

  // 이미지가 보이는지 여부
  bool isVisible = true;

  AnimationImage({
    required Sprite sprite,
    required Vector2 position,
  }) : super(
            sprite: sprite,
            size: Vector2(100, 100),
            position: position,
            anchor: Anchor.center,
            paint: Paint()
              ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final srcSize = sprite!.srcSize;
    final image = sprite!.image;

    // 빨간선
    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    // 파란선
    final paintBlue = Paint()
      ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop);

    // 투명선
    final paintTransparent = Paint()
      ..colorFilter = ColorFilter.mode(Colors.transparent, BlendMode.srcATop);

    // isVisible이 true일 때는 기존 이미지를 그리지 않음
    if (isVisible && !isSplitting) {
      // 빨간선만 그리기
      canvas.drawLine(
        Offset(size.x / 2, 0), // 시작점
        Offset(size.x / 2, lineWidth), // 끝점
        paintRed,
      );
    } else {
      // 이미지가 분리되어 왼쪽과 오른쪽으로 벌어진다.
      Rect leftTarget =
          Rect.fromLTWH(20 - splitOffset - gap, 0, size.x / 2, size.y);

      Rect rightTarget =
          Rect.fromLTWH(20 + splitOffset + gap, 0, size.x / 2, size.y);

      // 왼쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(leftTarget); // 왼쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, srcSize.x / 2, srcSize.y),
        leftTarget,
        paintBlue,
      );
      canvas.restore(); // 캔버스 복원

      // 오른쪽 반 그리기
      canvas.save(); // 캔버스를 저장
      canvas.clipRect(rightTarget); // 오른쪽 반만 잘라서 그리기
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(srcSize.x / 2, 0, srcSize.x / 2, srcSize.y),
        rightTarget,
        paintBlue,
      );
      canvas.restore(); // 캔버스 복원
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isSplitting) {
      if (lineWidth < maxLineWidth) {
        lineWidth += speed * dt;
      } else {
        // 선이 다 그려지면 분리 애니메이션 시작
        isSplitting = true;

        // 기존 이미지는 숨기기
        isVisible = false;
      }
    } else {
      // 이미지가 좌우로 벌어짐
      if (splitOffset < size.x / 2) {
        splitOffset += splitSpeed * dt;
      }
    }
  }
}
