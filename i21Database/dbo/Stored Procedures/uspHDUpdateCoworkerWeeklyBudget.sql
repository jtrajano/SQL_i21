CREATE PROCEDURE [dbo].[uspHDUpdateCoworkerWeeklyBudget]
(
	@CoworkerGoalId INT
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

BEGIN
		DECLARE @intCoworkerGoalId INT = @CoworkerGoalId
		DECLARE @dblBudgetAmount NUMERIC(18, 6) = 0
		DECLARE @dblUnderAllocatedAmount NUMERIC(18, 6) = 0
		DECLARE @dblZeroBudgetCount INT = 0

		SELECT @dblZeroBudgetCount = COUNT(CoworkerGoalDetail.intCoworkerGoalDetailId)
		FROM tblHDCoworkerGoalDetail CoworkerGoalDetail
		WHERE CoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId AND
			  CoworkerGoalDetail.dblBudget = 0

		SELECT TOP 1 @dblUnderAllocatedAmount = CoworkerGoal.dblUnderAllocated
		FROM tblHDCoworkerGoal CoworkerGoal
		WHERE CoworkerGoal.intCoworkerGoalId = @intCoworkerGoalId

		IF @dblZeroBudgetCount = 0 OR @dblUnderAllocatedAmount = 0
			RETURN

		SET @dblBudgetAmount = @dblUnderAllocatedAmount / @dblZeroBudgetCount

	    UPDATE tblHDCoworkerGoalDetail
		SET  tblHDCoworkerGoalDetail.dblBudget = @dblBudgetAmount
		WHERE tblHDCoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId AND
			  tblHDCoworkerGoalDetail.dblBudget = 0 

	    UPDATE tblHDCoworkerGoal
		SET  tblHDCoworkerGoal.dblUnderAllocated = 0
		WHERE tblHDCoworkerGoal.intCoworkerGoalId = @intCoworkerGoalId
			
END
GO