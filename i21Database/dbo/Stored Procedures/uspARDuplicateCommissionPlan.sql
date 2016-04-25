CREATE PROCEDURE [dbo].[uspARDuplicateCommissionPlan]
	@intCommissionPlanId		INT		
   ,@NewCommissionPlanId		INT = NULL OUTPUT
AS
	INSERT INTO tblARCommissionPlan
		([strCommissionPlanName]
		,[strDescription]
		,[strBasis]
		,[strEntities]
	    ,[strCalculationType]
	    ,[strHurdleFrequency]
	    ,[strHurdleType]
	    ,[dblHurdle]
	    ,[dblCalculationAmount]
	    ,[dtmStartDate]
	    ,[dtmEndDate]
	    ,[ysnPaymentRequired]
	    ,[ysnActive]
		,[intConcurrencyId])
	SELECT 
		 'DUP:' + [strCommissionPlanName]
		,[strDescription]
		,[strBasis]
		,[strEntities]
	    ,[strCalculationType]
	    ,[strHurdleFrequency]
	    ,[strHurdleType]
	    ,[dblHurdle]
	    ,[dblCalculationAmount]
	    ,[dtmStartDate]
	    ,[dtmEndDate]
	    ,[ysnPaymentRequired]
	    ,[ysnActive]
		,1
	FROM tblARCommissionPlan
		WHERE intCommissionPlanId = @intCommissionPlanId

	SET @NewCommissionPlanId = SCOPE_IDENTITY()

RETURN