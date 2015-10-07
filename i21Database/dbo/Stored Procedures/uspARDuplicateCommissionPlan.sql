CREATE PROCEDURE [dbo].[uspARDuplicateCommissionPlan]
	@intCommissionId		INT		
   ,@NewCommissionId		INT = NULL OUTPUT
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
		WHERE intCommissionId = @intCommissionId

	SET @NewCommissionId = SCOPE_IDENTITY()

RETURN