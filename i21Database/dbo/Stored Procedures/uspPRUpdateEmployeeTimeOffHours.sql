CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOffHours]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL,
	@intPaycheckId INT = NULL
AS
BEGIN
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees

--Get Employees with specified Time Off
SELECT E.intEntityId
	,dtmLastAward = CASE WHEN (strAwardPeriod = 'Paycheck' AND intPaycheckId IS NOT NULL) THEN
						DATEADD(DD, -1, dtmDateFrom) 
					WHEN (ISNULL(T.dtmEligible, E.dtmDateHired) > ISNULL(T.dtmLastAward, E.dtmDateHired)) THEN 
						ISNULL(T.dtmEligible, E.dtmDateHired)
					ELSE
						ISNULL(T.dtmLastAward, E.dtmDateHired)
					END
	,dtmNextAward = CAST(NULL AS DATETIME)
	,dblAccruedHours = CAST(0 AS NUMERIC(18, 6))
	,dblEarnedHours = CAST(0 AS NUMERIC(18, 6))
	,dblEarnedTotalHours = T.dblHoursEarned
	,dblRate
	,dblPerPeriod
	,strPeriod
	,dblRateFactor
	,strAwardPeriod
	,dtmDateHired
	,intPaycheckId
	,ysnPaycheckPosted = CASE WHEN (ysnVoid = 1) THEN 0 ELSE ysnPosted END
	,dtmPaycheckStartDate = dtmDateFrom
	,dtmPaycheckEndDate = dtmDateTo
	,dtmLastAwardTemp = CASE WHEN (strAwardPeriod = 'Paycheck' AND intPaycheckId IS NOT NULL) 
							THEN DATEADD(DD, -1, dtmDateFrom)
						WHEN strAwardPeriod = 'Start of Week' 
							THEN CAST(DATEADD(DD,0 - (DATEPART(DW, GETDATE()) - 2) ,GETDATE()) AS DATE)
						WHEN strAwardPeriod = 'End of Week' THEN
							CASE WHEN DATEDIFF(D, DATEADD(DAY, 8 - DATEPART(DW, GETDATE()), GETDATE()),GETDATE()) < 0
								THEN CAST(DATEADD(WK, -1, DATEADD(DAY, 8- DATEPART(DW, GETDATE()), GETDATE())) AS DATE)
							ELSE CAST(DATEADD(DAY, 8 - DATEPART(DW, GETDATE()), GETDATE()) AS DATE)
							END
						WHEN strAwardPeriod = 'Start of Month' 
							THEN CAST(DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0) AS DATE)
						WHEN strAwardPeriod = 'End of Month' THEN
							CASE WHEN DATEDIFF(D, CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE),GETDATE()) >= 0
								THEN CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE)
							ELSE CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()), 0)) AS DATE)
							END
						WHEN strAwardPeriod = 'Start of Quarter' 
							THEN CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE)
						WHEN strAwardPeriod = 'End of Quarter' THEN
							CASE WHEN DATEDIFF(D, CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE),GETDATE()) >= 0
								THEN CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)
							ELSE CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0)) AS DATE)
							END
						WHEN strAwardPeriod = 'Start of Year' 
							THEN CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), 0) AS DATE)
						WHEN strAwardPeriod = 'End of Year' 
							THEN CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1) AS DATE)
						WHEN strAwardPeriod = 'Anniversary Date' 
							THEN CAST(DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired),dtmDateHired) AS DATE)
						ELSE dtmLastAward
						END
INTO #tmpEmployees
FROM tblPREmployee E 
LEFT JOIN tblPREmployeeTimeOff T
	ON E.intEntityId = T.intEntityEmployeeId
LEFT JOIN (SELECT TOP 1 intPaycheckId
				,intEntityEmployeeId
				,ysnPosted
				,ysnVoid
				,dtmDateFrom
				,dtmDateTo 
			FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId) P
	ON E.intEntityId = P.intEntityEmployeeId
WHERE E.intEntityId = ISNULL(@intEntityEmployeeId, E.intEntityId)
	AND T.intTypeTimeOffId = @intTypeTimeOffId

