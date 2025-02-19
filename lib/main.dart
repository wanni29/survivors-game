import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with PanDetector, KeyboardEvents {
  late SpriteComponent player;
  late SpriteComponent enermy;
  Vector2 moveDirection = Vector2.zero();

  @override
  Future<void> onLoad() async {
    // 배경 추가하기
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(50, 0), // 천천히 스크롤되는 배경
      repeat: ImageRepeat.repeat,
    );
    add(parallax);

    // 캐릭터 추가하기
    player = SpriteComponent()
      ..sprite = await loadSprite('player.jpg')
      ..size = Vector2(50, 50)
      ..position = size / 4;
    add(player);

    // 적 추가하기
    enermy = SpriteComponent()
      ..sprite = await loadSprite('enermy.png')
      ..size = Vector2(50, 65)
      ..position = size / 2;
    add(enermy);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.position.add(info.delta.global);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    moveDirection = Vector2.zero();
    double moveSpeed = 1.65;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveDirection.x = -moveSpeed;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveDirection.x = moveSpeed;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      moveDirection.y = -moveSpeed;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      // 수정된 부분
      moveDirection.y = moveSpeed;
    }

    return KeyEventResult.handled; // 반드시 결과값을 반환해야 함
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 캐릭터 이동 속도
    player.position += moveDirection * 200 * dt;
  }
}
