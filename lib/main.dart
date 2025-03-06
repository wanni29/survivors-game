import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survivors_game/components/enemy.dart';
import 'package:survivors_game/components/health_bar.dart';
import 'package:survivors_game/components/player.dart';
import 'package:survivors_game/screens/game_over_screen.dart';
import 'package:survivors_game/screens/victory_screen.dart';
import 'package:survivors_game/test/clone_coding.dart';
import 'package:survivors_game/test/test_world.dart';
import 'package:survivors_game/test/camera_example.dart';

// 테스팅용
// void main() {
//   runApp(GameWidget(
//     game: TestWorld(),
//   ));
// }

// 게임 제작용
void main() {
  runApp(
    GameWidget(
      game: MyGame(),
      overlayBuilderMap: {
        'GameOver': (context, game) => GameOverScreen(game: game as MyGame),
        'Victory': (context, game) => VictoryScreen(game: game as MyGame),
        'RedFlash': (context, game) =>
            Container(color: Colors.red.withOpacity(0.3)),
      },
    ),
  );
}

class MyGame extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
  late Player player;
  late Enemy enermy;
  late HealthBar healthBar;
  Vector2 moveDirection = Vector2.zero();
  List<SpriteComponent> hearts = [];
  int playerHealth = 4; // 플레이어 체력 3
  bool spacePressed = false; // 연타 방지 로직 (변수값)

  @override
  Future<void> onLoad() async {
    // 사운드 캐시 다운로드 시키기
    await FlameAudio.audioCache
        .loadAll(['collision.mp3', 'hit.mp3', 'block.mp3', 'final_attack.mp3']);

    // 배경 추가하기
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.png')],
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

    // 적 체력바 추가하기
    healthBar = HealthBar(maxHealth: 100, currentHealth: 100)
      ..position = Vector2(0, size.y - 20) // 화면 하단에 배치
      ..size = Vector2(size.x, 20); // 전체 가로 너비
    add(healthBar);

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
      moveDirection.y = moveSpeed;
    }

    // -- 공격 코드 --
    if (keysPressed.contains(LogicalKeyboardKey.space) && !player.isAttacking) {
      // 스페이스 키가 눌렸고, 공격 중이 아니면 공격을 시작
      spacePressed = true;
    }

    if (spacePressed && !keysPressed.contains(LogicalKeyboardKey.space)) {
      // 스페이스 키를 뗐을 때 공격이 실행됨
      if (!player.isAttacking) {
        player.attack();
        player.isAttacking = true; // 공격 상태로 변경

        // 공격이 끝나면 다시 공격 가능하도록 설정
        Future.delayed(Duration(milliseconds: 150), () {
          player.isAttacking = false; // 공격이 끝난 후 다시 공격 가능
        });
      }
      spacePressed = false; // 키를 떼었으므로 상태 초기화
    }
    // -- 공격 코드 --

    // -- 방어 코드 --
    if (keysPressed.contains(LogicalKeyboardKey.shiftLeft) &&
        !player.isAttacking) {
      player.isBlocking = true;
    } else {
      player.isBlocking = false;
    }
    // -- 방어 코드 --

    // 반드시 결과값을 반환해야 함
    return KeyEventResult.handled;
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

  // player 체력 감소
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

  // 적 체력 감소
  void enemyHit(double damage) {
    healthBar.updateHealth(damage);

    if (healthBar.currentHealth == 0) {
      Future.delayed(Duration(milliseconds: 300), () {
        FlameAudio.play('final_attack.mp3');
      });
      // 게임 승리
      debugPrint('게임 승리');

      Future.delayed(Duration(milliseconds: 1800), () {
        overlays.add('Victory');
        // 게임 일시 정지
        pauseEngine();
      });
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

    // 가비지 데이터 제거 및 새로운 객체 생성
    remove(player);
    remove(enermy);
    remove(healthBar);

    player = Player(
      sprite: await loadSprite('player.jpg'),
      position: Vector2(size.x / 4, size.y / 4),
    );
    add(player);

    enermy = Enemy(
      sprite: await loadSprite('enemy.png'),
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(enermy);

    healthBar = HealthBar(maxHealth: 100, currentHealth: 100)
      ..position = Vector2(0, size.y - 20) // 화면 하단에 배치
      ..size = Vector2(size.x, 20);
    add(healthBar);

    // 🔹 엔진 다시 실행
    resumeEngine();
  }
}
