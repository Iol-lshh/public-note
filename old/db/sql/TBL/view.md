# view
- orm을 사용하기 쉽게 만든다.
- 뷰란, 쿼리 결과를 테이블로 저장하는 것이 아니다.
    - 쿼리를 저장하는 기능이다.
    - 때문에, 만능 뷰는 절대 지양한다.

```sql
-- view 기본
CREATE VIEW vw_code AS
SELECT C.*
FROM tb_master_code MC
LEFT JOIN tb_code C ON C.master_code = MC.code
;

-- cte가 들어간 뷰
CREATE VIEW vw_top_popular_menu AS
WITH cte_top_popular_menu AS (
    SELECT category, MAX(review) AS max_cnt
    FROM tb_top_menu_review
    GROUP BY category
)
SELECT TA.name, TA.category, TA.max_cnt
FROM tb_top_menu TA
LEFT JOIN cte_max_review MR
    ON MR.max_num_reviews = TA.reviews
;
```
