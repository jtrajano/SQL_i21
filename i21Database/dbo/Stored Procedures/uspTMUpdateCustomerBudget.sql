CREATE PROCEDURE [dbo].[uspTMUpdateCustomerBudget]
	@EntityId INT
AS
BEGIN	
	DECLARE @strBudgetAmountForBudgetBilling NVARCHAR(50)
	DECLARE @intEntityCustomerId INT

	SELECT 
		intEntityCustomerId = C.intCustomerNumber
		,dblBudget = SUM(ISNULL(A.dblEstimatedBudget,0.0))
		INTO #tmpCustomerBudget
	FROM tblTMBudgetCalculationSite A
	INNER JOIN tblTMSite B
		ON A.intSiteId = B.intSiteID
	INNER JOIN tblTMCustomer C
		ON C.intCustomerID = B.intCustomerID
	GROUP BY C.intCustomerNumber
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerBudget)
	BEGIN
		SELECT TOP 1 
			@strBudgetAmountForBudgetBilling = CAST(dblBudget AS NVARCHAR(50))
			,@intEntityCustomerId = intEntityCustomerId
		FROM #tmpCustomerBudget

		EXEC uspEMUpdateCustomerTable 'dblBudgetAmountForBudgetBilling', @strBudgetAmountForBudgetBilling, @intEntityCustomerId, @EntityId

		DELETE FROM #tmpCustomerBudget WHERE intEntityCustomerId = @intEntityCustomerId
	END
	
END
GO