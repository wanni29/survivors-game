import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:survivors_game/test/animation_image.dart';

class CloneCodingWorld extends FlameGame {
  late AnimationImage animationImage;
  double circleRadius = 1000;
  double shrinkSpeed = 500;

  @override
  Future<void> onLoad() async {
    // 배경추가하기
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(50, 0),
      repeat: ImageRepeat.repeat,
    );
    add(parallax);
  }
}
