# Common Table Expression
- inline view
- 쿼리문에서 존재하는 쿼리 결과의 집합 (임시 메모리 테이블)
    - 해당 쿼리문이 끝나면 버려진다
- 재귀가 가능하다

```sql
--
; 
WITH todo_changeVal_r1 AS (
    SELECT ho.startDate, ho.UserID
    FROM Hand_Over ho WITH(NOLOCK)
    INNER JOIN #todo_change tc 
        ON tc.Idx = ho.Idx 
        AND tc.r = 1 -- 변경할 값
)
UPDATE ho2
SET ho2.EndDate = r1.StartDate
FROM Hand_Over ho2
INNER JOIN #todo_change cr2 
    ON cr2.Idx = ho2.Idx 
    and cr2.r = 2-- r 2(변경 대상)
LEFT JOIN todo_changeVal_r1 r1 
    ON r1.UserID = cr2.UserID
;
```

## 장점
- 보기 편하다.
    - 서브 쿼리의 지옥보다는.. 
    - 생각의 흐름에 따라 순차적으로 쿼리를 읽을 수 있기 때문이다.

## 단점
- 간혹 옵티마이저가 바보짓을 할 때가 있다.
    - 주의하자.
    1. cte를 반복 사용
        - 반복 사용할때마다, 다시 조회하는 경우가 있다.


