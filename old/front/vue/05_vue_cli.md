# why?
1. 적절한 개발 웹 서버
    - file:// 파일 프로토콜이 아닌, Http/Https 프로토콜을 사용하기 위함
        - 페이지를 구성하는 방식을 결정할 수 있다.
        - 모던 js 는 실제로 파일 프로토콜에서 동작하지 않을 수 있다. 
            - 실제 환경과 다른 환경 (심지어 그냥 HTML 파일을 더블클릭으로 키는 것이므로)
        - 서버에 호스팅되는 앱을 구성할 필요가 있다.
2. 개발 환경 개선
    - 코드 작성 방식의 결함
        - 코드를 변경할 때마다 저장후, 페이지를 새로고침해야 한다.
            - 리로드마다, 모든 상태를 잃는다.
    - IDE를 사용함으로써 얻을 수 있는 지원
3. 복수 작업 파일에서의 문제
    - 작업이 복잡해질수록, 코드를 읽는데 문제가 많다.
    - 컴포넌트 템플릿을 문자열로 적는 것도 문제

# want
1. 페이지를 자동으로 갱신
2. IDE의 폭넓은 지원
    - 힌트, 자동 완성
3. 여러개의 파일로 코드를 쉽게 작성 및 모듈 사용(import)

# Vue CLI 란?
- vue 프레임워크는 아니고, vue 개발팀에서 만드는 툴
- 프로젝트 생성과 관리에 도움
- Node.js에서 돌아감

- 글로벌 설치: `npm install -g @vue/cli`

- 새 프로젝트 폴더 및 새 Vue 앱 생성: `vue create project-name`
    - 윈도우 로컬 정책 풀기: 
        - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`
        - `Get-ExecutionPolicy -list`
    - or 공식 패키지 사용: `npm init vue`

## 폴더 구조
- node_modules
    - 의존성 패키지들
- public
    - Vue 앱을 마운팅하는 index.html
- src
    - 작성하는 vue 코드
    - main.js 에서 App.vue를 받아 마운트한다.
    - App.vue
        - vue 파일은 vue 컴포넌트를 더 나은 방법으로 작성할 수 있게 돕는다.
        - 템플릿, 스크립트, 스타일으로 나뉜다.
        - Vue CLI가 브러우저에서 동작하도록 변환한다.
        - 빌드 워크플로 - build step을 통해 js 코드로 변환

## VS Code에 확장 플러그인 설치
- volar

## 파일 명명 규칙
- 케밥 케이스
    - kebap-case
- 파스칼 케이스
    - PascalCase
- 카멜 케이스
    - camelCase
- 스테이크 케이스(웹, 디비)
    - snake_case

 