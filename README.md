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

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.03.01.토요일 23:40분] 픽셀아트를 만들수 있어야 할것 같음, 그림을 그리는 작업이기는 하다만은, 계속 해서 게임을 만들어 나감에 있어 필수적으로 알아야 할것 같음
<br/>

현재 테크트리는 [flutter 기초] -> [flutter 응용(flame패키지)] -> [픽셀 아트 기초]  
오늘 저녁에 픽셀아트 튜토리얼 및 입문자 영상 강의 어떤거 따라 배울지 정하고 시작하기
</div>

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.02.24.월요일 18:35분] 픽셀아트를 만들수 있어야 할것 같음, 그림을 그리는 작업이기는 하다만은, 계속 해서 게임을 만들어 나감에 있어 필수적으로 알아야 할것 같음
<br/>

현재 테크트리는 [flutter 기초] -> [flutter 응용(flame패키지)] -> [픽셀 아트 기초]  
오늘 저녁에 픽셀아트 튜토리얼 및 입문자 영상 강의 어떤거 따라 배울지 정하고 시작하기
</div>

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.03.01.토요일 23:40분] 중요 개념  onLoad VS render 

onLoad : 컴포넌트가 로드될때 한 번 호출되며, 리소스를 로드하고 초기설정 수행
</br>
(단, onLoad안에서 'add 메소드'의 역할은 update와 render메서드가 자동으로 호출되어 매프레임마다 그리게 된다.)

render : 매 프레임마다 호출되며, 컴포넌트의 시각적 표현을 담당한다.

활용방법 : 우선은 onLoad메서드로 이미지를 지속적으로 업데이트를 진행 -> 이후 그려진 이미지를 지우거나, 반으로쪼개거나 분리시킨다면 render함수 로직안에
super.render(canvas)로직을 사용하여 커스터 마이징 한다.
enemy.dart로직 참고하기!
</div>

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.03.06.목요일 21:25분]  

카메라 로직을 찾던 도중 flutter flame 패키지 안정화 버전이 나왔다는것을 알게 되었음.
더 이상 로직을 실행할 'flutter run -d chrome --web-renderer html'을 입력하지 않아도 됨
flame 버전 '1.25.0' 버전은 안정화가 되었기때문에 cors정책이나 dart:ui 패키지에 대한 메소드를 구현하지 않았다는 에러가 발생하지 않음으로 device를 chrome에 맞춘 뒤 void main() {} 로직에서 run 버튼만 누르면 쉽게 실행이 된다.

카메라 구도에 관한 로직이 flame엔진 공식사이트에는 예제나 로직이 꼼꼼하게 설명 안해두었음.
뭔가 느낌이 '이런게 있어, 하지만 방법이나 로직은 너희가 알아서 구현해' 라는 느낌이였음. 그렇기 때문에 계속해서 지피티랑 코파일럿을 이용해서 로직을 찾으려 했지만 결국에는 구하지 못했음.
그런데 pub dev에 나랑 비슷한 경험을 한 사례가 있어서 누군가 이에 대한 패키지를 만들어 두지 않았을까 하는 맘에 보았더니 '  flame_camera_tools: ^2.0.0 ' 패키지가 존재함 camera_example 파일을 참고해서 구현을 진행하면됨. 
</div>

<div style="border: 1px solid #4CAF50; padding: 10px; border-radius: 5px;">
[2025.03.07.금요일 01:10분]  

[2025.02.20.목요일 01:30분]-> 이날에 발생했던 에러가 동일하게 발생해서 명령어 flutter run -d chrome --web-renderer html 을 입력했지만
플러터 플레임 패키지 개발진이 이 명령어를 막아두었다. 무엇이 문제일까 고민하던 도중 우연찮게 이미지를 사용하는 부분을 하나씩 주석 처리하면서
문제를 파악해 나갔고, 배경화면에 주석을 처리함으로써 다른 이미지가 정상적으로 나옴을 보고 배경화면의 이미지에 문제가 있다고 판단하여 
이미지를 수정해봄 -> 에러를 내뱉지 않음. 정확한 원인은 인코딩이 잘못된 이미지를 사용했기때문에 디코딩에서 막히는거였음
</div>


