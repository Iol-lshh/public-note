---
title: 카프카 테스트 작성하기
date: 2025-09-05
description: 카프카로 테스트를 작성하는 방법에 대한 고민과 실험
category:
  - 실험
  - 회고
---
카프카를 어떻게 써야하나. 나는 내가 짠 코드를 신뢰하지 않는다. 

> 예술은 완성될 수 없다, 그저 버려질 뿐이다.. (Art is never finished, only abandoned.) - 레오나르도 다빈치

심지어 예술은 예쁘기라도 하지, 코드는 분석해야하는... 그저 부채다. 그런 코드로 쌓아올린 애플리케이션은 믿을 수 없다. 때문에 테스트를 작성해야한다.

하지만 어떻게, 내 애플리케이션을 테스트하는데, 다른 애플리케이션에서 발행하는 이벤트에 대한 테스트를 작성 가능할까?

---

## 분해

어떤 부분을 테스트 할 것인가? 비즈니스 로직을 테스트하는 것인가, api를 테스트하는 것인가.
카프카를 이용하는 부분을 테스트한다는 의미는 인터페이스에 대한 이야기라고 생각한다. 카프카는 브로커로부터 이벤트를 컨슘하여 애플리케이션 내부로 전달하는 핸들링 인터페이스라고 보기 때문이다.

카프카를 테스트한다는 것은 애플리케이션의 유스케이스에서 조금 벗어나있다. 내가 테스트하고 싶은 것은, 카프카의 구성 설정에 따른 이야기다. 전체 플로우의 이벤트 발행자(Publisher)에 해당하는 카프카의 프로듀서(Producer) 부분에는 별로 관심이 없다. 알아서 잘 발행하겠지...

문제는 브로커와 플로우의 이벤트 구독자(Subscriber)에 해당하는 카프카의 컨슈머(Consumer)다.

브로커는 토픽과 파티션으로 구성된다.

- 토픽: 논리적 경로
- 파티션: 물리적 경로

![](img/diagram-apache-kafka.svg)

1. 파티션과 컨슈머는 1:1 일때, 병목이 없다. 

![](img/one_one.png)

파티션은 하나의 물리적인 빨대와 같다. 

2. 소스(프로듀서)로 부터 파티션이란 빨대를 컨슈머가 물고있는데, 다른 파티션도 이 컨슈머가 담당한다면, 번갈아가며 빨대를 물어야 한다. 병목이 된다.

![](img/less_consumer.png)

3. 컨슈머가 파티션의 갯수보다 많으면, 남는 컨슈머는 논다. 하지만, 리밸런싱에 대비하여 오버헤드를 줄일 수 있게 도와준다.

![](img/above_consumer.png)

리밸런싱에 대비하여 오버헤드를 줄일 수 있게 도와준다는 게 무슨 의미일까? 

만약 컨슈머 중 하나가 죽으면, 그룹 코디네이터(Group Coordinator)가 리밸런싱을 트리거한다. 이때 카프카는 STW(Stop The World)가 일어나고, 전체 시스템의 단일 장애지점으로 발전한다. 때문에 컨슈머를 파티션보다 갯수가 많게한다. 컨슈머 몇개가 놀 순 있겠지만, 컨슈머가 죽으면, 놀던(Idle) 컨슈머가 일하기 시작하면서, 이런 오버헤드를 줄인다. Lag가 쌓이는 것을 최소화할 수 있다.

카프카는 컨슈머 그룹을 둔다. 각 컨슈머 그룹은 각각의 컨슈머가 파티션에 대해 딱 한번만 호출하고자다. 컨슈머가 메시지를 읽다가 실패해도, 메시지는 유실되지 않고 새로운 컨슈머 그룹이 토픽에 붙는다.

![](img/partition_consumer.png)

---

## 테스트 작성

이제 다시 돌아가서 테스트를 작성해보자. 카프카의 파티션과 컨슈머에 따른 동작을 확인해보고 싶다. 카프카가 필요하다. 스프링 애플리케이션에는 두 가지 방안이 있다.

- 임베디드 카프카 (`@EmbededKafka`)
- 카프카 테스트 컨테이너

둘 모두 카프카를 테스트 환경에 제공한다. 하지만 둘은 조금 다르다.

#### 임베디드 카프카 (`@EmbededKafka`)

임베디드 카프카는 JVM 안에서 Java 코드 레벨에서 시뮬레이션 한다. 속도가 빠르고, CI 파이프라인에도 부담이 적다. 하지만 실제 Kafka 환경과 다르다.

