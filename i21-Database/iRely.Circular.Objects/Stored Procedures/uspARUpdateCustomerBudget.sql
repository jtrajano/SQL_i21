CREATE PROCEDURE [dbo].[uspARUpdateCustomerBudget] 
	@PaymentId	INT,
    @Post		BIT = 1
AS

DECLARE @customerId			INT
	  , @totalAmount		NUMERIC(18,6)
	  , @applyToBudget		BIT
	  , @datePaid			DATETIME
	  , @budgetId			INT
	  , @i					INT = 0
	  , @dblAmountPaid		DECIMAL(18,6)
	  , @dtmBudgetBeginDate DATETIME
	  , @dtmBudgetEndDate	DATETIME

SELECT TOP 1
	   @customerId			= arp.intEntityCustomerId
     , @totalAmount			= ISNULL(arp.dblAmountPaid, 0.000000)
	 , @applyToBudget		= ISNULL(arp.ysnApplytoBudget, 0)
	 , @datePaid			= arp.dtmDatePaid
	 , @dtmBudgetBeginDate	= arc.dtmBudgetBeginDate
FROM tblARPayment arp
INNER JOIN tblARCustomer arc
	ON arc.intEntityId = arp.intEntityCustomerId
WHERE intPaymentId = @PaymentId

SELECT TOP 1 @dtmBudgetEndDate  = DATEADD(DAY,1,dtmBudgetDate) FROM tblARCustomerBudget WHERE intEntityCustomerId = @customerId ORDER BY dtmBudgetDate DESC
SELECT ROW_NUMBER() OVER (ORDER BY intCustomerBudgetId) as CNT,* INTO #temp_ARCustomerBudget
FROM tblARCustomerBudget 
WHERE intEntityCustomerId = @customerId 

DECLARE @amount DECIMAL(18,6) = @totalAmount;
IF @applyToBudget = 1
BEGIN
	IF @Post = 1
		BEGIN
			WHILE(@i < (SELECT COUNT(1) FROM #temp_ARCustomerBudget))
				BEGIN
					SET @i = @i +1;
					SELECT @dblAmountPaid = 
							CASE WHEN dblAmountPaid != dblBudgetAmount
								THEN
										CASE WHEN @amount >= dblBudgetAmount
											THEN 
												dblBudgetAmount - dblAmountPaid
											ELSE
												@amount - (dblAmountPaid)
										END
								END,
							@amount = @amount - ISNULL(@dblAmountPaid,0)
					FROM #temp_ARCustomerBudget WHERE CNT = @i
	
					UPDATE #temp_ARCustomerBudget
					SET dblAmountPaid = CASE WHEN dblAmountPaid != dblBudgetAmount
												THEN 
												@dblAmountPaid
												ELSE 
												dblAmountPaid
												END
					WHERE CNT = @i

					UPDATE t
					SET t.dblAmountPaid = tmp.dblAmountPaid
					FROM tblARCustomerBudget t
					INNER JOIN #temp_ARCustomerBudget tmp
						ON tmp.intCustomerBudgetId = t.intCustomerBudgetId
				END
			
			DROP TABLE #temp_ARCustomerBudget
		END
	ELSE
		BEGIN
			SET @dblAmountPaid = 0;
			IF(@amount > (SELECT SUM(dblAmountPaid) FROM tblARCustomerBudget WHERE intEntityCustomerId = @customerId))
				BEGIN
					UPDATE tblARCustomerBudget
					SET dblAmountPaid = 0.000000
					WHERE intEntityCustomerId = @customerId
				END
			ELSE
				BEGIN
						WHILE(@i < (SELECT COUNT(1) FROM #temp_ARCustomerBudget))
						BEGIN
								SET @i = @i +1

								SELECT @dblAmountPaid = 
										(CASE WHEN dblAmountPaid = dblBudgetAmount
											THEN
												dblBudgetAmount
											ELSE
												CASE WHEN dblAmountPaid < dblBudgetAmount
													THEN
														dblBudgetAmount - dblAmountPaid
													END
											END),
										@amount = CASE WHEN @amount > @dblAmountPaid THEN @amount - @dblAmountPaid ELSE @amount END
								FROM #temp_ARCustomerBudget WHERE CNT = @i

								UPDATE t
								SET t.dblAmountPaid = t.dblBudgetAmount - @dblAmountPaid
								FROM tblARCustomerBudget t
								INNER JOIN #temp_ARCustomerBudget tmp
									ON t.intEntityCustomerId = tmp.intEntityCustomerId
									AND t.intCustomerBudgetId = tmp.intCustomerBudgetId
								WHERE tmp.CNT = @i

								SELECT @amount,@dblAmountPaid
						END
				END
		END	
END