---
title: 4. SpringBoot
date: 2025-01-07
description: 스프링 핵심 동작 원리
category:
  - java
  - basic_java
tags:
  - java
  - spring_boot
  - spring
  - IoC
  - beans
---

- 스프링(SPRING)은 자바(Java) 기반의 엔터프라이즈 애플리케이션 개발을 단순화하고 유연하게 만들기 위해 등장한 **프레임워크**입니다.  
- 기존 JEE(J2EE)가 가진 복잡한 설정 문제를 해결하기 위해 **의존성 주입(Dependency Injection, DI)**, **제어의 역전(Inversion of Control, IoC)** 등을 도입하면서, 모듈 간 결합도를 낮추고 유지보수성을 높였습니다.
	- 스프링의 가장 큰 특징은 **IoC 컨테이너**를 통해 개발자가 아닌 **컨테이너가 객체(빈, Bean)를 생성하고 의존성을 관리**한다는 점입니다.  
	- 이를 통해 개발자는 비즈니스 로직 구현에 집중할 수 있고, 설정 작업이 크게 줄어듭니다.
- 스프링은 **DI**, **AOP(Aspect-Oriented Programming)**, **Spring MVC** 등 다양한 모듈로 구성되어 있어, **필요한 부분만 골라 사용할 수 있습니다**.  
	- **Spring Boot**까지 결합하면 자동 설정(AutoConfiguration), 내장 서버(Embedded Server) 등으로 개발 생산성이 크게 향상됩니다.

---

## 4.1. IoC
- **IoC(Inversion of Control)** 컨테이너는 Spring 애플리케이션에서 **객체(bean)의 생성, 설정, 조립**을 담당하는 핵심 구성 요소입니다. 이 컨테이너는 Bean의 생명 주기를 관리하며, XML 파일이나 어노테이션으로 설정을 정의할 수 있습니다.

### 4.1.1. DIP (의존성 역전 원칙)
- 고수준 모듈(상위 레벨)이 저수준 모듈(하위 레벨)에 **직접 의존하지 말고**, 둘 다 추상화(인터페이스)에 **의존**해야 한다는 원칙

### 4.1.2. IoC (Inversion of Control)
- DIP를 실질적으로 구현하기 위한 패턴  
- 전통적인 **객체를 직접 생성하고 관리**하던 주체(애플리케이션 코드)에서, 그 **제어권**을 **스프링과 같은 컨테이너가 가짐
- 이를 통해 객체 생성, 초기화, 의존성 주입, 소멸 등의 과정을 컨테이너가 담당하며, 개발자는 필요한 객체만 선언

### 4.1.3. DI (의존성 주입)
- IoC를 구체화하는 기법으로, 필요한 객체를 직접 만들지 않고 **생성된 객체를 ‘주입’** 받는 것
- DI 유형:
  1. **생성자 주입**: 의존성을 생성자를 통해 전달합니다.
  2. **Setter 주입**: 공용 Setter 메서드를 통해 의존성을 설정합니다.
  3. **필드 주입**: 리플렉션을 사용한 직접 주입(권장되지 않음).

![](img/dip_ioc.png)

### 4.1.4 컨테이너 구현

#### 4.1.4.1. BeanFactory

- 스프링 IoC 컨테이너의 기본 인터페이스로, **객체를 생성하고 주입**하는 기능 제공  
- **게으른 로딩(Lazy Loading)** - 실제 객체가 필요할 때까지 빈을 생성하지 않음
 
#### 4.1.4.2. ApplicationContext

-  애플리케이션의 구동 시점에, 컨테이너를 생성하며, **모든 빈을 사전 로딩(Eager Loading)**
- AOP, 트랜잭션 관리, 메시지 리소스 관리(국제화), 이벤트 전파, 환경 설정(Profiles) 등 다양한 기능 지원
- 웹 애플리케이션의 경우 WebApplicationContext를 사용하여 **웹 관련 기능**을 추가 지원

---

## 4.2. 객체

- POJO, DAO, DTO, 그리고 Beans 같은 용어들은 혼란스럽다. 이에 대해 알아보자.

### 4.2.1. POJO (Plain Old Java Object)

