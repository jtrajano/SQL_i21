CREATE VIEW [dbo].[vyuHDCoworkerGoal]
AS
SELECT   [intCoworkerGoalId]				= CoworkerGoal.[intCoworkerGoalId]			
		,[intEntityId]						= CoworkerGoal.[intEntityId]	
		,[intReportsToId]					= CoworkerGoal.[intReportsToId]
		,[strFiscalYear]					= CoworkerGoal.[strFiscalYear]	
		,[intCurrencyId]					= CoworkerGoal.[intCurrencyId]		
		,[intUtilizationTargetAnnual]		= CoworkerGoal.[intUtilizationTargetAnnual]
		,[intUtilizationTargetWeekly]		= CoworkerGoal.[intUtilizationTargetWeekly]
		,[intUtilizationTargetMonthly]		= CoworkerGoal.[intUtilizationTargetMonthly]
		,[dblAnnualHurdle]					= CoworkerGoal.[dblAnnualHurdle]
		,[dblIncentiveRate]					= CoworkerGoal.[dblIncentiveRate]
		,[dblAnnualBudget]					= CoworkerGoal.[dblAnnualBudget]
		,[intCommissionAccountId]			= CoworkerGoal.[intCommissionAccountId]
		,[intRevenueAccountId]				= CoworkerGoal.[intRevenueAccountId]
		,[strGoal]							= CoworkerGoal.[strGoal]
		,[strCommissionType]				= CoworkerGoal.[strCommissionType]
		,[strRateType]						= CoworkerGoal.[strRateType]
		,[intCommissionRate]				= CoworkerGoal.[intCommissionRate]
		,[intConcurrencyId] 				= CoworkerGoal.[intConcurrencyId]
		,[strFullName]						= Entity.[strName]
		,[strReportsTo]						= ReportsTo.[strName]
		,[strCurrency]						= Currency.[strCurrency]
		,[strCommissionAccount]				= GLAccountCommission.strDescription
		,[strRevenueAccount]				= GLAccountRevenue.strDescription
FROM tblHDCoworkerGoal CoworkerGoal
		INNER JOIN tblEMEntity Entity
ON Entity.intEntityId = CoworkerGoal.intEntityId
		LEFT JOIN tblEMEntity ReportsTo
ON ReportsTo.intEntityId = CoworkerGoal.intReportsToId
		INNER JOIN tblSMCurrency Currency
ON Currency.intCurrencyID = CoworkerGoal.intCurrencyId
		LEFT JOIN tblGLAccount GLAccountCommission
ON GLAccountCommission.intAccountId = CoworkerGoal.intCommissionAccountId
		LEFT JOIN tblGLAccount GLAccountRevenue
ON GLAccountRevenue.intAccountId = CoworkerGoal.intRevenueAccountId

		
GO 