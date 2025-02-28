import 'package:flame/game.dart';
import 'package:survivors_game/test/animation_image.dart';

import 'package:survivors_game/test/animation_rectangle.dart';

class TestWorld extends FlameGame {
  late AnimationImage animationImage;
  @override
  Future<void> onLoad() async {
    animationImage = AnimationImage(
      sprite: await loadSprite('enemy.png'),
      position: size / 2,
    );
    add(animationImage);
  }
}
