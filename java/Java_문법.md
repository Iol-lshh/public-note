---
title: "Java 문법"
date: "2023-12-30"
description: "Java 문법 정리"
category: "java"
---

- [Java 문법](#java-문법)
    - [0. Java 기초](#0-java-기초)
        - [0.1 OOP 특징](#01-oop-특징)
        - [0.2 OOP 설계 5원칙 SOLID](#02-oop-설계-5원칙-solid)
        - [0.3 타입](#03-타입)
            - [0.3.1 Call by Value](#031-call-by-value)
            - [0.3.2 Call by Reference](#032-call-by-reference)
            - [0.3.3 String](#033-string)
            - [0.3.4 연산된 값](#034-연산된-값)
        - [0.4 접근자](#04-접근자)
        - [0.5 OOP](#05-인터페이스-클래스-인스턴스)
    - [1. 동작 파라미터](#1-동작-파라미터)
        - [1.0 메서드](#10-메서드)
            - [1.0.1 메서드 시그니처](#101-메서드-시그니처)
            - [1.0.2 메서드 오버로딩](#102-메서드-오버로딩)
        - [1.1 함수형 인터페이스와 구현 클래스](#11-함수형-인터페이스와-구현-클래스)
            - [1.1.1 추상적 조건으로 필터링](#111-추상적-조건으로-필터링)
            - [1.1.2 익명 클래스](#112-익명-클래스)
        - [1.2 람다](#12-람다)
        - [1.3 제네릭 Generic](#13-제네릭-generic)
        - [1.4 함수 디스크립터](#14-함수-디스크립터)
            - [1.4.1 기본 제공 함수형 인터페이스 (자바8)](#141-기본-제공-함수형-인터페이스-자바8)
        - [1.5 메서드 참조 ::](#15-메서드-참조)
        - [1.6 생성자 참조](#16-생성자-참조)
    - [2. 컬렉션](#2-컬렉션)
        - [2.1 상속 관계](#21-상속-관계)
            - [2.1.1 List](#211-list)
                - [2.1.1.1 Stack](#2111-stack)
                - [2.1.1.2 Vector](#2112-vector)
                - [2.1.1.3 ArrayList](#2113-arraylist)
            - [2.1.2 Set](#212-set)
                - [2.1.2.1 HashSet](#2121-hashset)
            - [2.1.3 Map](#213-map)
                - [2.1.3.1 Hashtable](#2131-hashtable)
                - [2.1.3.2 HashMap](#2132-hashmap)
        - [2.2 Sorted](#22-sorted)
            - [2.2.1 Comparator](#221-comparator)
        - [2.3 Comparable](#23-comparable)
    - [3. 스트림](#3-스트림)
        - [3.1 연산 함수](#31-연산-함수)
    - [4. Optional - null 처리](#4-optional---null-처리)
        - [4.1 작동 방식](#41-작동-방식)
            - [4.1.1 null 참조 처리 예](#411-null-참조-처리-예)
            - [4.1.2 Optional 처리의 예](#412-optional-처리의-예)
        - [4.2 Optional 랩 메서드](#42-optional-랩-메서드)
            - [4.2.1 빈 Optional - Optional.empty](#421-빈-optional---optionalempty)
            - [4.2.2 null이 아닌 Optional - Optional.of](#422-null이-아닌-optional---optionalof)
            - [4.2.3 null이 가능한 Optional - Optional.ofNullable](#423-null이-가능한-optional---optionalofnullable)
        - [4.3 Optional 언랩 메서드](#43-optional-언랩-메서드)
            - [4.3.1 get](#431-get)
            - [4.3.2 orElse](#432-orelse)
            - [4.3.3 orElseGet](#433-orelseget)
            - [4.3.4 orElseThrow](#434-orelsethrow)
            - [4.3.5 ifPresent](#435-ifpresent)
            - [4.3.6 ifPresentOrElse](#436-ifpresentorelse)
        - [4.4 Optional의 체이닝 처리 (스트림)](#44-optional의-체이닝-처리-스트림)
            - [4.4.1 map](#441-map)
            - [4.4.2 flatMap](#442-flatmap)
            - [4.4.3 filter](#443-filter)
            - [4.4.4 stream](#444-stream)
    - [5. 시간](#5-시간)
        - [5.1 클래스](#51-클래스)
            - [5.1.1 LocalDate](#511-localdate)
            - [5.1.2 LocalTime](#512-localtime)
            - [5.1.3 LocalDateTime](#513-localdatetime)
            - [5.1.4 Instant](#514-instant)
            - [5.1.5 Duration, Period](#515-duration-period)
        - [5.2 공통 메서드](#52-공통-메서드)

# Java 문법

# 0. Java 기초
## 0.1 OOP 특징
1. 캡슐화
2. 추상화 
3. 상속
4. 다형성

## 0.2 OOP 설계 5원칙 SOLID
- 객체 지향 설계시 지켜야할 원칙
1. SRP(Single Responsibility Principle): 단일 책임 원칙
2. OCP(Open Closed Priciple): 개방 폐쇄 원칙
3. LSP(Listov Substitution Priciple): 리스코프 치환 원칙
4. ISP(Interface Segregation Principle): 인터페이스 분리 원칙
5. DIP(Dependency Inversion Principle): 의존 역전 원칙

## 0.3 타입
### 0.3.1 Call by Value
- 기본 타입
    - byte, int, char, boolean ...
    - 변수의 메모리 위치에 바로 값을 가진다.
### 0.3.2 Call by Reference
- Array, Object
- Copy
    - shallow copy
    - deep copy

### 0.3.3 String
- Immutable
- StringBuffer
    - 수정이 많은 String 사용시, 지향

### 0.3.4 연산된 값
- getter, setter
- predicate: boolean 값을 반환하는 함수

## 0.4 접근자
- public: 접근 제한이 없는
- private: 클래스 내에서만 접근 가능한
- protected: 동일한 패키지 또는 파생클래스에서만 접근 가능한
- static: 고정된
    - 객체 생성 없이 사용할 수 있는 필드와 메소드를 생성하고자
    - 객체 참조 없이 바로 사용
- final: 최종적인
    - 값이 저장되면 최종적인 값이 되므로, 수정이 불가능
- static final: 상수 (고정된 최종)
- default: 인터페이스에서, 로직을 포함한 메소드 선언 가능한 (기본적인)

## 0.5 인터페이스, 클래스, 인스턴스
- 인터페이스: 객체의 명세
    - 동작의 추상화: 객체의 외부에서 쓰일 메서드들을 모두 작성
    - default 동작: default 접근자로 작성하는 default 로직
    - 상수
- 클래스: 객체 생성 틀 
    - 구현하는 인터페이스의 메서드(public)
    - 클래스 동작을 위한 내부 메서드(private)
    - 필드(field)
- 인스턴스: 힙에 올라가는 객체


# 1. 동작 파라미터
- 구성
    1. 호출 로직 (2번을 호출, 3번을 인자로 사용)
    2. 동작 호출 형식 (함수 디스크립터)
    3. 동작 파라미터 (함수 인터페이스와 구현 vs 람다)

## 1.0 메서드
### 1.0.1 메서드 시그니처
- 디자인된 메서드 구조
    - **메서드 명**과 **파라미터 리스트**로 구성

### 1.0.2 메서드 오버로딩
- 같은 메서드 명칭이나, 파라미터 리스트가 달라, 
    - 메서드 시그니처가 다른 메서드들
    - 하나의 클래스는 2개의 같은 메서드 시그니처를 가질 수 없다.
    - 메서드 시그니처는 **리턴 타입을 포함하지 않는다.**
```java
public int square(int x, int y) {
    ///
}
public double square(double x, double y) {
    ///
}
```

## 1.1 함수형 인터페이스와 구현 클래스
### 1.1.1 추상적 조건으로 필터링
- 전략 패턴
    - 런타임 단계에 논리 구현을 선택
- 추상적 필터링
    - 논리 로직과
    - 세부 조건을 분리 

```java
// # predicate 인터페이스 (3.함수형 인터페이스)
public interface ApplePredicate{
    boolean test(Apple apple);
}
// ## 무게 필터링 구현 (3-1.구현된 함수)
public Class AppleWeightPredicate implements ApplePredicate{
    public boolean test(Apple apple){
        return apple.getWeight() > 150;
    }
}
// ## 색 필터링 구현 (3-2.구현된 함수)
public Class AppleColorPredicate implements ApplePredicate{
    public boolean test(Apple apple){
        return GREEN.equals(apple.getColor);
    }
}

// # 추상화된 필터링 함수 (2.호출되는 함수)
public static List<Apple> filterApples(List<Apple> inventory, ApplePredicate p){
    List<Apple> result = new ArrayList<>();
    for(Apple apple: inventory){
        if(p.test(apple)){      // 추상화된 p를 통한 필터링
            result.add(apple);
        }
    }
    return result;
}

// # 전략 선택을 통한 필터링 (1.호출 로직)
List<Apple> greenApples = filterApples(inventory, new AppleColorPredicate());
```
- 함수형 인터페이스
    - 오직 하나의 추상 메서드를 갖는 인터페이스
    - Ex) 자바 API: Comparator, Runnable, Callabel, PrivilegedAction


### 1.1.2 익명 클래스
- 이름 없는 클래스
- 지역 클래스
- 클래스 선언과 인스턴스화를 동시에 진행
- 단순한 일회성 동작시
    - 람다 추천
```java
List<Apple> greenApples = filterApples(inventory, new ApplePredicate(){
    public boolean test(Apple apple){
        return GREEN.equals(apple.getColor);
    }
});
```


## 1.2 람다
- 익명 함수를 단순화한 것
- 함수형 인터페이스의 추상 메서드를 직접 구현함으로써,
    - 람다의 전체 표현식을 함수형 인터페이스를 구현한 클래스의 인스턴스로 취급
```java
List<Apple> greenApples = filterApples(inventory, (Apple apple) -> GREEN.equals(apple.getColor()));
```


## 1.3 제네릭 Generic
- 잘못된 타입의 인입을 컴파일 단계에서 방지한다.
- 클래스 외부에서 타입을 지정하기 때문에, 타입 체크와 변환이 필요 없다.
- 코드의 재사용성이 높다.
```java
// 제네릭를 이용한, 추상화 (3.함수형 인터페이스)
public interface Predicate<T>{
    boolean test(T t);
}

// 제네릭을 이용한, 필터 (2.호출되는 함수)
public static <T> List<T> filter(List<T> list, Predicate<T> p){
    List<T> result = new ArrayList<>();
    for(T e: list){
        if(p.test(e)){
            result.add(e);
        }
    }
    return result;
}

// T = Apple (1.호출 로직, 3-1.구현된 람다)
List<Apple> greenApples = filter(inventory, (Apple apple) -> GREEN.equals(apple.getColor()));
// T = Integer (1.호출 로직, 3-2.구현된 람다)
List<Integer> evenNumbers = filter(numbers, (Integer i) -> i % 2 == 0);
```


## 1.4 함수 디스크립터
- 람다 표현식의 시그니처를 서술해주는 메서드
```java
// # 함수 디스크립터에 해당 (2.호출되는 함수)
// r의 메서드의 명칭(run), 파라미터 리스트(없음), 반환값(void)을 설명해주고 있다.
public void process(Runnable r){
    r.run();
}

// # 로직과, 람다 표현식 (1.호출 로직, 3.람다)
// 함수형 인터페이스를 구현한 클래스의 인스턴스로써 사용되고 있다.
process(() -> System.out.println("run!"));
```

### 1.4.1 기본 제공 함수형 인터페이스 (자바8)
- `Predicate<T>`
    - `T -> boolean`
    - 참/거짓 단정자
- `Consumer<T>`
    - `T -> void`
    - 소비자
- `Function<T, R>`
    - `T -> R`
    - 기능자
- `Supplier<T>`
    - `() -> T`
    - 제공자
- `UnaryOperator<T>`
    - `T -> T`
    - 단항 연산자
- `BinaryOperator<T>`
    - `(T, T) -> T`
    - 이중 연산자

- `BiPredicate<T, U>`
    - `(T, U) -> boolean`
    - 이중 단정자
- `BiConsumer<T, U>`
    - `(T, U) -> void`
    - 이중 소비자
- `BiFunction<T, U, R>`
    - `(T, U) -> R`
    - 이중 기능자


## 1.5 메서드 참조 ::
- 특정 메서드만 호출하는 기능
```java
// java.util.Comparator.comparing 활용
inventory.sort(comparing(Apple::getWeight)); // 메서드 참조
```
1. 정적 메서드 참조
    - 비교
        - 람다: `(args) -> ClassName.staticMethods(args)`
        - 메서드 참조: `ClassName::staticMethod`
    - ex) `Integer::parseInt`
2. 다양한 형식의 인스턴스 메서드 참조
    - 비교
        - 람다: `(arg0, rest) -> arg0.instanceMethod(rest)`
        - 메서드 참조: `ClassName::instanceMethod(rest)` 
            - 단, ClassName은 arg0의 ClassName 형식
    - ex) `String::length`
3. 기존 객체의 인스턴스 메서드 참조
    - 비교
        - 람다: `(args) -> expr.instanceMethod(args)`
        - 메서드 참조: `expr::instanceMethod(args)`
    - ex) Transaction이라는 클래스가 있을때, 생성된 expensiveTransaction
        - `expensiveTransaction::getValue`


## 1.6 생성자 참조
```java
// # 1. Supplier: () -> Apple 시그니처의 생성자가 있다고 할 때,
// ## 1-0. 람다 방식
Supplier<Apple> c10 = () -> new Apple();
Apple a10 = c10.get();

// ## 1-1. 참조 방식
Supplier<Apple> c11 = Apple::new;
Apple a11 = c11.get(); // Supplier의 get을 통해 Apple 객체 생성이 가능하다.

// # 2. Function: Apple(Integer weight) 시그니처의 생성자가 있다고 할 때,
// ## 2-0. 람다 방식
Function<Integer, Apple> c20 = (weight) -> new Apple(weight);
Apple a20 = c20.apply(110);

// ## 2-1. 참조 방식
Function<Integer, Apple> c21 = Apple::new;
Apple a21 = c21.apply(110);

// # 3. 사용 방법
List<Integer> weights = Arrays.asList(7,3,4,10);
List<Apple> apples = map(weights, Apple::new);

public List<Apple> map(List<Integer> list, Function<Integer, Apple> f){
    List<Apple> result = new ArrayList<>();
    for(Integer i: list){
        result.add(f.apply(i));
    }
    return result;
}
```

# 2. 컬렉션

## 2.1 상속 관계
- Collection
    - List
        - LinkedList
        - Stack
        - Vector
        - ArrayList
    - Set
        - HashSet
        - SortedSet
            - TreeSet
- Map
    - Hashtable
    - HashMap
    - SortedMap
        - TreeMap

### 2.1.1 List
#### 2.1.1.1 Stack
- 메서드
    - push(): 데이터 삽입
    - pop(): 데이터 추출
    - peek(): 데이터 조회
    - search(): Stack으로부터 데이터 검색
#### 2.1.1.2 Vector
- 동기화 보장
- 지양
#### 2.1.1.3 ArrayList
- 동기화 보장하지 않는다
- 메서드
    - add(), get(), toArray(), contains(), size()
### 2.1.2 Set
- 집합
- 순서가 없다
- 중복되지 않는다
#### 2.1.2.1 HashSet
- 메서드
    - add(), next(), remove(), contains(), size()
### 2.1.3 Map
- key value 쌍의 리스트
- key는 중복되지 않는다
- 메서드
    - put(), get()
#### 2.1.3.1 Hashtable
- 동기화 보장
- 지양
#### 2.1.3.2 HashMap
- 동기화 보장하지 않는다

## 2.2 Sorted
- Set
    - SortedSet
        - TreeSet
- Map
    - SortedMap
        - TreeMap

### 2.2.1 Comparator
- sort시, Comparator를 구현하여, 정렬의 방식을 지정할 수 있다.
    - 오름차순, return 값의 양수가 후순위
- `compare(T o1, T o2)`
```java
// 제공되는 함수 인터페이스
public interface Comparator<T>{
    default int compare(T o1, T o2){
        return Integer.compare(o1.hashCode(), o2.hashCode());
    };
}

// 익명 클래스 방식
Arrays.sort(classList, new Comparator<ClassName>() {
    @Override
    public int compare(ClassName o1, ClassName o2) {
        return Integer.compare(o1.score, o2.score);
    }
});

// 람다 방식
Arrays.sort(classList, (ClassName o1, ClassName o2) -> Integer.compare(o1.score, o2.score));
```
- [Spec: `java.util > Interface Comparator<T>`](docs.oracle.com/javase/8/docs/api/java/util/Comparator.html#method.summary)

## 2.3 Comparable
- Comparable을 구현하여, 우위 방식을 구현할 수 있다.
- `compareTo(T o)`
```java
public class ClassName implements Comparable<Type> { 
    private score;

    @Override
    public int compareTo(ClassName another) {
        return this.score - another.score;
    }
}
```
- [Spec: `java.lang > Interface Comparable<T>`](https://docs.oracle.com/javase/8/docs/api/java/lang/Comparable.html#method.summary)


# 3. 스트림
- 데이터 처리 연산을 지원하는 소스에서 추출된 연속된 요소
- 특징
    1. 연속된 요소
    2. 소스
    3. 데이터 처리 연산
        - 컬렉션의 주제는 자료구조의 복잡성과 데이터
        - 스트림의 주제는 표현 계산식과 연산
    4. 파이프라이닝
        - laziness, short-circuiting 최적화를 얻을 수 있다.
    5. 내부 반복
        - 반복자를 사용하는 컬렉션과 달리, 내부 반복을 지원한다.
        - 외부 반복에서는 병렬성을 스스로 관리해야한다.
- 장점
    1. 선언형: 간결, 가독성 증대
    2. 조립성: 유연성 증대
        - 고수준 빌딩 블록으로 이루어져, 특정 스레딩 모델에 제한되지 않고, 자유롭게 사용 가능하다.
    3. 병렬화: 성능 향상
        - 소프트웨어 공학적으로(내부적으로) 멀티코어 아키텍처를 최대한 활용 가능
- 종류
    - 순차 `stream()`
    - 병렬 `parallelStream()`
        - 멀티스레드로 구현하지 않고, 병렬로 데이터 처리 가능
## 3.1 연산 함수
- filter
    - return을 boolean 값으로, 해당 element 필터링 여부 결정
- sorted
    - comparator를 받아, compare
- map
    - return 값으로 element들을 대체
- limit
    - 반환 갯수 제한
- collect
    - 집계하여 새로운 자료구조로 반환

```java
// # stream 파이프라인 처리
List<String> lowCaloricDishesName = menu.stream()
    .filter(d->d.getCalories() < 400>)
    .sorted(comparing(Dish::getCalories))
    .map(Dish::getName)
    .collect(toList());

// # parallelStream 병렬 처리
List<String> lowCaloricDishesName = menu.parallelStream()
    .filter(d->d.getCalories() < 400>)
    .sorted(comparing(Dish::getCalories))
    .map(Dish::getName)
    .collect(toList());
```



# 4. Optional - Null 처리
- `java.util.Optional<T>`
- `null` 참조
    - `null` 참조는 `NullPointerException`을 일으킨다.
    - `null`을 줄이기 위한 유효성 검사는 고려사항이 많다.
    - 에러의 근원. 시스템의 구멍.
    - 처리하기 위해, 코드를 어지럽힌다.
    - 아무 의미도 없다.
- `null` 참조 대신, `Optional` 클래스 활용을 지향한다.
    - js의 `?.`, 하스켈의 `Maybe`와 같은 역할
    - cf) Option[T]

## 4.1 작동 방식
![Java_Optional_Car](img_Java_Optional.png)
- `Optional` 객체는 값을 감싼다.
- 값이 없다면, `Optional.empty` 메서드가 빈 `Optional`을 반환한다.
    - `null`은 `NullPointerException`을 일으키지만, `Optional.empty()`는 `Optional` 객체이므로, 에러를 일으키지 않는다.
    - `null`의 경우, **의도적으로 빈 값인지, 잘못된 값인지, 판단이 불가능**하다.
    - `Optional`은 **의도적으로 값이 없을 수 있다**는 것을 명시적으로 보여준다.


### 4.1.1 null 참조 처리 예
```java
// 클래스 부분 생략
// 처리 부분
public String getCarInsuranceName(Person person){
    if (person == null){
        return "Unknown";
    }
    Car car = person.getCar();
    if(car == null){
        return "Unknown";
    }
    Insurance insurance = car.getInsurance();
    if(insurance == null){
        return "Unknown";
    }
    return insurance.getName();
    // 만약, if문 중에 null 처리를 한곳이라도 안해준다면, 반드시 에러가 발생한다.
}
```
### 4.1.2 Optional 처리의 예
```java
// 클래스
public class Person{
    private Optional<Car> car;
    public Opional<Car> getCar(){
        return car;
    }
}
//
public class Car{
    private Optional<Insurance> insurance;
    public Opional<Insurance> getInsurance(){
        return insurance;
    }
}
//
public class Insurance{
    private String name;
    public String getName(){
        return insurance;
    }
}
// 처리 부분 - null 참조 처리에 비해, 압도적으로 간결해졌다!
public String getCarInsuranceName(Optional<Person> person)
    return person.flatMap(Person::getCar)
                .flatMap(Car::getInsurance)
                .map(Insurance::getName)
                .orElse("Unknow");
```
- 실제로, JPA는 단일 Entity를 반환시, Optional로 반환함으로써,
- 조회된 Entity가 없을 수 있음을 명시한다!



## 4.2 Optional 랩 메서드
- Optional.empty()
- Optional.of()
- Optional.ofNullable()

### 4.2.1 빈 Optional - Optional.empty
- 비어있음을 의도적으로 표현
```java
Optional<Car> maybeCar = Optional.empty();
```

### 4.2.2 null이 아닌 Optional - Optional.of
- null이 될 수 없음을 표현
- null이라면, NullPointerException을 발생
```java
Optional<Car> maybeCar = Optional.of(car);
```

### 4.2.3 null이 가능한 Optional - Optional.ofNullable
- null이 가능
- null 이라면, 빈 Optional을 반환
```java
Optional<Car> maybeCar = Optional.ofNullable(car);
```


## 4.3 Optional 언랩 메서드
- get
- orElse
- orElseGet
- orElseThrow
- ifPresent
- ifPresentOrElse

### 4.3.1 get
- 랩핑된 값을 반환
- 값이 없다면, NoSuchElementException
- 가장 간단하지만, 안전하지 않은 메서드
- Optional에 반드시 값이 있다고 가정하지 않는 이상 지양
    - null 처리와 다를바가 없다.
### 4.3.2 orElse
- orElse(T other)
- 값이 없을 때, 기본값을 제공
    - other은 반환되지 않을 수 있을 뿐, 반드시 만들어 놓는다.
    - other에 entity 사용시/고비용시, orElseGet을 사용한다.
### 4.3.3 orElseGet
- `orElseGet(Supplier<? extends T> other)`
- orElse의 lazy 버전
    - 값이 없을때만, Supplier를 실행
        - 디폴트 메서드를 만드는 데 시간이 소모되거나(효율성),
        - Optional이 비어있을 때만, 기본값을 생성해야 할 때 사용
### 4.3.4 orElseThrow
- `orElseThrow(Supplier<? extends X> exceptionSupplier)`
- Optional이 비어있다면, exceptionSupplier를 통해 예외를 발생시킨다
    - 발생시킬 예외를 선택할 수 있다.
### 4.3.5 ifPresent
- `ifPresent(Consumer<? super T> consumer)`
- 값이 존재할 때, consumer를 실행
- 값이 없다면 아무일도 일어나지 않는다
### 4.3.6 ifPresentOrElse
- `ifPresentOrElse(Consumer<? super T> consumer, Runnable emptyAction)`
- Optional이 비었을 때, 받은 Runnable 인수를 실행한다.




## 4.4 Optional의 체이닝 처리 (스트림)
### 4.4.1 map
- Optional은 맵 사용 가능
- Optional은 요소 개수가 한 개 이하인 데이터 컬렉션
```java
Optional<Insurance> maybeInsurance = Optional.ofNullable(insurance);
Optional<String> name = maybeInsurance.map(Insurance::getName);
```

### 4.4.2 flatMap
- Optional안의 Optional 구조의 경우, map의 중첩이 불가능하다.
```java
Optional<Person> maybePerson = Optional.of(person);
Optional<String> name = maybePerson.map(Person::getCar)
                                    .map(Car::getInsurance) // 불가!
                                    .map(Insurance::getName);
```

- flatMap은 함수를 인수로 받아, 다른 스트림을 반환하는 메서드이다.
- 참조 체인을 하기 때문에, 가능하다.
```java
public String getCarInsuranceName(Optional<Person> person)
    return person.flatMap(Person::getCar) // person의 타입이 Optional<Car>가 된다.
                .flatMap(Car::getInsurance)
                .map(Insurance::getName)
                .orElse("Unknow");
```
- 순차적으로, person이 `flatMap`에 의해 `Optional<Person>`>`Optional<Car>`>`Optional<Insurance>` 로 변환되며 스트림이 진행된다.
- 만일, 도중 비어있다면, `Optional.empty`를 이후부터 반환한다.

### 4.4.3 filter
- `filter(Predicate<? extends T> predicate)`
- 값이 존재하고 Predicate에 알맞다면, Optional을 반환
- 값이 존재하지 않거나 Predicate에 맞지 않다면, 빈 Optional 반환

### 4.4.4 stream
- 값이 존재하면, 존재하는 값만 포함하는 스트림을 반환



# 5. 시간
- java.time 패키지를 사용한다.
    - 불변 객체
        - 스레드 안전성과 도메인 모델의 일관성을 유지하기 위해
- Java.util.Calendar와 Java.util.Date를 사용하지 않는다.
    - 날짜와 시간 계산이 난해하다.
    - 불변 객체가 아니다.

## 5.1 클래스
- LocalDate
- LocalTime
- LocalDateTime
- Instant
- Duration
- Period

### 5.1.1 LocalDate
- 연도, 달, 요일 등을 반환
```java
LocalDate date = LocalDate.of(1993, 4, 9);  // 1993-04-09의 LocalDate 객체

int year = date.getYear();                  //1993
Month month = date.getMonth();              //APRILL
int day = date.getDayOfMonth();             //9
DayOfWeek dow = date.getDayOfWeek();        //FRIDAY
int len = date.lengthOfMonth();             //30
boolean leap = date.isLeapYear();           //true (윤년)

LocalDate today = LocalDate.now();          //오늘 데이터의 LocalDate 객체
```
### 5.1.2 LocalTime
```java
LocalTime time = LocalTime.of(13, 45, 20);  // 13:45:20의 LocalTime 객체
int hour = time.getHour();                  // 13
int minute = time.getMinute();              // 45
int second = time.getSecond();              // 20
```

### 5.1.3 LocalDateTime
- LocalDate + LocalTime
```java
// 2017-09-21T13:45:20
LocalDateTime dt1 = LocalDateTime.of(2017, Month.SEPTEMBER, 21, 13, 45, 20)
LocalDateTime dt2 = LocalDateTime.of(date, time);
LocalDateTime dt3 = date.atTime(13, 45, 20);
LocalDateTime dt4 = date.atTime(time);
LocalDateTime dt5 = date.atDate(date);

LocalDate date = dt1.toLocalDate();
LocalTime time = dt1.toLocalTime();
```
### 5.1.4 Instant
- java.time.Instant
- 기계 날짜 시간(Unix epoch time 1970-01-01T00:00:00UTC 기준의 초)
- 나노초(10억분의 1)의 정밀도
- ofEpochSecond

### 5.1.5 Duration, Period
- 두 시간 객체 사이의 지속시간 클래스
```java
//
Duration d1 = Duration.between(time1, time2);
Duration d2 = Duration.between(dateTime1, dateTime2);
Duration d3 = Duration.between(instant1, instant2);
Duration d3 = Duration.between(LocalDate.of(2017, 9, 11), LocalDate.of(2017, 9, 21));

//
Duration d4 = Duration.ofMinutes(3);
Duration d4 = Duration.of(3, ChronoUnit.MINUTES);

//
Period tenDays = Period.ofDays(10);
Period threeWeeks = Period.ofWeeks(3);
Period twoYearsSixMonthsOneDay = Period.of(2, 6, 1);
```

## 5.2 공통 메서드
- 정적
    1. now
        - 시스템 시계로 Temporal 객체 생성
    2. of
        - 인자로 Temporal 객체 생성
    3. from
        - Temporal 인자로 클래스의 인스턴스 생성
    4. parse
        - 문자열을 파싱하여 Temporal 객체 생성
- 비정적
    1. get
        - Temporal 객체 상태
    2. atOffset
        - 시간대 오프셋과 Temporal 객체를 합친다
    3. atZone
        - 지역 시간대 오프셋과 Temporal 객체를 합친다
    4. format
        - 지정 포맷을 이용하여 Temporal 객체를 문자열로 변환
        - Instant 미지원
    5. plus
        - 특정 시간을 더한 Temporal 객체를 깊은 복사 생성
    6. minus
        - 특정 시간을 뺀 Temporal 객체를 깊은 복사 생성
    7. with
        - 일부 상태를 변경한 Temporal 객체를 깊은 복사 생성

