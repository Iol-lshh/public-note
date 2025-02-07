# `Class<?>`
- Relection API entry point
- 리플렉션 로직을 작성하는 Class 객체
- <https://docs.oracle.com/javase/8/docs/api/java/lang/Class.html>

## Class 객체가 가진 정보
- 객체의 type 또는 class
- 객체의 methods와 fields
- 상속 정보
    - extends
    - implements

# Class 객체를 얻는 3가지 방법
## 1. Object.getClass()
```java
String str = "some-string";
Car car = new Car();
Map<String, Integer> map = new HashMap<>();

Class<String> strClass = str.getClass();    // String
Class<Car> carClass = car.getClass();   // Car
Class<?> mapClass = map.getClass();     //Map이 아닌, 런타임 타입인 HashMap을 갖는다. 
```

- 원시타입은 객체가 아니라는 것을 주의하자
```java
int value = 55;
Class intClass = value.getClass(); // compile error
```

## 2. .class
```java
Class<String> strClass = String.class;    // String
Class<Car> carClass = Car.class;   // Car
Class<?> mapClass = HashMap.class;     //Map이 아닌, 런타임 타입인 HashMap을 갖는다. 

// primitive type 원시타입 클래스
Class booleanType = boolean.class;
Class inttype = int.class;
Class doubleType = double.class;
// 클래스 작성시에, 필드의 타입이나, 메서드의 반환 타입/ 파라미터 타입이 원시 타입일 수 있기 때문에 존재한다.
// 뿐만 아니라, 필요한 상황이 있기 때문
class MyClass{
    private int value; // 필드의 타입이 원시타입
    public boolean isNegative(float x){...} // 리턴 타입과 파라미터 타입이 원시 타입
}
```

## 3. Class.forName(...)
- `Class` class의  정적(static) 메서드 `forName`
- 클래스 경로에서 동적으로 클래스를 찾을 수 있다.
    - 패키지명을 포함한 이름을 사용한다.

``` java
Class<?> strType = Class.forName("java.lang.String");
Class<?> carType = Class.forName("vehicles.Car");
Class<?> engineType = Class.forName("vehicles.Car$Engine"); // inner class는 $ 로 구분된다.

///
package vehicles;
class Car{
    ...
    static class Engine{...}
}

///// 원시타입은 런타임 오류가 난다.
int val = 55;
Class intClass = Class.forName("int"); // Runtime Error
```
- 클래스 이름 오타는 런타임 오류를 낸다.
    - ClassNotFoundException

- 세가지 방법 중, forName 메서드가 가장 유연하지만, 가장 위험한 방법이다.

### Class.forName()의 Use Cases
1. 인스턴스를 확인하거나, 만들려는 타입이 런타임 중 사용자 정의 구성 파일에서 전달될 때, 이 메서드를 사용한다.
    - ex) MyBatis

2. 확인하려는 클래스가 프로젝트에 없고, 코드 컴파일할때 클래스가 없을 경우, 이 메서드를 사용한다.
    - 클래스는 런타임 중, 앱의 클래스 경로에서 추가된다.
    - 런타임시, 클래스를 불러와서 사용하는 별도의 라이브러리를 구축하는 경우에 편리하다.

# Java Wildcards '?'
1. 와일드카드 클래스로 매개변수의 클래스 객체를 나타낼 수 있다.

2. 컴파일에서 컴파일러가 제네릭 타입을 명확히 모를때, 와일드카드를 사용하여 해결할 수 있다.
```java
Class<?> carClass = Class.forName("vehicles.Car");

Map<String, Integer> genericMap = new HashMap<>();
Class<?> hashMapClass = genericMap.getClass();
```
3. 클래스가 메서드로 전달되는 것을 제한할 수 있다.
```java
public List<String> findAllMethods(Class<? extends Collection> clazz){
    ...
}
```

# 예제
```java
private static void printClassInfo(Class<?>... classes) {

    for (Class<?> clazz : classes) {

        System.out.println(String.format("class name : %s, class package name : %s",
                clazz.getSimpleName(),//
                clazz.getPackageName()));//

        Class<?>[] implementedInterfaces = clazz.getInterfaces();//

        for (Class<?> implementedInterface : implementedInterfaces) {
            System.out.println(String.format("class %s implements : %s",
                    clazz.getSimpleName(),//
                    implementedInterface.getSimpleName()));//
        }

        System.out.println("Is array : " + clazz.isArray());//
        System.out.println("Is primitive : " + clazz.isPrimitive());//
        System.out.println("Is enum : " + clazz.isEnum());//
        System.out.println("Is interface : " + clazz.isInterface());//
        System.out.println("Is anonymous :" + clazz.isAnonymousClass());//

        System.out.println();
        System.out.println();
    }
}

public static void main(String[] args) throws ClassNotFoundException {
    //
    Class<String> stringClass = String.class;
    Map<String, Integer> mapObject = new HashMap<>();
    Class<?> hashMapClass = mapObject.getClass();
    Class<?> squareClass = Class.forName("exercises.Main$Square");

    //
    printClassInfo(stringClass, hashMapClass, squareClass);
}
```
