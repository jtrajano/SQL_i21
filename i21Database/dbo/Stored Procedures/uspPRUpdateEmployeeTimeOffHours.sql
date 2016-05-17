CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOffHours]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL
AS
BEGIN

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees

	--Get Employees with specified Time Off
	SELECT E.intEntityEmployeeId
		  ,dtmLastAward = CASE WHEN (ISNULL(T.dtmEligible, E.dtmDateHired) > ISNULL(T.dtmLastAward, E.dtmDateHired)) THEN 
								ISNULL(T.dtmEligible, E.dtmDateHired)
							ELSE
								ISNULL(T.dtmLastAward, E.dtmDateHired)
						  END
		  ,dtmNextAward = CASE WHEN (strAwardPeriod = 'Start of Week') THEN
								CAST(DATEADD(WK, DATEDIFF(WK, 6, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Week') THEN
								CAST(DATEADD(DD, 7-(DATEPART(DW, GETDATE())), GETDATE()) AS DATE)
							 WHEN (strAwardPeriod = 'Start of Month') THEN
								CAST(DATEADD(M, DATEDIFF(M, 0, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Month') THEN
								CAST(DATEADD(S, -1, DATEADD(MM, DATEDIFF(M, 0, GETDATE()) + 1, 0)) AS DATE)
							 WHEN (strAwardPeriod = 'Start of Quarter') THEN
								CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE)
							 WHEN (strAwardPeriod = 'End of Quarter') THEN
								CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE)
							 WHEN (strAwardPeriod = 'Start of Year') THEN
								DATEADD(YY, DATEDIFF(YY,0,getdate()), 0)
							 WHEN (strAwardPeriod = 'End of Year') THEN
								DATEADD(YY, DATEDIFF(YY,0,getdate()) + 1, -1)
							 WHEN (strAwardPeriod = 'Anniversary Date') THEN
								DATEADD(YY, YEAR(GETDATE()) - YEAR(E.dtmDateHired), E.dtmDateHired)
							 ELSE NULL 
						END
		,dblAccruedHours = CAST(0 AS NUMERIC(18, 6))
		,dblEarnedHours = CAST(0 AS NUMERIC(18, 6))
		,dblRate
		,dblPerPeriod
		,strPeriod
		,dblMaxEarned
		,dblMaxCarryover
		,dblRateFactor
		,strAwardPeriod
		,ysnHasCarryover = CAST (0 AS BIT)
	INTO #tmpEmployees
	FROM tblPREmployee E LEFT JOIN tblPREmployeeTimeOff T
		ON E.intEntityEmployeeId = T.intEntityEmployeeId
	WHERE E.intEntityEmployeeId = ISNULL(@intEntityEmployeeId, E.intEntityEmployeeId)
		 AND T.intTypeTimeOffId = @intTypeTimeOffId

	--Clean-up Next Award Date
	UPDATE #tmpEmployees 
		SET dtmNextAward = CASE WHEN (dtmNextAward = dtmLastAward) THEN
								CASE WHEN (strAwardPeriod IN ('Start of Week', 'End of Week')) THEN
										DATEADD(WK, 1, dtmNextAward)
									 WHEN (strAwardPeriod IN ('Start of Month', 'End of Month')) THEN
										DATEADD(MM, 1, dtmNextAward)
									 WHEN (strAwardPeriod IN ('Start of Quarter', 'End of Quarter')) THEN
										DATEADD(QQ, 1, dtmNextAward)
									 WHEN (strAwardPeriod IN ('Start of Year', 'End of Year', 'Anniversary Date')) THEN
										DATEADD(YY, 1, dtmNextAward)
									 ELSE dtmNextAward 
								END
							ELSE
								dtmNextAward
							END
	
	--Mark periods that exceed 1 year
	UPDATE #tmpEmployees 
		SET ysnHasCarryover = CASE WHEN (DATEDIFF(YY, dtmLastAward, GETDATE()) > 1) THEN 1 ELSE 0 END

	--Calculate Total Accrued Hours
	UPDATE #tmpEmployees 
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
													  AND P.intEntityEmployeeId = #tmpEmployees.intEntityEmployeeId
													  AND P.dtmDateTo > #tmpEmployees.dtmLastAward AND P.dtmDateTo <= GETDATE() 
													  AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId), 0) * dblRate * dblRateFactor
								WHEN (strPeriod = 'Day') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(DD, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(DD, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(DD, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Week') THEN 
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(WK, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(WK, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(WK, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Month') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(MM, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(MM, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(MM, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Quarter') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(QQ, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(QQ, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(QQ, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Year') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(YY, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(YY, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(YY, dtmLastAward, GETDATE()) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								ELSE 0
							END
		--Calculate Total Earned Hours
		,dblEarnedHours = CASE WHEN (GETDATE() >= CASE WHEN (ysnHasCarryover = 1) THEN DATEADD(YY, -1, dtmNextAward) ELSE dtmNextAward END) THEN
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
													  AND P.intEntityEmployeeId = #tmpEmployees.intEntityEmployeeId
													  AND P.dtmDateTo > #tmpEmployees.dtmLastAward AND P.dtmDateTo <= #tmpEmployees.dtmNextAward 
													  AND EE.intEmployeeAccrueTimeOffId = @intTypeTimeOffId), 0) * dblRate * dblRateFactor
								WHEN (strPeriod = 'Day') THEN 
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(DD, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(DD, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(DD, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Week') THEN 
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(WK, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(WK, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(WK, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Month') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(MM, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(MM, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(MM, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Quarter') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(QQ, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(QQ, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(QQ, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								WHEN (strPeriod = 'Year') THEN
									CASE WHEN (ysnHasCarryover = 1) THEN
										CASE WHEN (((DATEDIFF(YY, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor) < dblMaxCarryover) THEN
												((DATEDIFF(YY, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor)
											ELSE
												dblMaxCarryover
											END
									ELSE
										(DATEDIFF(YY, dtmLastAward, dtmNextAward) / ISNULL(NULLIF(dblPerPeriod, 0), 1)) * dblRate * dblRateFactor
									END
								ELSE 0
							END
						ELSE 0
						END
		

	--Update Each Employee Hours
	DECLARE @intEmployeeId INT
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
	BEGIN
		SELECT TOP 1 
			@intEmployeeId = intEntityEmployeeId
		FROM #tmpEmployees 
		
		--Update Accrued Hours
		UPDATE tblPREmployeeTimeOff
			SET dblHoursAccrued = CASE WHEN ((T.dblMaxEarned > 0) AND (T.dblAccruedHours > T.dblMaxEarned)) THEN
									T.dblMaxEarned 
								  ELSE
									T.dblAccruedHours
								  END
		FROM
		#tmpEmployees T
		WHERE T.intEntityEmployeeId = @intEmployeeId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
				AND intTypeTimeOffId = @intTypeTimeOffId

		--Update Earned Hours
		UPDATE tblPREmployeeTimeOff
			SET dblHoursEarned = CASE WHEN ((T.dblMaxEarned > 0) AND (dblHoursEarned + T.dblEarnedHours) > T.dblMaxEarned) THEN
									T.dblMaxEarned
								 ELSE
									(dblHoursEarned + T.dblEarnedHours)
								END
				,dblHoursAccrued = dblHoursAccrued - T.dblEarnedHours
				,dtmLastAward = CASE WHEN (T.ysnHasCarryover = 1) THEN DATEADD(YY, -1, T.dtmNextAward) ELSE T.dtmNextAward END
		FROM
		#tmpEmployees T
		WHERE T.intEntityEmployeeId = @intEmployeeId
				AND tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
				AND intTypeTimeOffId = @intTypeTimeOffId 
				AND CASE WHEN (T.ysnHasCarryover = 1) THEN DATEADD(YY, -1, T.dtmNextAward) ELSE T.dtmNextAward END <= CAST(GETDATE() AS DATE)

		DELETE FROM #tmpEmployees WHERE intEntityEmployeeId = @intEmployeeId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployees')) DROP TABLE #tmpEmployees
END
GO