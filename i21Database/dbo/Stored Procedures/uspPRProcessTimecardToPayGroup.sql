CREATE PROCEDURE [dbo].[uspPRProcessTimecardToPayGroup]
	@strDepartmentIds	NVARCHAR(MAX) = ''
	,@dtmBeginDate		DATETIME
	,@dtmEndDate		DATETIME
	,@intUserId			INT = NULL
AS
BEGIN

DECLARE @dtmBegin DATETIME
	   ,@dtmEnd DATETIME
	   ,@dtmPay DATETIME
	   ,@xmlDepartments XML

/* Localize Parameters for Optimal Performance */
SELECT @dtmBegin		= @dtmBeginDate
	  ,@dtmEnd			= @dtmEndDate
	  ,@xmlDepartments  = CAST('<A>'+ REPLACE(@strDepartmentIds, ',', '</A><A>')+ '</A>' AS XML)

--Parse the Departments Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intDepartmentId
INTO #tmpDepartments
FROM @xmlDepartments.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

/* Insert Timecards to Temp Table for iteration */
SELECT 
	T.intEntityEmployeeId
	,T.intEmployeeEarningId
	,T.intEmployeeDepartmentId
	,dblRegularHours =  CASE WHEN (SUM(T.dblHours) > ISNULL(E.dblDefaultHours, 0) AND ISNULL(E.dblDefaultHours, 0) > 0)
							THEN ISNULL(E.dblDefaultHours, 0)
						ELSE 
							SUM(T.dblHours)
						END
	,dblOvertimeHours = CASE WHEN (SUM(T.dblHours) > ISNULL(E.dblDefaultHours, 0) AND ISNULL(E.dblDefaultHours, 0) > 0)
							THEN SUM(T.dblHours) - ISNULL(E.dblDefaultHours, 0)
						ELSE 
							0
						END
	,E.dblDefaultHours
INTO #tmpTimecard
FROM tblPRTimecard T LEFT JOIN tblPREmployeeEarning E 
	ON T.intEmployeeEarningId = E.intEmployeeEarningId 
	AND T.intEntityEmployeeId = E.intEntityEmployeeId
WHERE T.ysnApproved = 1
	AND T.intPaycheckId IS NULL
	AND T.intPayGroupDetailId IS NULL
	AND T.dblHours > 0
	AND T.intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
	AND CAST(FLOOR(CAST(T.dtmTimeIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,T.dtmTimeIn) AS FLOAT)) AS DATETIME)
	AND CAST(FLOOR(CAST(T.dtmTimeOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,T.dtmTimeOut) AS FLOAT)) AS DATETIME)
GROUP BY
	T.intEntityEmployeeId
	,T.intEmployeeEarningId
	,T.intEmployeeDepartmentId
	,E.dblDefaultHours

DECLARE @intEmployeeEarningId INT
DECLARE @intEmployeeDepartmentId INT
DECLARE @intEntityEmployeeId INT
DECLARE @intPayGroupDetailId INT

