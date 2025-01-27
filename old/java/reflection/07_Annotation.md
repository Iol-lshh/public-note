# Annotation
- 메서드, 생성자, 필드, 클래스, 매개변수, 예외처리
- 자체로는 기능이 없으며, 프로그램에 영향을 끼치지 않는다.
    - 추가 정보나, 애너테이트하는 타깃 관련 메타 데이터를 제공
    - 전체 프로그램 관련 정보를 제공
    - 단순 주석으로 생각할 수 있으나, 아주 강력
    - 컴파일러, 컴파일러 타임 도구와 통합할 수 있다.
    - JVM에서 Reflection을 이용해, 런타임 동안 접근할 수 있게 선택할 수 있다.

- 언제 얼마나 실행되어야하는지 정보를 가지게 할 수도 있다.
    - `@Scheduled(initialDelay = 1000, fixedRate = 60)`

## 마킹 애너테이션
- 요소를 지니지 않은 애너테이션
- 특정 기능으로 타깃을 표시하기만 한다.
- `@NotNull`

# 리플렉션과의 관계
- 직접적인 관계는 없으나, 같이 많이 쓰인다.
    - 어떤 타깃에 접근해야하는지,
    - 무슨 작업을 해야하는지 지시하고 명령할 수 있다.
- 애플리케이션을 리플렉션과 분리할 수 있다.
    - 코드를 특정 이름이나, 구조로 제한하지 않아도 된다.
    - `@Component`
        - Considered for auto detection
    - `@Autowired`
        - Dependencies are injected automatically
    - 리플렉션에 다른 클래스를 다루고, 초기화하는 방법을 알려줄 수 있다.
- 메서드의 순서와 호출 시기를 알려줄 수 있다.
    - `@Before`
        - run before every test
    - `@After`
        - run after each test
    - `@Test`
        - Test methods
    - `@Ignore`
        - Temporarily ignore
- 데이터베이스 테이블, 필드 변수 자체에 다른 별칭을 넣을 수 있다.
- 직렬화 프로토콜 요소 사이를 매핑할 수 있다.
```java
@Table(name = "EMPLOYEES")
class Employee{
    @JsonProperty("employee_name")
    @Column("first_name")
    private String name;

    @JsonProperty("employee_lastname")
    @Column("family_name")
    private String lastName;
}
```

- 메서드와 생성자 인수 이름을 컴파일링 이후 제거한다.
    - 매개변수에 사용하여, 같은 유형의 서로 다른 매개변수를 구별할 수 있게 한다.
```java
// Before Compilation
class PhoneBookEndpoint{
    @RequestMapping
    List<String> getPhoneNumbers(
        @RequestParam("first_name") String name,
        @RequestParam("last_name") String lastName){
        ...
    }
}
// After Compilation
class PhoneBookEndpoint{
    @RequestMapping
    List<String> getPhoneNumbers(
        @RequestParam("first_name") String arg0,
        @RequestParam("last_name") String arg1){
        ...
    }
}
```

# Annotation 정의 구조
- 인터페이스 키워드로 선언
```java
@interface Retryable{
    int numOrRetries();
    long initialDelay();
    long duration();
    BackoffStrategy strategy();
    String failureMessage();
}
```
##  java.lang.annotaion.Annotation
- 모든 애너테이션은 애너테이션 인터페이스를 확장
- 리플렉션으로 애너테이션을 검사할 수 있다.

## 애너테이션 요소
- 애너테이션 내부의 요소는 인터페이스 메서드와 유사한 방법으로 선언된다.
    - default 값을 줄 수 있다.
    - 기본값을 가진 요소는 생략할 수 있다.
```java
@interface Retryable{
    int numOrRetries() default 10;
    long initialDelay() default 0;
    long duration() default 1000; 
    BackoffStrategy strategy() default BackoffStategy.FIXED;
    String failureMessage() default "Request Failed";
}

// 인터페이스의 메서드를 애너테이션
 @Retryable(
    numOfRetries = 10,
    initialDelay = 60,
    duration = 5000,
    strategy = EXPONENTIAL
 )
 void sendRequestToClient(Address address)
```
### 애너테이션 타입
- 모든 원시 타입
- Strings
- Enums
- `Classes(Class<?>)`
- 다른 애너테이션
- 모든 유형의 위 타입들의 배열

# 메타 애너테이션
- Not all annotations are visibel at Runtime
- JVM은 애너테이션을 기본적으로 무시한다.
- 애너테이션의 가시성과 다른 많은 특성을 제어하기 위한 메타 애너테이션
    - 다른 애너테이션에 적용된다.

```java
@SomeMetaAnnotation
@interface CustomAnnotation{
    ...
}
```

## @Retention
- 보존 애너테이션
- How a marked annotation is stored
    - 표시된 애너테이션의 저장 기간
- For how long it is going to be retained
    - 저장 상태의 보존 기간을 명시
- 보존 애너테이션의 타입은 세가지가 있다(enum)

### RetentionPolicy.SOURCE
- 컴파일러가 버릴 애너테이션
- IDE와 컴파일러가 오류나 경고를 보내는 걸 돕는다.
- `@Override`
    - 부모 클래스나, 인터페이스의 메서드 선언을 재정의한다는 것을 컴파일러에 알려준다.
- `@SuppressWarnings`
    - 무시하고 싶은 내용 관련하여, 경고를 보내지 않게 컴파일러에게 내용 전달

### RetentionPolicy.CLASS
- 컴파일러가 클래스 파일에 표시된 애너테이션을 저장
    - 단, JVM에 런타임 때, 애너테이션을 무시
- 코드를 읽고 분석한 다음, 새로운 클래스를 생성하는 코드 생성기가 사용할 수 있다.
    - 코드 생성 후, 애너테이션은 런타임 동안 아무런 작용도 하지 않는다.
- 모든 애너테이션의 default RetentionPolicy
    - 보존 메타 애너테이션으로 표시되지 않는다.
- `@AutoValue`

### RetentionPolicy.RUNTIME
- 컴파일러가 클래스 파일에 표시된 애너테이션을 저장
- 런타임 동안, JVM이 인식 및 이용

```java
@Retention(RetentionPolicy.RUNTIME)
@interface RequestValidated{
    Class<? Extends Validator> validationClass();
    String validationFailureMessage() default "request rejected";
}
```

## @Target
- 애너테이션이 적용될 수 있는 타깃을 제한
    - ElementType.ANNOTATION_TYPE
    - ElementType.CONSTRUCTOR
    - ElementType.FIELD
    - ElementType.LOCAL_VARIABLE
    - ElementType.METHOD
    - ElementType.PACKAGE
    - ElementType.PARAMETER
    - ElementType.TYPE
```java
@Target({
    ElementType.FIELD,
    ElementType.LOCAL_VARIABLE,
    ElementType.PARAMETER
})
@Retention(RetentionPolicy.RUNTIME)
@interface ParamName{
    String value();
}
```

## `isAnnotationPresent(Class<? extends Annotation> annotationClass)`
- 어노테이션이 붙어있는지 알려주는 함수
- 인자의 종류
    - Class
    - Field
    - Method
    - Constructor
    - Parameter


