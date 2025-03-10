---
title: Isolation과 Lock 정리
date: 2025-03-02
description: Isolation에 따라 Lock은 어떻게 동작하는가
category:
  - DB
  - book
tags:
  - DB
  - RDBMS
  - MSSQL
  - SQLServer
  - MySQL
---
![](img/isolation_header.webp)

## 트랜잭션과 ACID

애플리케이션은 트랜잭션 일관성을 갖춰야 한다. 트랜잭션은 정합성(Consistency)과 활동성(Liveness)이 모두 고려되어야 한다. 트랜잭션을 어떻게 구현해야 할까? 보통 ACID를 말한다.

- **Atomicity** (원자성): 트랜잭션이 여러 동작으로 이루어져 있어도, 모두 수행되거나 전혀 수행되지 않아야 한다.
- **Consistency** (일관성, 정합성): 트랜잭션이 무결성과 제약 조건을 유지한다. 불변식(Invariant) 보호
- **Isolation** (고립성): 트랜잭션들은 서로 독립적으로 실행되어야 하며, 서로 영향을 끼치지 않는다.
- **Durability** (지속성): 트랜잭션이 성공적으로 완료되면, 영구적으로 저장되어야 한다.

> 트랜잭션의 일관성(Consistency)은 데이터베이스 시스템의 원자성(Atomicity)과 격리성(Isolation)에 기대어 구현될 수 있다. - [Designing Data-Intensive Applications, Kleppmann]

RDBMS의 동작을 살펴보자.

---

엔진에 따라서 세부사항이 다르겠지만, 개념은 비슷하게 동작된다.

우선 Lock에 대해서 알아야 한다.

## 동시성 제어와 Lock의 개념

데이터 소스 티어에 속하는 데이터베이스 시스템은 또한 하나의 소프트웨어이다. 애플리케이션 부분과 파일 시스템 부분으로 되어있다. 애플리케이션은 데이터를 파일 시스템으로 넣기 위해 메모리를 사용하기도 하고, 파일시스템이나 메모리는 스레드에 대하여 공유 자원이다. (물론 데이터베이스는 더 복잡하고 구성이 다르기도 하지만, 우선 설명을 위해 일반적이고 개념적으로 생각해보자.)

동시성 제어가 필요해지는 것이다. 운영체제는 임계 구역을 보호하기 위해 Lock을 제공하며, 데이터베이스 시스템은 이를 확장하여 자체적인 동시성 제어 기법을 적용한다.

참고로.. Lock은 기술적으로 **자원(Resource)의 개념**으로 이해해야 한다. Mutex나 Semaphore를 생각하면 이해하기 쉽다. Lock을 건다는 것은 획득의 개념이라는 것을 리마인드하고 분류해보자.

개념적으로 생각해봤을 때, 데이터베이스는 다음 락을 구현해야 할 것이다.

- **Read Lock**: 다른 사용자가 같이 읽는 것은 허용하지만 변경하는 것은 허용하지 않음
- **Update Lock**: 다른 사용자가 읽는 것, 변경하는 것 모두 허용하지 않음

이 Read Lock과 Update Lock을 구현하기 위해 좀 더 명확하게 이야기해보자. 읽기, 수정하기 같은 What관점의 단어가 아니라 기술적인 How 관점의 단어를 써보면 이렇다.

- **Shared Lock**(공유 락, S-Lock): S-Lock을 획득한 자원에 대해, 다른 트랜잭션은 S-Lock을 획득할 수 있다. (공유되는 Lock 자원임)
- **Exclusive Lock**(배타 락, X-Lock): X-Lock을 획득한 자원에 대해, 
  - 다른 트랜잭션은 어떤 Lock도 획득 불가능하며, 
  - S-Lock을 획득한 자원에 대해서 다른 트랜잭션은 X-Lock을 획득할 수 없다.

서버 애플리케이션 티어에서 생각해봤을때, 트랜잭션 안에서 일관성을 지키려면 어떻게 처리되어야 할까? Pessimistic Lock? 트랜잭션 안에서 `SELECT ... FOR UPDATE` 쿼리를 쓰면 돼요! 궁금한게 있다. 혹시, 트랜잭션의 격리 레벨을 바꿔가며 적용해봤나?

---

일단 이런 트랜잭션 간에 발생 가능한 문제들에 대해 정확한 정의를 하고 가자.