/* Add Timecards to Pay Group Detail */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTimecard)
	BEGIN 

		/* Select Timecard to Add */
		SELECT TOP 1 
			@intEmployeeEarningId	  = intEmployeeEarningId
			,@intEmployeeDepartmentId = intEmployeeDepartmentId
			,@intEntityEmployeeId = intEntityEmployeeId
		FROM #tmpTimecard

		/* Delete any Generated Hours that occupies this Period */
		DELETE FROM tblPRPayGroupDetail
		WHERE (intEmployeeEarningId = @intEmployeeEarningId OR strCalculationType IN ('Overtime', 'Shift Differential'))
			AND intDepartmentId = @intEmployeeDepartmentId
			AND intEntityEmployeeId = @intEntityEmployeeId
			AND dtmDateFrom >= @dtmBegin AND dtmDateFrom <= @dtmEnd
			AND intSource = 0

		/* Insert Regular Hours To Pay Group Detail */
		INSERT INTO tblPRPayGroupDetail
			(intPayGroupId
			,intEntityEmployeeId
			,intEmployeeEarningId
			,intTypeEarningId
			,intDepartmentId
			,intWorkersCompensationId
			,strCalculationType
			,dblDefaultHours
			,dblHoursToProcess
			,dblAmount
			,dblTotal
			,dtmDateFrom
			,dtmDateTo
			,intSource
			,intSort
			,intConcurrencyId)
		SELECT
			EE.intPayGroupId
			,TC.intEntityEmployeeId
			,TC.intEmployeeEarningId
			,EE.intTypeEarningId
			,TC.intEmployeeDepartmentId
			,CASE WHEN (EE.strCalculationType IN ('Hourly Rate', 'Overtime', 'Fixed Amount')) THEN EMP.intWorkersCompensationId ELSE NULL END
			,EE.strCalculationType
			,TC.dblRegularHours
			,TC.dblRegularHours
			,EE.dblRateAmount
			,CASE WHEN (EE.strCalculationType IN ('Fixed Amount')) THEN EE.dblRateAmount ELSE ROUND(TC.dblRegularHours * EE.dblRateAmount, 2) END
			,@dtmBegin 
			,@dtmEnd
			,3
			,1
			,1
		FROM #tmpTimecard TC 
			INNER JOIN tblPREmployeeEarning EE 
				ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
			INNER JOIN tblPREmployee EMP
				ON EMP.[intEntityId] = EE.intEntityEmployeeId
			LEFT JOIN tblPREmployeeEarning EL
				ON EE.intEmployeeEarningLinkId = EL.intTypeEarningId
				AND EE.intEntityEmployeeId = EL.intEntityEmployeeId
		WHERE TC.intEmployeeEarningId = @intEmployeeEarningId
		  AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId
		  AND TC.intEntityEmployeeId = @intEntityEmployeeId
		  AND EE.strCalculationType IN ('Hourly Rate', 'Fixed Amount')

		/* Get the Created Pay Group Detail Id*/
		SELECT @intPayGroupDetailId = @@IDENTITY

		/* Insert Overtime Hours To Pay Group Detail */
		INSERT INTO tblPRPayGroupDetail
			(intPayGroupId
			,intEntityEmployeeId
			,intEmployeeEarningId
			,intTypeEarningId
			,intDepartmentId
			,strCalculationType
			,dblDefaultHours
			,dblHoursToProcess
			,dblAmount
			,dblTotal
			,dtmDateFrom
			,dtmDateTo
			,intSource
			,intSort
			,intConcurrencyId)
		SELECT
			TCE.intPayGroupId
			,TCE.intEntityEmployeeId
			,EL.intEmployeeEarningId
			,EL.intTypeEarningId
			,TCE.intEmployeeDepartmentId
			,EL.strCalculationType
			,TCE.dblOvertimeHours
			,TCE.dblOvertimeHours
			,EL.dblRateAmount 
			,ROUND(TCE.dblOvertimeHours * EL.dblRateAmount, 2)
			,@dtmBegin 
			,@dtmEnd
			,3
			,1
			,1
		FROM tblPREmployeeEarning EL 
			INNER JOIN (SELECT EE.*, TC.dblRegularHours, TC.dblOvertimeHours, TC.intEmployeeDepartmentId 
						FROM #tmpTimecard TC INNER JOIN tblPREmployeeEarning EE 
						ON TC.intEmployeeEarningId = EE.intEmployeeEarningId) TCE
			ON EL.intEmployeeEarningLinkId = TCE.intTypeEarningId
				AND EL.intEntityEmployeeId = TCE.intEntityEmployeeId	
		WHERE TCE.intEmployeeDepartmentId = @intEmployeeDepartmentId
		  AND TCE.dblOvertimeHours > 0
		  AND TCE.intEntityEmployeeId = @intEntityEmployeeId
		  AND EL.strCalculationType IN ('Overtime')

		/* Insert Shift Differential Hours To Pay Group Detail */
		INSERT INTO tblPRPayGroupDetail
			(intPayGroupId
			,intEntityEmployeeId
			,intEmployeeEarningId
			,intTypeEarningId
			,intDepartmentId
			,strCalculationType
			,dblDefaultHours
			,dblHoursToProcess
			,dblAmount
			,dblTotal
			,dtmDateFrom
			,dtmDateTo
			,intSort
			,intConcurrencyId)
		SELECT
			EL.intPayGroupId
			,EL.intEntityEmployeeId
			,EL.intEmployeeEarningId
			,EL.intTypeEarningId
			,SD.intEmployeeDepartmentId
			,EL.strCalculationType
			,0
			,0
			,SUM(SD.dblTotal)
			,SUM(SD.dblTotal)
			,@dtmBegin 
			,@dtmEnd
			,1
			,1
		FROM
			(SELECT TCSH.*, 
				dblTotal = CONVERT(NUMERIC(18, 2), dblHours * CASE WHEN (strDifferentialPay = 'Shift') THEN dblMaxRate ELSE dblRate END)
			FROM 
				(SELECT 
					SHIFTHOURS.*,
					MAXRATE.dblMaxRate
				FROM
				(SELECT TCS.*
						,dblHours = CONVERT(NUMERIC(18, 2),
							CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								ELSE 0
						END)
					FROM
					(SELECT
						TC.intTimecardId, TC.dtmDate, TC.intEntityEmployeeId, TC.intEmployeeEarningId, EE.intTypeEarningId,
						TC.intEmployeeDepartmentId,	DS.intShiftNo, TC.dtmTimeIn, TC.dtmTimeOut, D.strDifferentialPay
						,dtmShiftStart = DATEADD(HH, DATEPART(HH, dtmStart), DATEADD(MI, DATEPART(MI, dtmStart), DATEADD(SS, DATEPART(SS, dtmStart), DATEADD(MS, DATEPART(MS, dtmStart), dtmDate))))
						,dtmShiftEnd = CASE WHEN (dtmStart > dtmEnd) THEN
												DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), DATEADD(DD, 1, dtmDate)))))
											ELSE
												DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), dtmDate))))
											END
						,dblRate = CONVERT(NUMERIC(18, 6),
									CASE WHEN (strRateType = 'Per Hour') THEN
											DS.dblRate
										ELSE 
											ISNULL((SELECT TOP 1 dblRateAmount FROM tblPREmployeeEarning 
														WHERE intEmployeeEarningId = TC.intEmployeeEarningId 
														AND intEntityEmployeeId = TC.intEntityEmployeeId), 0) 
											* DS.dblRate
										END)
					FROM 
						(SELECT intTimecardId, intEntityEmployeeId, intEmployeeEarningId, intEmployeeDepartmentId, dtmDate
							,dtmTimeIn = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeIn)
							,dtmTimeOut = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeOut) 
						FROM tblPRTimecard
						WHERE ysnApproved = 1 AND intPaycheckId IS NULL AND intPayGroupDetailId IS NULL AND dblHours > 0
							AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
							AND CAST(FLOOR(CAST(dtmTimeIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmTimeIn) AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(dtmTimeOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmTimeOut) AS FLOAT)) AS DATETIME)) TC
						INNER JOIN tblPREmployeeEarning EE
							ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
							AND TC.intEntityEmployeeId = EE.intEntityEmployeeId
						LEFT JOIN tblPRDepartmentShift DS 
							ON TC.intEmployeeDepartmentId = DS.intDepartmentId
						INNER JOIN tblPRDepartment D
							ON D.intDepartmentId = DS.intDepartmentId
					) TCS
					WHERE 
						CONVERT(NUMERIC(18, 2),
							CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								ELSE 0
						END) > 0
					) SHIFTHOURS
					INNER JOIN 
					(SELECT intTimecardId
							,dblMaxRate = MAX(dblRate)
						FROM
						(SELECT
							TC.intTimecardId, TC.dtmDate, TC.intEntityEmployeeId, TC.intEmployeeEarningId, EE.intTypeEarningId,
							TC.intEmployeeDepartmentId,	DS.intShiftNo, TC.dtmTimeIn, TC.dtmTimeOut, D.strDifferentialPay
							,dtmShiftStart = DATEADD(HH, DATEPART(HH, dtmStart), DATEADD(MI, DATEPART(MI, dtmStart), DATEADD(SS, DATEPART(SS, dtmStart), DATEADD(MS, DATEPART(MS, dtmStart), dtmDate))))
							,dtmShiftEnd = CASE WHEN (dtmStart > dtmEnd) THEN
												DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), DATEADD(DD, 1, dtmDate)))))
											ELSE
												DATEADD(HH, DATEPART(HH, dtmEnd), DATEADD(MI, DATEPART(MI, dtmEnd), DATEADD(SS, DATEPART(SS, dtmEnd), DATEADD(MS, DATEPART(MS, dtmEnd), dtmDate))))
											END
							,dblRate = CONVERT(NUMERIC(18, 6),
										CASE WHEN (strRateType = 'Per Hour') THEN
												DS.dblRate
											ELSE 
												ISNULL((SELECT TOP 1 dblRateAmount FROM tblPREmployeeEarning 
															WHERE intEmployeeEarningId = TC.intEmployeeEarningId 
															AND intEntityEmployeeId = TC.intEntityEmployeeId), 0) 
												* DS.dblRate
											END)
						FROM 
							(SELECT intTimecardId, intEntityEmployeeId, intEmployeeEarningId, intEmployeeDepartmentId, dtmDate
								,dtmTimeIn = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeIn)
								,dtmTimeOut = DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), dtmTimeOut) 
							FROM tblPRTimecard
							WHERE ysnApproved = 1 AND intPaycheckId IS NULL AND intPayGroupDetailId IS NULL AND dblHours > 0
								AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
								AND CAST(FLOOR(CAST(dtmTimeIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmTimeIn) AS FLOAT)) AS DATETIME)
								AND CAST(FLOOR(CAST(dtmTimeOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmTimeOut) AS FLOAT)) AS DATETIME)) TC
							INNER JOIN tblPREmployeeEarning EE
								ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
								AND TC.intEntityEmployeeId = EE.intEntityEmployeeId
							LEFT JOIN tblPRDepartmentShift DS 
								ON TC.intEmployeeDepartmentId = DS.intDepartmentId
							INNER JOIN tblPRDepartment D
								ON D.intDepartmentId = DS.intDepartmentId
						) TCS
						WHERE 
							CONVERT(NUMERIC(18, 2),
								CASE WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftStart AND dtmTimeOut < dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn > dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn >= dtmShiftStart AND dtmTimeIn < dtmShiftEnd AND dtmTimeOut <= dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmTimeIn, dtmTimeOut) AS NUMERIC(18, 6)) / 60
								WHEN (dtmTimeIn < dtmShiftStart AND dtmTimeOut > dtmShiftEnd) THEN
									CAST(DATEDIFF(MI, dtmShiftStart, dtmShiftEnd) AS NUMERIC(18, 6)) / 60
								ELSE 0
							END) > 0
						GROUP BY intTimecardId
					) MAXRATE
					ON SHIFTHOURS.intTimecardId = MAXRATE.intTimecardId
				) TCSH
			) SD
			LEFT JOIN tblPREmployeeEarning EL
			ON SD.intTypeEarningId = EL.intEmployeeEarningLinkId
			AND SD.intEntityEmployeeId = EL.intEntityEmployeeId
					WHERE SD.intEmployeeDepartmentId = @intEmployeeDepartmentId
						AND SD.dblTotal > 0
						AND SD.intEntityEmployeeId = @intEntityEmployeeId
						AND EL.strCalculationType IN ('Shift Differential')
			GROUP BY
				EL.intPayGroupId
				,EL.intEntityEmployeeId
				,EL.intEmployeeEarningId
				,EL.intTypeEarningId
				,SD.intEmployeeDepartmentId
				,EL.strCalculationType

		/* Update Processed Timecards */
		UPDATE tblPRTimecard
		SET dblRegularHours = Y.dblRegularHours
			,dblOvertimeHours = Y.dblOvertimeHours
			,intPayGroupDetailId = @intPayGroupDetailId
			,intProcessedUserId = @intUserId
			,dtmProcessed = GETDATE()
		FROM
		(SELECT
			intTimecardId
			,dblRegularHours = CASE WHEN (X.dblDefaultHours > 0) THEN
								CASE WHEN (X.dblDefaultHours > X.dblRunningHours) THEN X.dblHours 
									ELSE CASE WHEN (X.dblHours < (X.dblRunningHours - X.dblDefaultHours)) THEN 0
											ELSE X.dblHours - (X.dblRunningHours - X.dblDefaultHours) END
									END
								ELSE X.dblHours END
		   ,dblOvertimeHours = CASE WHEN (X.dblDefaultHours > 0) THEN
								CASE WHEN (X.dblDefaultHours > X.dblRunningHours) THEN 0 
									ELSE CASE WHEN (X.dblHours < (X.dblRunningHours - X.dblDefaultHours)) THEN X.dblHours 
									ELSE (X.dblRunningHours - X.dblDefaultHours) END
									END
								ELSE 0 END
		FROM
			(SELECT 
				TC.intTimecardId
				,TC.intEntityEmployeeId
				,TC.dtmDate
				,TC.intEmployeeEarningId
				,TC.intEmployeeDepartmentId
				,TC.dtmTimeIn
				,TC.dtmTimeOut
				,TC.ysnApproved
				,TC.dblHours
				,EE.dblDefaultHours
				,dblRunningHours = (SELECT
										SUM (TCR.dblHours) 
									FROM
										tblPRTimecard TCR
									WHERE 
										TCR.dtmTimeOut <= TC.dtmTimeOut 
										AND TCR.intEntityEmployeeId = TC.intEntityEmployeeId
										AND TCR.intEmployeeEarningId = TC.intEmployeeEarningId
										AND TCR.intEmployeeDepartmentId = TC.intEmployeeDepartmentId
										AND CAST(FLOOR(CAST(TCR.dtmTimeIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TCR.dtmTimeIn) AS FLOAT)) AS DATETIME)
										AND CAST(FLOOR(CAST(TCR.dtmTimeOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TCR.dtmTimeOut) AS FLOAT)) AS DATETIME))
			FROM
				tblPRTimecard TC LEFT JOIN tblPREmployeeEarning EE
				ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
			WHERE
				TC.ysnApproved = 1
				AND TC.dblHours > 0
				AND TC.intEmployeeEarningId = @intEmployeeEarningId
				AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId
				AND CAST(FLOOR(CAST(TC.dtmTimeIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TC.dtmTimeIn) AS FLOAT)) AS DATETIME)
				AND CAST(FLOOR(CAST(TC.dtmTimeOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TC.dtmTimeOut) AS FLOAT)) AS DATETIME)
			GROUP BY 
				TC.intTimecardId
				,TC.intEntityEmployeeId
				,TC.dtmDate
				,TC.intEmployeeEarningId
				,TC.intEmployeeDepartmentId
				,TC.dblHours
				,TC.dtmTimeIn
				,TC.dtmTimeOut
				,TC.ysnApproved
				,EE.dblDefaultHours) X
			) Y
		WHERE tblPRTimecard.intTimecardId = Y.intTimecardId

		/* Loop Control */
		DELETE FROM #tmpTimecard 
		WHERE intEmployeeEarningId = @intEmployeeEarningId
			AND intEmployeeDepartmentId = @intEmployeeDepartmentId 
			AND intEntityEmployeeId = @intEntityEmployeeId
	END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTimecard')) DROP TABLE #tmpTimecard

END
GO
