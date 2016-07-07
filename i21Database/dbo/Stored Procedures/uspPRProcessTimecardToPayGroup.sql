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
DECLARE @intPayGroupDetailId INT

/* Add Timecards to Pay Group Detail */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTimecard)
	BEGIN 

		/* Select Timecard to Add */
		SELECT TOP 1 
			@intEmployeeEarningId	  = intEmployeeEarningId
			,@intEmployeeDepartmentId = intEmployeeDepartmentId
		FROM #tmpTimecard

		/* Insert Regular Hours To Pay Group Detail */
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
			EE.intPayGroupId
			,TC.intEntityEmployeeId
			,TC.intEmployeeEarningId
			,EE.intTypeEarningId
			,TC.intEmployeeDepartmentId
			,EE.strCalculationType
			,TC.dblRegularHours
			,TC.dblRegularHours
			,EE.dblRateAmount
			,TC.dblRegularHours * EE.dblRateAmount
			,@dtmBegin 
			,@dtmEnd
			,1
			,1
		FROM #tmpTimecard TC INNER JOIN tblPREmployeeEarning EE 
			ON TC.intEmployeeEarningId = EE.intEmployeeEarningId
			LEFT JOIN tblPREmployeeEarning EL
				ON EE.intEmployeeEarningLinkId = EL.intTypeEarningId
				AND EE.intEntityEmployeeId = EL.intEntityEmployeeId
		WHERE TC.intEmployeeEarningId = @intEmployeeEarningId
		  AND TC.intEmployeeDepartmentId = @intEmployeeDepartmentId
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
			,TCE.dblOvertimeHours * TCE.dblRateAmount
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
		  AND EL.strCalculationType IN ('Overtime')

		/* Updated Processed Timecards */
		UPDATE tblPRTimecard 
		SET intPayGroupDetailId = @intPayGroupDetailId
		WHERE ysnApproved = 1
			AND intPaycheckId IS NULL
			AND intPayGroupDetailId IS NULL
			AND dblHours > 0
			AND intEmployeeEarningId = @intEmployeeEarningId
			AND intEmployeeDepartmentId = @intEmployeeDepartmentId
			AND CAST(FLOOR(CAST(dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDateIn) AS FLOAT)) AS DATETIME)
			AND CAST(FLOOR(CAST(dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDateOut) AS FLOAT)) AS DATETIME)

		/* Loop Control */
		DELETE FROM #tmpTimecard 
		WHERE intEmployeeEarningId = @intEmployeeEarningId
			AND intEmployeeDepartmentId = @intEmployeeDepartmentId 
	END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTimecard')) DROP TABLE #tmpTimecard

END
GO

