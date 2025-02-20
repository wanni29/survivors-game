import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/components/player.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
  late Player player;
  late Enemy enermy;
  Vector2 moveDirection = Vector2.zero();
  List<SpriteComponent> hearts = [];
  int playerHealth = 3; // 플레이어 체력 3

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
    player = Player(
      sprite: await loadSprite('player.jpg'),
      position: size / 4,
    );
    add(player);

    // 적 추가하기
    enermy = Enemy(
      sprite: await loadSprite('enemy.png'),
      position: size / 2,
    );
    add(enermy);

    // 하트 UI 추가
    _addHearts();
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

  void _addHearts() async {
    for (var i = 0; i < 3; i++) {
      final heart = SpriteComponent()
        ..sprite = await loadSprite('heart.png')
        ..size = Vector2(80, 80)
        ..position = Vector2(size.x - (85 * (i + 1)), 10); // 우측 상단 정렬
      hearts.add(heart);
      add(heart);
    }
  }

  void decreaseHealth() {
    if (playerHealth > 0) {
      playerHealth--;
      remove(hearts[playerHealth]);
      debugPrint('체력 감소! 남은 체력 : $playerHealth');
    }
    if (playerHealth == 0) {
      debugPrint('게임 오버!');
      // 게임 오버 화면
    }
  }
}
