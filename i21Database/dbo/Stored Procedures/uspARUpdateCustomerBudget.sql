CREATE PROCEDURE [dbo].[uspARUpdateCustomerBudget]
	@PaymentId	INT,
    @Post		BIT = 1
AS

DECLARE @customerId		INT
	  , @totalAmount	NUMERIC(18,6)
	  , @budgetAmount	NUMERIC(18,6)
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

	WHILE(@totalAmount > 0)
	BEGIN
		IF @Post = 1
			BEGIN
				SELECT TOP 1 
					@budgetId		= intCustomerBudgetId
					,@budgetAmount	= CASE WHEN @totalAmount >= CB.dblBudgetAmount THEN CB.dblBudgetAmount ELSE CB.dblBudgetAmount -@totalAmount END
				FROM
					tblARCustomer C 
				INNER JOIN 
					tblARCustomerBudget CB 
						ON C.intEntityCustomerId = CB.intEntityCustomerId
				WHERE 
					C.intEntityCustomerId = @customerId
					AND (CB.ysnUsedBudget = 0 OR CB.dblBudgetAmount <> 0.0000000)
				ORDER BY
					CB.dtmBudgetDate
			END
		ELSE
			BEGIN
				SELECT TOP 1 
					@budgetId		= intCustomerBudgetId
					,@budgetAmount	= CASE WHEN @totalAmount >= CB.dblAmountPaid THEN CB.dblAmountPaid  ELSE CB.dblAmountPaid - @totalAmount END 
				FROM
					tblARCustomer C 
				INNER JOIN 
					tblARCustomerBudget CB 
						ON C.intEntityCustomerId = CB.intEntityCustomerId
				WHERE 
					C.intEntityCustomerId = @customerId
					AND CB.dblAmountPaid <> 0.0000000
				ORDER BY
					CB.dtmBudgetDate DESC
			END

		IF ISNULL(@budgetId, 0) > 0
			BEGIN
				UPDATE tblARCustomerBudget 
				SET
					dblBudgetAmount	= CASE WHEN @Post = 1 THEN dblBudgetAmount - @budgetAmount ELSE dblBudgetAmount + @budgetAmount END
					,dblAmountPaid	= CASE WHEN @Post = 1 THEN dblAmountPaid + @budgetAmount ELSE dblAmountPaid - @budgetAmount END
					,ysnUsedBudget	= CASE WHEN (CASE WHEN @Post = 1 THEN dblBudgetAmount - @budgetAmount ELSE dblBudgetAmount + @budgetAmount END) = 0 THEN 1 ELSE 0 END
				WHERE intCustomerBudgetId = @budgetId
			END

		SET @totalAmount = @totalAmount - @budgetAmount
	END
	

END
