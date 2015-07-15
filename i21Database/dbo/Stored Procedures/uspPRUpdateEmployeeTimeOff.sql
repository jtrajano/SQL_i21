CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOff]
	@intTypeTimeOffId INT
AS
BEGIN

	UPDATE tblPREmployeeTimeOff
	SET dtmEligible = TimeOff.dtmEligible
		,dblRate = TimeOff.dblRate
		,dblPerPeriod = TimeOff.dblPerPeriod
		,strPeriod = TimeOff.strPeriod
		,strAwardPeriod = TimeOff.strAwardPeriod
		,dblMaxEarned = TimeOff.dblMaxEarned
		,dblMaxCarryover = TimeOff.dblMaxCarryover
	FROM tblPRTypeTimeOff TimeOff INNER JOIN tblPREmployeeTimeOff EmpTimeOff
		ON TimeOff.intTypeTimeOffId = EmpTimeOff.intTypeTimeOffId
	WHERE EmpTimeOff.intTypeTimeOffId = @intTypeTimeOffId

END
GO