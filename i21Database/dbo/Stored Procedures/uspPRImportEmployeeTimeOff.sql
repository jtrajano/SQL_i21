CREATE PROCEDURE dbo.uspPRImportEmployeeTimeOff(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'A095FB6F-E7B5-41E0-97A9-DFE6E6CBEC40'
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()
DECLARE @NewId AS INT
DECLARE @EmployeeEntityNo AS INT

DECLARE @intEntityNo AS INT
DECLARE @strEmployeeId AS NVARCHAR(100)
DECLARE @strTimeOffId AS NVARCHAR(100)
DECLARE @strTimeOffDesc AS NVARCHAR(100)
DECLARE @dtmEligibleDate AS NVARCHAR(100)
DECLARE @dblRate AS FLOAT(50)
DECLARE @dblPerPeriod AS FLOAT(50) 
DECLARE @strPeriod AS NVARCHAR(100)
DECLARE @dblRateFactor AS FLOAT(50) 
DECLARE @strAwardOn AS NVARCHAR(100)
DECLARE @dblMaxEarned AS FLOAT(50) 
DECLARE @dblMaxCarryOver AS FLOAT(50) 
DECLARE @dblMaxBalance AS FLOAT(50) 
DECLARE @dtmLastAwardDate AS NVARCHAR(100)
DECLARE @dblHoursCarryOver AS FLOAT(50) 
DECLARE @dblHoursAccrued AS FLOAT(50) 
DECLARE @dblHoursEarned AS FLOAT(50) 
DECLARE @dblHoursUsed AS FLOAT(50) 
DECLARE @dblAdjustments AS FLOAT(50) 
DECLARE @EmployeeCount AS INT

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
SELECT
	guiApiImportLogDetailId = NEWID()
	,guiApiImportLogId = @guiLogId
	,strField		= 'Employee ID'
	,strValue		= SE.intEntityNo
	,strLogLevel		= 'Error'
	,strStatus		= 'Failed'
	,intRowNo		= SE.intRowNumber
	,strMessage		= 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(100)) + '.'
	FROM tblApiSchemaEmployeeTimeOff SE
	LEFT JOIN tblPREmployeeTimeOff E ON E.intEntityEmployeeId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo)
	WHERE SE.guiApiUniqueId = @guiApiUniqueId
	AND SE.intEntityNo IS NULL

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTimeOff')) 
DROP TABLE #TempEmployeeTimeOff

