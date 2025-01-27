> [Home](/README.md)

# 코틀린 문법
- 참조: Kotlin in Action

##  문Statement과 식Expression
- 문: 값이 될 수 없는 것
    - 블록의 최상위 요소로써, 값을 만들어내지 않는다.
    - 자바는, 모든 제어 구조가 문(if, switch, for, while, try)
    - 코틀린은, 할당에서 대입은 문
- 식: 값이 될 수 있는 것
    - 계산에 참여할 수 있다.
    - 코틀린은, 루프를 제외한 대부분의 제어 구조가 식(if, when, try)
    - 자바는, 할당에서 대입은 식

# 0. 코틀린 기초
- 정적 타입
    - 성능
    - 신뢰성
    - 유지 보수성
    - 도구 지원: 안전한 리팩토링과 정확한 코드 자동 완성 기능
- 타입 추론
    - 정적 타입 지정 언어의 불편함 해소
    - nullable 타입 지원
        - 컴파일 시점에 널 포인터 예외 검사 가능으로 신뢰성 향상

## 0.1 함수형 프로그래밍
### 0.1.1 **함수형 프로그래밍**의 핵심 세 가지 개념

### 0.1.1.1 함수 타입
- **일급 시민** first-class
    1. 함수를 변수에 저장
    2. 함수를 인자로 다른 함수에 전달
    3. 함수에서 새로운 함수를 만들어 반환

#### 0.1.1.2 **불변성** immutability
- 내부 상태가 바뀌지 않는 불변 객체를 사용한다.

#### 0.1.1.3 **순수 함수** - 부수효과 side effect 없음
- 입력이 같다면, 항상 같은 출력을 반환한다.
- 다른 객체의 상태를 변경하지 않는다.
- 함수 외부 또는 외부 환경과 상호작용하지 않는다.

### 0.1.2 함수형 프로그래밍의 이점
1. 간결성
    - 명령형 코드에 비해 간결
2. 다중 스레드에서 안전
    - 불변 데이터 구조이기에, 여러 스레드가 변경할 수 없다.
3. 테스트가 용이
    - 순수 함수이기에, 독립적 테스트가 쉽다.

- 함수 종류
    1. 데이터 호출: 데이터 의존
    2. 비즈니스 로직: 순수 함수 가능
    3. 프레젠테이션 로직: 렌더링의 사이드이펙트 의존

## 0.2 함수

### 0.2.1 함수 기본 구조
```kotlin
fun max(a: Int, b: Int): Int {  // 각각 함수 이름, 파라미터 목록, 반환 타입
    return if (a > b) a else b // 함수 본문
}
```
- 함수 이름, 파라미터 목록, 반환 타입, 함수 본문으로 이루어져있다.

#### 0.2.1.1 식이 본문인 함수
```kotlin
fun max(a: Int, b: Int) = if (a > b) a else b
```
- 정적 타입: 컴파일 시점에 타입이 지정되어야 한다.
- 타입 추론: 식의 결과 타입을 함수 반환 타입으로 추론하여, 생략이 가능하다. 

## 0.3 변수
### 0.3.1 타입
- 타입 추론때문에 변수 선언시 생략이 가능하다.
```kotlin
val question = "hello kotlin"   // String
val answer = 1                  // Int
val yearsToCompute = 7.5e6      // Double
```

### 0.3.2 val VS var
1. val
    - 값 value을 의미
    - 변경 불가 immutable
    - read only. 참조를 저장
    - 재대입 불가. 자바로 치면 final 변수, js로 치면 const
2. var
    - 변수 variable을 의미
    - 변경 가능 mutable 참조
    - 자바의 일반 변수에 해당, js에서 var 또는 let
- 기본적으로 val로 불변 변수로 선언하고, 꼭 필요할 경우에만 var를 사용한다.

### 0.3.3 문자열 템플릿
- `$` 를 이용하여, 직접 변수를 문자열 내부에 접합 가능
```kotlin
val name = "Kotlin"
println("Hello, $name!")
```

- 컴파일러는 식을 정적static으로 컴파일 시점에 파싱하기 때문에, 존재하지 않는 변수를 문자열 템플릿 안에서 사용하면 컴파일 오류가 발생
- `{}`를 이용하여, 복잡한 식을 삽입 가능
```kotlin
if(args.size > 0){
    println("Hello, ${args[0]}!")
}
```
- $를 문자열로 넣고 싶다면, `\$` 로 이스케이프한다.
- 한글(유니코드 문자)은 문자열 템플릿이 오해를 할 수 있기 때문에, 되도록 {}를 써준다.

## 0.4 클래스 class
```kotlin
class Person(val name: String, var age: Int)
```
- 접근 제어자(public, private)와 생성자가 필요 없다.
- 값 객체 value object: 코드 없이 데이터만 저장하는 클래스

### 0.4.1 프로퍼티 property
- 필드와 접근자를 묶어 프로퍼티라고 한다.
- val: 읽기 전용 프로퍼티
    - 내부적으로 비공개 필드, 공개 getter를 만들어낸다.
- var: 쓸 수 있는 프로퍼티
    - 내부적으로 비공개 필드, 공개 getter, 공개 setter를 만들어낸다.
```kotlin
Person person = Person("Bob", 29)
println(person.name)    // 내부적으로 자동으로 getter를 호출한다.
pseron.age += 1         // 내부적으로 자동으로 setter를 호출한다.
```
### 0.4.2 커스텀 접근자
```kotlin
class Rectangle(val height: Int, val width: Int){
    val isSquare: Boolean
        get(){      // 프로퍼티의 getter를 직접 구현
            return height == width
        }
}
```

