CREATE FUNCTION [dbo].[fnARGetCustomerBudget]
(
	@entityCustomerId INT,
	@budgetDate	      DATETIME
)
RETURNS NUMERIC(18,6) AS
BEGIN
	DECLARE @customerBudget NUMERIC(18,6)

	SELECT @customerBudget = dblBudgetAmount 
	FROM tblARCustomer C INNER JOIN tblARCustomerBudget CB 
		ON C.intEntityCustomerId = CB.intEntityCustomerId
	WHERE C.intEntityCustomerId = @entityCustomerId
	AND (ISNULL(@budgetDate, GETDATE()) >= CB.dtmBudgetDate AND ISNULL(@budgetDate, GETDATE()) < DATEADD(MONTH, 1, CB.dtmBudgetDate))

	RETURN ISNULL(@customerBudget, 0.000000)
END