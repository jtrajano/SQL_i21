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
		DECLARE   @intCoworkerGoalId INT = @CoworkerGoalId
				 ,@dblBudgetAmount NUMERIC(18, 6) = 0
				 ,@dblUnderAllocatedAmount NUMERIC(18, 6) = 0
				 ,@dblZeroBudgetCount INT = 0

		SELECT @dblZeroBudgetCount = COUNT(CoworkerGoalDetail.intCoworkerGoalDetailId)
		FROM tblHDCoworkerGoalDetail CoworkerGoalDetail
		WHERE CoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId AND
			  CoworkerGoalDetail.dblBudget = 0

		SELECT TOP 1 @dblUnderAllocatedAmount = CoworkerGoal.dblUnderAllocated
		FROM tblHDCoworkerGoal CoworkerGoal
		WHERE CoworkerGoal.intCoworkerGoalId = @intCoworkerGoalId

		IF @dblZeroBudgetCount = 0 OR @dblUnderAllocatedAmount = 0
			RETURN

		--SET @dblBudgetAmount = @dblUnderAllocatedAmount / @dblZeroBudgetCount

		--Distribution Logic
		DECLARE  @CurrentUnAllocatedAmount NUMERIC(18,6) = @dblUnderAllocatedAmount
				,@CurrentCoworkerGoalDetailId INT = 0
		WHILE @dblZeroBudgetCount > 0
		BEGIN
			SELECT TOP 1 @CurrentCoworkerGoalDetailId = CoworkerGoalDetail.intCoworkerGoalDetailId
			FROM tblHDCoworkerGoalDetail CoworkerGoalDetail
			WHERE CoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId AND
			      CoworkerGoalDetail.dblBudget = 0

			SET @CurrentUnAllocatedAmount = @CurrentUnAllocatedAmount - @dblBudgetAmount

			IF @dblZeroBudgetCount = 1
			BEGIN
				SET @dblBudgetAmount =  @CurrentUnAllocatedAmount
			END
			ELSE
			BEGIN			
				SET @dblBudgetAmount = ROUND(@CurrentUnAllocatedAmount / @dblZeroBudgetCount, 2)
			END

			UPDATE tblHDCoworkerGoalDetail
			SET dblBudget = @dblBudgetAmount
			WHERE intCoworkerGoalDetailId = @CurrentCoworkerGoalDetailId

			SET @dblZeroBudgetCount = @dblZeroBudgetCount - 1		

		END

	    --UPDATE tblHDCoworkerGoalDetail
		--SET  tblHDCoworkerGoalDetail.dblBudget = @dblBudgetAmount
		--WHERE tblHDCoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId AND
		--	  tblHDCoworkerGoalDetail.dblBudget = 0 

	    UPDATE tblHDCoworkerGoal
		SET  tblHDCoworkerGoal.dblUnderAllocated = 0
		WHERE tblHDCoworkerGoal.intCoworkerGoalId = @intCoworkerGoalId
			
END
GO