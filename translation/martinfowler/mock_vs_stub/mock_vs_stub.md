---
title: Mocks Aren't Stubs 번역
date: 2025-07-18
description: Mock과 Stub 차이점
author: Martin Fowler
category:
  - 번역
  - test
---
- 원본: [Mocks Aren't Stubs(Martin Fowler, 2007.01.02)](https://martinfowler.com/articles/mocksArentStubs.html)

'mock 객체(Mock Objects)'라는 용어는 테스트를 위해 실제 객체를 모방하는 특수 객체를 설명하는 데 널리 사용되는 용어가 되었습니다. 대부분의 언어 환경에는 이제 mock 객체를 쉽게 생성할 수 있는 프레임워크가 있습니다. 그러나 흔히 간과되는 것은 mock 객체가 특수 사례 테스트 객체의 한 형태에 불과하며, 다른 스타일의 테스팅을 가능하게 한다는 것입니다. 이 글에서는 mock 객체가 어떻게 작동하는지, 어떻게 행동 검증 기반의 테스팅을 장려하는지, 그리고 mock 객체 커뮤니티가 어떻게 이를 사용하여 다른 스타일의 테스팅을 개발하는지 설명할 것입니다.

---

생각 저는 몇 년 전 익스트림 프로그래밍(XP) 커뮤니티에서 "mock 객체"라는 용어를 처음 접했습니다. 그 이후로 mock 객체를 점점 더 많이 접하게 되었습니다. 부분적으로는 mock 객체의 선도적인 개발자들 중 많은 이들이 다양한 시기에 Thoughtworks에서 제 동료였기 때문입니다. 부분적으로는 XP의 영향을 받은 테스팅 문헌에서 이를 점점 더 많이 보게 되었기 때문입니다.

하지만 종종 mock 객체가 제대로 설명되지 않는 것을 봅니다. 특히 테스팅 환경의 흔한 도우미인 **스텁**(stubs)과 혼동되는 경우가 많습니다. 이러한 혼동을 이해합니다. 저도 한동안은 비슷하다고 생각했지만, mock 객체 개발자들과의 대화를 통해 제 거북이 등껍질 같은 두뇌에 mock 객체에 대한 이해가 서서히 스며들었습니다.

이 차이점은 사실 두 가지 개별적인 차이점입니다. 한편으로는 테스트 결과가 검증되는 방식, 즉 **상태 검증**(state verification)과 **행동 검증**(behavior verification) 간의 구분이 있습니다. 다른 한편으로는 테스팅과 설계가 함께 작동하는 방식에 대한 완전히 다른 철학이 있는데, 저는 이를 **classic**(classical) 및 **모키스트**(mockist) 테스트 주도 개발 스타일이라고 부릅니다.

## 정규 테스트(Regular Tests)

두 가지 스타일을 간단한 예시로 설명하겠습니다. (예시는 Java로 되어 있지만, 원리는 어떤 객체 지향 언어에도 적용됩니다.) 주문 객체를 창고 객체에서 채우려고 합니다. 주문은 매우 간단하며, 제품 하나와 수량만 있습니다. 창고는 다양한 제품의 재고를 보유합니다. 주문에 창고에서 자신을 채우도록 요청할 때 두 가지 가능한 응답이 있습니다. 창고에 주문을 채울 만큼의 제품이 충분하면 주문은 채워지고 창고의 해당 제품 수량은 적절한 양만큼 줄어듭니다. 창고에 제품이 충분하지 않으면 주문은 채워지지 않고 창고에서는 아무 일도 일어나지 않습니다.

이 두 가지 행동은 몇 가지 테스트를 의미하며, 이는 매우 일반적인 JUnit 테스트처럼 보입니다.

```java
public class OrderStateTester extends TestCase {
    private static String TALISKER = "Talisker";
    private static String HIGHLAND_PARK = "Highland Park";
    private Warehouse warehouse = new WarehouseImpl();

    protected void setUp() throws Exception {
        warehouse.add(TALISKER, 50);
        warehouse.add(HIGHLAND_PARK, 25);
    }

    public void testOrderIsFilledIfEnoughInWarehouse() {
        Order order = new Order(TALISKER, 50);
        order.fill(warehouse);
        assertTrue(order.isFilled());
        assertEquals(0, warehouse.getInventory(TALISKER));
    }

    public void testOrderDoesNotRemoveIfNotEnough() {
        Order order = new Order(TALISKER, 51);
        order.fill(warehouse);
        assertFalse(order.isFilled());
        assertEquals(50, warehouse.getInventory(TALISKER));
    }
}
```

xUnit 테스트는 일반적으로 설정(setup), 실행(exercise), 검증(verify), 해체(teardown)의 네 단계를 따릅니다. 이 경우 설정 단계는 `setUp` 메서드(창고 설정)와 테스트 메서드(주문 설정)에서 부분적으로 수행됩니다. `order.fill` 호출은 실행 단계입니다. 여기서는 테스트하려는 작업을 수행하도록 객체를 조작합니다. `assert` 문은 검증 단계로, 실행된 메서드가 작업을 올바르게 수행했는지 확인합니다. 이 경우 명시적인 해체 단계는 없으며, 가비지 컬렉터가 이를 암묵적(implicitly)으로 처리합니다.

설정 단계에서 우리는 두 종류의 객체를 함께 배치합니다. Order는 우리가 테스트하는 클래스이지만, `Order.fill`이 작동하려면 Warehouse 인스턴스도 필요합니다. 이 상황에서 Order는 우리가 테스트에 집중하는 객체입니다. 테스팅 지향적인 사람들은 이러한 것을 'object-under-test' 또는 'system-under-test'와 같은 용어로 부르기를 좋아합니다. 어느 용어든 말하기 거북하지만, 널리 받아들여지는 용어이므로 참고 사용하겠습니다. Meszaros를 따라 System Under Test, 즉 **SUT**라는 약어를 사용하겠습니다.

따라서 이 테스트를 위해 SUT( `Order` )와 하나의 협력자( `warehouse` )가 필요합니다. `warehouse`가 필요한 이유는 두 가지입니다. 하나는 테스트할 동작이 전혀 작동하도록 하기 위해서( `Order.fill`이 `warehouse`의 메서드를 호출하기 때문)이고, 다른 하나는 검증을 위해서입니다( `Order.fill`의 결과 중 하나는 `warehouse`의 상태에 잠재적인 변화를 주기 때문). 이 주제를 더 탐구하면서 SUT와 협력자 간의 구분이 중요해진다는 것을 알게 될 것입니다. (이전 버전의 이 글에서는 SUT를 "주요 객체"로, 협력자를 "보조 객체"로 언급했습니다).

이러한 테스트 스타일은 **상태 검증**(state verification)을 사용합니다. 이는 메서드가 실행된 후 SUT와 해당 협력자의 상태를 검사하여 실행된 메서드가 올바르게 작동했는지 판단한다는 의미입니다. 보시다시피, mock 객체는 다른 검증 접근 방식을 가능하게 합니다.

## Mock 객체를 사용한 테스트

이제 동일한 동작을 mock 객체를 사용하여 구현해 보겠습니다. 이 코드에서는 jMock 라이브러리를 사용하여 mock 객체를 정의합니다. jMock은 Java mock 객체 라이브러리입니다. 다른 mock 객체 라이브러리도 있지만, 이 라이브러리는 이 기법의 원작자들이 작성한 최신 라이브러리이므로 시작하기에 좋습니다.

```java
public class OrderInteractionTester extends MockObjectTestCase {
    private static String TALISKER = "Talisker";

    public void testFillingRemovesInventoryIfInStock() {
        //setup - data
        Order order = new Order(TALISKER, 50);
        Mock warehouseMock = new Mock(Warehouse.class);

        //setup - expectations
        warehouseMock.expects(once()).method("hasInventory")
                     .with(eq(TALISKER),eq(50))
                     .will(returnValue(true));
        warehouseMock.expects(once()).method("remove")
                     .with(eq(TALISKER), eq(50))
                     .after("hasInventory");

        //exercise
        order.fill((Warehouse) warehouseMock.proxy());

        //verify
        warehouseMock.verify();
        assertTrue(order.isFilled());
    }

    public void testFillingDoesNotRemoveIfNotEnoughInStock() {
        Order order = new Order(TALISKER, 51);
        Mock warehouse = mock(Warehouse.class);
        warehouse.expects(once()).method("hasInventory")
                 .withAnyArguments()
                 .will(returnValue(false));
        order.fill((Warehouse) warehouse.proxy());
        assertFalse(order.isFilled());
    }
}
```

우선 `testFillingRemovesInventoryIfInStock`에 집중해 주세요. 다음 테스트에서는 몇 가지 단축키를 사용했습니다.

시작부터 설정 단계가 매우 다릅니다. 우선 **데이터와 기대치**라는 두 부분으로 나뉩니다. 데이터 부분은 우리가 작업하려는 객체를 설정하며, 그런 의미에서 전통적인 설정과 유사합니다. 차이점은 생성되는 객체에 있습니다. SUT는 동일합니다. 즉, 주문입니다. 그러나 협력자는 창고 객체가 아니라 mock 창고입니다. 기술적으로는 `Mock` 클래스의 인스턴스입니다.

설정의 두 번째 부분은 mock 객체에 대한 기대를 생성합니다. 기대치는 SUT가 실행될 때 mock 객체에서 어떤 메서드가 호출되어야 하는지를 나타냅니다.

모든 기대치가 설정되면 SUT를 실행합니다. 실행 후에는 검증을 수행하는데, 이는 두 가지 측면을 가집니다. 이전과 마찬가지로 SUT에 대해 어설션(assert)을 실행합니다. 거기에다가 **mock 객체 또한 검증**하여, 기대치에 따라 호출되었는지 확인합니다.

여기서 핵심적인 차이점은 주문이 창고와의 상호작용에서 올바른 작업을 수행했는지 확인하는 방식입니다. 상태 검증을 사용하면 창고의 상태에 대한 어설션을 통해 이를 수행합니다. mock 객체는 **행동 검증**을 사용하는데, 여기서는 대신 주문이 창고에 대한 올바른 호출을 했는지 확인합니다. 우리는 설정 중에 mock 객체에 무엇을 기대해야 하는지 알려주고, 검증 중에 mock 객체에 자신을 검증하도록 요청함으로써 이 확인을 수행합니다.

두 번째 테스트에서는 몇 가지 다른 작업을 수행합니다. 첫째, `MockObjectTestCase`의 `mock` 메서드를 사용하여 mock 객체를 다르게 생성합니다. 이는 jMock 라이브러리의 편의 메서드로, 나중에 명시적으로 `verify`를 호출할 필요가 없음을 의미하며, 이 편의 메서드로 생성된 모든 mock 객체는 테스트 끝에 자동으로 검증됩니다. 첫 번째 테스트에서도 이렇게 할 수 있었지만, mock 객체를 사용한 테스트가 어떻게 작동하는지 보여주기 위해 검증을 더 명시적으로 보여주고 싶었습니다.

두 번째 테스트 케이스에서 다른 점은 `withAnyArguments`를 사용하여 기대치에 대한 제약 조건을 완화했다는 것입니다. 이렇게 한 이유는 첫 번째 테스트에서 숫자가 창고로 전달되는지 확인하므로 두 번째 테스트에서 해당 요소를 반복할 필요가 없기 때문입니다. 나중에 주문의 로직이 변경되어야 한다면, 하나의 테스트만 실패하여 테스트 마이그레이션 작업을 간소화 할 수 있습니다. 여기서 `withAnyArguments`를 썼지만, 안 써도 똑같이 동작하기 때문에 굳이 쓸 필요 없다는 걸 알게 되었습니다.

### EasyMock 사용하기

mock 객체 라이브러리는 여러가지가 있습니다. 제가 자주 사용하는 것 중 하나는 Java 및 .NET 버전 모두에 있는 EasyMock입니다. EasyMock은 행동 검증을 가능하게 하지만, jMock과는 스타일에서 몇 가지 차이점이 있어 이야기할 필요가 있습니다. 다음은 익숙한 테스트입니다.

```java
public class OrderEasyTester extends TestCase {
    private static String TALISKER = "Talisker";
    private MockControl warehouseControl;
    private Warehouse warehouseMock;

    public void setUp() {
        warehouseControl = MockControl.createControl(Warehouse.class);
        warehouseMock = (Warehouse) warehouseControl.getMock();
    }

    public void testFillingRemovesInventoryIfInStock() {
        //setup - data
        Order order = new Order(TALISKER, 50);

        //setup - expectations
        warehouseMock.hasInventory(TALISKER, 50);
        warehouseControl.setReturnValue(true);
        warehouseMock.remove(TALISKER, 50);
        warehouseControl.replay();

        //exercise
        order.fill(warehouseMock);

        //verify
        warehouseControl.verify();
        assertTrue(order.isFilled());
    }

    public void testFillingDoesNotRemoveIfNotEnoughInStock() {
        Order order = new Order(TALISKER, 51);
        warehouseMock.hasInventory(TALISKER, 51);
        warehouseControl.setReturnValue(false);
        warehouseControl.replay();
        order.fill((Warehouse) warehouseMock);
        assertFalse(order.isFilled());
        warehouseControl.verify();
    }
}
```

EasyMock은 기대를 설정하기 위해 기록/재생에 대한 metaphor를 사용합니다. 목 처리하려는 각 객체에 대해 컨트롤과 목 객체를 생성합니다. mock 객체는 보조 객체의 인터페이스를 만족시키고, 컨트롤은 추가 기능을 제공합니다. 기대치를 나타내려면 mock 객체에서 예상하는 인수를 사용하여 메서드를 호출합니다. 반환 값이 필요한 경우 컨트롤을 호출합니다. 기대치 설정을 마치면 컨트롤에서 `replay`를 호출합니다. 이 시점에서 mock 객체는 기록을 마치고 주요 객체에 응답할 준비가 됩니다. 완료되면 컨트롤에서 `verify`를 호출합니다.

사람들은 처음에는 기록/재생 메타포에 당황하더라도 빠르게 익숙해지는 것 같습니다. 이는 jMock의 제약 조건보다 장점이 있는데, 문자열로 메서드 이름을 지정하는 대신 mock 객체에 실제 메서드 호출을 하기 때문입니다. 이는 IDE에서 코드 자동 완성을 사용할 수 있고, 메서드 이름 리팩토링 시 테스트가 자동으로 업데이트된다는 의미입니다. 단점은 더 느슨한 제약 조건을 가질 수 없다는 것입니다. 

jMock 개발자들은 실제 메서드 호출을 허용하는 다른 기법을 사용할 새로운 버전을 개발 중입니다.

## mock 객체와 스텁의 차이점

처음 많은 사람들은 mock 객체를 일반적인 테스팅 개념인 스텁과 혼동했습니다. 점차 사람들은 그 차이점을 더 잘 이해하게 된 것 같습니다 (그리고 거기에 이 논문의 이전 버전이 도움이 되었기를 바랍니다). 그러나 사람들이 mock 객체를 사용하는 방식을 완전히 이해하려면 mock 객체와 다른 종류의 테스트 더블(test doubles)을 이해하는 것이 중요합니다. ("더블"? 이 용어가 생소하더라도 걱정하지 마세요. 몇 단락만 기다리면 모든 것이 명확해질 것입니다.)

이러한 방식으로 테스팅을 수행할 때, 소프트웨어의 한 요소에 한 번에 집중하게 됩니다. 이것이 "단위 테스트(unit testing)"라는 일반적인 용어가 나온 이유입니다. 문제는 단일 단위를 작동시키려면 종종 다른 단위가 필요하다는 점입니다. 이것이 우리 예시에서 어떤 종류의 창고가 필요한 이유입니다.

위에서 보여드린 두 가지 테스팅 스타일에서, 첫 번째 경우는 실제 창고 객체를 사용하고 두 번째 경우는 mock 창고를 사용하는데, 물론 이는 실제 창고 객체가 아닙니다. mock 객체를 사용하는 것은 테스트에서 실제 창고를 사용하지 않는 한 가지 방법이지만, 이와 같은 테스팅에 사용되는 비실제 객체에는 다른 형태도 있습니다.

이것에 대해 이야기하는 어휘는 곧 혼란스러워집니다. 스텁(stub), mock(mock), 가짜(fake), 더미(dummy) 등 온갖 단어가 사용됩니다. 이 글에서는 Gerard Meszaros의 책 어휘를 따를 것입니다. 모든 사람이 사용하는 것은 아니지만, 좋은 어휘라고 생각하고 제 에세이이므로 어떤 단어를 사용할지는 제가 선택할 수 있습니다. 

Meszaros는 **테스트 더블**(Test Double)이라는 용어를 테스팅 목적으로 실제 객체 대신 사용되는 모든 종류의 가상 객체에 대한 일반적인 용어로 사용합니다. 이 이름은 영화의 스턴트 더블(Stunt Double) 개념에서 유래했습니다. (그의 목표 중 하나는 이미 널리 사용되는 이름을 피하는 것이었습니다.) Meszaros는 이어서 다섯 가지 특정 종류의 더블을 정의했습니다.

• **더미**(Dummy) 객체는 전달되지만 실제로는 사용되지 않습니다. 보통은 단순히 매개변수 목록을 채우는 데 사용됩니다.

• **가짜**(Fake) 객체는 실제 작동하는 구현을 가지고 있지만, 일반적으로 프로덕션에는 적합하지 않은 어떤 편법을 사용합니다 (인메모리 데이터베이스가 좋은 예입니다).

• **스텁**(Stubs)은 테스트 중에 이루어진 호출에 대해 미리 정해진 답변을 제공하며, 일반적으로 테스트를 위해 프로그래밍된 것 외에는 아무것도 응답하지 않습니다.

• **스파이**(Spies)는 호출된 방식에 따라 일부 정보를 기록하는 스텁입니다. 한 가지 형태는 몇 개의 메시지가 전송되었는지 기록하는 이메일 서비스일 수 있습니다.

• **목 객체**(Mocks)는 여기서 논의하는 것으로, 예상되는 호출 사양을 형성하는 기대치로 미리 프로그래밍된 객체입니다.

이러한 종류의 더블 중 mock 객체만이 **행동 검증**을 고집합니다. 다른 더블은 상태 검증을 사용할 수 있으며, 일반적으로 사용합니다. mock 객체는 실행 단계에서 다른 더블처럼 동작하여 SUT가 실제 협력자와 통신하고 있다고 믿게 해야 하지만, mock 객체는 설정 및 검증 단계에서 차이가 있습니다. 

테스트 더블에 대해 더 자세히 알아보려면 예시를 확장해야 합니다. 많은 사람들이 실제 객체가 다루기 어렵지 않은 경우에만 테스트 더블을 사용합니다. 테스트 더블의 더 흔한 경우는 주문을 채우는 데 실패했을 때 이메일 메시지를 보내고 싶다고 말하는 경우입니다. 문제는 테스트 중에 고객에게 실제 이메일 메시지를 보내고 싶지 않다는 것입니다. 그래서 대신 우리가 제어하고 조작할 수 있는 이메일 시스템의 테스트 더블을 만듭니다.

여기서 mock 객체와 스텁의 차이를 알아보기 시작할 수 있습니다. 이 메일링 행동에 대한 테스트를 작성한다면, 다음과 같은 간단한 스텁을 작성할 수 있습니다.

```java
public interface MailService {
    public void send (Message msg);
}

public class MailServiceStub implements MailService {
    private List<Message> messages = new ArrayList<Message>();
    public void send (Message msg) {
        messages.add(msg);
    }
    public int numberSent() {
        return messages.size();
    }
}
```

그런 다음 이 스텁에 대해 **상태 검증**을 다음과 같이 사용할 수 있습니다.

```java
class OrderStateTester...
public void testOrderSendsMailIfUnfilled() {
    Order order = new Order(TALISKER, 51);
    MailServiceStub mailer = new MailServiceStub();
    order.setMailer(mailer);
    order.fill(warehouse);
    assertEquals(1, mailer.numberSent());
}
```

물론 이것은 매우 간단한 테스트입니다. 메시지가 전송되었는지 여부만 확인합니다. 올바른 사람에게 올바른 내용으로 전송되었는지 테스트하지는 않았지만, 요점을 설명하기에는 충분합니다. 

mock 객체를 사용하면 이 테스트는 상당히 다르게 보일 것입니다.

```java
class OrderInteractionTester...
public void testOrderSendsMailIfUnfilled() {
    Order order = new Order(TALISKER, 51);
    Mock warehouse = mock(Warehouse.class);
    Mock mailer = mock(MailService.class);
    order.setMailer((MailService) mailer.proxy());
    mailer.expects(once()).method("send");
    warehouse.expects(once()).method("hasInventory")
             .withAnyArguments()
             .will(returnValue(false));
    order.fill((Warehouse) warehouse.proxy());
}
```

두 경우 모두 실제 메일 서비스 대신 테스트 더블을 사용하고 있습니다. 스텁은 상태 검증을 사용하는 반면 mock 객체는 행동 검증을 사용한다는 차이점이 있습니다.

스텁에 대해 상태 검증을 사용하려면 검증을 돕기 위해 스텁에 추가 메서드를 만들어야 합니다. 결과적으로 스텁은 `MailService`를 구현하지만 추가 테스트 메서드를 추가합니다.

mock 객체는 항상 행동 검증을 사용하는 반면, 스텁은 양쪽 모두 가능합니다. Meszaros는 행동 검증을 사용하는 스텁을 **테스트 스파이**(Test Spy)라고 부릅니다. 차이점은 더블이 정확히 어떻게 실행되고 검증되는지에 있으며, 이는 독자에게 맡기겠습니다.

## Classical 과 Mockist 테스트

이제 두 번째 이분법, 즉 classic TDD와 mockist TDD를 탐구할 시점입니다. 여기서 가장 큰 문제는 mock 객체(또는 다른 더블)를 **언제** 사용할 것인가입니다.

**classic TDD** 스타일은 가능하다면 실제 객체를 사용하고, 실제 객체를 사용하기 어렵다면 더블을 사용하는 것입니다. 따라서 classic TDD 개발자는 실제 창고를 사용하고 메일 서비스에는 더블을 사용할 것입니다. 어떤 종류의 더블인지는 그다지 중요하지 않습니다. 

**mockist TDD** 실무자는 흥미로운 행동을 가진 모든 객체에 대해 항상 mock 객체를 사용할 것입니다. 이 경우 창고와 메일 서비스 모두에 해당됩니다.

다양한 mock 프레임워크는 mockist 테스팅을 염두에 두고 설계되었지만, 많은 classist들은 더블을 생성하는 데 유용하다는 것을 발견합니다.

mockist 스타일의 중요한 파생물은 [**행동 주도 개발**(Behavior Driven Development, BDD)](https://dannorth.net/introducing-bdd/)입니다. BDD는 원래 제 동료 Daniel Terhorst-North가 TDD가 설계 기법으로 어떻게 작동하는지에 초점을 맞춰 사람들이 테스트 주도 개발을 더 잘 배우도록 돕기 위한 기법으로 개발되었습니다. 이는 TDD가 객체가 무엇을 해야 하는지에 대해 생각하는 데 어떻게 도움이 되는지 더 잘 탐구하기 위해 테스트를 행동으로 이름을 바꾸는 것으로 이어졌습니다. BDD는 mockist 접근 방식을 취하지만, 이름 지정 스타일과 기법 내에 분석을 통합하려는 욕구 모두에서 이를 확장합니다. BDD가 이 글과 관련된 유일한 점은 BDD가 mockist 테스팅을 사용하는 TDD의 또 다른 변형이라는 것뿐이므로, 여기서는 더 이상 자세히 다루지 않겠습니다. 더 많은 정보는 링크를 따라가 보세요.

때때로 "디트로이트(Detroit)" 스타일은 "고전주의(classical)"로, "런던(London)" 스타일은 "mockist"으로 사용되는 것을 볼 수 있습니다. 이는 XP가 원래 디트로이트의 C3 프로젝트에서 개발되었고, mockist 스타일은 런던의 초기 XP 채택자들이 개발했다는 사실을 암시합니다. 또한 많은 mockist TDD 개발자들이 그 용어, 심지어 classic 테스팅과 mockist 테스팅 간에 다른 스타일을 암시하는 어떤 용어도 싫어한다는 점을 언급해야 합니다. 그들은 두 스타일 사이에 유용한 구분이 없다고 생각합니다.

## 차이점과 선택

이 글에서 저는 상태 또는 행동 검증 / classic 또는 mockist TDD라는 두 가지 차이점을 설명했습니다. 선택을 할 때 염두에 두어야 할 주장은 무엇일까요? 상태 대 행동 검증 선택부터 시작하겠습니다.

가장 먼저 고려해야 할 것은 컨텍스트입니다. 주문과 창고처럼 쉬운 협업에 대해 생각하고 있습니까, 아니면 주문과 메일 서비스처럼 어려운 협업에 대해 생각하고 있습니까?

쉬운 협업이라면 선택은 간단합니다. 만약 제가 classic TDD 개발자라면 mock 객체, 스텁 또는 어떤 종류의 더블도 사용하지 않을 것입니다. 실제 객체와 상태 검증을 사용할 것입니다. 만약 제가 mockist TDD 개발자라면 mock 객체와 행동 검증을 사용할 것입니다. 전혀 결정할 필요가 없습니다.

만약 어려운 협업이라면, 제가 mockist라면 결정할 필요가 없습니다. 그냥 mock 객체와 행동 검증을 사용합니다. 만약 제가 classist라면 선택권이 있지만, 어떤 것을 사용할지는 큰 문제는 아닙니다. 보통 classist들은 각 상황에 가장 쉬운 경로를 사용하여 사례별로 결정할 것입니다.

따라서 보시다시피, 상태 대 행동 검증은 대부분 큰 결정이 아닙니다. 진정한 문제는 classic TDD와 mockist TDD 사이입니다. 결과적으로 상태 및 행동 검증의 특성은 그 논의에 영향을 미치며, 그곳에 대부분의 에너지를 집중할 것입니다.

하지만 그 전에, 예외적인 경우를 하나 언급하겠습니다. 가끔은 상태 검증을 사용하기 정말 어려운 경우가 있습니다. 심지어 협업이 어렵지 않더라도 말입니다. 이에 대한 좋은 예는 캐시입니다. 캐시의 핵심은 캐시 히트인지 미스인지 상태로는 알 수 없다는 점입니다. 이는 심지어 **하드코어 classic TDD 개발자에게도 행동 검증이 현명한 선택**이 되는 경우입니다. 양방향으로 다른 예외가 있을 것이라고 확신합니다.

classic과 mockist 선택에 대해 깊이 파고들수록 고려해야 할 요소가 많으므로, 대략적인 그룹으로 나누어 설명하겠습니다.

### TDD 주도(Driving TDD)

mock 객체는 XP 커뮤니티에서 나왔으며, XP의 주요 특징 중 하나는 테스트 작성을 통해 시스템 설계를 반복적으로 발전시키는 **테스트 주도 개발**(Test Driven Development)에 대한 강조입니다.

따라서 mockist들이 특히 mockist 테스팅이 설계에 미치는 영향에 대해 이야기하는 것은 놀라운 일이 아닙니다. 특히 그들은 **요구 주도 개발**(need-driven development)이라는 스타일을 옹호합니다. 이 스타일에서는 시스템의 외부를 위한 첫 번째 테스트를 작성하여 [사용자 스토리](https://martinfowler.com/bliki/UserStory.html) 개발을 시작하고, 일부 인터페이스 객체를 SUT로 만듭니다. 협력자에 대한 기대치를 생각함으로써 SUT와 그 주변 객체 간의 상호작용을 탐구하며, 이는 SUT의 아웃바운드 인터페이스를 효과적으로 설계하는 것입니다.

첫 번째 테스트를 실행하면, mock 객체에 대한 기대치가 다음 단계의 사양과 테스트의 시작점을 제공합니다. 각 기대치를 협력자에 대한 테스트로 전환하고 시스템에 한 번에 하나의 SUT로 작업하는 과정을 반복합니다. 이 스타일은 **외부에서 내부로**(outside-in)라고도 불리는데, 이는 매우 설명적인 이름입니다. 계층화된 시스템과 잘 작동합니다. 먼저 mock 계층을 사용하여 UI를 프로그래밍합니다. 그런 다음 하위 계층에 대한 테스트를 작성하고, 한 번에 한 계층씩 시스템을 점차적으로 탐색합니다. 이는 매우 구조화되고 제어된 접근 방식이며, 많은 사람들이 OO와 TDD에 대한 초보자들을 안내하는 데 도움이 된다고 믿습니다.

Classic TDD는 이와 다릅니다. mock 객체 대신 스텁 메서드를 사용하여 유사한 단계별 접근 방식을 수행할 수 있습니다. 이를 위해 협력자로부터 무언가가 필요할 때마다 테스트에 필요한 정확한 응답을 하드코딩하여 SUT가 작동하도록 만듭니다. 그런 다음 해당 부분이 완료되면 하드코딩된 응답을 적절한 코드로 대체합니다.

그러나 Classic TDD는 다른 것도 할 수 있습니다. 일반적인 스타일은 **중간에서 외부로**(middle-out)입니다. 이 스타일에서는 기능을 선택하고 이 기능이 작동하는 데 필요한 도메인에 무엇이 필요한지 결정합니다. 도메인 객체가 필요한 작업을 수행하도록 만들고 일단 작동하면 그 위에 UI를 계층화합니다. 이렇게 하면 아무것도 가짜로 만들 필요가 없을 수도 있습니다. 많은 사람들이 도메인 모델에 먼저 집중하여 도메인 논리가 UI로 새는 것을 방지하는 데 도움이 되기 때문에 이 방식을 좋아합니다.

mockist와 classist 모두 한 번에 하나의 스토리를 진행한다는 점을 강조해야 합니다. 한 계층이 완료될 때까지 다음 계층을 시작하지 않고 애플리케이션을 계층별로 구축하는 사고방식도 있습니다. classist와 mockist 모두 민첩한 배경을 가지고 있으며 세분화된 반복을 선호합니다. 결과적으로 그들은 계층별이 아닌 기능별로 작업합니다.

### 픽스처 설정(Fixture Setup)

classic TDD에서는 SUT뿐만 아니라 테스트에 응답하여 SUT가 필요로 하는 모든 협력자도 생성해야 합니다. 예시에서는 객체가 두 개에 불과했지만, 실제 테스트에는 종종 많은 보조 객체가 포함됩니다. 일반적으로 이러한 객체는 테스트가 실행될 때마다 생성되고 해체됩니다.

그러나 mockist 테스트는 SUT와 그 바로 옆에 있는 mock 객체만 생성하면 됩니다. 이렇게 하면 복잡한 픽스처를 구축하는 데 드는 복잡한 작업을 피할 수 있습니다 (이론상으로는 그렇습니다. 꽤 복잡한 mock 설정에 대한 이야기를 접했지만, 이는 도구를 제대로 사용하지 못했기 때문일 수도 있습니다)

실제로 classic 테스터는 가능한 한 복잡한 픽스처를 재사용하는 경향이 있습니다. 가장 간단한 방법으로는 픽스처 설정 코드를 xUnit `setup` 메서드에 넣는 것입니다. 더 복잡한 픽스처는 여러 테스트 클래스에서 사용해야 하므로, 이 경우 특별한 픽스처 생성 클래스를 만듭니다. 저는 보통 초기 Thoughtworks XP 프로젝트에서 사용된 명명 규칙에 따라 이들을 [**Object Mothers**](https://martinfowler.com/bliki/ObjectMother.html)라고 부릅니다. Mothers를 사용하는 것은 대규모 classic 테스팅에서 필수적이지만, Mothers는 유지보수해야 하는 추가 코드이며 Mothers에 대한 변경은 테스트 전체에 상당한 파급 효과를 미칠 수 있습니다. 픽스처를 설정하는 데 성능 비용이 발생할 수도 있지만, 제대로 수행될 경우 심각한 문제로 들은 적은 없습니다. 대부분의 픽스처 객체는 생성 비용이 저렴하며, 그렇지 않은 객체는 보통 더블로 처리됩니다.

그 결과 저는 두 스타일 모두 상대방이 너무 많은 노력을 요구한다고 비난하는 것을 들었습니다. mockist들은 픽스처를 생성하는 데 많은 노력이 든다고 말하지만, classist들은 이는 재사용될 수 있으며 테스트마다 mock 객체를 생성해야 한다고 말합니다.

### 테스트 격리(Test Isolation)

mockist 테스팅을 사용하여 시스템에 버그를 도입하면, 일반적으로 버그를 포함하는 SUT의 테스트만 실패합니다. 그러나 classic 접근 방식을 사용하면 클라이언트 객체의 모든 테스트도 실패할 수 있으며, 이는 버그가 있는 객체가 다른 객체의 테스트에서 협력자로 사용될 때 실패로 이어집니다. 결과적으로 자주 사용되는 객체에서의 실패는 시스템 전체에 걸쳐 테스트 실패의 파급 효과를 초래합니다.

mockist 테스터들은 이를 주요 문제로 간주합니다. 이는 오류의 근원을 찾아 수정하기 위해 많은 디버깅을 초래합니다. 그러나 classist들은 이를 문제의 원인으로 표현하지 않습니다. 일반적으로 어떤 테스트가 실패하는지 보면 범인을 비교적 쉽게 찾아낼 수 있으며, 개발자들은 다른 실패가 근본적인 오류에서 파생된 것임을 알 수 있습니다. 또한 정기적으로 테스트를 수행한다면 (그렇게 해야 합니다) 최근에 편집한 내용으로 인해 문제가 발생했음을 알기 때문에 결함을 찾는 것이 어렵지 않습니다.

여기서 중요할 수 있는 한 가지 요소는 테스트의 **세분성**(granularity)입니다. classic 테스트는 여러 실제 객체를 실행하기 때문에, 종종 단일 테스트가 단일 객체가 아닌 객체 클러스터의 주요 테스트가 되는 경우가 많습니다. 그 클러스터가 많은 객체에 걸쳐 있다면, 버그의 실제 원인을 찾기가 훨씬 더 어려울 수 있습니다. 여기서 발생하는 문제는 테스트가 너무 **굵은 입자**(coarsed grain)이라는 것입니다.

mockist 테스트는 이러한 문제로 고통받을 가능성이 적습니다. 왜냐하면 협력자에 대해 더 세분화된 테스트가 필요하다는 것을 명확히 하기 위해 기본 객체 외의 모든 객체를 mock 처리하는 것이 관행이기 때문입니다. 그렇다고 해서 지나치게 굵은 입자 테스트를 사용하는 것이 classic 테스팅 기법의 실패라고 할 수는 없으며, 오히려 classic 테스팅을 제대로 수행하지 못한 결과입니다. 좋은 경험 법칙은 모든 클래스에 대해 세분화된 테스트를 분리하는 것입니다. 클러스터가 때때로 합리적일 수 있지만, 그 수는 극히 소수의 객체, 즉 6개 이하로 제한되어야 합니다. 또한, 지나치게 굵은 입자 테스트로 인해 디버깅 문제가 발생하면, 테스트 주도 방식으로 디버깅하여 진행하면서 더 세분화된 테스트를 생성해야 합니다.

본질적으로 고전적인 xUnit 테스트는 단순히 단위 테스트가 아니라 **미니 통합 테스트**이기도 합니다. 결과적으로 많은 사람들은 클라이언트 테스트가 객체의 주요 테스트가 놓쳤을 수 있는 오류, 특히 클래스가 상호 작용하는 영역을 포착할 수 있다는 사실을 좋아합니다. mockist 테스트는 그러한 장점을 잃습니다. 또한 mockist 테스트의 기대치가 잘못되어 단위 테스트가 통과되지만 본질적인 오류를 가릴 위험도 있습니다.

여기서 어떤 스타일의 테스트를 사용하든 시스템 전체에 걸쳐 작동하는 **더 굵은 입자 인수 테스트**와 결합해야 한다는 점을 강조해야 합니다. 저는 인수 테스트 사용을 늦게 시작하여 후회했던 프로젝트들을 종종 접했습니다.

### 구현에 대한 테스트 결합(Coupling Tests to Implementations)

mockist 테스트를 작성할 때, SUT가 공급자와 올바르게 통신하는지 확인하기 위해 SUT의 아웃바운드 호출을 테스트합니다. classic 테스트는 최종 상태에만 관심을 가지며, 그 상태가 어떻게 파생되었는지에는 관심이 없습니다. 따라서 mockist 테스트는 메서드의 구현에 더 많이 **결합**(coupled)됩니다. 협력자에 대한 호출의 성격을 변경하면 일반적으로 mockist 테스트가 깨집니다.

이러한 결합은 몇 가지 우려를 낳습니다. 가장 중요한 것은 **테스트 주도 개발**(Test Driven Development)에 미치는 영향입니다. mockist 테스팅을 사용하면 테스트를 작성할 때 행동의 구현에 대해 생각하게 됩니다. 실제로 mockist 테스터들은 이를 장점으로 봅니다. 그러나 classist들은 외부 인터페이스에서 일어나는 일에 대해서만 생각하고, 테스트 작성을 마칠 때까지 구현에 대한 모든 고려를 미루는 것이 중요하다고 생각합니다.

구현에 대한 결합은 리팩토링도 방해하는데, 구현 변경이 classic 테스팅보다 테스트를 깨뜨릴 가능성이 훨씬 높기 때문입니다.

이는 mock 툴킷의 특성으로 인해 더욱 악화될 수 있습니다. 종종 mock 도구는 이 특정 테스트와 관련이 없더라도 매우 구체적인 메서드 호출과 매개변수 일치를 지정합니다. jMock 툴킷의 목표 중 하나는 기대치의 사양에서 더 유연하여, 중요하지 않은 영역에서 기대치를 더 느슨하게 허용하는 것입니다. 이는 리팩토링을 더 까다롭게 만들 수 있는 문자열을 사용하는 비용을 감수합니다.

### 디자인 스타일

이러한 테스팅 스타일의 가장 흥미로운 측면 중 하나는 설계 결정에 미치는 영향입니다. 두 가지 유형의 테스터들과 대화하면서, 이러한 스타일이 장려하는 설계 방식 간에 몇 가지 차이점을 알게 되었지만, 아직 표면적인 부분만 건드린 것 같습니다.

저는 이미 계층을 다루는 방식의 차이점을 언급했습니다. mockist 테스팅은 **외부에서 내부로**(outside-in) 접근 방식을 지원하는 반면, 도메인 모델 우선 스타일을 선호하는 개발자들은 classic 테스팅을 선호하는 경향이 있습니다.

더 작은 수준에서 저는 mockist 테스터들이 값을 반환하는 메서드보다는 **수집 객체**(collecting object)에 작용하는 메서드를 선호하는 경향이 있다는 것을 발견했습니다. 객체 그룹에서 정보를 수집하여 보고서 문자열을 생성하는 행동을 예로 들어 보겠습니다. 이를 수행하는 일반적인 방법은 보고서 메서드가 다양한 객체에서 문자열 반환 메서드를 호출하고 결과 문자열을 임시 변수에 조립하는 것입니다. mockist 테스터는 문자열 버퍼를 다양한 객체에 전달하고 해당 객체가 버퍼에 다양한 문자열을 추가하도록 하는 경향이 더 강할 것입니다. 문자열 버퍼를 **수집 매개변수**(collecting parameter)로 취급하는 것입니다.

mockist 테스터들은 **'기차 사고(train wrecks)'**, 즉 `getThis().getThat().getTheOther()`와 같은 메서드 체인을 피하는 것에 대해 더 많이 이야기합니다. 메서드 체인을 피하는 것은 **디미터의 법칙**(Law of Demeter)을 따르는 것으로도 알려져 있습니다. 메서드 체인은 좋지 않은 징후이지만, 포워딩 메서드로 부풀려진 중간자 객체라는 반대 문제도 좋지 않은 징후입니다. (저는 디미터의 법칙이 '디미터의 제안'으로 불렸다면 더 편했을 것이라고 항상 느꼈습니다).

객체 지향 설계에서 사람들이 가장 이해하기 어려운 것 중 하나는 [**"묻지 말고 시켜라(Tell Don't Ask)"**](https://martinfowler.com/bliki/TellDontAsk.html) 원칙인데, 이는 클라이언트 코드에서 데이터를 뜯어내어 처리하기보다는 객체에게 무언가를 하도록 지시하는 것을 장려합니다. mockist들은 mockist 테스팅을 사용하면 이를 촉진하고 요즘 너무 많은 코드에 만연한 **게터(getter) 혼란**을 피하는 데 도움이 된다고 말합니다. classist들은 이를 수행하는 다른 많은 방법이 있다고 주장합니다.

상태 기반 검증의 인정된 문제점은 **검증만을 지원하기 위해 질의 메서드를 생성할 수 있다**는 것입니다. 객체의 API에 오직 테스트만을 위해 메서드를 추가하는 것은 결코 편안하지 않으며, 행동 검증은 그 문제를 피합니다. 이에 대한 반론은 그러한 수정이 실제로는 대개 사소하다는 것입니다.

mockist들은 [**역할 인터페이스**(role interfaces)](https://martinfowler.com/bliki/RoleInterface.html)를 선호하며, 이러한 테스팅 스타일이 더 많은 역할 인터페이스를 장려한다고 주장합니다. 각 협업이 개별적으로 mock 처리되므로 역할 인터페이스로 전환될 가능성이 더 높기 때문입니다. 따라서 위 예시에서 보고서 생성을 위해 문자열 버퍼를 사용하는 경우, mockist는 해당 도메인에서 의미 있는 특정 역할을 발명할 가능성이 더 높을 것입니다. 이 역할은 문자열 버퍼로 구현될 **수도** 있습니다.

이러한 디자인 스타일의 차이점이 대부분의 mockist들에게 핵심적인 동기 부여 요인이라는 점을 기억하는 것이 중요합니다. TDD의 기원은 진화적 설계를 지원하는 강력한 자동 회귀 테스트를 얻으려는 열망이었습니다. 그 과정에서 TDD 실무자들은 테스트를 먼저 작성하는 것이 설계 프로세스에 상당한 개선을 가져온다는 것을 발견했습니다. mockist들은 어떤 종류의 설계가 좋은 설계인지에 대한 강력한 아이디어를 가지고 있으며, 주로 사람들이 이러한 설계 스타일을 개발하도록 돕기 위해 mock 라이브러리를 개발했습니다.

## classist가 되어야 할까, mockist가 되어야 할까?

저는 이 질문에 자신 있게 대답하기 어렵습니다. 개인적으로 저는 항상 구식 classic TDD 개발자였으며, 지금까지는 바꿀 이유를 찾지 못했습니다. mockist TDD에서 설득력 있는 이점을 찾지 못했고, 테스트를 구현에 결합하는 결과에 대해 우려하고 있습니다.

이는 제가 mockist 프로그래머를 관찰했을 때 특히 두드러졌습니다. 테스트를 작성하는 동안 행동의 결과에 집중하고 그것이 어떻게 수행되는지에 대해서는 생각하지 않는다는 점이 정말 마음에 듭니다. mockist는 기대치를 작성하기 위해 SUT가 어떻게 구현될 것인지를 끊임없이 생각합니다. 이는 저에게는 정말 부자연스럽게 느껴집니다.

저는 또한 장난감 수준 이상으로 mockist TDD를 시도해 본 적이 없다는 단점을 가지고 있습니다. 테스트 주도 개발 자체에서 배운 것처럼, 어떤 기법을 진지하게 시도해 보지 않고서는 판단하기 어려운 경우가 많습니다. 저는 매우 만족하고 확신에 찬 mockist 개발자들을 많이 알고 있습니다. 따라서 저는 여전히 확신에 찬 classist이지만, 여러분이 스스로 판단할 수 있도록 두 가지 주장을 최대한 공정하게 제시하고 싶습니다.

그러므로 mockist 테스팅이 매력적으로 들린다면, 한번 시도해 보시길 제안합니다. 특히 mockist TDD가 개선하려는 영역에서 문제가 있다면 시도해 볼 가치가 있습니다. 저는 여기서 두 가지 주요 영역을 봅니다. 하나는 테스트가 깔끔하게 깨지지 않고 문제의 위치를 알려주지 않아 테스트 실패 시 디버깅에 많은 시간을 소비하는 경우입니다. (이는 더 세분화된 클러스터에 classic TDD를 사용해서도 개선할 수 있습니다.) 두 번째 영역은 객체에 충분한 행동이 없을 때입니다. mockist 테스팅은 개발 팀이 더 행동이 풍부한 객체를 만들도록 장려할 수 있습니다.

## 결론

단위 테스팅, xUnit 프레임워크 및 테스트 주도 개발에 대한 관심이 커지면서 점점 더 많은 사람들이 mock 객체를 접하고 있습니다. 많은 경우 사람들은 mock 객체 프레임워크에 대해 약간 배우지만, 그 기반이 되는 **mockist/classic 분할**(mockist/classical divide)을 완전히 이해하지 못합니다. 그 분할 중 어느 쪽에 기울든, 이러한 관점의 차이를 이해하는 것이 유용하다고 생각합니다. mock 프레임워크가 유용하다는 것을 알기 위해 mockist가 될 필요는 없지만, 소프트웨어의 많은 설계 결정을 안내하는 사고방식을 이해하는 것이 유용합니다.

이 글의 목적은 이러한 차이점을 지적하고 그 장단점을 제시하는 것이었습니다. mockist 사고방식에는 제가 다룰 시간이 없었던 더 많은 것이 있습니다. 특히 설계 스타일에 미치는 영향이 그렇습니다. 앞으로 몇 년 동안 이에 대해 더 많은 글이 쓰여지고, 코드를 작성하기 전에 테스트를 작성하는 것의 흥미로운 결과에 대한 우리의 이해가 깊어지기를 바랍니다.