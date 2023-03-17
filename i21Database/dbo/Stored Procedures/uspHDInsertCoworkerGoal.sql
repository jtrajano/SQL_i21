CREATE PROCEDURE [dbo].[uspHDInsertCoworkerGoal]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN
			INSERT INTO tblHDCoworkerGoal		
				(
					 [intEntityId]					
					,[strFiscalYear]					
					,[intCurrencyId]					
					,[intUtilizationTargetAnnual]	
					,[intUtilizationTargetWeekly]	
					,[intUtilizationTargetMonthly]	
					,[dblAnnualHurdle]							
					,[dblAnnualBudget]				
					,[intCommissionAccountId]		
					,[intRevenueAccountId]			
					,[strGoal]						
					,[strCommissionType]				
					,[strCommissionRateType]					
					,[dblCommissionRate]
					,[strIncentiveType]				
					,[strIncentiveRateType]
					,[dblIncentiveRate]
					,[dblUnderAllocated]
					,[intReportsToId]				
					,[intConcurrencyId]		
					,[ysnActive]						
					,[ysnCanViewOtherCoworker]		
				)
				SELECT  [intEntityId]					= ImportCoworkerGoal.[intEntityId]					
					   ,[strFiscalYear]					= ImportCoworkerGoal.[strFiscalYear]					
					   ,[intCurrencyId]					= ImportCoworkerGoal.[intCurrencyId]					
					   ,[intUtilizationTargetAnnual]	= ImportCoworkerGoal.[intUtilizationTargetAnnual]	
					   ,[intUtilizationTargetWeekly]	= ImportCoworkerGoal.[intUtilizationTargetWeekly]	
					   ,[intUtilizationTargetMonthly]	= ImportCoworkerGoal.[intUtilizationTargetMonthly]	
					   ,[dblAnnualHurdle]				= ImportCoworkerGoal.[dblAnnualHurdle]							
					   ,[dblAnnualBudget]				= ImportCoworkerGoal.[dblAnnualBudget]				
					   ,[intCommissionAccountId]		= ImportCoworkerGoal.[intCommissionAccountId]		
					   ,[intRevenueAccountId]			= ImportCoworkerGoal.[intRevenueAccountId]			
					   ,[strGoal]						= ImportCoworkerGoal.[strGoal]						
					   ,[strCommissionType]				= ImportCoworkerGoal.[strCommissionType]				
					   ,[strCommissionRateType]			= ImportCoworkerGoal.[strCommissionRateType]					
					   ,[dblCommissionRate]				= ImportCoworkerGoal.[dblCommissionRate]
					   ,[strIncentiveType]				= ImportCoworkerGoal.[strIncentiveType]				
					   ,[strIncentiveRateType]			= ImportCoworkerGoal.[strIncentiveRateType]	
					   ,[dblIncentiveRate]				= ImportCoworkerGoal.[dblIncentiveRate]	
					   ,[dblUnderAllocated]				= ImportCoworkerGoal.[dblUnderAllocated]		
					   ,[intReportsToId]				= ImportCoworkerGoal.[intReportsToId]				
					   ,[intConcurrencyId]				= ImportCoworkerGoal.[intConcurrencyId]				
					   ,[ysnActive]						= ImportCoworkerGoal.[ysnActive]						
					   ,[ysnCanViewOtherCoworker]		= ImportCoworkerGoal.[ysnCanViewOtherCoworker]		
				FROM tblHDImportCoworkerGoal ImportCoworkerGoal

				DECLARE @CoworkerGoalId int

				DECLARE CoworkerGoalLoop CURSOR 
				  LOCAL STATIC READ_ONLY FORWARD_ONLY
				FOR 

				SELECT DISTINCT a.intCoworkerGoalId 
				FROM tblHDCoworkerGoal a
					 LEFT JOIN tblHDCoworkerGoalDetail b
				ON a.intCoworkerGoalId = b.intCoworkerGoalId
				WHERE b.intTimeEntryPeriodDetailId IS NULL

				OPEN CoworkerGoalLoop
				FETCH NEXT FROM CoworkerGoalLoop INTO @CoworkerGoalId
				WHILE @@FETCH_STATUS = 0
				BEGIN 
    
					EXEC uspHDCreateCoworkerGoalDetail @CoworkerGoalId
					EXEC uspHDSyncAgentTimeEntrySummary @CoworkerGoalId, 0, 1, 0

					FETCH NEXT FROM CoworkerGoalLoop INTO @CoworkerGoalId
				END
				CLOSE CoworkerGoalLoop
				DEALLOCATE CoworkerGoalLoop


				DELETE FROM tblHDImportCoworkerGoal

				--EXEC [dbo].[uspHDSyncCoworkerSuperVisor]
END
GO