# 개발 시간 서비스 (Development-time Services)

- 개발 시간 서비스는 애플리케이션 개발 중 실행에 필요한 외부 종속성을 제공합니다. 이러한 서비스는 개발 중에만 사용되며, 애플리케이션이 배포되면 비활성화됩니다.
- Spring Boot는 Docker Compose와 Testcontainers라는 두 가지 개발 시간 서비스를 지원합니다. 아래에서 각각의 세부 사항을 설명합니다.

## Docker Compose 지원

- Docker Compose는 애플리케이션이 필요한 여러 서비스 컨테이너를 정의하고 관리할 수 있는 인기 있는 기술입니다. 애플리케이션 디렉토리 옆에 compose.yml 파일을 생성하여 서비스 컨테이너를 정의하고 구성합니다.
- 일반적인 워크플로:
  1. docker compose up 실행 → 필요한 서비스 실행
  2. 애플리케이션 작업
  3. 작업 종료 후 docker compose down 실행
- Spring Boot는 spring-boot-docker-compose 모듈을 통해 Docker Compose와의 통합을 지원합니다.
- 이를 프로젝트에 추가하려면 다음과 같이 의존성을 설정합니다.

```maven
<dependencies>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-docker-compose</artifactId>
    <optional>true</optional>
  </dependency>
</dependencies>
```
  
```gradle
dependencies {
  developmentOnly("org.springframework.boot:spring-boot-docker-compose")
}
```

- 이 모듈을 의존성에 포함하면 Spring Boot는 다음을 자동으로 수행합니다:
  - 작업 디렉토리에서 compose.yml 또는 유사한 파일 검색
  - 발견한 compose.yml 파일로 docker compose up 실행
  - 각 컨테이너에 대한 서비스 연결 빈 생성
  - 애플리케이션 종료 시 docker compose stop 실행
- 필수 조건:
  - Docker 및 Docker Compose CLI(2.2.0 이상)가 설치되어 있어야 합니다.

## 서비스 연결 (Service Connections)

- 서비스 연결은 원격 서비스와의 연결을 의미합니다. Spring Boot는 자동 구성으로 서비스 연결 정보를 사용하여 원격 서비스와의 연결을 설정합니다.
- Docker Compose는 컨테이너 내부 포트를 로컬의 임의 포트로 매핑합니다.
- Spring Boot는 로컬에서 매핑된 포트를 자동으로 검색하여 연결을 설정합니다.
- 지원되는 연결 세부 정보:
  - PostgreSQL, MySQL, Redis, RabbitMQ 등 주요 서비스에 대한 자동 연결 지원

### 사용자 정의 이미지 (Custom Images)

- 표준 이미지를 사용하는 대신 사용자 정의 이미지를 사용하는 경우에도 Spring Boot는 지원합니다.
- 조건: 표준 이미지에서 사용하는 환경 변수를 동일하게 지원해야 함
- 방법: compose.yml 파일에 org.springframework.boot.service-connection 레이블 추가
- 예시:

```yaml
services:
  redis:
    image: 'mycompany/mycustomredis:7.0'
    ports:
      - '6379
    labels:
      org.springframework.boot.service-connection: redis
```
  
### 컨테이너 제외

- 특정 컨테이너를 애플리케이션과 연결하지 않으려면 org.springframework.boot.ignore 레이블을 추가하여 제외할 수 있습니다.
- 예시:

```yaml
services:
  redis:
    image: 'redis:7.0'
    ports:
      - '6379'
    labels:
      org.springframework.boot.ignore: true
```
  
### 컨테이너 준비 상태 대기

- 컨테이너가 준비되는 데 시간이 걸릴 수 있으므로, compose.yml 파일에 healthcheck를 추가해 상태 확인을 설정하는 것이 좋습니다.
- 예시:

```yaml
services:
  redis:
    image: 'redis:7.0'
    ports:
      - '6379'
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
```
  
- Spring Boot는 기본적으로 TCP/IP 연결을 통해 컨테이너의 준비 상태를 확인합니다. 필요 시 레이블을 통해 비활성화할 수 있습니다.

### Docker Compose 라이프사이클 제어

- 기본적으로 Spring Boot는 애플리케이션 시작 시 docker compose up을 호출하고 종료 시 docker compose stop을 호출합니다
- 이를 변경하려면 spring.docker.compose.lifecycle-management 속성을 사용할 수 있습니다:
  - none: Docker Compose 실행 및 중지 없음
  - start-only: 시작 시 실행, 종료 시 중지 없음
  - start-and-stop: 시작 시 실행, 종료 시 중지

## 테스트에서 Docker Compose 사용

- 테스트에서 Docker Compose를 사용하려면 spring.docker.compose.skip.in-tests를 false로 설정합니다.
- Gradle 사용 시 spring-boot-docker-compose 의존성을 testAndDevelopmentOnly로 변경해야 합니다.

### Testcontainers 지원

- Testcontainers는 Java 코드를 사용하여 컨테이너를 정의하고 관리하는 방식으로, YAML 대신 Java에서 컨테이너를 구성할 수 있습니다.
- 사용 예시:

```java
@TestConfiguration(proxyBeanMethods = false)
public class MyContainersConfiguration {
  @Bean
  @ServiceConnection
  public MongoDBContainer mongoDbContainer() {
    return new MongoDBContainer("mongo:5.0");
  }
}
```
  
#### DevTools와 통합

- Testcontainers 컨테이너는 @RestartScope로 정의하면, 애플리케이션 재시작 시 상태를 유지할 수 있습니다.
- Spring Boot의 Docker Compose 및 Testcontainers 지원을 통해 개발 환경에서 컨테이너 관리를 더욱 간편하게 할 수 있습니다.
