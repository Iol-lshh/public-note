# `Constructor<?>`
- `java.lang.reflect.Constructor<?>`
- 생성자에 대한 모든 정보
    - 매개변수의 개수에 한정되지 않는다.
    - 매개변수 타입에 한정되지 않는다.
        - 클래스는 생성자 오버로딩이 가능하기 때문에

# 생성자 객체를 가져오기
## Class.getDeclaredConstructors()
- 클래스의 모든 생성자를 반환
    - 접근 제한자를 무시하고 모두 반환

## Class.getConstructors()
- public 생성자만 반환

## 매개변수 타입을 알 때
- 매개변수 타입 목록을 전달하여, 특정 클래스를 반환받을 수 있다.
    - 없다면, NoSuchMethodException
- `Class.getConstructor(Class<?> ... parameterTypes)`
- `Class.getDeclaredConstructor(Class<?> ... parameterTypes)`

```java
Constructor<?> [] constructors = Person.class.getConstructors();
Constructor<?> defaultConstructor = Person.class.getDeclaredConstructor();
```

# 객체 생성
- `Constructor.newInstance(Object ... arguments)`
    - 생성자에 선언된 순서대로 생성자 매개변수를 가변인수로 받는 메서드
    - 접근 가능한 생성자라면, 객체를 생성해준다.

```java
public static void main(String [] args) throws IllegalAccessException, InstantiationException, InvocationTargetException {

    Address address = createInstanceWithArguments(Address.class, "First Street", 10);

    Person person = createInstanceWithArguments(Person.class,  address, "John", 20);
    System.out.println(person);
}

public static <T> T createInstanceWithArguments(Class<T> clazz, Object ... args) throws IllegalAccessException, InvocationTargetException, InstantiationException {

    for (Constructor<?> constructor : clazz.getDeclaredConstructors()) {
        if(constructor.getParameterTypes().length == args.length) {

            return (T) constructor.newInstance(args);
        }
    }
    System.out.println("An appropriate constructor was not found");
    return null;
}
```

## 접근 제한 Constructor 객체 접근
- private class는 동일 패키지에서만 사용이 가능하다.
- `constructor.setAccessible(true)`
    - 접근이 제한된 생성자도 사용할 수 있게 한다.
```java
Constructor<ServerConfiguration> constructor = ServerConfiguration.class.getDeclaredConstructor(int.class, String.class);

constructor.setAccessible(true);
constructor.newInstance(8080, "Good Day!");
```
- 특별한 경우에만 사용한다.

## 1. 적절한 예시: Parsing to/from Java Objects
```java
import com.fasterxml.jackson.databind.ObjectMapper;

class HttpClient{
    private final ObjectMapper objectMapper;

    public float getPriceFromService(){
        // 요청 보낼 데이터를 만든다.
        Request request = buildRequest();
        byte[] requestData = objectMapper.writeValueAsBytes(request);
        
        // 요청 데이터로 요청하고, 응답을 받아온다.
        byte[] responseData = sendHttpRequest(requestData);
        
        // 응답 객체를 초기화
        Response response = objectMapper.readValue(requestData, Response.class);
        return response.getPrice();
    }
}
```

## 2. 적절한 예시: Dependency Injection
![tictactoe_dependency](tictactoe_dependency.png)
1. 각 의존 관계에서, 생성자 매개변수 타입을 확인한다.
2. 해당 타입의 객체를 생성한다.
    - ComputerPlayer
3. 의존성 주입해준다.
    - ComputerInputProvider
4. 재귀적으로 탐색하며(DFS) 반복한다.
```java
////
public static void main(String[] args) throws IllegalAccessException, InstantiationException, InvocationTargetException {
    Game game = createObjectRecursively(TicTacToeGame.class);
    game.startGame();
}

//// 생성하고 의존성 주입을 도움
public static <T> T createObjectRecursively(Class<T> clazz) throws IllegalAccessException, InvocationTargetException, InstantiationException {
    Constructor<?> constructor = getFirstConstructor(clazz);

    List<Object> constructorArguments = new ArrayList<>();

    // Constructor 객체를 통해, 의존성 주입할 객체의 타입을 확인
    for (Class<?> argumentType : constructor.getParameterTypes()) {
        // 재귀적인 생성
        Object argumentValue = createObjectRecursively(argumentType);
        // Constructor 객체에 의존성 주입
        constructorArguments.add(argumentValue);
    }

    // Constructor 객체를 이용한 객체 생성
    constructor.setAccessible(true);
    return (T) constructor.newInstance(constructorArguments.toArray());
}

////
private static Constructor<?> getFirstConstructor(Class<?> clazz) {
    Constructor<?>[] constructors = clazz.getDeclaredConstructors();
    if (constructors.length == 0) {
        throw new IllegalStateException(String.format("No constructor has been found for class %s", clazz.getName()));
    }

    return constructors[0];
}
```

