# 토이프로젝트 : 생존게임만들기
- 시작일자 : 2025.02.19.수요일 23:30분


# 에러일지
<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.02.20.목요일 01:30분]에러제목 : The following ImageCodecException was thrown building FutureBuilder<void>(dirty, state:
_FutureBuilderState<void>#3f27f):
Failed to decode image using the browser's ImageDecoder API.
Image source: encoded image bytes
Original browser error: InvalidStateError: Failed to retrieve track metadata.
<br>
<br>


Flutter 웹 프로젝트를 실행할 때, 기본적으로 CanvasKit 렌더러를 사용하게 된다.  
그러나 크롬 브라우저는 HTML 기반 렌더링을 기본적으로 허용하며,  
CanvasKit은 WebGL을 활용하기 때문에 CORS 정책에 의해 이미지 로딩이 차단될 수 있다.
<br>
이를 해결하기 위해, 렌더링 방식을 HTML 렌더러로 변경하면 된다.
```
flutter run -d chrome --web-renderer html
```
</div>

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.02.20.목요일 10:20분]에러제목 : CollisionCallbacks을 적용해도 충돌감지가 되지 않았던 이유
<br>
<br>
extends Flame에 충돌을 감지하는 리스너를 달아주어야 한다.
아래의 코드처럼 최상위 루트에 감지기를 달아줌으로써 기능을 구현할수있다.

```
class MyGame extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
        ...
    }

```

</div>


<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.02.24.월요일 18:30분] 보수 작업 필요 - 각각의 코드가 책임이 없는 상황임, main.dart안에 player와 enemy의 메소드가 섞여 있는 상황이라 다음에 유지 및 보수작업 또는 새로운 로직을  추가할때 상당히 복잡함을 느낀다.
지금까지 로직은 진짜 필수 기능만을 만들어 둔것이기 때문에 앞으로 더 많은 기술들이나 
여러 공격 형태 패턴들이 나오게 될때 더욱 더 복잡하게 진행이 될것으로 예상이 됨.
<br/>
그렇기 때문에 로직을 좀 더 단순화 시킨 이후 적의 스킬이라던지, 다양한 패턴들을 넣는것이 좋다고 판단이 듬

</div>





