CREATE PROCEDURE [dbo].[uspARUpdateCustomerBudget]
	@PaymentId	INT,
    @Post		BIT = 1
AS

DECLARE @customerId		INT
	  , @totalAmount	NUMERIC(18,6)
	  , @applyToBudget	BIT
	  , @datePaid		DATETIME
	  , @budgetId		INT

SELECT TOP 1
	   @customerId		= intEntityCustomerId
     , @totalAmount		= ISNULL(dblAmountPaid, 0.000000)
	 , @applyToBudget	= ISNULL(ysnApplytoBudget, 0)
	 , @datePaid		= dtmDatePaid
FROM tblARPayment 
WHERE intPaymentId = @PaymentId

IF @applyToBudget = 1
BEGIN
	IF @Post = 1
		BEGIN
			SELECT TOP 1 
				@budgetId		= intCustomerBudgetId
			FROM
				tblARCustomer C 
			INNER JOIN 
				tblARCustomerBudget CB 
					ON C.[intEntityId] = CB.intEntityCustomerId
			WHERE 
				C.[intEntityId] = @customerId
				AND (CB.ysnUsedBudget = 0 OR CB.dblBudgetAmount <> 0.0000000)
				AND (ISNULL(@datePaid, GETDATE()) >= CB.dtmBudgetDate AND ISNULL(@datePaid, GETDATE()) < DATEADD(MONTH, 1, CB.dtmBudgetDate))
			ORDER BY
				CB.dtmBudgetDate
		END
	ELSE
		BEGIN
			SELECT TOP 1 
				@budgetId		= intCustomerBudgetId
			FROM
				tblARCustomer C 
			INNER JOIN 
				tblARCustomerBudget CB 
					ON C.[intEntityId] = CB.intEntityCustomerId
			WHERE 
				C.[intEntityId] = @customerId
				AND CB.dblAmountPaid <> 0.0000000
				AND (ISNULL(@datePaid, GETDATE()) >= CB.dtmBudgetDate AND ISNULL(@datePaid, GETDATE()) < DATEADD(MONTH, 1, CB.dtmBudgetDate))
			ORDER BY
				CB.dtmBudgetDate DESC
		END

	IF ISNULL(@budgetId, 0) > 0
		BEGIN
			UPDATE tblARCustomerBudget 
			SET dblAmountPaid	= CASE WHEN @Post = 1 THEN dblAmountPaid + @totalAmount ELSE dblAmountPaid - @totalAmount END
				, ysnUsedBudget	= CASE WHEN @Post = 1 
											THEN 1 
										ELSE CASE WHEN dblAmountPaid - @totalAmount > 0 THEN 1 ELSE 0 END 
									END
			WHERE intCustomerBudgetId = @budgetId
		END
END
