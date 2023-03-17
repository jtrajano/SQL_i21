CREATE PROCEDURE [dbo].[uspHDSyncAgentTimeEntrySummary]
(
	 @CoworkerGoalId INT
	,@TimeEntryPeriodDetailId INT
	,@NewCoworkerGoal BIT = 0
	,@SyncAllColumn BIT = 1
	,@UpdateCoworkerWeeklyBudget BIT = 1
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

BEGIN
	      DECLARE	 @intEntityId INT = 0
					,@intCoworkerGoalId INT 
					,@intTimeEntryPeriodDetailId INT 
					,@strFiscalYear NVARCHAR(50)
					,@ysnNewCoworkerGoal BIT 
					,@ysnSyncAllColumn  BIT 
					,@ysnUpdateCoworkerWeeklyBudget  BIT 
				
		SET	@intCoworkerGoalId						 = @CoworkerGoalId
		SET @intTimeEntryPeriodDetailId				 = @TimeEntryPeriodDetailId				
		SET @ysnNewCoworkerGoal						 = @NewCoworkerGoal				
		SET @ysnSyncAllColumn						 = @SyncAllColumn				
		SET @ysnUpdateCoworkerWeeklyBudget			 = @UpdateCoworkerWeeklyBudget				
				
		--FROM COWORKER GOAL
		IF @intTimeEntryPeriodDetailId = 0
		BEGIN

			IF @ysnUpdateCoworkerWeeklyBudget = CONVERT(BIT, 1)
			BEGIN		
				EXEC uspHDUpdateCoworkerWeeklyBudget @intCoworkerGoalId
			END

			SELECT TOP 1  @intEntityId = CoworkerGoal.intEntityId
						 ,@strFiscalYear = CoworkerGoal.strFiscalYear
			FROM tblHDCoworkerGoal CoworkerGoal
					INNER JOIN vyuHDAgentDetail AgentDetail
			ON CoworkerGoal.intEntityId = AgentDetail.intEntityId
			WHERE intCoworkerGoalId = @intCoworkerGoalId

			--Loop All Period
			DECLARE @PeriodDetailId int

			DECLARE PeriodDetailLoop CURSOR 
			  LOCAL STATIC READ_ONLY FORWARD_ONLY
			FOR 

			SELECT CoworkerGoalDetail.intTimeEntryPeriodDetailId
			FROM tblHDCoworkerGoalDetail CoworkerGoalDetail
			WHERE CoworkerGoalDetail.intCoworkerGoalId = @intCoworkerGoalId
			GROUP BY CoworkerGoalDetail.intTimeEntryPeriodDetailId

			OPEN PeriodDetailLoop
			FETCH NEXT FROM PeriodDetailLoop INTO @PeriodDetailId
			WHILE @@FETCH_STATUS = 0
			BEGIN 

				EXEC [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary] @intEntityId, @PeriodDetailId, 0, @ysnNewCoworkerGoal, @ysnSyncAllColumn

				FETCH NEXT FROM PeriodDetailLoop INTO @PeriodDetailId
			END
			CLOSE PeriodDetailLoop
			DEALLOCATE PeriodDetailLoop


		END
		ELSE
		--FROM Time Entry Period
		BEGIN

			DECLARE @EntityId INT = 0

			DECLARE EmployeeLoop CURSOR 
			  LOCAL STATIC READ_ONLY FORWARD_ONLY
			FOR 

			SELECT Agent.intEntityId
			FROM vyuHDAgentDetail Agent
			WHERE Agent.ysnDisabled = CONVERT(BIT, 0)
			AND Agent.intEntityId IS NOT NULL
			GROUP BY Agent.intEntityId

			OPEN EmployeeLoop
			FETCH NEXT FROM EmployeeLoop INTO @EntityId
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				EXEC [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary] @EntityId, @intTimeEntryPeriodDetailId, 0, @ysnNewCoworkerGoal, @ysnSyncAllColumn

				FETCH NEXT FROM EmployeeLoop INTO @EntityId
			END
			CLOSE EmployeeLoop
			DEALLOCATE EmployeeLoop

		END
END
GO