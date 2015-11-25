﻿CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTimeOff]
	@intTypeTimeOffId INT,
	@intEntityEmployeeId INT = NULL
AS
BEGIN

	--Get Employees with specified Time Off
	SELECT E.intEntityEmployeeId, DATEDIFF(YEAR, ISNULL(E.dtmOriginalDateHired, GETDATE()), GETDATE()) intYearsOfService
	INTO #tmpEmployees
	FROM tblPREmployee E LEFT JOIN tblPREmployeeTimeOff T
	ON E.intEntityEmployeeId = T.intEntityEmployeeId
	WHERE E.intEntityEmployeeId = ISNULL(@intEntityEmployeeId, E.intEntityEmployeeId)
		 AND T.intTypeTimeOffId = @intTypeTimeOffId

	DECLARE @intEmployeeId INT
	DECLARE @intYearsOfService INT

	--Step 1: Update each Employee Time Off
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEmployees)
	BEGIN
		SELECT TOP 1 
			@intEmployeeId = intEntityEmployeeId
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
			,D.dblMaxCarryover FROM 
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

		DELETE FROM #tmpEmployees WHERE intEntityEmployeeId = @intEmployeeId
	END

END
GO

