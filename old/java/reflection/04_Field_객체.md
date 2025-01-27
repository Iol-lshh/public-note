# `Field<?>`
- Reflection 필드 클래스는 각 필드를 나타낸다.
    - 필드 이름, 타입, 등으로 이루어져있다.

## 객체 호출
### Class.getDeclaredFields()
- 클래스의 모든 **정의된** 필드들의 배열을 반환
    - 접근 제어자를 무시
    - 상속된 필드는 제외

### Class.getFields()
- 클래스의 모든 **public** 필드들의 배열을 반환
    - 상속된 필드까지 모든 public 필드를 포함

### Class.getDeclaredField(fieldName)
- 이름으로 클래스에 **정의된** 단일 필드 객체를 반환

### Class.getField(fieldName)
- 이름으로 public 단일 필드 객체를 반환
    - 상속된 필드까지 호출

### NoSuchFieldException
- 필드를 찾을 수 없다면, 반환되는 예외


