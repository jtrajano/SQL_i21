CREATE PROCEDURE [dbo].[uspPRGeneratePayGroupDetail]
	@strPayGroupIds	NVARCHAR(MAX) = '',
	@intUserId INT = NULL
AS
BEGIN

	/* Localize Parameters */
	DECLARE @xmlPayGroups XML
	SET @xmlPayGroups = CAST('<A>'+ REPLACE(@strPayGroupIds, ',', '</A><A>')+ '</A>' AS XML) 

	/* Parse Pay Groups Parameter to Temporary Table */
	SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intPayGroupId
	INTO #tmpPayGroups
	FROM @xmlPayGroups.nodes('/A') AS X(T) 
	WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

	/* Loop Each Pay Group Id, Insert to Pay Group Details */
	DECLARE @intPayGroupId INT
	DECLARE @dblOverrideHours NUMERIC(18, 6) = 0
	DECLARE @ysnStandardHours BIT = 1
	DECLARE @dtmDateFrom DATETIME
	DECLARE @dtmDateTo DATETIME
	DECLARE @intPayGroupDetailId INT

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPayGroups)
	BEGIN
		SELECT TOP 1 @intPayGroupId = intPayGroupId FROM #tmpPayGroups
		
		SELECT TOP 1 
			@ysnStandardHours = ysnStandardHours,
			@dblOverrideHours = dblHolidayHours,
			@dtmDateFrom = dtmBeginDate,
			@dtmDateTo = dtmEndDate
		FROM tblPRPayGroup 
		WHERE intPayGroupId = @intPayGroupId

		INSERT INTO tblPRPayGroupDetail(
			intPayGroupId
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
			@intPayGroupId
			,EE.intEntityEmployeeId
			,EE.intEmployeeEarningId
			,EE.intTypeEarningId
			,intDepartmentId = (SELECT TOP 1 intDepartmentId FROM tblPREmployeeDepartment
								WHERE intEntityEmployeeId = EE.intEntityEmployeeId ORDER BY intEmployeeDepartmentId ASC)
			,intWorkersCompensationId = CASE WHEN (EE.strCalculationType IN ('Hourly Rate', 'Overtime', 'Salary')) 
											THEN (SELECT TOP 1 intWorkersCompensationId FROM tblPREmployee WHERE [intEntityId] = EE.intEntityEmployeeId) 
											ELSE NULL END
			,EE.strCalculationType
			,dblDefaultHours = CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours 
									ELSE (CASE WHEN (EE.dblDefaultHours <> 0) THEN @dblOverrideHours ELSE 0 END + EE.dblDefaultHours) END					
			,dblHoursToProcess = CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours 
									ELSE (CASE WHEN (EE.dblDefaultHours <> 0) THEN @dblOverrideHours ELSE 0 END + EE.dblHoursToProcess) END
			,EE.dblRateAmount
			,dblTotal = ROUND(CASE WHEN (EE.strCalculationType IN ('Hourly Rate', 'Overtime')) THEN
									CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours 
										ELSE (CASE WHEN (EE.dblHoursToProcess <> 0) THEN @dblOverrideHours ELSE 0 END + EE.dblHoursToProcess)
										END * EE.dblRateAmount
								WHEN (EE.strCalculationType IN ('Rate Factor')) THEN 
									CASE WHEN (ELink.strCalculationType = 'Hourly Rate') THEN
											CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours 
											ELSE (CASE WHEN (EE.dblHoursToProcess <> 0) THEN @dblOverrideHours ELSE 0 END + EE.dblHoursToProcess)
											END * EE.dblRateAmount
										WHEN (ELink.strCalculationType IN ('Fixed Amount', 'Salary')) THEN
											CASE WHEN (ELink.dblDefaultHours <> 0) THEN
													CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours 
													ELSE (CASE WHEN (EE.dblHoursToProcess <> 0) THEN @dblOverrideHours ELSE 0 END + EE.dblHoursToProcess)
													END * EE.dblRateAmount
												ELSE 
													EE.dblRateAmount
												END
										ELSE
											0
										END
								ELSE
									EE.dblRateAmount
								END, 2)
			,@dtmDateFrom
			,@dtmDateTo
			,EE.intSort
			,1
		FROM tblPREmployeeEarning EE
			LEFT JOIN tblPREmployeeEarning ELink 
				ON EE.intEntityEmployeeId = ELink.intEntityEmployeeId
				 AND EE.intEmployeeEarningLinkId = ELink.intTypeEarningId
		WHERE EE.intPayGroupId = @intPayGroupId
			AND (EE.ysnDefault = 1 OR EE.dblDefaultHours <> 0)
			AND EE.intEmployeeEarningId NOT IN (SELECT intEmployeeEarningId FROM tblPRPayGroupDetail 
												WHERE intPayGroupId = @intPayGroupId
												AND dtmDateFrom >= ISNULL(@dtmDateFrom, dtmDateFrom) AND dtmDateFrom <= ISNULL(@dtmDateTo, dtmDateTo))

		DELETE FROM #tmpPayGroups WHERE intPayGroupId = @intPayGroupId
	END

END
GO