CREATE PROCEDURE [dbo].[uspHDInsertCoworkerGoal]
AS
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
					,[dblIncentiveRate]				
					,[dblAnnualBudget]				
					,[intCommissionAccountId]		
					,[intRevenueAccountId]			
					,[strGoal]						
					,[strCommissionType]				
					,[strRateType]					
					,[intCommissionRate]				
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
					   ,[dblIncentiveRate]				= ImportCoworkerGoal.[dblIncentiveRate]				
					   ,[dblAnnualBudget]				= ImportCoworkerGoal.[dblAnnualBudget]				
					   ,[intCommissionAccountId]		= ImportCoworkerGoal.[intCommissionAccountId]		
					   ,[intRevenueAccountId]			= ImportCoworkerGoal.[intRevenueAccountId]			
					   ,[strGoal]						= ImportCoworkerGoal.[strGoal]						
					   ,[strCommissionType]				= ImportCoworkerGoal.[strCommissionType]				
					   ,[strRateType]					= ImportCoworkerGoal.[strRateType]					
					   ,[intCommissionRate]				= ImportCoworkerGoal.[intCommissionRate]				
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

					FETCH NEXT FROM CoworkerGoalLoop INTO @CoworkerGoalId
				END
				CLOSE CoworkerGoalLoop
				DEALLOCATE CoworkerGoalLoop


				DELETE FROM tblHDImportCoworkerGoal
END
GO