## 트랜잭션 간 문제와 격리 레벨

- **Dirty Read**: 다른 트랜잭션에서 아직 커밋되지 않은 데이터를 읽는 현상.
  - 딴 트랜잭션에서 뭔가 쓰기 작업을 하고 아직 Commit도 안했는데, 읽히는 것이다.
- **Non-Repeatable Read**: 같은 트랜잭션 내에서 동일한 쿼리를 두 번 실행했을 때, **결과가 달라지는** 현상.
  - 딴 트랜잭션에서 Update하고 Commit 한거다. 내 트랜잭션은 아직 끝나지도 않았는데, 다시 읽어보면 Commit된 Update 내용으로 바뀌어 있는 것이다.
- **Phantom Read**: 같은 트랜잭션 내에서 동일한 조건의 쿼리를 실행했을 때, 이전에는 없던 **새로운 행**이 나타나는 현상.
  - 딴 트랜잭션에서 Insert하고 Commit 한거다. 다시 읽어보면, 원래 있던 데이터들은 똑같은데, Commit된 Insert 내용들이 갑자기 등장한 것이다.

왜 이런 문제가 생긴다는 걸까? 일반적으로 격리 레벨(Isolation Level)은 이 문제 해결에 따라 네 가지 레벨로 정의된다. (MVCC 구현 방법에 대해서는 RDBMS마다 다르므로 개념적으로 기술했다.)

- **READ UNCOMMITTED**: 커밋 안된 것도 읽음
- **READ COMMITTED**: 최소한 커밋 된 것만 읽음
- **REPEATABLE READ**: 반복해서 같은 쿼리로 읽었을 때 결과가 같음
- **SERIALIZABLE**: 직렬화 수준의 동기적인 트랜잭션

다음은 어디서나 볼 수 있는 흔한 정리표다.

| 격리 수준                | 더티 리드 (Dirty Read) | 비반복 읽기 (Non-Repeatable Read) | 팬텀 리드 (Phantom Read) |
| -------------------- | ------------------ | ---------------------------- | -------------------- |
| **READ UNCOMMITTED** | 발생 가능❗️            | 발생 가능❗️                      | 발생 가능❗️              |
| **READ COMMITTED**   | 방지됨 ✅              | 발생 가능❗️                      | 발생 가능❗️              |
| **REPEATABLE READ**  | 방지됨 ✅              | 방지됨 ✅                        | 발생 가능❗️              |
| **SERIALIZABLE**     | 방지됨 ✅              | 방지됨 ✅                        | 방지됨 ✅                |

좀 더 자세히 들어가보자. 
MySQL(innoDB)과 PostgreSQL은 MVCC(undo log)를 통해 트랜잭션 격리를 관리하므로 구조가 조금 더 복잡하다. 우선 MSSQL의 트랜잭션 격리 레벨을 살펴보고, MySQL(innoDB)의 격리레벨을 살펴보자.

---

## MSSQL의 트랜잭션

트랜잭션 하에서 조회되는 레코드들에 대해서 동일한 Lock을 제공하는 것으로 구현된다.

- 쓰기 작업은 무조건 **X-Lock**을 획득한다.
- **READ UNCOMMITTED**: 조회되는 레코드들에 대해서 S-Lock조차 획득하지 않음.
- **READ COMMITTED**: 조회되는 레코드들에 대해서 S-Lock 획득. 단, **조회가 끝나는 순간 곧바로 S-Lock 반환**. 이러니 다른 트랜잭션이 Update 하는걸 막지 못하는거다.
- **REPEATABLE READ**: 조회되는 레코드들에 대해서 **트랜잭션이 끝날때까지** S-Lock 획득. Insert하는 레코드는 모르니, 팬텀리드를 막을 수 없다.
- **SERIALIZABLE**: 조회되는 레코드들마다 트랜잭션이 끝날때까지 **모든 읽는 범위** S-Lock(RangeS-S, 공유 키 범위 + 공유 리소스)을 획득. 쓰기 또한 범위 X-Lock(RangeX-X, 배타 키 범위 + 배타 리소스) 획득. 한 트랜잭션이라도 해당 범위를 갱신하려고 하면 대기 발생. (PG는 스냅샷 방식을 쓰지만, 아이디어는 동일하다고 본다.)

