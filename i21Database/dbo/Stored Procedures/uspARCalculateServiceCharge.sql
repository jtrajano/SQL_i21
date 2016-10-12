CREATE PROCEDURE [dbo].[uspARCalculateServiceCharge]
	@customerIds		NVARCHAR(MAX) = '',
	@statusIds	        NVARCHAR(MAX) = '',
	@isRecap			BIT = 0,
	@calculation        NVARCHAR(25) = '',
	@asOfDate			DATE,
	@isIncludeBudget	BIT = 0,
	@arAccountId		INT = 0,
	@scAccountId		INT = 0,
	@currencyId			INT = 0,
	@locationId			INT = 0,
	@batchId			NVARCHAR(100) = NULL OUTPUT,
	@totalAmount		NUMERIC(18,6) = NULL OUTPUT
AS
	CREATE TABLE #tmpCustomers (intEntityId INT, intServiceChargeId INT)	
	DECLARE @tblTypeServiceCharge	  [dbo].[ServiceChargeTableType]
	DECLARE @tempTblTypeServiceCharge [dbo].[ServiceChargeTableType]
	DECLARE @zeroDecimal		NUMERIC(18, 6)
	SET @zeroDecimal = 0.000000

	--VALIDATION
	IF ISNULL(@arAccountId, 0) = 0
		BEGIN
			RAISERROR(120005, 16, 1) 
			RETURN 0
		END

	IF ISNULL(@scAccountId, 0) = 0
		BEGIN
			RAISERROR(120020, 16, 1) 
			RETURN 0
		END

	IF ISNULL(@locationId, 0) = 0
		BEGIN
			RAISERROR(120021, 16, 1) 
			RETURN 0
		END

	IF (@isRecap = 1)
		BEGIN
			SET @batchId = CONVERT(NVARCHAR(100), NEWID())
			SET @totalAmount = @zeroDecimal
		END
	ELSE
		SET @batchId = NULL

	--GET SELECTED CUSTOMERS
	IF (@customerIds = '')
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId) 
			SELECT E.intEntityCustomerId, C.intServiceChargeId FROM vyuARCustomerSearch E
				INNER JOIN tblARCustomer C ON E.intEntityCustomerId = C.intEntityCustomerId
				WHERE E.ysnActive = 1 AND ISNULL(C.intServiceChargeId, 0) <> 0
		END
	ELSE
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId)
			SELECT intEntityCustomerId, intServiceChargeId FROM tblARCustomer WHERE intEntityCustomerId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@customerIds)) AND ISNULL(intServiceChargeId, 0) <> 0
		END

	--GET SELECTED STATUS CODES
	IF (@statusIds <> '')
		BEGIN
			DELETE FROM #tmpCustomers
			WHERE intEntityId NOT IN (SELECT intEntityCustomerId FROM tblARCustomerAccountStatus WHERE intAccountStatusId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@statusIds)))
		END

	--PROCESS EACH CUSTOMER
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomers)
		BEGIN
			DECLARE @entityId			INT,
					@serviceChargeId	INT					

			SELECT TOP 1 @entityId = intEntityId,
						 @serviceChargeId = intServiceChargeId FROM #tmpCustomers
			DELETE FROM @tempTblTypeServiceCharge
			IF (@serviceChargeId > 0)
				BEGIN
					--GET INVOICES DUE
					INSERT INTO @tempTblTypeServiceCharge
					SELECT I.intInvoiceId
						 , NULL
						 , @entityId
						 , I.strInvoiceNumber
						 , NULL
						 , dblAmountDue = I.dblInvoiceTotal
						 , dblTotalAmount = CASE WHEN SC.strCalculationType = 'Percent'
						 						THEN
						 							CASE WHEN SC.dblServiceChargeAPR > 0
						 								THEN
						 									CASE WHEN SC.dblMinimumCharge > ((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																					THEN I.dtmDueDate 
																																					ELSE I.dtmCalculated 
																																				 END, ISNULL(PD.dtmDatePaid, @asOfDate)) * I.dblInvoiceTotal
						 		  								THEN SC.dblMinimumCharge
																ELSE (((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0  AND ISNULL(I.ysnCalculated, 0) = 0
																																	THEN I.dtmDueDate 
 																																	ELSE I.dtmCalculated 
																																END, ISNULL(PD.dtmDatePaid, @asOfDate)) * I.dblInvoiceTotal)
						 									END
						 								ELSE 0
						 							END
						 						ELSE 
						 							SC.dblPercentage
						 					END
					FROM tblARInvoice I
						INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
						INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
						LEFT JOIN (SELECT PD.intInvoiceId
										, dblAmountPaid = SUM(ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblInterest, @zeroDecimal))
										, dtmDatePaid   = MAX(dtmDatePaid)
								   FROM tblARPaymentDetail PD INNER JOIN tblARPayment P 
										ON PD.intPaymentId = P.intPaymentId 
										AND P.ysnPosted = 1 
										AND P.dtmDatePaid <= @asOfDate
								  GROUP BY PD.intInvoiceId
						) AS PD ON PD.intInvoiceId = I.intInvoiceId AND PD.dtmDatePaid > I.dtmDueDate						
					WHERE I.ysnPosted = 1 							  
						AND I.strTransactionType = 'Invoice'
						AND I.strType IN ('Standard', 'Transport Delivery')
						AND I.intEntityCustomerId = @entityId
						AND DATEADD(DAY, SC.intGracePeriod, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END) < @asOfDate
						AND (PD.dtmDatePaid IS NOT NULL AND DATEADD(DAY, SC.intGracePeriod, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END) < PD.dtmDatePaid OR PD.dtmDatePaid IS NULL)

					--GET CUSTOMER BUDGET DUE
					IF ISNULL(@isIncludeBudget, 0) = 1
						BEGIN
							INSERT INTO @tempTblTypeServiceCharge
							SELECT NULL
								 , CB.intCustomerBudgetId
								 , CB.intEntityCustomerId
								 , NULL
								 , 'Customer Budget For: ' + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)     
								 , CB.dblBudgetAmount				
								 , dblTotalAmount = CASE WHEN strCalculationType = 'Percent'
								 						THEN
								 							CASE WHEN dblServiceChargeAPR > 0
								 								THEN
								 									CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId), @asOfDate) * CB.dblBudgetAmount
								 											THEN dblMinimumCharge
								 											ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId), @asOfDate) * CB.dblBudgetAmount)
								 									END
								 								ELSE 0
								 							END
								 						ELSE 
								 							dblPercentage
								 					END
							FROM tblARCustomerBudget CB
								INNER JOIN tblARCustomer C ON CB.intEntityCustomerId = C.intEntityCustomerId	
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
								INNER JOIN [tblEMEntityLocation] EL ON CB.intEntityCustomerId = EL.intEntityId AND EL.ysnDefaultLocation = 1	
							WHERE CB.intEntityCustomerId = @entityId
								AND DATEADD(DAY, SC.intGracePeriod, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 AND ISNULL(CB.ysnCalculated, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId)) < @asOfDate
								AND CB.dblBudgetAmount > @zeroDecimal
								AND (CB.ysnCalculated = 0 OR CB.ysnForgiven = 1)
						END

					IF (@calculation = 'By Invoice')
						BEGIN
							--GET AMOUNT DUE PER INVOICE
							INSERT INTO @tblTypeServiceCharge
							SELECT intInvoiceId
								 , intBudgetId
								 , intEntityCustomerId
								 , strInvoiceNumber
								 , strBudgetDesciption
								 , dblAmountDue
								 , dblTotalAmount 
							FROM @tempTblTypeServiceCharge 
							WHERE ISNULL(dblAmountDue, @zeroDecimal) <> @zeroDecimal 
							  AND ISNULL(dblTotalAmount, @zeroDecimal) <> @zeroDecimal							  
						END
					ELSE
						BEGIN
							--GET AMOUNT DUE PER CUSTOMER
							INSERT INTO @tblTypeServiceCharge
							SELECT NULL
								 , NULL
								 , @entityId
								 , 'Balance As Of: ' + CONVERT(NVARCHAR(50), @asOfDate, 101)
								 , NULL
								 , SUM(dblAmountDue)
								 , SUM(dblTotalAmount) 
							FROM @tempTblTypeServiceCharge 
								GROUP BY intEntityCustomerId 
								HAVING SUM(dblAmountDue) > @zeroDecimal 
								   AND SUM(dblTotalAmount) > @zeroDecimal
						END
					
					IF EXISTS(SELECT TOP 1 1 FROM @tblTypeServiceCharge)
						BEGIN
							SET @totalAmount = @totalAmount + (SELECT SUM(dblTotalAmount) FROM @tblTypeServiceCharge)
							EXEC dbo.uspARInsertInvoiceServiceCharge @isRecap, @batchId, @entityId, @locationId, @currencyId, @arAccountId, @scAccountId, @asOfDate, @tblTypeServiceCharge

							DELETE FROM @tblTypeServiceCharge WHERE intEntityCustomerId = @entityId
						END
					
				END
			DELETE FROM #tmpCustomers WHERE intEntityId = @entityId
		END

	DROP TABLE #tmpCustomers