## 0.5 정리
```kotlin
data class Person(val name: String, val age: Int? = null)
// data 클래스
// 널이 될 수 있는 타입 Int?
// 파라미터 디폴트 값

fun main(args: Array<String>){  // 최상위 엔트리 함수
    val person = listOf(Person("철수"), Person("영희", age = 29))
    // 이름 붙여 할당하는 파라미터 age

    val oldest = persons.maxBy{it.age ?: 0}
    // 람다식과 엘비스 연산자(?:)

    println("나이가 가장 많은 사람: $oldest")
    // 문자열 템플릿 $
}
```

- 람다식: it은 특수한 예약어. 람다 식의 유일한 인자로 사용. 파라미터 생략 가능

- 엘비스 연산자: null 인 경우, 주어진 값(0)을 반환하고, 그렇지 않은 경우 그대로 반환


## 0.6 비교 제어

### 0.6.1 when
- switch 문 대용
- when은 제어식이다. 값이 될 수 있다.
- break를 필요로 하지 않는다.

#### 0.6.1.1 enum과 when
```kotlin
// enum 정의
enum class Color(
    val r: Int, val g: Int, val b: Int
){
    RED(255, 0, 0), ORANGE(255, 165, 0), YELLOW(255, 255, 0),
    GREEN(0, 255, 0), BLUE(0, 0, 255), INDIGO(75, 0, 130),
    VIOLET(238, 130, 238);

    fun rgb() = (r * 256 + g) * 256 + b
}

// when 사용
fun getMnemonic(color: Color) = 
    when (color){
        Color.RED, Color.ORANGE, Color.YELLOW -> "warm"
        Color.GREEN -> "natural"
        Color.BLUE, Color.INDIGO, Color.VIOLET -> "cold"
    }

// when에 임의의 객체를 사용
fun mix(c1: Color, c2: Color) = 
    when (setOf(c1, c2)){
        setOf(RED, YELLOW) -> ORANGE
        setOf(YELLOW, BLUE) -> GREEN
        setOf(BLUE, VIOLET) -> INDIGO
        else -> throw Exception("Dirty color")
    }

// 인자 없는 when
// when이 인자를 받지 않기 위해선, 각각의 조건은 boolean 결과여야 한다.
fun mixOptimized(c1: Color, c2: Color) = 
    when {
        (c1 == RED && c2 == YELLOW) ||
        (c1 == YELLOW && C2 = RED) -> 
            ORANGE
        (c1 == YELLOW && BLUE == YELLOW) ||
        (c1 == BLUE && YELLOW = RED) -> 
            GREEN
        (c1 == BLUE && VIOLET == YELLOW) ||
        (c1 == VIOLET && BLUE = RED) -> 
            INDIGO
        else -> throw Exception("Dirty color")
    }
```

### 0.6.2 if 스마트 캐스트
- if 문에 의해, 비교된 타입은, 이후 블록 안에서 스마트 캐스팅 된다.
```kotlin
// 식을 표현하는 클래스 계층
interface Expr
class Num(val value: Int): Expr
class Sum(val left: Expr, val right: Expr): Expr    // Expr 타입(Num, Sum)이 인자로 올 수 있다.

fun eval(e: Expr):Int {
    if(e is Num){   // if 문에 의해, e가 Num 타입이라면, 이후 자동으로 캐스팅 된다.
        return n.value
    }
    if(e is Sum){   // if 문에 의해, e가 Sum 타입이라면, 이후 자동으로 캐스팅 된다.
        return eval(e.right) + eval(e.left)
    }
    throw IllegalArgumentException("Unknow expression")
}
```

#### 0.6.2.1 when 또한 스마트 캐스팅 된다.
- when 문에 의해, 비교된 타입은, 이후 블록 안에서 스마트 캐스팅 된다.
```kotlin
fun evalOptimized(e: Expr):Int =
    when (e){
        is Num ->   // 스마트 캐스트 
            e.value
        is Sum ->   // 스마트 캐스트
            eval(e.right) + eval(e.left)
        else -> 
            throw IllegalArgumentException("Unknow expression")
    }

```

## 0.7 이터레이션 제어
- 루프는 문이다.

### 0.7.1 .. 연산자
- 시작 값과 끝 값을 연결하여, 범위를 만든다.
- 범위를 통해, 루프문에 이용한다.
- 범위 값을 이용한 제어를 수열progression이라고 한다.

```kotlin
val oneToTen = 1..10    // 범위가 된다.
```

#### 0.7.1.1 map에 대한 이터레이션
```kotlin
val binaryReps = TreeMap<Char, String>()
for(c in 'A'..'F'){
    // 1. 아스키 코드를 2진으로 바꾼다.
    val binary = Integer.toBinaryString(c.toInt())
    // 2. 맵에 넣는다.  
    binaryReps[c] = binary  
}
```

### 0.7.2 in을 이용한 범위 검사
- in, !in을 통해 어떤 값이 범위에 속하지 않는지 검사할 수 있다.
```kotlin
fun isLetter(c: Char) = c in 'a'..'z' || c in 'A'..'Z'
fun isNotDigit(c: Char) = c !in '0'..'9'

fun recognize(c: Char) = when(c){
    in '0'...'9' -> "digit"
    in 'a'..'z', in 'A'..'Z' -> "letter"
    else -> "dontKnow"
}

"Kotlin" in setOf("Java", "Scala") // false
```

## 0.8 예외 처리 제어
- try는 식이다.
- 다른 클래스의 인스턴스 생성과 마찬가지로, 예외 인스턴스 생성시 new가 필요 없다.
- 함수에 던질 수 있는 예외를 명시할 필요가 없다.

