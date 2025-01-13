/*
대상자를 임시테이블과
CTE 문법을 이용하여,
커서 없이 집합적으로 값을 보정

SELECT * FROM [_Temp].DBO.[TBL_인수인계]
select ho.*
from Hand_Over ho with(nolock)
inner join [_Temp].DBO.[TBL_인수인계] ho with(nolock) on ho.UserID = ho.UserID
where ho.userid = '<아이디>'
*/
--로직 시작
BEGIN TRAN
	SELECT
		ROW_NUMBER() OVER( PARTITION BY ho.UserID ORDER BY ho.Idx DESC) r
		, ho.Idx
		, ho.UserID
	INTO #todo_change
	FROM Hand_Over ho WITH(NOLOCK)
	INNER JOIN [_Temp].DBO.[TBL_인수인계] tmp WITH(NOLOCK) ON tmp.UserID = ho.UserID
	ORDER BY tmp.userid
	
	--1. FinalFlag를 전부 null
	UPDATE ho
	SET FinalFlag = NULL
	FROM Hand_Over ho
	INNER JOIN [_Temp].DBO.[TBL_인수인계] tmp WITH(NOLOCK) ON tmp.UserID = ho.UserID
	
	--2. last index에 FinalFlag 'Y'
	UPDATE ho
	SET FinalFlag = 'Y'
	FROM Hand_Over ho
	INNER JOIN #todo_change tc ON tc.Idx = ho.Idx
	WHERE tc.r = 1
	
	--3. r 1의 startdate 를, r 2의 EndDate에 넣는다
	; WITH todo_changeVal_r1 AS(
		SELECT ho.startDate, ho.UserID
		FROM Hand_Over ho WITH(NOLOCK)
		INNER JOIN #todo_change tc ON tc.Idx = ho.Idx AND tc.r = 1 -- 변경할 값
	)
	UPDATE ho2
	SET ho2.EndDate = r1.StartDate
	FROM Hand_Over ho2
	INNER JOIN #todo_change cr2 ON cr2.Idx = ho2.Idx and cr2.r = 2-- r 2(변경 대상)
	LEFT JOIN todo_changeVal_r1 r1 ON r1.UserID = cr2.UserID
	
	--4. r 2의 startdate 를, r 3의 EndDate에 넣는다
	; WITH todo_changeVal_r2 AS(
		SELECT ho.startDate, ho.UserID
		FROM Hand_Over ho WITH(NOLOCK)
		INNER JOIN #todo_change tc ON tc.Idx = ho.Idx AND tc.r = 2 -- 변경할 값
	)
	UPDATE ho3
	SET ho3.EndDate = r2.StartDate
	FROM Hand_Over ho3
	INNER JOIN #todo_change cr3 ON cr3.Idx = ho3.Idx AND cr3.r = 3-- r 2(변경 대상)
	LEFT JOIN todo_changeVal_r2 r2 ON r2.UserID = cr3.UserID
	
	--단건 확인
	SELECT ho.*
	FROM Hand_Over ho WITH(NOLOCK)
	INNER JOIN [_Temp].DBO.[TBL_인수인계] tmp WITH(NOLOCK) ON tmp.UserID = ho.UserID
	WHERE tmp.userid = '???'
	
	--복수 확인
	SELECT ho.*
	FROM Hand_Over ho WITH(NOLOCK)
	INNER JOIN [_Temp].DBO.[TBL_인수인계] tmp WITH(NOLOCK) ON tmp.UserID = ho.UserID
	ORDER BY tmp.UserID
ROLLBACK
--COMMIT
