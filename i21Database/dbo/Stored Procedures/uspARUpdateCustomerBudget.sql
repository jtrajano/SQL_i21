CREATE PROCEDURE [dbo].[uspARUpdateCustomerBudget] 
	@tblPaymentsToUpdateBudget	Id READONLY,
    @Post						BIT = 1
AS

IF(OBJECT_ID('tempdb..#PAYMENTSWITHBUDGET') IS NOT NULL)
BEGIN
    DROP TABLE #PAYMENTSWITHBUDGET
END

IF(OBJECT_ID('tempdb..#CUSTOMERBUDGET') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERBUDGET
END

CREATE TABLE #CUSTOMERBUDGET (
	  intCustomerBudgetId	INT NULL
	, intEntityCustomerId	INT NULL
	, dblBudgetAmount		NUMERIC(18,6) NULL
	, dblAmountPaid         NUMERIC(18,6) NULL
	, dtmBudgetDate         DATETIME NULL
)

--GET PAYMENTS WITH APPLY BUDGET
SELECT intEntityCustomerId
	 , intPaymentId
	 , dblAmountPaid
	 , dtmDatePaid
INTO #PAYMENTSWITHBUDGET
FROM tblARPayment P
INNER JOIN @tblPaymentsToUpdateBudget TB ON P.intPaymentId = TB.intId
WHERE P.ysnApplytoBudget = 1

WHILE EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSWITHBUDGET)
	BEGIN
		DECLARE @intPaymentId			INT = NULL
			  , @intEntityCustomerId	INT = NULL
			  , @dblAmountPaid			NUMERIC(18, 6) = 0
			  , @dblAmountApplied		NUMERIC(18, 6) = 0
			  , @dtmDatePaid			DATETIME = NULL			  

		SELECT TOP 1 @intPaymentId 			= intPaymentId
				   , @intEntityCustomerId 	= intEntityCustomerId
				   , @dblAmountPaid			= (CASE WHEN @Post = 1 THEN 1 ELSE -1 END * dblAmountPaid)
				   , @dtmDatePaid			= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid)))
		FROM #PAYMENTSWITHBUDGET

		--GET CUSTOMER'S BUDGET
		DELETE FROM #CUSTOMERBUDGET
		INSERT INTO #CUSTOMERBUDGET
		SELECT intCustomerBudgetId	= BUDGET.intCustomerBudgetId
			 , intEntityCustomerId  = BUDGET.intEntityCustomerId
			 , dblBudgetAmount		= BUDGET.dblBudgetAmount
	 		 , dblAmountPaid		= BUDGET.dblAmountPaid
	 		 , dtmBudgetDate		= BUDGET.dtmBudgetDate
		FROM tblARCustomerBudget BUDGET
		CROSS APPLY (
			SELECT dtmBudgetDate = CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmBudgetDate)))
			FROM tblARCustomerBudget B
			WHERE @dtmDatePaid BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), B.dtmBudgetDate))) AND DATEADD(DAYOFYEAR, -1, DATEADD(MONTH, 1, CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), B.dtmBudgetDate)))))
			--WHERE @dtmDatePaid BETWEEN B.dtmBudgetDate AND DATEADD(DAYOFYEAR, -1, DATEADD(MONTH, 1, B.dtmBudgetDate))
			AND intEntityCustomerId = @intEntityCustomerId 
		) NEAREST
		WHERE BUDGET.intEntityCustomerId = @intEntityCustomerId
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), BUDGET.dtmBudgetDate))) >= NEAREST.dtmBudgetDate

		--APPLY CUSTOMER'S PAYMENT TO BUDGET LOG
		WHILE EXISTS (SELECT TOP 1 NULL FROM #CUSTOMERBUDGET)
			BEGIN
				DECLARE @intCustomerBudgetId	INT = NULL
					  , @dblBudgetApplied		NUMERIC(18, 6) = 0
					  , @dblBudgetAmount		NUMERIC(18, 6) = 0
					  , @dblAvailableBudget		NUMERIC(18, 6) = 0
				
				IF (@dblAmountPaid = 0)
					RETURN

				SELECT TOP 1 @intCustomerBudgetId 	= intCustomerBudgetId
						   , @dblBudgetApplied	  	= dblAmountPaid
						   , @dblBudgetAmount		= dblBudgetAmount
						   , @dblAvailableBudget	= dblBudgetAmount - dblAmountPaid
				FROM #CUSTOMERBUDGET
				ORDER BY dtmBudgetDate

				--IF PAYMENT AMOUNT > CURRENT BUDGET, GET NEXT BUDGET
				IF (@dblAmountPaid > @dblAvailableBudget) AND @Post = 1
					BEGIN						
						IF (@dblAvailableBudget > 0)
							BEGIN
								--INSERT TO BUDGET LOG
								INSERT INTO tblARPaymentBudget (
									  [intCustomerBudgetId]
									, [intPaymentId]
									, [dblPayment]
									, [intConcurrencyId]
								)
								VALUES (
									  @intCustomerBudgetId
									, @intPaymentId
									, @dblAvailableBudget
									, 1
								)
							END

						SET @dblAmountPaid = @dblAmountPaid - @dblAvailableBudget

						DELETE FROM #CUSTOMERBUDGET WHERE intCustomerBudgetId = @intCustomerBudgetId						
					END
				ELSE IF @Post = 1
					BEGIN
						--INSERT TO BUDGET LOG
						INSERT INTO tblARPaymentBudget (
							  [intCustomerBudgetId]
							, [intPaymentId]
							, [dblPayment]
							, [intConcurrencyId]
						)
						VALUES (
							  @intCustomerBudgetId
							, @intPaymentId
							, @dblAmountPaid
							, 1
						)

						DELETE FROM #CUSTOMERBUDGET WHERE intEntityCustomerId = @intEntityCustomerId 
					END
				ELSE IF @Post = 0
					BEGIN						
						DELETE FROM #CUSTOMERBUDGET WHERE intEntityCustomerId = @intEntityCustomerId
					END
			END

		-- UPDATE BUDGET TABLE
		UPDATE BUDGET
		SET BUDGET.dblAmountPaid = BUDGET.dblAmountPaid + ISNULL(PAYMENTBUDGET.dblAmountApplied, 0)
		  , BUDGET.ysnUsedBudget = CASE WHEN (BUDGET.dblAmountPaid + ISNULL(PAYMENTBUDGET.dblAmountApplied, 0)) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		FROM tblARCustomerBudget BUDGET
		CROSS APPLY (
			SELECT dblAmountApplied = CASE WHEN @Post = 1 THEN 1 ELSE -1 END * SUM(dblPayment)
			FROM tblARPaymentBudget PB
			WHERE PB.intCustomerBudgetId = BUDGET.intCustomerBudgetId
			  AND PB.intPaymentId = @intPaymentId
			GROUP BY PB.intPaymentId
		) PAYMENTBUDGET
		WHERE BUDGET.intEntityCustomerId = @intEntityCustomerId

		IF @Post = 0
			DELETE FROM tblARPaymentBudget WHERE intPaymentId = @intPaymentId

		DELETE FROM #PAYMENTSWITHBUDGET WHERE intPaymentId = @intPaymentId		
	END