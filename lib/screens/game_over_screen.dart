import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:survivors_game/main.dart';

class GameOverScreen extends StatelessWidget {
  final MyGame game;
  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 흐려진 배경 만들기
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 블러 효과 추가
            child: Container(
              color: Colors.black.withOpacity(0.5), // 반투명 검정 배경,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  game.resetGame();
                  game.overlays.remove('GameOver'); // 게임 오버  UI 제거
                  game.resumeEngine();
                },
                child: const Text('다시 시작'),
              ),
            ],
          ),
        )
      ],
    );
  }
}
