CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOff]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL,
	@intUserId INT = 0,
	@ysnFromUpdateUser BIT = 0
AS
BEGIN


	--Temporary Variable for audit log
	CREATE TABLE #tmpTableForAuditTimeOff(
		intEntityEmployeeId Int,
		dblRateOld NUMERIC(18, 6),
		dblRateNew NUMERIC(18, 6),
		dblPerPeriodOld NUMERIC(18, 6),
		dblPerPeriodNew NUMERIC(18, 6),
		strPeriodOld VARCHAR(100),
		strPeriodNew VARCHAR(100),
		strAwardPeriodOld VARCHAR(100),
		strAwardPeriodNew VARCHAR(100),
		dblMaxEarnedOld NUMERIC(18, 6),
		dblMaxEarnedNew NUMERIC(18, 6),
		dblMaxCarryoverOld NUMERIC(18, 6),
		dblMaxCarryoverNew NUMERIC(18, 6),
		dblMaxBalanceOld NUMERIC(18, 6),
		dblMaxBalanceNew NUMERIC(18, 6),	
	)
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
								OR (strAwardPeriod NOT IN ('Anniversary Date', 'End of Year') AND GETDATE() >= dtmNextAward AND YEAR(GETDATE()) > YEAR(dtmLastAward))
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
			,dblMaxBalance = T.dblMaxBalance
		OUTPUT
			inserted.intEntityEmployeeId,
			deleted.dblRate, inserted.dblRate,
			deleted.dblPerPeriod,inserted.dblPerPeriod,
			deleted.strPeriod,inserted.strPeriod,
			deleted.strAwardPeriod,inserted.strAwardPeriod,
			deleted.dblMaxEarned , inserted.dblMaxEarned,
			deleted.dblMaxCarryover, inserted.dblMaxCarryover,
			deleted.dblMaxBalance, inserted.dblMaxBalance
		INTO #tmpTableForAuditTimeOff
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
			,D.dblMaxCarryover 
			,D.dblMaxBalance FROM 
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
												THEN 
													CASE WHEN (dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - ISNULL(YTD.dblHoursUsed, 0)) < 0 --check if negative if so  set to 0
															THEN 0
														ELSE
															(dblHoursCarryover + dblHoursEarned - EOT.dblHoursUsed - ISNULL(YTD.dblHoursUsed, 0))
														END
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

		
	------------CREATE AUDIT ENTRY
		DECLARE @cur_Id INT;
		DECLARE @cur_Namespace VARCHAR(max);
		DECLARE @cur_Action VARCHAR(30);
		DECLARE @cur_Description VARCHAR(100);
		DECLARE @cur_From VARCHAR(100);
		DECLARE @cur_To VARCHAR(100);
		DECLARE @cur_EntityId Int;


		DECLARE AuditTableCursor CURSOR FOR
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE	
				WHEN @ysnFromUpdateUser = 1 THEN 'Rate(Updated in Update Employees)'
				ELSE 'Rate'
			END,
			CAST(CAST(dblRateOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblRateNew AS FLOAT) AS NVARCHAR(20)),@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Per Period(Updated in Update Employees)'
				ELSE 'Per Period' 
			END
			,CAST(CAST(dblPerPeriodOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblPerPeriodNew AS FLOAT) AS NVARCHAR(20)),@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Period(Updated in Update Employees)'
				ELSE 'Period'
			END,
			strPeriodOld,strPeriodNew,@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Award Period(Updated in Update Employees)'
				ELSE 'Award Period'
			END,
			strAwardPeriodOld,strAwardPeriodNew,@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Max Earned(Updated in Update Employees)'
				ELSE 'Max Earned' 
			END,
			CAST(CAST(dblMaxEarnedOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblMaxEarnedNew AS FLOAT) AS NVARCHAR(20)),@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Max Carryover(Updated in Update Employees)'
				ELSE 'Max Carryover'
			END,
			CAST(CAST(dblMaxCarryoverOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblMaxCarryoverNew AS FLOAT) AS NVARCHAR(20)),@intUserId FROM #tmpTableForAuditTimeOff 
		UNION
		SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated',
			CASE 
				WHEN @ysnFromUpdateUser = 1 THEN 'Max Balance(Updated in Update Employees)'
				ELSE 'Max Balance'
			END,
			CAST(CAST(dblMaxBalanceOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblMaxBalanceNew AS FLOAT) AS NVARCHAR(20)),@intUserId FROM #tmpTableForAuditTimeOff 

		OPEN AuditTableCursor
			
		FETCH NEXT FROM AuditTableCursor INTO @cur_Id,@cur_Namespace,@cur_Action,@cur_Description,@cur_From,@cur_To,@cur_EntityId
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
		--Insert individual Record to audit log
			EXEC uspSMAuditLog
				@keyValue = @cur_Id,
				@screenName = @cur_Namespace,
				@entityId = @cur_EntityId,
				@actionType = @cur_Action,
				@changeDescription  = @cur_Description,
				@fromValue = @cur_From,
				@toValue = @cur_To

			FETCH NEXT FROM AuditTableCursor INTO @cur_Id,@cur_Namespace,@cur_Action,@cur_Description,@cur_From,@cur_To,@cur_EntityId
		END
		CLOSE AuditTableCursor
		DEALLOCATE AuditTableCursor

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTableForAuditTimeOff')) DROP TABLE #tmpTableForAuditTimeOff 
END
GO