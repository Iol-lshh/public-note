# 생명주기
![lifecycle.jpeg](lifecycle.jpeg)
## 초기화
0. createApp
    - 앱 실행
    - DOM에 mount
        - 어디에 렌더링할지 알리기

1. *beforeCreate()*
2. *created()*
    - 화면에 표시되지 않는다.
    - 일반 앱 구성에 대해 인지한다.
3. Compile template
    - 모든 동적 플레이스홀더와 보간 등이 제거된다.
    - 사용자에게 표시될 구체적인 값으로 대체된다.
4. *beforeMount()*
5. *mounted()*
    - 화면에 나타난다.
    - Vue 앱이 초기화되었다.
    - 템플릿 컴파일이 끝났다.
    - 화면에 표시할 대상을 인지하고 브라우저에 지시 사항을 넘긴다.
    - 브라우저가 HTML 요소들을 추가한다.
6. Mounted Vue Instance    

## 업데이트
7. Data Changed
    - 새로운 생명 주기가 트리거
8. *beforeUpdate()*
9. *updated()*
    - 업데이트를 완료하고, 화면에 나타낸다.
    - 템플릿 마운트를 해체하지 않는다.
    - 업데이트는 변경사항만 처리하고 화면에 렌더링한다.

## 언마운트
7. Instance Unmounted
    - 앱 마운트를 해체한다.
    - 화면의 모든 컨텐츠를 삭제하며, 앱 사용이 불가하다.
8. *beforeUnmount()*
    - 컨텐츠 삭제 직전 단계
9. *unmounted()*
    - 두 훅을 화면 clean 코드에 활용할 수 있다.
    - 서버에 HTTP 요청을 보내서 마운트 해제되는 앱을 추적할 수 있다.



