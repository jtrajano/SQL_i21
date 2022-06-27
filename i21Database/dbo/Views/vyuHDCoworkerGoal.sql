﻿CREATE VIEW [dbo].[vyuHDCoworkerGoal]
AS
SELECT   [intCoworkerGoalId]				= CoworkerGoal.[intCoworkerGoalId]			
		,[intEntityId]						= CoworkerGoal.[intEntityId]	
		,[intReportsToId]					= CoworkerGoal.[intReportsToId]
		,[strFiscalYear]					= CoworkerGoal.[strFiscalYear]	
		,[intCurrencyId]					= CoworkerGoal.[intCurrencyId]		
		,[intUtilizationTargetAnnual]		= CoworkerGoal.[intUtilizationTargetAnnual]
		,[intUtilizationTargetWeekly]		= CoworkerGoal.[intUtilizationTargetWeekly]
		,[intUtilizationTargetMonthly]		= CoworkerGoal.[intUtilizationTargetMonthly]
		,[dblAnnualHurdle]					= ISNULL(CoworkerGoal.[dblAnnualHurdle], 0)
		,[strIncentiveType]					= CoworkerGoal.[strIncentiveType]
		,[strIncentiveRateType]				= CoworkerGoal.[strIncentiveRateType]
		,[dblIncentiveRate]					= ISNULL(CoworkerGoal.[dblIncentiveRate], 0)
		,[dblAnnualBudget]					= ISNULL(CoworkerGoal.[dblAnnualBudget], 0)
		,[intCommissionAccountId]			= CoworkerGoal.[intCommissionAccountId]
		,[intRevenueAccountId]				= CoworkerGoal.[intRevenueAccountId]
		,[strGoal]							= CoworkerGoal.[strGoal]
		,[strCommissionType]				= CoworkerGoal.[strCommissionType]
		,[strCommissionRateType]			= CoworkerGoal.[strCommissionRateType]
		,[dblCommissionRate]				= ISNULL(CoworkerGoal.[dblCommissionRate], 0)
		,[dblUnderAllocated]				= ISNULL(CoworkerGoal.[dblUnderAllocated], 0)
		,[ysnActive]						= CoworkerGoal.[ysnActive]
		,[ysnCanViewOtherCoworker]			= CoworkerGoal.[ysnCanViewOtherCoworker]
		,[intConcurrencyId] 				= CoworkerGoal.[intConcurrencyId]
		,[strFullName]						= Entity.[strName]
		,[strReportsTo]						= ReportsTo.[strName]
		,[strCurrency]						= Currency.[strCurrency]
		,[strCommissionAccount]				= GLAccountCommission.strAccountId
		,[strRevenueAccount]				= GLAccountRevenue.strAccountId
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