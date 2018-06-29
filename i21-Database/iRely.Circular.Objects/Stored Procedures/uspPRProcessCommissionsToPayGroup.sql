CREATE PROCEDURE [dbo].[uspPRProcessCommissionsToPayGroup]
	@intCommissionId	INT
	,@intUserId			INT = NULL
	,@isSuccessful		BIT = 0 OUTPUT
AS
BEGIN

/* Initialize Variables */
DECLARE @intCommissionEarningId INT = NULL
		,@intEntityId INT = NULL
		,@dblTotalAmount NUMERIC(18, 6) = 0
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME

SELECT TOP 1 
	@intEntityId = intEntityId 
	,@dblTotalAmount = dblTotalAmount
	,@dtmStartDate = dtmStartDate
	,@dtmEndDate = dtmEndDate
FROM tblARCommission WHERE intCommissionId = @intCommissionId

SELECT TOP 1 
	@intCommissionEarningId = intCommissionEarningId 
FROM tblPRCompanyPreference

/* Check if Commission Earning is setup on Company Preference */
IF (@intCommissionEarningId IS NULL)
	BEGIN
		RAISERROR('Commission Earning ID was not set in Company Configuration.', 11, 1)
		GOTO Process_Exit
	END

/* Check if Entity is Employee Type and is Active */
IF NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployee WHERE intEntityId = @intEntityId AND ysnActive = 1)
	BEGIN
		RAISERROR('Entity is not an active Employee.', 11, 1)
		GOTO Process_Exit
	END

/* Check if Entity Uses the Commission Earning ID */
IF NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intTypeEarningId = @intCommissionEarningId AND intEntityEmployeeId = @intEntityId)
	BEGIN
		RAISERROR('Employee is not setup with the Commission Earning', 11, 1)
		GOTO Process_Exit
	END

/* Insert Commission To Pay Group Detail */
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
	,intCommissionId
	,intSort
	,intConcurrencyId)
SELECT
	EE.intPayGroupId
	,EE.intEntityEmployeeId
	,EE.intEmployeeEarningId
	,EE.intTypeEarningId
	,intDepartmentId = (SELECT TOP 1 intDepartmentId FROM tblPREmployeeDepartment WHERE intEntityEmployeeId = EE.intEntityEmployeeId)
	,intWorkersCompensationId = NULL
	,EE.strCalculationType
	,dblDefaultHours = 0
	,dblHoursToProcess = 0
	,dblAmount = @dblTotalAmount
	,dblTotal = @dblTotalAmount
	,CAST(FLOOR(CAST(@dtmStartDate AS FLOAT)) AS DATETIME)
	,CAST(FLOOR(CAST(@dtmEndDate AS FLOAT)) AS DATETIME)
	,intSource = 5
	,intCommissionId = @intCommissionId
	,1
	,1
FROM
	tblPREmployeeEarning EE
WHERE EE.intTypeEarningId = @intCommissionEarningId
	AND intEntityEmployeeId = @intEntityId

IF (@@ERROR <> 0)
	GOTO Process_Exit
ELSE
	SET @isSuccessful = 1

Process_Exit:

END
GO