SELECT * INTO #TempEmployeeTimeOff FROM tblApiSchemaEmployeeTimeOff where guiApiUniqueId = @guiApiUniqueId
	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeTimeOff)
	BEGIN
		SELECT TOP 1 
			 @strEmployeeId			= LTRIM(RTRIM(intEntityNo))
			,@intEntityNo			= (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = LTRIM(RTRIM(intEntityNo)))
			,@strTimeOffId			= strTimeOffId
			,@strTimeOffDesc		= strTimeOffDesc
			,@dtmEligibleDate		= CAST(dtmEligibleDate AS NVARCHAR) 
			,@dblRate				= dblRate
			,@dblPerPeriod			= dblPerPeriod
			,@strPeriod				= strPeriod
			,@dblRateFactor			= dblRateFactor
			,@strAwardOn			= strAwardOn
			,@dblMaxEarned			= dblMaxEarned
			,@dblMaxCarryOver		= dblMaxCarryOver
			,@dblMaxBalance			= dblMaxBalance
			,@dtmLastAwardDate		= CAST(dtmLastAwardDate AS NVARCHAR) 
			,@dblHoursCarryOver		= CAST(dblHoursCarryOver AS FLOAT) 
			,@dblHoursAccrued		= CAST(dblHoursAccrued AS FLOAT)
			,@dblHoursEarned		= CAST(dblHoursEarned AS FLOAT)
			,@dblHoursUsed			= CAST(dblHoursUsed AS FLOAT)
			,@dblAdjustments		= CAST(dblAdjustments AS FLOAT)
		FROM #TempEmployeeTimeOff

		SELECT TOP 1 
			@EmployeeEntityNo = COUNT(intEntityEmployeeId) 
		FROM tblPREmployeeTimeOff
		WHERE intEntityEmployeeId = @intEntityNo
		  AND intTypeTimeOffId = (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strTimeOffId AND strDescription = @strTimeOffDesc)

		IF (@EmployeeEntityNo = 0)
			BEGIN
				SELECT TOP 1 @EmployeeCount = COUNT(intEntityId) FROM tblPREmployee WHERE strEmployeeId = @strEmployeeId
				IF(@EmployeeCount != 0)
				BEGIN
					INSERT INTO tblPREmployeeTimeOff(
						 intEntityEmployeeId
						,intTypeTimeOffId
						,dblRate
						,dblPerPeriod
						,strPeriod
						,dblRateFactor
						,strAwardPeriod
						,dblMaxCarryover
						,dblMaxEarned
						,dblMaxBalance
						,dtmLastAward
						,dblHoursAccrued
						,dblHoursEarned
						,dblHoursCarryover
						,dblHoursUsed
						,dtmEligible
						,intSort
						,intConcurrencyId
					)
					VALUES
					(
						 (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE intEntityId = @intEntityNo)
						,(SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strTimeOffId AND strDescription = @strTimeOffDesc)
						,@dblRate
						,@dblPerPeriod
						,@strPeriod
						,@dblRateFactor
						,@strAwardOn
						,@dblMaxCarryOver
						,@dblMaxEarned
						,@dblMaxBalance
						,CONVERT(DATE, @dtmLastAwardDate)
						,@dblHoursAccrued
						,@dblHoursEarned
						,@dblHoursCarryOver
						,@dblHoursUsed
						,CONVERT(DATE, @dtmEligibleDate)
						,1
						,1
					)
				END
				

				SET @NewId = SCOPE_IDENTITY()
				DELETE FROM #TempEmployeeTimeOff WHERE LTRIM(RTRIM(intEntityNo)) =LTRIM(RTRIM(@strEmployeeId))  AND strTimeOffId = @strTimeOffId AND strTimeOffDesc = @strTimeOffDesc

			END
		ELSE
			BEGIN
				UPDATE tblPREmployeeTimeOff SET 
					 intTypeTimeOffId = (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strTimeOffId AND strDescription = @strTimeOffDesc)
					,dblRate = @dblRate
					,dblPerPeriod = @dblPerPeriod
					,strPeriod = @strPeriod
					,dblRateFactor = @dblRateFactor
					,strAwardPeriod = @strAwardOn
					,dblMaxCarryover = @dblMaxCarryOver
					,dblMaxEarned = @dblMaxEarned
					,dblMaxBalance = @dblMaxBalance
					,dtmLastAward = CONVERT(DATE, @dtmLastAwardDate) 
					,dblHoursAccrued = @dblHoursAccrued
					,dblHoursEarned = @dblHoursEarned
					,dblHoursCarryover = @dblHoursCarryOver
					,dblHoursUsed = @dblHoursUsed
					,dtmEligible = CONVERT(DATE, @dtmEligibleDate)
				WHERE intEmployeeTimeOffId = @intEntityNo
				AND intTypeTimeOffId = (SELECT TOP 1 intTypeTimeOffId FROM tblPRTypeTimeOff WHERE strTimeOff = @strTimeOffId AND strDescription = @strTimeOffDesc)

				DELETE FROM #TempEmployeeTimeOff WHERE LTRIM(RTRIM(intEntityNo)) =LTRIM(RTRIM(@strEmployeeId))  AND strTimeOffId = @strTimeOffId AND strTimeOffDesc = @strTimeOffDesc
			END

	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeTimeOff')) 
	DROP TABLE #TempEmployeeTimeOff

END


GO