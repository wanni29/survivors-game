import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Enemy extends SpriteComponent with CollisionCallbacks {
  Enemy({required Sprite sprite, required Vector2 position})
      : super(sprite: sprite, size: Vector2(50, 65), position: position);

  @override
  Future<void> onLoad() async {
    // 적도 히트 박스 추가
    add(RectangleHitbox());
  }
}
