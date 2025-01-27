# java.lang.reflect.InvocationHandler
```java
public class CustomedHandler implements InvocationHandler{
    private final DbReader realDbReader;
    
    @Override   
    public Object invoke(Object proxy, Method method, Object[] args){
        return method.invoke(realDbReader, args);
    }
}
```
- proxy
    - 동적 프록시 객체의 인스턴스
- method
    - 프록시 객체에 호출되는 인터페이스 메서드
- args
    - 메서드 호출자가 메서드에 입력하는 인수 배열


# 동적 프록시 인스턴스

```java
Object Proxy.newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler handler)
```
- loader
    - 동적 프록시 클래스
- interfaces
    - 동적 프록시 클래스가 구현할 모든 인터페이스 배열
- handler
    - 프록시의 InvocationHandler 인스턴스의 정의
- Return 두가지 모두 생성한다
    1. 제공된 모든 인터페이스를 구현하는 동적 프록시 **클래스**
    2. 동적 프록시 클래스 **인스턴스**


    