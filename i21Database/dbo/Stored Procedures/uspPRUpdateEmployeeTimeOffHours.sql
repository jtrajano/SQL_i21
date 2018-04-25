﻿CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOffHours]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL
AS
BEGIN

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees

	--Get Employees with specified Time Off
	SELECT E.intEntityId
		,dtmLastAward = CASE WHEN (ISNULL(T.dtmEligible, E.dtmDateHired) > ISNULL(T.dtmLastAward, E.dtmDateHired)) THEN 
								ISNULL(T.dtmEligible, E.dtmDateHired)
							ELSE
								ISNULL(T.dtmLastAward, E.dtmDateHired)
						  END
		,dtmNextAward = CAST(NULL AS DATETIME)
		,dblAccruedHours = CAST(0 AS NUMERIC(18, 6))
		,dblEarnedHours = CAST(0 AS NUMERIC(18, 6))
		,dblRate
		,dblPerPeriod
		,strPeriod
		,dblRateFactor
		,strAwardPeriod
		,dtmDateHired
	INTO #tmpEmployees
	FROM tblPREmployee E LEFT JOIN tblPREmployeeTimeOff T
		ON E.intEntityId = T.intEntityEmployeeId
	WHERE E.intEntityId = ISNULL(@intEntityEmployeeId, E.intEntityId)
		 AND T.intTypeTimeOffId = @intTypeTimeOffId

	--Calculate Next Award Date
	UPDATE #tmpEmployees 
		SET dtmNextAward = CASE WHEN (strAwardPeriod = 'Start of Week') THEN
								CAST(DATEADD(WK, DATEDIFF(WK, 6, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Week') THEN
								CASE WHEN (dtmLastAward) < CAST(DATEADD(DD, 7-(DATEPART(DW, GETDATE())), GETDATE()) AS DATE) THEN
									DATEADD(DD, -7, CAST(DATEADD(DD, 7-(DATEPART(DW, GETDATE())), GETDATE()) AS DATE))
								ELSE 
									CAST(DATEADD(DD, 7-(DATEPART(DW, GETDATE())) + 7, GETDATE()) AS DATE)
								END
							 WHEN (strAwardPeriod = 'Start of Month') THEN
								CAST(DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Month') THEN
								CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE)
							 WHEN (strAwardPeriod = 'Start of Quarter') THEN
								CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Quarter') THEN
								CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)
							 WHEN (strAwardPeriod = 'Start of Year') THEN
								CASE WHEN (dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,getdate()), 0)) THEN
									DATEADD(YY, DATEDIFF(YY,0,GETDATE()), 0)
								ELSE 
									DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, 0)
								END
							 WHEN (strAwardPeriod = 'End of Year') THEN
								CASE WHEN (dtmLastAward) < (DATEADD(YY, DATEDIFF(YY,0,getdate()), -1)) THEN
									DATEADD(YY, DATEDIFF(YY,0,GETDATE()), -1)
								ELSE 
									DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, -1)
								END
							 WHEN (strAwardPeriod = 'Anniversary Date') THEN
								DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired)
							 ELSE NULL 
						END

	UPDATE #tmpEmployees 
		--Calculate Total Accrued Hours
		SET dblAccruedHours = CASE WHEN (strPeriod = 'Hour') THEN 
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
												WHERE P.ysnPosted = 1
													  AND P.intEntityEmployeeId = #tmpEmployees.intEntityId
													  AND P.dtmDateTo > #tmpEmployees.dtmLastAward AND P.dtmDateTo <= #tmpEmployees.dtmNextAward 
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
							END * dblRate * dblRateFactor
						ELSE 0
					END

	--Update Each Employee Hours
	DECLARE @intEmployeeId INT
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
	BEGIN
		SELECT TOP 1 
			@intEmployeeId = [intEntityId]
		FROM #tmpEmployees 
		
		--Reset Hours Used, Move Earned to Carryover
		UPDATE EOT
			SET dblHoursUsed = CASE WHEN (T.strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= T.dtmNextAward) THEN 0
									WHEN (T.strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND YEAR(GETDATE()) > YEAR(T.dtmLastAward)) THEN 0
									ELSE EOT.dblHoursUsed END
				,dblHoursCarryover = CASE WHEN (T.strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= T.dtmNextAward) THEN 
											CASE WHEN ((dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - YTD.dblHoursUsed) < dblMaxCarryover) 
												THEN (dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - YTD.dblHoursUsed)
												ELSE dblMaxCarryover END
										  WHEN (T.strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND YEAR(GETDATE()) > YEAR(T.dtmLastAward)) THEN
											CASE WHEN ((dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - YTD.dblHoursUsed) < dblMaxCarryover) 
											THEN (dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - YTD.dblHoursUsed)
											ELSE dblMaxCarryover END
									ELSE dblHoursCarryover END
				,dblHoursEarned = CASE WHEN (T.strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= T.dtmNextAward) THEN 0
									WHEN (T.strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND YEAR(GETDATE()) > YEAR(T.dtmLastAward)) THEN 0
									ELSE dblHoursEarned END
		FROM 
			tblPREmployeeTimeOff EOT
			INNER JOIN #tmpEmployees T
				ON EOT.intEntityEmployeeId = T.intEntityId
			LEFT JOIN vyuPREmployeeTimeOffUsedYTD YTD
				ON T.intEntityId = YTD.intEntityEmployeeId
		WHERE T.[intEntityId] = @intEmployeeId
			AND EOT.intEntityEmployeeId = @intEmployeeId
			AND EOT.intTypeTimeOffId = @intTypeTimeOffId
			AND YTD.intTypeTimeOffId = @intTypeTimeOffId
			AND YTD.intYear = YEAR(T.dtmLastAward)

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
			SET dblHoursEarned = CASE WHEN ((dblHoursEarned + T.dblEarnedHours) > dblMaxEarned) THEN
									dblMaxEarned
								 ELSE
									(dblHoursEarned + T.dblEarnedHours)
								END
				,dblHoursAccrued = CASE WHEN (T.strPeriod = 'Hour') THEN dblHoursAccrued - T.dblEarnedHours ELSE 0 END 
				,dtmLastAward = T.dtmNextAward
		FROM
		#tmpEmployees T
		WHERE T.[intEntityId] = @intEmployeeId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
				AND intTypeTimeOffId = @intTypeTimeOffId 
				AND ((T.strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= T.dtmNextAward)
					OR (T.strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND GETDATE() > T.dtmLastAward))

		DELETE FROM #tmpEmployees WHERE [intEntityId] = @intEmployeeId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees
END
GO