(MSSQL도 MVCC를 옵션(SNAPSHOT Isolation)으로 제공하지만, SNAPSHOT 격리 레벨까지 이야기 하면 MySQL보다 먼저 이야기 하는 이유가 없으니, 우선 여기까지만 이야기하자.)

MSSQL은 **Update Lock**이라는 특별한 Lock 메커니즘을 제공한다. (정말 직관적인 명칭이 아닐수도 없다. 글 초반에 트랜잭션 시스템이 구현해야 할 두 가지 Read/Update Lock에 대해 정리했었다. 마이크로소프트는 종종 자체적인 방식으로 기능을 설계하지만, 이번만큼은 상당히 직관적인 개념 정의의 기능이 아닐 수 없다.)

- **Update Lock**(U-Lock): U-Lock을 획득한 자원에 대해, 다른 트랜잭션의 U-Lock, X-Lock 획득을 방지한다. S-Lock은 허용된다. U-Lock은 Update 가능성이 있는 단위에 대해 걸어두고, 실제 Update 쿼리 동작시에 X-Lock으로 바뀐다.

S-Lock과 X-Lock의 실제 적용 시점을 분리해서, **U-Lock을 얻고 있는 동안에도 단순 조회의 경우엔 가능하도록 열어둔 것**이다. 물론 트랜잭션 격리 레벨에 따라 U-Lock도 더 높은 제한의 Lock을 따라가겠지만. **Read Lock 획득이 중요한 시스템에서 교착 상태를 매우 줄이고, 시스템의 활동성(liveness)을 크게 제공하게 된다.** (비관적 락이라는 것에는 변함 없다. 또한 필요에 따라 CQRS를 추가적으로 적용하는 것도 좋을 것이다.)

- cf) MSSQL은 트랜잭션의 버전 관리를 위해 트랜잭션 로그 파일(`.ldf`)에 데이터베이스 변경 사항을 순차적으로 기록한다.
  - **Transaction Log**: MSSQL에서는 변경 전 데이터(before image), **모든 변경 사항(INSERT, UPDATE, DELETE 등)을 기록**하는 것. rollback 및 redo를 지원한다.
  - `TXID: 1001 | UPDATE users | id = 1 | BEFORE: 'Alice' | AFTER: 'Alice (Updated)'`
    - **트랜잭션 ID:** 해당 트랜잭션의 고유 식별자
    - **기존 값 (before image):** `'Alice'`
    - **변경된 값 (after image):** `'Alice (Updated)'`

---

## MySQL(InnoDB)의 트랜잭션

MySQL(InnoDB)은 MSSQL의 Lock을 이용한 단순한 트랜잭션 구현 방식에 비해 조금 더 복잡한 방식으로 구현된다. MVCC를 이용하여 트랜잭션을 구현하며, MVCC는 Undo Log, Read View로 구현한다. (Redo Log도 있다.)

- **MVCC**(Multi Version Concurrency Control): 다중 버전 동시성 제어. 데이터베이스 관리 시스템에서 데이터베이스에 대한 동시 액세스를 제공하고 프로그래밍 언어에서 트랜잭션 메모리를 구현하는 데 일반적으로 사용되는 **비잠금 동시성 제어 방법.** **읽기 작업이 쓰기 작업을 블록하지 않게 한다.**
- **Redo Log**: 트랜잭션 커밋 보장하거나 크래시 복구를 위한 로그 파일(`ib_logfile0`, `ib_logfile1`)
  - ex) `[TRX_ID: 1001 | Space ID: 5 | Page No: 123 | Offset: 64 | Data: balance=50 | Log Type: MLOG_WRITE]` (의사코드)
- **Undo Log**: **Undo는** 마지막으로 변경한 내용을 지우고 이전 상태로 되돌리는 행위로, 이를 위해 이전 상태를 저장해두는 로그 파일(`ibdata1` 또는 `undo tablespaces`).
  - ex) `[TRX_ID: 1001 | Space ID: 5 | Page No: 123 | Offset: 64 | Before Image: balance=100 | Log Type: MLOG_UNDO_UPDATE | Prev Undo Pointer: NULL]` (의사코드)
