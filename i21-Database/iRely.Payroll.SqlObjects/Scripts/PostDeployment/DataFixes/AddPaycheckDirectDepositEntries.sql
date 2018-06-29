/*
* Adds corresponding entries to tblPRPaycheckDirectDeposit table  
* for all Direct Deposit Paychecks that are already posted
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[uspPRPaycheckEFTDistribution]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  
EXEC ('
	DECLARE @intPaycheckId INT

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID(''tempdb..#tmpPaychecks'')) DROP TABLE #tmpPaychecks

	SELECT DISTINCT intPaycheckId 
	INTO #tmpPaychecks
	FROM tblPRPaycheck WHERE ysnDirectDeposit = 1 
		AND ysnPosted = 1 AND intPaycheckId NOT IN (SELECT intPaycheckId FROM tblPRPaycheckDirectDeposit)
		AND intPaycheckId NOT IN (
			SELECT intPaycheckId FROM tblPRPaycheck WHERE intEntityEmployeeId IN (
				SELECT intEntityId FROM tblPREmployee 
				WHERE intEntityId NOT IN (SELECT DISTINCT intEntityId FROM tblEMEntityEFTInformation)))

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPaychecks)
	BEGIN
		SELECT TOP 1 @intPaycheckId = intPaycheckId FROM #tmpPaychecks

		EXEC uspPRPaycheckEFTDistribution @intPaycheckId

		DELETE FROM #tmpPaychecks WHERE intPaycheckId = @intPaycheckId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID(''tempdb..#tmpPaychecks'')) DROP TABLE #tmpPaychecks
')

END