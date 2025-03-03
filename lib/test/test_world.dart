import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/test/animation_image.dart';

class TestWorld extends FlameGame {
  late AnimationImage animationImage;

  @override
  Future<void> onLoad() async {
    // 배경 추가하기
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(50, 0), // 천천히 스크롤되는 배경
      repeat: ImageRepeat.repeat,
    );
    add(parallax);

    animationImage = AnimationImage(
      sprite: await loadSprite('enemy.png'),
      position: size / 2,
    );
    add(animationImage);
  }
}
