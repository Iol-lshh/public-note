# actuator

- `management.endpoint.<오픈할 endpoint 이름>.enabled`로 활성화
- endpoint는 활성화 조건을 갖기도 한다.
  - 의존하는 bean이 있기도 하다.

```groovy
// actuator 의존성 추가
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

## endpoints 노출 여부 지정

- `management.endpoints.<web or jmx>.exposure.<include or exclude>`로 지정
  - include: 노출
  - exclude: 비노출
- `"*"`을 이용해 모두 허용할 수 있다.
  - yml의 특수 문자 `*`과 착각하지 않는다.
- endpoints에서 노출한다면, 별도로 명시하지 않는다면, 
  - enabled: true를 default로 한다.

```yaml
management:
    endpoint:
        health:
            enabled: true
        beans:
            enabled: true
    endpoints: 
        web:
            exposure:
                include:
                    - health
                    - beans 
        jmx:
            exposure:
                include: "*"
                exclude:
                    - health
                    - beans      
```

## 캐시

- actuator 반환 값을 캐시한다.
  - default는 0ms

```yaml
management:
    endpoint:
        health:
            enabled: true
            cache:
                time-to-live: 1d
```

## CORS 지원

```yaml
management:
    endpoint:
        web:
            cors:
                allowed-origins: http://test.com
                allowed-methods: GET
```

## 커스텀 endpoint

```java
@Endpoint(id= "myCustomInfo")
public class MyCustomEndPoint {
    @ReadOperation
    public List customInfo() {
        return Arrays.asList("1", "2");
    }
}

@Configuration
public class EndpointConfig {
    @Bean
    public MyCustomEndPoint myCustomEndPoint() {
        return new MyCustomEndPoint();
    }
}
```

## @RestController와의 차이

- @RestController는 인수를 기본적으로 value로 들어간다.
- @Endpoint에는 value가 없다.
  - 때문에 id를 명시한다.

## 어노테이션 종류

- 요청하는 HTTP method에 따라, 다른 어노테이션의 메서드를 실행한다.
  - @ReadOperation: GET
  - @WriteOperation: POST
  - @DeleteOperation: DELETE

## 파라미터 수신 방법

### 1. query string

```java
@ReadOperation
public List<Man> customInfo(@Nullable Optional<String> mayBeName, boolean includeVersion) {
    if(mayBeName.isEmpty()) {
        return repo.findAll();
    }
    Optional<Man> man = repo.findMan(name);
    if(man.isEmpty()) {
        return Arrays.empty();
    }
    if(!includeVersion) {
        man.version("");
    }
    return Arrays.asList(man);
}
```

### 2. request body

```java
@Endpoint(id= "myCustomedInfo")
public class MyCustomEndPoint {
    @WriteOperation
    public void customInfo(String name, boolean enable) {
        Man man = repo.findMan(name);
        man.enable(enable);
        return;
    }
}
```

### 3. path parameter

```java
@ReadOperation
public String customInfo(@Selector Optional<String> mayBeName) {
    return mayBeName.orElse("");
}

@ReadOperation
public String customInfo(@Selector(match = Selector.Match.ALL_REMAINING) String[] mayBeNames) {
    return Arrays.asList(mayBeNames);
}
```

## web, JMX 전용 선택

- @WebEndPoint
- @JmxEndPoint

## @RestControllerEndpoint, @ServletEndpoint

- 일반적인 restController처럼 구현 가능하다.
- Controller 앞의 서블릿으로도 구현 가능하다.
  - 하지만, @EndPoint로 구현할 것을 권장하고 있다.

## health endpoint

- 애플리케이션의 전반적인 구동 상태를 보여준다.
  - 애플리케이션을 구동하는 컴포넌트들의 상태도 보여줄 수 있다.

```yaml
management:
    endpoints:
        web:
            exposure:
                include: "*"
    endpoint:
        health:
            show-components: ALWAYS
```

- show-components
  - ALWAYS
  - NEVER
  - WHEN_AUTHORIZED
- show-details
  - ALWAYS
  - NEVER
  - WHEN_AUTHORIZED
- 제공 정보
  - diskspace
  - ping
  - db
  - cassandra
  - couchbase
  - elasticsearch
  - 등등...

## 커스텀 health

```java
@Component
public class MyCustomHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        Builder healthBuilder; 
        
        if(status()) {
            healthBuilder = Health.up();
        } else {
            healthBuilder = Health.outOfService();
        }

        healthBuilder
            .withDetail("key1", "val1")
            .withDetail("key2", "val2")
            .build();

        return healthBuilder.build();
    }

    boolean status() {
        return System.currentTimeMillis() % 2 == 0;
    } 
}
```

- 하나라도 up이 아니면, up이 아니다.
  - 하나라도 down이면, 애플리케이션의 상태는 down
- 보통 관습적인 명명
  - Indicator: 컴포넌트
  - AutoConfiguration: Bean으로 만들어주는 애

## info endpoint

- 다양한 정보를 보여준다.
  - build (default 활성화)
  - git (default 활성화)
  - env
  - java
  - os

```yaml
management:
    endpoint:
        web:
            exposure:
                include: "*"
    info:
        build:
            enabled: true
        git:
            enabled: true
        env:
            enabled: true
        java:
            enabled: true
        os:
            enabled: true

info:
    name: developer_y
    age: 11
    group-id: "${group}"
```

- info.env
  1. application.properties에 넣거나,
  2. `-Dinfo.name=aaaa` 식으로 run 할 때, add VM option으로 넣을 수 있다.
- 전역의 env와 착각 주의
  - 전역 env는 모든 env를 보여준다.
  - value는 디폴트로 *로 마스킹되어있다.

## git info

- generate-git infomation

```groovy
plugins {
    id "com.gorylenko.gradle-git-properties" version "2.4.1"
}
```
