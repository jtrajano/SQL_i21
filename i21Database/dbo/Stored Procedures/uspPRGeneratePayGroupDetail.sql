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

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPayGroups)
	BEGIN
		SELECT TOP 1 @intPayGroupId = intPayGroupId FROM #tmpPayGroups
		
		SELECT TOP 1 
			@ysnStandardHours = ysnStandardHours,
			@dblOverrideHours = dblHolidayHours
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
			,intEntityEmployeeId
			,intEmployeeEarningId
			,intTypeEarningId
			,intDepartmentId = (SELECT TOP 1 intDepartmentId FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = tblPREmployeeEarning.intEntityEmployeeId ORDER BY intEmployeeDepartmentId ASC)
			,intWorkersCompensationId = CASE WHEN (strCalculationType IN ('Hourly Rate', 'Overtime', 'Fixed Amount')) 
											THEN (SELECT TOP 1 intWorkersCompensationId FROM tblPREmployee WHERE intEntityEmployeeId = tblPREmployeeEarning.intEntityEmployeeId) 
											ELSE NULL END
			,strCalculationType
			,dblDefaultHours = CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours ELSE dblDefaultHours END					
			,dblHoursToProcess = CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours ELSE dblHoursToProcess END
			,dblRateAmount
			,dblTotal = ROUND(CASE WHEN (strCalculationType IN ('Rate Factor', 'Overtime') AND intEmployeeEarningLinkId IS NOT NULL) THEN 
							CASE WHEN ((SELECT TOP 1 strCalculationType FROM tblPRTypeEarning WHERE intTypeEarningId = tblPREmployeeEarning.intEmployeeEarningLinkId) = 'Hourly Rate') THEN
								CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours ELSE dblHoursToProcess END * dblRateAmount
							ELSE
								dblRateAmount
							END
						WHEN (strCalculationType = 'Hourly Rate') THEN
							CASE WHEN (@ysnStandardHours = 0) THEN @dblOverrideHours ELSE dblHoursToProcess END * dblRateAmount
						ELSE
							dblRateAmount
						END, 2)
			,NULL
			,NULL
			,intSort
			,1
		FROM tblPREmployeeEarning
		WHERE intPayGroupId = @intPayGroupId
			AND (ysnDefault = 1 OR dblDefaultHours > 0)
			AND intEmployeeEarningId NOT IN (SELECT intEmployeeEarningId FROM tblPRPayGroupDetail WHERE intPayGroupId = @intPayGroupId)

		DELETE FROM #tmpPayGroups WHERE intPayGroupId = @intPayGroupId
	END

END
GO