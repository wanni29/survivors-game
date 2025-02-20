import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/components/player.dart';
import 'package:survivors_game/screens/game_over_screen.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
      overlayBuilderMap: {
        'GameOver': (context, game) => GameOverScreen(game: game as MyGame),
        'RedFlash': (context, game) =>
            Container(color: Colors.red.withOpacity(0.3))
      },
    ),
  );
}

class MyGame extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
  late Player player;
  late Enemy enermy;
  Vector2 moveDirection = Vector2.zero();
  List<SpriteComponent> hearts = [];
  int playerHealth = 4; // 플레이어 체력 3

  @override
  Future<void> onLoad() async {
    // 사운드 캐시 다운로드 시키기
    await FlameAudio.audioCache.loadAll(['hit.mp3']);

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
    if (!player.isKnockback) {
      player.position.add(info.delta.global);
    }
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

      if (playerHealth >= 1) {
        remove(hearts[playerHealth - 1]);
      }

      debugPrint('체력 감소! 남은 체력 : $playerHealth');
    }
    if (playerHealth == 0) {
      // 게임 오버 화면
      debugPrint('게임 오버!');

      // 게임 오버 UI 표시
      overlays.add('GameOver');

      // 게임 일시정지
      pauseEngine();
    }
  }

  // 빨간색 오버레이 표시 함수
  void showRedFlash() {
    overlays.add('RedFlash'); // 빨간 화면 추가

    // 0.3초 후에 자동으로 사라지게 함
    add(TimerComponent(
        period: 0.5,
        onTick: () {
          overlays.remove('RedFlash');
        }));
  }

  void resetGame() async {
    // 체력 초기화
    playerHealth = 4;

    // 하트 다시 추가
    hearts.clear();
    _addHearts();

    // 플레이어 위치 초기화
    player.position = size / 4;

    // 적 위치 초기화
    enermy.position = size / 2;

    // 🔹 엔진 다시 실행
    resumeEngine();
  }
}
