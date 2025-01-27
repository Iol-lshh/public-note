# Spring Active Profiles 란?
- 프로파일을 사용하여 스프링 부트 애플리케이션의 서버(phase)를 구성하는 방안
- `application-{profile}.properties` 또는 `application-{profile}.yml` 파일을 통해 이루어진다.

- 프로파일 자동 반영
```yaml
# application.yml 예시 - dev 동작
spring:
  profiles:
    active: dev
```

# 파일 구조
```css
src
└── main
    └── resources
        ├── application.properties
        ├── application-dev.properties
        └── application-prod.properties
```

# profile active
- 애플리케이션이 시작될 때 스프링 부트는 spring.profiles.active 속성을 확인하여 활성화할 프로파일을 결정
    - spring.profiles.active=dev로 설정되어 있다면 dev 프로파일이 활성화
```bash
# dev
java -jar your-application.jar --spring.profiles.active=dev

# prod
java -jar your-application.jar --spring.profiles.active=prod
```

# Phase 구축
- `dev` 개발 환경
    - `alpha` 알파 릴리즈 환경 ( QA test )
- `staging`, `stg`: 사내 릴리즈, QA
- `prod` 운영 릴리즈 환경

- 특정 프로파일에 대한 서버 설정을 지정할 수 있다.
```yaml
# 개발 환경 설정 application-dev.yml
server.port=8080
server.servlet.context-path=/dev

# 프로덕션 환경 설정 application-prod.yml
server.port=80
server.servlet.context-path=/
```