- **트랜잭션 아이디**(TRX_ID): 트랜잭션을 식별하는 ID
- **DB_TRX_ID**: 모든 레코드에는 `DB_TRX_ID`라는 숨겨진 시스템 열이 있어, 이 레코드를 마지막으로 수정한 트랜잭션 ID를 저장한다.
- **Read View**: 특정 트랜잭션이 데이터를 읽을 때, 그 시점에서 생성되는 데이터의 스냅샷(snapshot). 메모리에 저장되며, 트랜잭션이 종료되면 휘발된다.

ReadView는 다음으로 구성된다.

- **활성 트랜잭션 리스트**: Read View가 생성된 시점에서 아직 커밋되지 않은 트랜잭션들의 ID 목록
- **최소 트랜잭션 ID (m_low_limit_id)**: Read View 생성 시점에서 활성 트랜잭션 중 가장 낮은 트랜잭션 ID (이 값보다 작은 트랜잭션 ID를 가진 데이터는 "이미 커밋된 상태"로 간주)
- **최대 트랜잭션 ID (m_up_limit_id)**: Read View 생성 시점까지의 가장 높은 트랜잭션 ID (이 값보다 큰 ID를 가진 트랜잭션의 변경 사항은 무시)
- **Creator 트랜잭션 ID (m_creator_trx_id)**: 해당 Read View를 생성한 트랜잭션 ID (자신의 변경 사항은 볼 수 있도록 예외 처리하기 위함)

```cpp
class ReadView {
private:
  trx_id_t m_low_limit_id;  // 최소 트랜잭션 ID
  trx_id_t m_up_limit_id;   // 최대 트랜잭션 ID
  trx_id_t m_creator_trx_id; // 생성자 트랜잭션 ID
  std::vector<trx_id_t> m_ids; // 활성 트랜잭션 ID 목록
public:
  // 생성 및 관리 메서드
  void open(trx_t* trx);
  bool changes_visible(trx_id_t id);
};
```

각 행(row)에는 트랜잭션 ID와 롤백 포인터가 포함된 undo 로그가 연결되어 있어, MVCC는 이를 활용해 적절한 데이터 버전을 선택한다. Read View는 Undo Log를 활용하여 "트랜잭션 시작 시점"의 데이터를 지속적으로 조회할 수 있도록 보장한다.

**Read View를 이용한 MVCC의 쿼리 조회**는 다음과 같이 구현되었다.

- **새로운 Read View를 생성**. 쿼리 시작 시점의 활성 트랜잭션 정보(m_low_limit_id, m_up_limit_id, m_creator_trx_id 등)를 캡처 (트랜잭션 레벨에 따라 다르게 동작)
- 데이터 페이지를 조회
  - 논리적으로 인덱스 또는 힙(클러스터드 인덱스가 없는 경우)을 이용해 조회
  - 물리적으로 데이터 페이지를 메모리(버퍼 풀)에서 확인하고, 없으면 디스크에서 읽어 버퍼 풀에 로드 (이 시점에서 페이지에는 커밋 여부와 상관없는 모든 변경의 **최신 상태**가 포함됨)
- 가져온 **레코드를 기준**으로 레코드의 DB_TRX_ID와 Read View 비교하여 분기
  - **DB_TRX_ID == m_creator_trx_id**: 현재 트랜잭션의 변경이므로 가져온 레코드 반환.
  - **DB_TRX_ID < m_low_limit_id**: 현재 트랜잭션의 Read View 생성 전에 COMMIT된 상태라고 간주하고 가져온 레코드 반환.
  - **DB_TRX_ID > m_up_limit_id**: 현재 트랜잭션의 Read View 생성 이후 시작된 트랜잭션이므로 무시하고 Undo Log 확인.
  - **m_low_limit_id ≤ DB_TRX_ID ≤ m_up_limit_id**: 활성 트랜잭션일 수 있으니 Undo Log 확인
- Undo Log 체인을 따라가며 DB_TRX_ID가 Read View 생성 전에 커밋된 버전(Before Image)을 탐색
- Undo Log에 버전이 없으면, 그 시점의 데이터는 **커밋된 최초 상태**로 간주됨

MSSQL의 물리적 Lock 방식과 달리 MySQL은 MVCC를 통해 논리적 스냅샷으로 트랜잭션을 구현하고 있는 것이다. 그렇다면 트랜잭션 격리 레벨에 따라 무엇이 바뀌는 걸까?

### MySQL의 격리 레벨 구현

