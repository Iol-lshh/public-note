# Nine Ways to Shoot Yourself in the Foot with PostgreSQL

- 대부분의 문제는 초기에는 드러나지 않지만, 데이터가 많아지고 쿼리가 복잡해질수록 심각한 성능 문제로 이어질 수 있습니다.

---

## 1. `work_mem` 기본값을 그대로 사용하기

- `work_mem`은 쿼리 연산이 임시 파일을 디스크에 기록하기 전 사용할 수 있는 메모리 크기를 결정하는 설정입니다. 
- 기본값을 유지하면 작은 데이터베이스에서는 문제가 없지만, 데이터가 많아지면 성능이 급격히 저하될 수 있습니다.

### 해결책

- `pgbadger`를 활용해 로그 분석
- `pganalyze` 같은 모니터링 시스템 사용
- 적절한 `work_mem` 값 계산 및 조정
- 특정 트랜잭션에서 `SET LOCAL work_mem`으로 값 조정 가능

```sql
work_mem = ($YOUR_INSTANCE_MEMORY * 0.8 - shared_buffers) / $YOUR_ACTIVE_CONNECTION_COUNT
```

---

## 2. 모든 애플리케이션 로직을 Postgres 함수와 프로시저에 넣기

- PostgreSQL의 함수 및 프로시저는 강력한 기능을 제공하지만, 무분별한 사용은 성능을 저하시킵니다. 
- 특히 중첩 함수나 재귀 호출은 예상치 못한 지연과 복제 지연(replication lag)을 유발할 수 있습니다.

### 해결책

- 간단한 함수는 괜찮지만, 가능한 한 `IMMUTABLE` 또는 `STABLE`로 선언
- 데이터 구조 조작 및 비즈니스 로직은 애플리케이션 계층에서 처리
- 데이터베이스 확장성을 고려하여 부하를 최소화

---

## 3. 트리거를 과도하게 사용하기

 - 트리거는 강력하지만 효율적이지 않습니다.
 - `generated columns` 또는 `materialized views` 같은 대안을 고려하세요.

### 해결책

- `BEFORE` 트리거와 `AFTER` 트리거를 각각 하나씩만 사용
- 트리거 함수명을 통일하고, 모든 로직을 한 함수 내에 유지
- 트리거 내부에서 개별적으로 처리하지 말고, 일괄 처리(batch processing)를 활용

---

## 4. `NOTIFY`를 과도하게 사용하기

- `NOTIFY`는 메시지 큐를 직접 관리하지 않아도 되게 해주지만, 많은 이벤트를 처리할 때는 성능 문제가 발생할 수 있습니다.

### 해결책

- `NOTIFY` 대신 이벤트를 큐 테이블에 저장하고 일정 간격으로 배치 처리
- 이벤트 소비 속도를 조절하여 데이터베이스 부하를 줄이기
- 이벤트 처리 후, 데이터를 적절히 정리하여 성능 최적화

```sql
CREATE TABLE event_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type text NOT NULL,
  data jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  occurred_at timestamptz NOT NULL,
  acquired_at timestamptz,
  failed_at timestamptz
);
```

```sql
UPDATE event_queue
SET acquired_at = now()
WHERE id IN (
  SELECT id
  FROM event_queue
  WHERE acquired_at IS NULL
  ORDER BY occurred_at
  FOR UPDATE SKIP LOCKED
  LIMIT 1000
)
RETURNING *;
```

---

## 5. `EXPLAIN ANALYZE`를 실데이터에서 실행하기

- `EXPLAIN ANALYZE`는 쿼리를 실제 실행하면서 실행 계획을 보여주기 때문에 프로덕션 환경에서는 조심해서 사용해야 합니다.

### 해결책

- 프로덕션 데이터의 샘플을 주기적으로 백업하여 별도의 샌드박스 환경에서 분석
- `EXPLAIN`을 먼저 실행하고, 필요할 때만 `ANALYZE`를 추가 실행
- 샌드박스 환경은 프로덕션보다 작은 크기로 유지하여 성능 문제를 미리 감지

---

## 6. CTE(Common Table Expressions)를 서브쿼리 대신 사용하세요

- CTE(예: `WITH` 쿼리)는 직관적이지만, 항상 성능이 더 좋은 것은 아닙니다. 
- PostgreSQL 12 이전에는 CTE가 항상 물리적으로 실행되었기 때문에 서브쿼리보다 성능이 낮은 경우가 많았습니다.

### 해결책

- `EXPLAIN`을 사용하여 CTE와 서브쿼리를 비교
- PostgreSQL 12 이상에서는 최적화가 자동으로 이루어지므로 큰 차이가 없을 수도 있음

---

## 7. 재귀 CTE를 성능이 중요한 쿼리에 사용하기

- 재귀 CTE는 우아한 해결책이지만, 데이터가 많아질수록 성능 저하가 발생합니다.

### 해결책

- 데이터 읽기 요청이 많다면, 미리 계산된 결과를 `materialized view` 또는 별도 테이블에 저장하여 조회 속도 최적화
- `SELECT` 성능을 높이는 대신, `INSERT`나 `UPDATE` 시점에 비용을 지불하는 방식으로 설계

---

## 8. 외래 키(Foreign Key)에 인덱스를 추가하지 않기

- PostgreSQL은 외래 키에 자동으로 인덱스를 생성하지 않습니다. 따라서 `JOIN` 또는 `ON DELETE` / `ON UPDATE` 성능이 저하될 수 있습니다.

### 해결책

- 외래 키가 포함된 컬럼에 명시적으로 인덱스 추가
- 삭제 및 갱신 작업 시 성능 저하를 방지하기 위해 정기적인 모니터링 수행

```sql
CREATE INDEX ON orders (customer_id);
```

---

## 9. `IS NOT DISTINCT FROM`을 인덱싱된 컬럼에 사용하기

- `IS NOT DISTINCT FROM`은 `NULL`을 비교할 때 유용하지만, 인덱스를 사용할 수 없게 만듭니다.

### 해결책

- 직접 `NULL` 비교 후 `=` 연산을 사용하는 방식으로 최적화
- 쿼리 실행 계획을 분석하여 성능이 저하되는지 확인

```sql
SELECT * FROM foo
WHERE (bar IS NULL AND baz IS NULL)
OR bar = baz;
```

---

## 결론

- 이 글에서 소개한 9가지 실수는 초기에는 문제가 되지 않지만, 데이터가 커질수록 심각한 성능 문제로 이어질 수 있습니다.
- PostgreSQL을 확장 가능한 방식으로 운영하려면, 처음부터 적절한 설정과 패턴을 선택하는 것이 중요합니다.
