CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOff]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL
AS
BEGIN

	--Get Employees with specified Time Off
	SELECT E.intEntityId
		,intYearsOfService = DATEDIFF(YEAR, ISNULL(E.dtmDateHired, GETDATE()), GETDATE())
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
		,ysnForReset = CAST(0 AS BIT)
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
	
	--Calculate if Time Off is Scheduled for Reset
	UPDATE #tmpEmployees
	SET ysnForReset = CASE WHEN (
								 (strAwardPeriod IN ('Anniversary Date', 'End of Year') AND GETDATE() >= dtmNextAward AND YEAR(dtmLastAward) < YEAR(dtmNextAward)  )
								OR (strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND YEAR(GETDATE()) > YEAR(dtmLastAward))
								) THEN 1 
							ELSE 0 END

	DECLARE @intEmployeeId INT
	DECLARE @intYearsOfService INT

	--Step 1: Update each Employee Time Off
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
	BEGIN
		SELECT TOP 1 
			@intEmployeeId = [intEntityId]
			,@intYearsOfService = intYearsOfService 
		FROM #tmpEmployees 

		--Update each Employee Time Off Rate
		UPDATE tblPREmployeeTimeOff
		SET dblRate = T.dblRate
			,dblPerPeriod = T.dblPerPeriod
			,strPeriod = T.strPeriod
			,strAwardPeriod = T.strAwardPeriod
			,dblMaxEarned = T.dblMaxEarned
			,dblMaxCarryover = T.dblMaxCarryover
		FROM
		(SELECT 
			TOP 1
			D.intTypeTimeOffId
			,D.dblYearsOfService
			,D.dblRate
			,D.dblPerPeriod
			,D.strPeriod
			,M.strAwardPeriod
			,D.dblMaxEarned
			,D.dblMaxCarryover FROM 
		tblPRTypeTimeOff M 
		RIGHT JOIN (SELECT * FROM tblPRTypeTimeOffDetail 
					WHERE intTypeTimeOffId = @intTypeTimeOffId 
					  AND dblYearsOfService <= @intYearsOfService) D 
			ON M.intTypeTimeOffId = D.intTypeTimeOffId
		LEFT JOIN tblPREmployeeTimeOff E
			ON D.intTypeTimeOffId = E.intTypeTimeOffId
		WHERE E.intEntityEmployeeId = @intEmployeeId
		ORDER BY D.dblYearsOfService DESC
		) T
		WHERE tblPREmployeeTimeOff.intEntityEmployeeId = @intEmployeeId
			AND tblPREmployeeTimeOff.intTypeTimeOffId = @intTypeTimeOffId

		--Reset Adjustments, Move Earned to Carryover
		UPDATE EOT
			SET dblHoursUsed = CASE WHEN (T.ysnForReset = 1) THEN 0 ELSE EOT.dblHoursUsed END
				,dblHoursCarryover = CASE WHEN (T.ysnForReset = 1) THEN 
											CASE WHEN ((dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - ISNULL(YTD.dblHoursUsed, 0)) < dblMaxCarryover) 
												THEN (dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - ISNULL(YTD.dblHoursUsed, 0))
											ELSE dblMaxCarryover END
									ELSE dblHoursCarryover END
				,dblHoursEarned = CASE WHEN (T.ysnForReset = 1) THEN 0
									ELSE dblHoursEarned END
		FROM 
			tblPREmployeeTimeOff EOT
			INNER JOIN #tmpEmployees T
				ON EOT.intEntityEmployeeId = T.intEntityId
			LEFT JOIN (SELECT * FROM vyuPREmployeeTimeOffUsedYTD WHERE intTypeTimeOffId = @intTypeTimeOffId) YTD
				ON T.intEntityId = YTD.intEntityEmployeeId
				AND YTD.intTypeTimeOffId = @intTypeTimeOffId
				--AND YTD.intYear = YEAR(T.dtmLastAward)
		WHERE T.[intEntityId] = @intEmployeeId
			AND EOT.intTypeTimeOffId = @intTypeTimeOffId

		DELETE FROM #tmpEmployees WHERE [intEntityId] = @intEmployeeId
	END

END
GO