```java
@SpringBootTest
@EmbeddedKafka(partitions = 3,
        brokerProperties = {
            "listeners=PLAINTEXT://localhost:0",
            "auto.create.topics.enable=true"
        })
class EmbeddedKafkaIntegrationTest {

    static final String TOPIC = "demo.internal.topic-v1";

    private static EmbeddedKafkaBroker embeddedKafka;

    // Spring이 주입한 EmbeddedKafkaBroker를 DynamicPropertySource에서 쓰기 위해 보관
    @Autowired
    void setEmbedded(EmbeddedKafkaBroker broker) {
        embeddedKafka = broker;
        // 컨테이너 리스너들이 브로커 준비될 때까지 기다리게 도와줌(테스트 안정화)
        broker.getTopics().forEach(t -> ContainerTestUtils.waitForAssignment(
            broker.getKafkaServers(), broker.getPartitionsPerTopic()));
    }

    @DynamicPropertySource
    static void kafkaProps(DynamicPropertyRegistry r) {
        r.add("spring.kafka.bootstrap-servers", () -> embeddedKafka.getBrokersAsString());
        // 필요 시 테스트용 직렬화/역직렬화 기본값
        r.add("spring.kafka.consumer.auto-offset-reset", () -> "latest");
        r.add("spring.kafka.consumer.key-deserializer", () -> "org.apache.kafka.common.serialization.StringDeserializer");
        r.add("spring.kafka.consumer.value-deserializer", () -> "org.apache.kafka.common.serialization.StringDeserializer");
        r.add("spring.kafka.producer.key-serializer", () -> "org.apache.kafka.common.serialization.StringSerializer");
        r.add("spring.kafka.producer.value-serializer", () -> "org.apache.kafka.common.serialization.StringSerializer");
    }

    @Autowired KafkaTemplate<String, String> kafkaTemplate;
    @Autowired TestListener listener;

    @Test
    void produce_and_consume_with_embedded_kafka() throws InterruptedException {
        var key = "order-1";
        var payload = "hello-embedded";
        kafkaTemplate.send(TOPIC, key, payload).join();

        var record = listener.queue.poll(Duration.ofSeconds(5).toMillis(), java.util.concurrent.TimeUnit.MILLISECONDS);
        assertThat(record).isNotNull();
        assertThat(record.key()).isEqualTo(key);
        assertThat(record.value()).isEqualTo(payload);
    }

    // 테스트 전용 리스너: 실제 앱 리스너 대신, 수신 메시지를 큐에 쌓아 단언하기 쉽게 함
    static class TestListener {
        final BlockingQueue<ConsumerRecord<String, String>> queue = new LinkedBlockingQueue<>();

        @KafkaListener(id = "embedded-test-listener", topics = TOPIC)
        public void onMessage(ConsumerRecord<String, String> rec) {
            queue.offer(rec);
        }
    }

    @TestConfiguration
    static class Cfg {
        @Bean TestListener testListener() { return new TestListener(); }
    }
}
```

#### Kafka Testcontainers

실제 카프카를 도커 컨테이너로 띄운다. 초기화 비용은 크지만, 실제 운영 환경과 유사한 통합 테스트를 수행시킬 수 있다. 실제 카프카를 띄우는 것이기 때문에, 신뢰성이 매우 높다. 브로커 장애, 리밸런싱, 네트워크 지연을 설정하여 시뮬레이션이 가능하다.

```java
@SpringBootTest
@Testcontainers
class KafkaTestcontainersIntegrationTest {

    static final String TOPIC = "demo.internal.topic-v1";

    // Confluent Kafka 이미지 사용 (버전은 프로젝트에 맞게 고정하세요)
    @Container
    static final KafkaContainer KAFKA =
        new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:7.6.1"));

    @DynamicPropertySource
    static void kafkaProps(DynamicPropertyRegistry r) {
        r.add("spring.kafka.bootstrap-servers", KAFKA::getBootstrapServers);
        r.add("spring.kafka.consumer.auto-offset-reset", () -> "latest");
        r.add("spring.kafka.consumer.key-deserializer", () -> "org.apache.kafka.common.serialization.StringDeserializer");
        r.add("spring.kafka.consumer.value-deserializer", () -> "org.apache.kafka.common.serialization.StringDeserializer");
        r.add("spring.kafka.producer.key-serializer", () -> "org.apache.kafka.common.serialization.StringSerializer");
        r.add("spring.kafka.producer.value-serializer", () -> "org.apache.kafka.common.serialization.StringSerializer");
        // 필요 시, acks/compression/retries 등 운영과 유사하게 맞출 수 있음
    }

    @Autowired KafkaTemplate<String, String> kafkaTemplate;
    @Autowired TestListener listener;

    @Test
    void produce_and_consume_with_testcontainers() throws InterruptedException {
        var key = "order-2";
        var payload = "hello-testcontainers";
        kafkaTemplate.send(TOPIC, key, payload).join();

        var record = listener.queue.poll(Duration.ofSeconds(10).toMillis(), java.util.concurrent.TimeUnit.MILLISECONDS);
        assertThat(record).isNotNull();
        assertThat(record.key()).isEqualTo(key);
        assertThat(record.value()).isEqualTo(payload);
    }

    static class TestListener {
        final BlockingQueue<ConsumerRecord<String, String>> queue = new LinkedBlockingQueue<>();

        @KafkaListener(id = "tc-test-listener", topics = TOPIC)
        public void onMessage(ConsumerRecord<String, String> rec) {
            queue.offer(rec);
        }
    }

    @org.springframework.boot.test.context.TestConfiguration
    static class Cfg {
        @Bean TestListener testListener() { return new TestListener(); }
    }
}
```

---

작성중...


### 참조

- https://docs.spring.io/spring-kafka/reference/testing.html