--Calculate Next Award Date
UPDATE #tmpEmployees 
	SET dtmNextAward = CASE WHEN (#tmpEmployees.strAwardPeriod = 'Start of Week') THEN 
							CASE WHEN DATEDIFF(D, DATEADD(DD,0 - (DATEPART(DW, GETDATE()) - 2) ,GETDATE()),GETDATE()) >= 1
								THEN CAST(DATEADD(WK, 1, DATEADD(DD,0 - (DATEPART(DW, GETDATE()) - 2) , GETDATE())) AS DATE)
							ELSE CAST(DATEADD(DD,0 - (DATEPART(DW, GETDATE()) - 2) ,GETDATE()) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'End of Week') THEN
							CAST(DATEADD(DD,6 - (DATEPART(DW, GETDATE()) - 2) ,GETDATE()) AS DATE)
						WHEN (#tmpEmployees.strAwardPeriod = 'Start of Month') THEN
							CASE WHEN DATEDIFF(D, GETDATE(), #tmpEmployees.dtmLastAwardTemp) >= 0 THEN 
								CAST(DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0) AS DATE)
							ELSE 
								CAST(DATEADD(M, 1, CAST(DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0) AS DATE)) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'End of Month') THEN
							CASE WHEN DATEDIFF(D, CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, #tmpEmployees.dtmPaycheckEndDate) + 1, 0)) AS DATE), GETDATE()) >= 0 
									THEN CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, '2019-03-25 00:00:00.000') + 1, 0)) AS DATE)
								ELSE CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'Start of Quarter') THEN
							CASE WHEN DATEDIFF(D, GETDATE(), CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE)) >= 0
								THEN CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE)
							ELSE CAST(DATEADD(Q, 1,CAST(DATEADD(Q, DATEDIFF(Q, 17, GETDATE()), 0) AS DATE)) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'End of Quarter') THEN
							CASE WHEN ETO.dtmLastAward IS NOT NULL THEN 
								CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)
							ELSE 
								CAST(DATEADD(Q, 1, CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'Start of Year') THEN
							CASE WHEN (ETO.dtmLastAward) < (DATEADD(YY, DATEDIFF(YY, 0, GETDATE()), 0)) THEN
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), 0) AS DATE)
							ELSE 
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, 0) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'End of Year') THEN
							CASE WHEN (ETO.dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1)) THEN
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1) AS DATE)
							ELSE 
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, -1) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'Anniversary Date') THEN
							CASE WHEN (ETO.dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,getdate()), 0)) THEN
								CAST(DATEADD(YY, YEAR(GETDATE()) - YEAR(#tmpEmployees.dtmDateHired), #tmpEmployees.dtmDateHired) AS DATE)
							ELSE 
								CAST(DATEADD(YY, YEAR(GETDATE()) - YEAR(#tmpEmployees.dtmDateHired) + 1, #tmpEmployees.dtmDateHired) AS DATE)
							END							
						WHEN (#tmpEmployees.strAwardPeriod = 'Paycheck') THEN #tmpEmployees.dtmDateHired
						ELSE NULL 
					END
FROM tblPREmployeeTimeOff ETO
	WHERE intEntityEmployeeId = @intEntityEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId

UPDATE #tmpEmployees 
	--Calculate Total Accrued Hours
	SET dblAccruedHours = CASE WHEN (strPeriod = 'Hour' AND strAwardPeriod NOT IN ('Paycheck')) THEN 
								ISNULL((SELECT SUM((PE.dblHours / ISNULL(NULLIF(dblPerPeriod, 0), 1)))
										FROM tblPRPaycheck P 
										LEFT JOIN tblPRPaycheckEarning PE 
											ON P.intPaycheckId = PE.intPaycheckId
										INNER JOIN tblPREmployeeEarning EE 
											ON PE.intEmployeeEarningId = EE.intEmployeeEarningId
										INNER JOIN tblPREmployeeTimeOff ET 
											ON EE.intEmployeeAccrueTimeOffId = ET.intTypeTimeOffId 
												AND ET.intEntityEmployeeId = P.intEntityEmployeeId 
										WHERE #tmpEmployees.intPaycheckId IS NOT NULL 
											AND P.intPaycheckId = #tmpEmployees.intPaycheckId
											AND P.intEntityEmployeeId = #tmpEmployees.intEntityId
											AND P.dtmDateTo <= GETDATE()
											AND P.dtmDateTo > #tmpEmployees.dtmLastAwardTemp
											AND GETDATE() < #tmpEmployees.dtmNextAward 
											AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId), 0)
							ELSE 0
						END * dblRate * dblRateFactor * CASE WHEN (ysnPaycheckPosted = 0) THEN -1 ELSE 1 END

	--Calculate Total Earned Hours
	,dblEarnedHours = CASE WHEN (GETDATE() >= dtmNextAward OR #tmpEmployees.dtmPaycheckEndDate <= #tmpEmployees.dtmLastAwardTemp) THEN
							CASE WHEN (strPeriod = 'Hour') THEN 
								ISNULL((SELECT SUM((PE.dblHours / ISNULL(NULLIF(dblPerPeriod, 0), 1)))
										FROM tblPRPaycheck P 
										LEFT JOIN tblPRPaycheckEarning PE 
											ON P.intPaycheckId = PE.intPaycheckId
										INNER JOIN tblPREmployeeEarning EE 
											ON PE.intEmployeeEarningId = EE.intEmployeeEarningId
										INNER JOIN tblPREmployeeTimeOff ET 
											ON EE.intEmployeeAccrueTimeOffId = ET.intTypeTimeOffId 
												AND ET.intEntityEmployeeId = P.intEntityEmployeeId 
										WHERE #tmpEmployees.intPaycheckId IS NOT NULL 
											AND P.intPaycheckId = #tmpEmployees.intPaycheckId
											AND P.intEntityEmployeeId = #tmpEmployees.intEntityId
											AND P.dtmDateTo <= GETDATE()
											AND (GETDATE() >= #tmpEmployees.dtmNextAward OR P.dtmDateTo <= #tmpEmployees.dtmLastAwardTemp) 
											AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId), 0)
							WHEN (strPeriod = 'Day') THEN 
								DATEDIFF(DD, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)
							WHEN (strPeriod = 'Week') THEN 
								DATEDIFF(WK, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)
							WHEN (strPeriod = 'Month') THEN
								DATEDIFF(MM, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)
							WHEN (strPeriod = 'Quarter') THEN
								DATEDIFF(QQ, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)
							WHEN (strPeriod = 'Year') THEN
								CASE WHEN (DATEDIFF(YY, dtmLastAward, dtmNextAward) <= 0) THEN 1 ELSE (DATEDIFF(YY, dtmLastAward, dtmNextAward)) END
									/ ISNULL(NULLIF(dblPerPeriod, 0), 1)
							ELSE 0
						END * dblRate * dblRateFactor * CASE WHEN (ysnPaycheckPosted = 0) THEN -1 ELSE 1 END
						ELSE 0 
						END

--Update Each Employee Hours
DECLARE @intEmployeeId INT

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
BEGIN
	SELECT TOP 1 
		@intEmployeeId = [intEntityId]
	FROM #tmpEmployees 

	SELECT dblHoursEarned
		,dblHoursAccrued
	FROM tblPREmployeeTimeOff
	WHERE intEntityEmployeeId = @intEntityEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId

	--Update Accrued Hours
	UPDATE tblPREmployeeTimeOff
		SET dblHoursAccrued = CASE WHEN (T.strPeriod = 'Hour') THEN ISNULL(dblHoursAccrued,0) + T.dblAccruedHours ELSE 0 END
	FROM #tmpEmployees T
	WHERE T.[intEntityId] = @intEmployeeId
		AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId
		AND GETDATE() < T.dtmNextAward

	SELECT dblHoursEarned
		,dblHoursAccrued
	FROM tblPREmployeeTimeOff
	WHERE intEntityEmployeeId = @intEntityEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId

	--Update Earned Hours
	UPDATE tblPREmployeeTimeOff
		SET dblHoursEarned = CASE WHEN ((dblHoursEarned + T.dblEarnedHours) > dblMaxEarned) AND ysnPaycheckPosted = 1 THEN dblMaxEarned
								ELSE T.dblEarnedTotalHours + T.dblEarnedHours
							 END
	FROM #tmpEmployees T
	WHERE T.[intEntityId] = @intEmployeeId
		AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId

	--Update Last Award Date
	UPDATE tblPREmployeeTimeOff
		SET dtmLastAward = CASE WHEN (T.strAwardPeriod = 'Paycheck' AND ysnPaycheckPosted = 0) THEN
							  DATEADD(DD, -1, dtmPaycheckStartDate)
						   ELSE T.dtmLastAwardTemp
						   END
	FROM #tmpEmployees T
	WHERE T.[intEntityId] = @intEmployeeId
		AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
		AND intTypeTimeOffId = @intTypeTimeOffId

	DELETE FROM #tmpEmployees WHERE [intEntityId] = @intEmployeeId
END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees
END