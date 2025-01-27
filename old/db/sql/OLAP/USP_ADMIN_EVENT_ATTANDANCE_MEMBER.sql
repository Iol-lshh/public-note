USE [Gamification]
GO

/****** Object:  StoredProcedure [dbo].[USP_ADMIN_EVENT_ATTANDANCE_MEMBER]    Script Date: 2023-11-24 오전 9:20:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==========================================================================================
-- 작 성 자 : 홍성혁
-- 작 성 일 : 2023-06-28
-- 기능정의 : 게이미피케이션 출석 계산
-- 수정이력 : 
		2023-06-28	/	홍성혁	/	최초작성
		2023-10-18	/	홍성혁	/	with 이슈로 연속성 확인, 연속성 집계 분리(#111796)
-- 실행예제 :
		DECLARE @out_TotalCount INT = 0
		EXEC [dbo].[USP_ADMIN_EVENT_ATTANDANCE_MEMBER] '1', '1', '100', @out_TotalCount OUTPUT
==========================================================================================*/
CREATE PROC [dbo].[USP_ADMIN_EVENT_ATTANDANCE_MEMBER]
	@in_EventCode INT
	, @in_PageNo INT = '1'
	, @in_PageSize INT = '20'
	, @out_TotalCount INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @strStartDate VARCHAR(10) = ''						-- 이벤트 시작일
		, @strEndDate VARCHAR(10) = ''						-- 이벤트 종료일
		, @intTimeSize INT = '5'							-- 회차 사이 즈
		, @strValidAttandance VARCHAR(13) = '2,3,4,5,6'					-- 유효 요일 (1: 일, 2: 월, ~ 7: 토)

	SELECT TOP 1
		@strStartDate = CONVERT(VARCHAR(10), StartDate, 121)
		, @strEndDate = CONVERT(VARCHAR(10), EndDate, 121)
		--, @intTimeSize		-- 회차 사이즈: 차후 이벤트에 따라 유동적 사이즈 조절 가능하도록 
		--, @strValidAttandance	-- 유효 요일: 차후 이벤트에 따라 유동적 사이즈 조절 가능하도록 
	FROM TBL_APP_ATTENDANCE_EVENT
	WHERE EventCode = @in_EventCode

	-- 해당 일자
	SELECT
		ROW_NUMBER() OVER (ORDER BY number) AS RowNum	-- 연속성, 이벤트 경과 날짜
		, DATEADD(DAY, number, @strStartDate) AS TargetDate
	INTO #TargetDates
	FROM master..spt_values
	WHERE type = 'P'
	AND number BETWEEN 0 AND DATEDIFF(DAY, @strStartDate, @strEndDate)
	AND DATEPART(WEEKDAY, DATEADD(DAY, number, @strStartDate)) IN (SELECT CAST(ListValue AS INT) FROM fnSplitString(@strValidAttandance, ','))

	-- 총 참가 일자
	;WITH TotalDates AS(
		SELECT
			AAEL.UserId
			, AAEL.Eventcode
			, AAEL.EventDate
			, ROW_NUMBER() OVER (PARTITION BY AAEL.UserId ORDER BY D.RowNum) AS TotalAttendance	-- 총 참가
			, D.RowNum AS Continuity -- 연속성, 이벤트 경과 날짜
			, AAEL.RegDate
		FROM TBL_APP_ATTENDANCE_EVENT_LOG AAEL
		INNER JOIN #TargetDates D ON AAEL.EventDate = D.TargetDate
		WHERE AAEL.Eventcode = @in_EventCode
	)
	-- 연속성 확인
	, IsContinuityDates AS(
		SELECT
			TD.UserId
			, TD.Eventcode
			, TD.EventDate
			, TD.TotalAttendance
			, IIF(LAG(TD.Continuity) OVER(PARTITION BY TD.UserId, TD.Eventcode ORDER BY TD.EventDate) = TD.Continuity - 1, 1, 0) as isContinuity
			, TD.RegDate
		FROM TotalDates TD
	)
	-- 연속성 집계
	, ContinuityDates AS(
		SELECT
			SUM(IIF(isContinuity = 1, 0, 1))
				OVER (PARTITION BY UserId, Eventcode ORDER BY EventDate) AS isContinuityTimes -- 연속성 회차
			, TotalAttendance	-- 총 참가
			, UserId
			, Eventcode
			, EventDate
			, RegDate
		FROM IsContinuityDates
	)
	-- 조회
	SELECT
		ROW_NUMBER() OVER(ORDER BY CR.USERID DESC, CR.EventDate DESC) AS ROWNUM
		, ROW_NUMBER() OVER(ORDER BY CR.USERID, CR.EventDate ) AS NUM
		--, CR.[DAY]
		, CASE WHEN LEN(U.NickName) >= 3 THEN LEFT(U.NickName, 1) + REPLICATE('*', LEN(U.NickName) - 2) + RIGHT(U.NickName, 1)
			WHEN LEN(U.NickName) = 2 THEN LEFT(U.NickName, 1) + '*'
			ELSE '*' END AS NickName
		, U.SchoolClass
		, U.Grade
		-- 아바타
		, AN.NickName AS AvatarName
		, CR.UserId
		, CR.EventDate  
		-- 회차에 맞는 연속 출석수
		, IIF(SUM(1) OVER(PARTITION BY CR.UserId, CR.Eventcode, CR.isContinuityTimes ORDER BY CR.EventDate) % @intTimeSize = 0
			, @intTimeSize
			, SUM(1) OVER(PARTITION BY CR.UserId, CR.Eventcode, CR.isContinuityTimes ORDER BY CR.EventDate)% @intTimeSize) AS ROWDAY 
		-- 총 참석
		, CR.TotalAttendance AS EVENTCNT
		, CONVERT(VARCHAR(21), CR.RegDate,121) AS RewardDate
	INTO #TMP
	FROM ContinuityDates CR
	LEFT JOIN TBL_USER U ON U.UserID = CR.UserId
	OUTER APPLY (
		SELECT TOP 1
			NickName
		FROM TBL_User_AvatarNickName_History
		WHERE useridx = U.Idx
		ORDER BY Idx DESC
	) AN

	SET @out_TotalCount = @@ROWCOUNT

	SELECT *
		, ROW_NUMBER() OVER(ORDER BY RewardDate DESC) RowNumber
	FROM #TMP
	ORDER BY RewardDate DESC
	OFFSET (@in_PageNo-1) * @in_PageSize ROWS
	FETCH NEXT @in_PageSize ROWS ONLY


	SELECT
		@strStartDate AS EventStartDate
		, @strEndDate AS EventEndDate
		, (SELECT MAX(RowNum) 
			FROM #TargetDates) AS Total
		, (SELECT COUNT(1) 
			FROM #TargetDates 
			WHERE TargetDate <  CONVERT(VARCHAR(10), GETDATE(), 121)) AS Past
		, (SELECT COUNT(1) 
			FROM #TargetDates 
			WHERE TargetDate >=  CONVERT(VARCHAR(10), GETDATE(), 121)) AS Remain
		, EventName
	FROM TBL_APP_ATTENDANCE_EVENT
	WHERE EventCode = @in_EventCode

	DROP TABLE #TMP
	DROP TABLE #TargetDates
END
GO

