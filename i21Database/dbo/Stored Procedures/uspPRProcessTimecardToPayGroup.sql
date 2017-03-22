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
	AND CAST(FLOOR(CAST(T.dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,T.dtmDateIn) AS FLOAT)) AS DATETIME)
	AND CAST(FLOOR(CAST(T.dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,T.dtmDateOut) AS FLOAT)) AS DATETIME)
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
			,ROUND(TC.dblRegularHours * EE.dblRateAmount, 2)
			,@dtmBegin 
			,@dtmEnd
			,1
			,1
		FROM #tmpTimecard TC 
			INNER JOIN tblPREmployeeEarning EE 
				ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
			INNER JOIN tblPREmployee EMP
				ON EMP.intEntityEmployeeId = EE.intEntityEmployeeId
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
				,TC.dtmDateIn
				,TC.dtmTimeIn
				,TC.dtmDateOut
				,TC.dtmTimeOut
				,TC.ysnApproved
				,TC.dblHours
				,EE.dblDefaultHours
				,dblRunningHours = (SELECT
										SUM (TCR.dblHours) 
									FROM
										tblPRTimecard TCR
									WHERE 
										TCR.dtmDateOut <= TC.dtmDateOut 
										AND TCR.intEntityEmployeeId = TC.intEntityEmployeeId
										AND TCR.intEmployeeEarningId = TC.intEmployeeEarningId
										AND TCR.intEmployeeDepartmentId = TC.intEmployeeDepartmentId
										AND CAST(FLOOR(CAST(TCR.dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TCR.dtmDateIn) AS FLOAT)) AS DATETIME)
										AND CAST(FLOOR(CAST(TCR.dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TCR.dtmDateOut) AS FLOAT)) AS DATETIME))
			FROM
				tblPRTimecard TC LEFT JOIN tblPREmployeeEarning EE
				ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
			WHERE
				TC.ysnApproved = 1
				AND TC.dblHours > 0
				AND TC.intEmployeeEarningId = @intEmployeeEarningId
				AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId
				AND CAST(FLOOR(CAST(TC.dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,TC.dtmDateIn) AS FLOAT)) AS DATETIME)
				AND CAST(FLOOR(CAST(TC.dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,TC.dtmDateOut) AS FLOAT)) AS DATETIME)
			GROUP BY 
				TC.intTimecardId
				,TC.intEntityEmployeeId
				,TC.dtmDate
				,TC.intEmployeeEarningId
				,TC.intEmployeeDepartmentId
				,TC.dblHours
				,TC.dtmDateIn
				,TC.dtmTimeIn
				,TC.dtmDateOut
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
