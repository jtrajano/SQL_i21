﻿CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOffHours]
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
		,dblBalance = (T.dblHoursCarryover + T.dblHoursEarned) - T.dblHoursUsed - ISNULL(TOYTD.dblHoursUsedYTD,0)
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
		,ysnForReset = CAST(0 AS BIT)
	INTO #tmpEmployees
	FROM tblPREmployee E 
		LEFT JOIN tblPREmployeeTimeOff T
			ON E.intEntityId = T.intEntityEmployeeId
		LEFT JOIN (SELECT TOP 1 intPaycheckId, intEntityEmployeeId, ysnPosted, ysnVoid, dtmDateFrom, dtmDateTo 
					FROM tblPRPaycheck WHERE intPaycheckId = @intPaycheckId) P
			ON E.intEntityId = P.intEntityEmployeeId
	LEFT JOIN(
	SELECT intEntityEmployeeId
		,intTypeTimeOffId
		,intYear
		,dblHoursUsedYTD = dblHoursUsed 
	FROM vyuPREmployeeTimeOffUsedYTD
	) TOYTD ON T.intEntityEmployeeId = TOYTD.intEntityEmployeeId AND T.intTypeTimeOffId = TOYTD.intTypeTimeOffId
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
							CASE WHEN dtmLastAward IS NOT NULL THEN 
								CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)
							ELSE 
								CAST(DATEADD(Q, 1, CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'Start of Year') THEN
							CASE WHEN (dtmLastAward) < (DATEADD(YY, DATEDIFF(YY, 0, GETDATE()), 0)) THEN
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), 0) AS DATE)
							ELSE 
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, 0) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'End of Year') THEN
							CASE WHEN (dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1)) THEN
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1) AS DATE)
							ELSE 
								CAST(DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, -1) AS DATE)
							END
						WHEN (#tmpEmployees.strAwardPeriod = 'Anniversary Date') THEN
							CASE WHEN (dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,getdate()), 0)) THEN
								CAST(DATEADD(YY, YEAR(GETDATE()) - YEAR(#tmpEmployees.dtmDateHired), #tmpEmployees.dtmDateHired) AS DATE)
							ELSE 
								CAST(DATEADD(YY, YEAR(GETDATE()) - YEAR(#tmpEmployees.dtmDateHired) + 1, #tmpEmployees.dtmDateHired) AS DATE)
							END							
						WHEN (#tmpEmployees.strAwardPeriod = 'Paycheck') THEN #tmpEmployees.dtmDateHired
						ELSE NULL 
					END

	--Calculate if Time Off is Scheduled for Reset
	UPDATE #tmpEmployees
	SET ysnForReset = CASE WHEN ((strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= dtmNextAward AND YEAR(dtmLastAward) < YEAR (dtmNextAward)  )
									OR 
								  (strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND YEAR(GETDATE()) > YEAR(dtmLastAward))
								) THEN 1 
							ELSE 0 END

	UPDATE #tmpEmployees 
		--Calculate Total Accrued Hours
		SET dblAccruedHours = CASE WHEN (strPeriod = 'Hour' AND strAwardPeriod <> 'Paycheck') THEN 
									ISNULL((SELECT SUM((PE.dblHours / ISNULL(NULLIF(dblPerPeriod, 0), 1)))
											FROM tblPRPaycheck P 
												LEFT JOIN tblPRPaycheckEarning PE 
													ON P.intPaycheckId = PE.intPaycheckId
												INNER JOIN tblPREmployeeEarning EE 
													ON PE.intEmployeeEarningId = EE.intEmployeeEarningId
												INNER JOIN tblPREmployeeTimeOff ET 
													ON EE.intEmployeeAccrueTimeOffId = ET.intTypeTimeOffId 
														AND ET.intEntityEmployeeId = P.intEntityEmployeeId 
												WHERE P.ysnPosted = 1
													  AND P.intEntityEmployeeId = #tmpEmployees.intEntityId
													  AND P.dtmDateTo > #tmpEmployees.dtmLastAward AND P.dtmDateTo <= GETDATE() 
													  AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId), 0)
								ELSE 0
							END * dblRate * dblRateFactor
		--Calculate Total Earned Hours
		,dblEarnedHours = CASE WHEN (GETDATE() >= dtmNextAward) THEN
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
												WHERE 
														(	
														--(#tmpEmployees.intPaycheckId IS NOT NULL AND P.intPaycheckId = #tmpEmployees.intPaycheckId)
														--OR 
														(
														--#tmpEmployees.intPaycheckId IS NULL AND 
														P.ysnPosted = 1 AND P.dtmDateTo > #tmpEmployees.dtmLastAward AND P.dtmDateTo <= #tmpEmployees.dtmNextAward)
														)
														
														AND P.intEntityEmployeeId = #tmpEmployees.intEntityId
														AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId
													  ), 0)


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
							END * dblRate * dblRateFactor ---* CASE WHEN (ysnPaycheckPosted = 0) THEN -1 ELSE 1 END -->>> earned hours get negative when paycheck unposted
						ELSE 0
					END

	--Update Each Employee Hours
	DECLARE @intEmployeeId INT
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
	BEGIN
		SELECT TOP 1 
			@intEmployeeId = [intEntityId]
		FROM #tmpEmployees 

		--Update Accrued Hours
		UPDATE tblPREmployeeTimeOff
			SET dblHoursAccrued = CASE WHEN (T.strPeriod = 'Hour') THEN T.dblAccruedHours ELSE 0 END
		FROM
		#tmpEmployees T
		WHERE T.[intEntityId] = @intEmployeeId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
				AND intTypeTimeOffId = @intTypeTimeOffId

		--Update Earned Hours
		UPDATE tblPREmployeeTimeOff
			SET dblHoursEarned = CASE WHEN ((dblHoursEarned + T.dblEarnedHours) > dblMaxEarned) AND ysnPaycheckPosted = 1 
								THEN 
										CASE WHEN (dblMaxBalance IS NOT NULL AND dblBalance + T.dblEarnedHours > dblMaxBalance) THEN
												dblHoursEarned + ISNULL(NULLIF(ABS(T.dblEarnedHours - (dblBalance - dblMaxBalance)), -(T.dblEarnedHours - (dblBalance - dblMaxBalance)) ),0)
											ELSE
											dblMaxEarned
										END
							    ELSE 
										CASE WHEN (dblMaxBalance IS NOT NULL AND dblBalance + T.dblEarnedHours > dblMaxBalance) THEN
												dblHoursEarned + ISNULL(NULLIF(ABS(T.dblEarnedHours - (dblBalance - dblMaxBalance)), -(T.dblEarnedHours - (dblBalance - dblMaxBalance)) ),0)
											ELSE
											T.dblEarnedTotalHours + T.dblEarnedHours
										END
								END
								
				,dblHoursAccrued = CASE WHEN (T.strPeriod = 'Hour' AND T.strAwardPeriod <> 'Paycheck') THEN dblHoursAccrued - T.dblEarnedHours ELSE 0 END 
				,dtmLastAward = CASE WHEN (T.strAwardPeriod = 'Paycheck' AND ysnPaycheckPosted = 0) THEN
									DATEADD(DD, -1, dtmPaycheckStartDate) 
								ELSE 
										CASE WHEN (T.strAwardPeriod IN( 'Anniversary Date', 'End of Year')) THEN
												CASE WHEN ysnForReset =1 THEN 
													T.dtmNextAward
												ELSE
													tblPREmployeeTimeOff.dtmLastAward
												END
										ELSE
												T.dtmNextAward
										END

										
								END
		FROM
		#tmpEmployees T
		WHERE T.[intEntityId] = @intEmployeeId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
				AND intTypeTimeOffId = @intTypeTimeOffId 
				--AND ((T.strAwardPeriod IN ('Anniversary Date', 'End of Year', 'Start of Year') AND GETDATE() >= T.dtmNextAward)
				--	OR (T.strAwardPeriod IN ('Paycheck') AND T.dtmNextAward >= T.dtmLastAward)
				--	OR (T.strAwardPeriod NOT IN ('Anniversary Date', 'End of Year', 'Start of Year', 'Paycheck') AND GETDATE() > T.dtmLastAward))

		DELETE FROM #tmpEmployees WHERE [intEntityId] = @intEmployeeId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees
END