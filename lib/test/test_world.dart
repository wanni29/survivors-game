import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/test/animation_image.dart';

class TestWorld extends FlameGame {
  late AnimationImage animationImage;
  double circleRadius = 1000; // 초기 원의 반지름
  double shrinkSpeed = 500; // 원이 줄어드는 속도

  @override
  Future<void> onLoad() async {
    // 배경 추가하기
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(50, 0), // 천천히 스크롤되는 배경
      repeat: ImageRepeat.repeat,
    );
    add(parallax);

    // 애니메이션 이미지 추가하기
    animationImage = AnimationImage(
      sprite: await loadSprite('enemy.png'),
      position: size / 2,
    );
    add(animationImage);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 원이 점점 줄어들도록 함
    if (circleRadius > 120) {
      circleRadius -= shrinkSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 원의 클리핑 영역 설정
    canvas.save();
    Path path = Path()
      ..addOval(Rect.fromCircle(
        center: animationImage.position.toOffset(),
        radius: circleRadius,
      ))
      ..addRect(Rect.fromLTWH(0, 0, size.x, size.y))
      ..fillType = PathFillType.evenOdd;
    canvas.clipPath(path);

    // 배경을 검은색으로 설정
    final backgroundPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    // 클리핑 영역 해제
    canvas.restore();
  }
}
