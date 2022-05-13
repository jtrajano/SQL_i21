CREATE PROCEDURE [dbo].[uspPRGetPaycheckEmployeeEarnings]
	@intPaycheckId INT
	,@intYear INT	
	,@intEmployeeId INT
AS
BEGIN

SELECT YEAR (vyuPRPaycheckEarning.dtmPayDate) intYear, 
		DATEPART (QQ, vyuPRPaycheckEarning.dtmPayDate) intQuarter,
       vyuPRPaycheckEarning.intPaycheckEarningId,
       vyuPRPaycheckEarning.intPaycheckId,
       vyuPRPaycheckEarning.intEntityEmployeeId,
       vyuPRPaycheckEarning.dtmPayDate,
       vyuPRPaycheckEarning.intEmployeeEarningId,
       vyuPRPaycheckEarning.strEarning,
       vyuPRPaycheckEarning.strDescription,
       vyuPRPaycheckEarning.intTypeEarningId,
       vyuPRPaycheckEarning.strCalculationType,
       vyuPRPaycheckEarning.intEmployeeDepartmentId,
       vyuPRPaycheckEarning.strDepartment,
       vyuPRPaycheckEarning.dblHours,
       vyuPRPaycheckEarning.dblAmount,
       vyuPRPaycheckEarning.dblTotal,
       vyuPRPaycheckEarning.dblHoursYTD,
       vyuPRPaycheckEarning.dblTotalYTD,
       vyuPRPaycheckEarning.ysnSSTaxable,
       vyuPRPaycheckEarning.ysnMedTaxable,
       vyuPRPaycheckEarning.ysnFITTaxable,
       vyuPRPaycheckEarning.ysnStateTaxable,
       vyuPRPaycheckEarning.ysnLocalTaxable,
       vyuPRPaycheckEarning.intAccountId,
       vyuPRPaycheckEarning.intSort,
       vyuPRPaycheckEarning.intConcurrencyId,
       vyuPRPaycheckEarning.dblGross
  from vyuPRPaycheckEarning 
 where vyuPRPaycheckEarning.ysnVoid = 0
 AND (NULLIF(@intPaycheckId,0) IS NULL OR vyuPRPaycheckEarning.intPaycheckId = @intPaycheckId )
 AND (@intYear IS NULL OR YEAR (vyuPRPaycheckEarning.dtmPayDate) = @intYear )
 AND (@intEmployeeId IS NULL OR vyuPRPaycheckEarning.intEntityEmployeeId = @intEmployeeId )

END
GO