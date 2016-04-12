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

SELECT TOP 1 @budgetId = intCustomerBudgetId 
FROM tblARCustomer C INNER JOIN tblARCustomerBudget CB 
	ON C.intEntityCustomerId = CB.intEntityCustomerId
WHERE C.intEntityCustomerId = @customerId
AND ISNULL(@datePaid, GETDATE()) BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)

IF ISNULL(@budgetId, 0) > 0 AND @applyToBudget = 1
	BEGIN
		UPDATE tblARCustomerBudget 
			SET dblBudgetAmount = CASE WHEN @Post = 1 THEN dblBudgetAmount - @totalAmount ELSE dblBudgetAmount + @totalAmount END
			  , ysnUsedBudget	= CASE WHEN @Post = 1 
										THEN 1 
										ELSE CASE WHEN dblBudgetAmount + @totalAmount <> (SELECT TOP 1 dblMonthlyBudget FROM tblARCustomer WHERE intEntityCustomerId = tblARCustomerBudget.intEntityCustomerId)
											THEN 1 ELSE 0 END 
								  END
		WHERE intCustomerBudgetId = @budgetId
	END