- POJO는 이름 그대로 프레임워크에 의존하지 않는 단순한 Java 클래스
- **특징:**
	1. 특정 상속을 요구하지 않음 (예: `Entity`를 확장하거나 `Serializable` 인터페이스를 구현할 필요 없음)
	2. 선택적으로 기본 생성자를 가질 수 있음
	3. 필드는 `private`으로 선언되며, `public` getter와 setter를 통해 접근 가능

```java
public class User {
    private String username;
    private String email;

    public User() {} // 선택적

    public User(String username, String email) {
        this.username = username;
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
```

### 4.2.2. JAVA Beans

- Java Beans는 Java 프레임워크와 연동되거나 프레임워크에 특화된 규약을 따르는 특별한 POJO 클래스
- **특징:**
	1. 기본 생성자를 반드시 가짐
	2. (선택적이지만 일반적으로) `Serializable`을 구현
	3. 필드는 `private`으로 선언되며, `public` getter와 setter를 통해 접근 가능

```java
import java.io.Serializable;

public class Product implements Serializable {
    private String name;
    private double price;

    public Product() {}

    public Product(String name, double price) {
        this.name = name;
        this.price = price;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}
```

### 4.2.3. Spring Beans

- Spring Bean은 Spring IoC(Inversion of Control) 컨테이너에 의해 관리되는 객체.
- POJO나 JavaBean 모두 Spring Bean으로 등록 및 관리될 수 있다.
- **특징:**
	1. Spring 컨테이너에 의해 생성, 구성 및 관리됨
	2. 정의 방법: `@Component`, `@Service`, `@Repository`, `@Controller`, `@Bean`
	3. 생명주기가 컨테이너에 의해 제어됨 (초기화, 소멸 등)

```java
@Configuration
public class AppConfig {
    @Bean
    public OrderService orderService() {
        return new OrderService();
    }
}
```

#### 4.2.3.1. 스프링 빈 생명주기
- 스프링 빈은 보통 싱글톤이다. (스코프 제외)
- 다음과 같은 라이프사이클을 갖는다.
	1. **인스턴스화**: 스프링이 빈을 인스턴스화
	2. **속성 주입**: 의존성을 주입받음
	3. **초기화 전 (BeanPostProcessor)**: 초기화 전 사용자 정의 로직 실행
	4. **초기화**: @PostConstruct 또는 InitializingBean 메서드 호출
	5. **초기화 후 (BeanPostProcessor)**: 초기화 후 사용자 정의 로직 실행
	6. **소멸**: 애플리케이션 종료 시 소멸

### 4.2.3. DTO (Data Transfer Object)
- DTO는 애플리케이션의 계층 간 데이터 전달을 목적으로 하는 객체
- 서비스 계층과 프레젠테이션 계층 사이 또는 네트워크 경계를 넘어 데이터 전송 시 사용
- **특징:**
	1. 데이터 캡슐화 및 메서드 호출 수 감소
	2. 내부 도메인/엔티티 모델을 직접 노출하지 않음

```java
public class UserDTO {
    private String name;
    private String email;

    public UserDTO(String name, String email) {
        this.name = name;
        this.email = email;
    }

    // Getter와 Setter
}
```

### 4.2.4. DAO (Data Access Object)
- 데이터 소스(예: 데이터베이스)에 접근하는 로직을 추상화하고 캡슐화하는 객체
- CRUD(Create, Read, Update, Delete) 작업을 수행하는 메서드를 제공해야 함
- Spring의 영향으로 Repository라는 단어로 사용하기도 함
- **특징:**
	1. 비즈니스 로직과 데이터 접근 로직을 분리
	2. 데이터베이스 로직을 모듈화하여 응집력을 높임

```java
public interface UserDao {
    void saveUser(User user);
    User getUserById(int id);
    List<User> getAllUsers();
    void updateUser(User user);
    void deleteUser(int id);
}

public class UserDaoImpl implements UserDao {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/example";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "password";

    @Override
    public void saveUser(User user) {
        // 사용자 저장 로직
    }

    @Override
    public User getUserById(int id) {
        // ID로 사용자 조회 로직
    }

    @Override
    public List<User> getAllUsers() {
        // 모든 사용자 조회 로직
    }

    @Override
    public void updateUser(User user) {
        // 사용자 업데이트 로직
    }

    @Override
    public void deleteUser(int id) {
        // 사용자 삭제 로직
    }
}
```