- 쓰기 작업은 무조건 **X-Lock**을 획득한다.
- **READ UNCOMMITTED**: Read View를 생성하지 않는다. 바로 원본 레코드를 읽기 때문에 Dirty Read 발생 가능.
- **READ COMMITTED**: 조회 시점에 **새로운 Read View를 생성**하고 조회가 끝난 뒤 휘발
- **REPEATABLE READ**: 트랜잭션 시작 시점에 **새로운 Read View를 생성**하고 트랜잭션 종료 후 휘발
- **SERIALIZABLE**: 트랜잭션 시작 시 Read View 생성. 읽기 시 범위에 S-Next-Key Lock을 획득하며 트랜잭션 종료까지 유지. 쓰기 시 X-Next-Key Lock 획득

### MySQL Update Lock의 부재

MySQL은 MVCC를 활용하여, 동시성을 확보했다. 하지만 자원의 경합 상태에 이르렀을 때, 동기화를 필요로 한다. 이때 잠금을 사용하게 된다. MySQL은 Lock을 두 가지 제공해준다. S-Lock과 X-Lock이다. 이를 쿼리로 명시적으로 획득한다면 다음과 같다.

- `SELECT ... FOR UPDATE`: 트랜잭션 동안 조회 레코드에 X-Lock 획득
- `SELECT ... FOR SHARE`: 트랜잭션 동안 조회 레코드에 공유 락(S-Lock) 획득

잠금은 비즈니스 트랜잭션이 **데이터를 로드하기 전에 잠금을 획득해야 한다**. 잠근 데이터의 **최신 버전을 얻는다는 보장이 없다면, 잠금을 획득할 필요가 없다**. 즉 비관적 락이 필요하다면, `SELECT ... FOR UPDATE` X-Lock을 획득 해야만 하는 것이다. 

문제는 **조회 행에 대해 X-Lock을 획득**하게 되면, 동일한 행을 조회하는 다른 트랜잭션이 S-Lock을 얻지 못하게 되고, **READ COMMITTED의 단순 조회(read)에서도 Deadlock이 발생할 수 있다.** 설사 프로토콜을 잘 정립해서 사내 전역적으로 프로토콜에 대한 컨벤션을 잘 따른다 해도, 트래픽이 높아지면 병목지점이 될 확률이 매우 높다.

"우리는 CQRS로 해결할꺼에요. 읽을땐 NoSQL로 읽고, 쓸때마다 NoSQL로 복사해 넣어줄 겁니다. 디비지움은 충분히 빠르거든요!" CQRS는 읽기(read) 부하를 줄이는 방법일 뿐, 쓰기(write) 충돌을 해결하는 방식이 아니다. 데이터 정합성을 중요시하는 도메인의 트랜잭션 환경에서는 결과적 일관성(eventual consistency)만으로 문제를 해결할 수 없으며, 데이터 불일치 문제를 초래할 가능성이 크다. (물론 CQRS도 이제 설명하는 아이디어를 반영 했다면 아주 좋다.)

MSSQL의 U-Lock 아이디어를 적용할 때다.

PostgreSQL은 MySQL과 유사한 방식의 MVCC로 트랜잭션을 구현했다. Lock에도 S-Lock과 X-Lock만이 존재하는데, 대신 Advisory Lock을 제공한다. 이는 MSSQL의 U-Lock과는 달리, 데이터 행(row)이 아닌 애플리케이션에서 직접 관리하는 논리적 리소스를 대상으로 한다.

- **Advisory Lock**: 애플리케이션 수준에서 정의할 수 있는 사용자 지정 잠금 방식이다. Advisory Lock은 DB 내부의 기본적인 락 메커니즘과 독립적으로 동작하며, 개발자가 직접 **U-Lock과 유사한 저장 잠금(update lock) 동작을 설계할 수 있다.**

U-Lock과 Advisory Lock은 접근 방식이 다르지만, 동일한 아이디어로 문제를 해결한다. 두 방식 모두 트랜잭션에서 락을 획득하되, U-Lock과 X-Lock의 획득을 제한하면서도 S-Lock과는 공유할 수 있도록 동작하게 된다.
MySQL을 쓴다면, 이 아이디어를 이용하여 애플리케이션 레벨에서 직접 구현 필요하다. (예: Redis Distributed Lock)