CREATE PROCEDURE [dbo].[uspARDuplicateCommissionPlan]
	@intCommissionPlanId		INT		
   ,@NewCommissionPlanId		INT = NULL OUTPUT
AS
	INSERT INTO tblARCommissionPlan
		([strCommissionPlanName]
		,[strDescription]
		,[strBasis]
		,[strHourType]
		,[strUnitType]
		,[strAccounts]
		,[strSalespersons]
		,[strAgents]
		,[strDrivers]
		,[strItemCategories]
		,[strItems]
		,[intApprovalListId]
	    ,[strCalculationType]
	    ,[strHurdleFrequency]
	    ,[strHurdleType]
	    ,[dblHurdle]
	    ,[dblCalculationAmount]
	    ,[dtmStartDate]
	    ,[dtmEndDate]
	    ,[ysnPaymentRequired]		
	    ,[ysnActive]
		,[ysnMarginalSales]
		,[intCommissionAccountId]
		,[intConcurrencyId])
	SELECT 
		 'DUP:' + [strCommissionPlanName]
		,[strDescription]
		,[strBasis]
		,[strHourType]
		,[strUnitType]
		,[strAccounts]
		,[strSalespersons]
		,[strAgents]
		,[strDrivers]
		,[strItemCategories]
		,[strItems]
		,[intApprovalListId]
	    ,[strCalculationType]
	    ,[strHurdleFrequency]
	    ,[strHurdleType]
	    ,[dblHurdle]
	    ,[dblCalculationAmount]
	    ,[dtmStartDate]
	    ,[dtmEndDate]
	    ,[ysnPaymentRequired]
	    ,[ysnActive]
		,[ysnMarginalSales]
		,[intCommissionAccountId]
		,1
	FROM tblARCommissionPlan
		WHERE intCommissionPlanId = @intCommissionPlanId

	SET @NewCommissionPlanId = SCOPE_IDENTITY()

RETURN