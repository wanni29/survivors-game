import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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
