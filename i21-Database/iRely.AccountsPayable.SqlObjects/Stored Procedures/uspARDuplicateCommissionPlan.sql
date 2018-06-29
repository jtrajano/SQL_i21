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

	IF ISNULL(@NewCommissionPlanId, 0) <> 0
		BEGIN
			INSERT INTO tblARCommissionPlanAccount (
				  [intCommissionPlanId]
				, [intAccountId]
			) 
			SELECT [intCommissionPlanId] = @NewCommissionPlanId
				 , [intAccountId] = [intAccountId]
			FROM tblARCommissionPlanAccount
			WHERE [intCommissionPlanId] = @intCommissionPlanId

			INSERT INTO tblARCommissionPlanAgent (
				  [intCommissionPlanId]
				, [intEntityAgentId]
			)
			SELECT [intCommissionPlanId] = @NewCommissionPlanId
				 , [intEntityAgentId] = [intEntityAgentId]
			FROM tblARCommissionPlanAgent
			WHERE [intCommissionPlanId] = @intCommissionPlanId

			INSERT INTO tblARCommissionPlanItem (
				  [intCommissionPlanId]
				, [intItemId]
			)
			SELECT [intCommissionPlanId] = @NewCommissionPlanId
			     , [intItemId] = [intItemId]
			FROM tblARCommissionPlanItem
			WHERE [intCommissionPlanId] = @intCommissionPlanId

			INSERT INTO tblARCommissionPlanItemCategory (
				  [intCommissionPlanId]
				, [intItemCategoryId]
			)
			SELECT [intCommissionPlanId] = @NewCommissionPlanId
			     , [intItemCategoryId] = [intItemCategoryId]
			FROM tblARCommissionPlanItemCategory
			WHERE [intCommissionPlanId] = @intCommissionPlanId

			INSERT INTO tblARCommissionPlanSalesperson (
				  [intCommissionPlanId]
				, [intEntitySalespersonId]
			)
			SELECT [intCommissionPlanId] = @NewCommissionPlanId
			     , [intEntitySalespersonId] = [intEntitySalespersonId]
			FROM tblARCommissionPlanSalesperson
			WHERE [intCommissionPlanId] = @intCommissionPlanId
		END

RETURN