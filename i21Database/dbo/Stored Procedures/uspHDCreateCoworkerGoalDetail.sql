﻿CREATE PROCEDURE [dbo].[uspHDCreateCoworkerGoalDetail]
(
	 @CoworkerGoalId INT
)
AS
BEGIN
	DECLARE   @intTimeEntryPeriodDetail INT = NULL,
			  @strFiscalYear NVARCHAR(10),
			  @ysnActive BIT = 0

	SELECT TOP 1  @strFiscalYear = strFiscalYear
				 ,@ysnActive     = ysnActive
	FROM tblHDCoworkerGoal
	WHERE intCoworkerGoalId = @CoworkerGoalId

	SELECT TOP 1 @intTimeEntryPeriodDetail = intTimeEntryPeriodId
	FROM tblHDTimeEntryPeriod
	WHERE strFiscalYear = @strFiscalYear

	IF @intTimeEntryPeriodDetail IS NULL
	BEGIN
		DELETE FROM tblHDCoworkerGoalDetail
		WHERE intCoworkerGoalId = @CoworkerGoalId

		RETURN
	END

	IF @intTimeEntryPeriodDetail IS NOT NULL AND
	EXISTS(
			SELECT TOP 1 ''
			FROM tblHDCoworkerGoalDetail a
			WHERE a.intCoworkerGoalId = @CoworkerGoalId 					
	)
	BEGIN

		DELETE FROM tblHDCoworkerGoalDetail
		WHERE intCoworkerGoalId = @CoworkerGoalId

	END

	INSERT INTO tblHDCoworkerGoalDetail
	(
		 [intCoworkerGoalId]
		,[intBillingPeriod]
		,[strBillingPeriodName]
		,[dblBudget]
		,[intUtilization]
		,[intTimeEntryPeriodDetailId]
		,[ysnActive]
	)
	SELECT  [intCoworkerGoalId]			 = @CoworkerGoalId
		   ,[intBillingPeriod]			 = TimeEntryPeriodDetail.intBillingPeriod
		   ,[strBillingPeriodName]		 = TimeEntryPeriodDetail.strBillingPeriodName
		   ,[dblBudget]					 = 0
		   ,[intUtilization]			 = 0
		   ,[intTimeEntryPeriodDetailId] = TimeEntryPeriodDetail.[intTimeEntryPeriodDetailId]
		   ,[ysnActive]					 = CONVERT(BIT, @ysnActive)
    FROM tblHDTimeEntryPeriodDetail TimeEntryPeriodDetail
	WHERE intTimeEntryPeriodId = @intTimeEntryPeriodDetail
END

GO