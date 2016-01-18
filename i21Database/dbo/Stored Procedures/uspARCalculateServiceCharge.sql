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
	
	--VALIDATION
	IF (@arAccountId = 0 OR @arAccountId IS NULL)
		BEGIN
			RAISERROR('There is no setup for AR Account in the Company Preference.', 11, 1) 
			RETURN 0
		END

	IF (@scAccountId = 0 OR @scAccountId IS NULL)
		BEGIN
			RAISERROR('There is no setup for Service Charge Account in the Company Preference.', 11, 1) 
			RETURN 0
		END

	IF (@isRecap = 1)
		BEGIN
			SET @batchId = CONVERT(NVARCHAR(100), NEWID())
			SET @totalAmount = 0.000000
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
			WHERE intEntityId NOT IN (SELECT intEntityCustomerId FROM tblARCustomer WHERE intAccountStatusId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@statusIds)))
		END

	--PROCESS EACH CUSTOMER
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomers)
		BEGIN
			DECLARE @entityId INT,
					@serviceChargeId INT

			SELECT TOP 1 @entityId = intEntityId,
						 @serviceChargeId = intServiceChargeId FROM #tmpCustomers
			
			IF (@serviceChargeId > 0)
				BEGIN
					DECLARE @tblTypeServiceCharge [dbo].[ServiceChargeTableType]
					
					IF (@calculation = 'By Invoice')
						BEGIN
							--GET AMOUNT DUE PER INVOICE
							INSERT INTO @tblTypeServiceCharge
							SELECT intInvoiceId
								 , NULL
								 , @entityId
								 , strInvoiceNumber
								 , NULL
								 , dblAmountDue
								 , dblTotalAmount = CASE WHEN strCalculationType = 'Percent'
														THEN
															CASE WHEN dblServiceChargeAPR > 0
																THEN
																	CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END, @asOfDate) * dblAmountDue
								  										THEN dblMinimumCharge
								  										ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END, @asOfDate) * dblAmountDue)
																	END
																ELSE 0
															END
														ELSE 
															dblPercentage
													END
							FROM tblARInvoice I
								INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
							WHERE I.ysnPosted = 1 
							  AND I.ysnPaid = 0
							  AND I.strTransactionType = 'Invoice'
							  AND I.strType = 'Standard'
							  AND I.intEntityCustomerId = @entityId
							  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDueDate))) <= @asOfDate
							  AND CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END > intGracePeriod
							  AND (I.ysnCalculated = 0 OR I.ysnForgiven = 1)

							IF ISNULL(@isIncludeBudget, 0) = 1
								BEGIN
									INSERT INTO @tblTypeServiceCharge
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
										INNER JOIN tblEntityLocation EL ON CB.intEntityCustomerId = EL.intEntityId AND EL.ysnDefaultLocation = 1	
									WHERE CB.intEntityCustomerId = @entityId
										AND dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId) <= @asOfDate
										AND CB.dblBudgetAmount > 0.000000
										AND DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId), @asOfDate) > intGracePeriod
										AND (CB.ysnCalculated = 0 OR CB.ysnForgiven = 1)
								END
						END
					ELSE
						BEGIN
							--GET AMOUNT DUE PER CUSTOMER
							INSERT INTO @tblTypeServiceCharge
							SELECT NULL
							     , NULL
							     , @entityId
								 , 'Customer Balance'
								 , NULL
								 , dblAmountDue = SUM(dblAmountDue)
								 , dblTotalAmount = SUM(CASE WHEN strCalculationType = 'Percent'
													    	THEN 
													    		CASE WHEN dblServiceChargeAPR > 0
																THEN
																	CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END, @asOfDate) * dblAmountDue
								  										THEN dblMinimumCharge
								  										ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END, @asOfDate) * dblAmountDue)
																	END
																ELSE 0
															END
													    ELSE 
													    	dblPercentage
													    END)
							FROM tblARInvoice I
								INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
							WHERE I.ysnPosted = 1 
							  AND I.ysnPaid = 0
							  AND I.strTransactionType = 'Invoice'
							  AND I.strType = 'Standard'
							  AND I.intEntityCustomerId = @entityId
							  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmDueDate))) <= @asOfDate
							  AND CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END > intGracePeriod
							  AND (I.ysnCalculated = 0 OR I.ysnForgiven = 1)
							GROUP BY I.intEntityCustomerId

							IF ISNULL(@isIncludeBudget, 0) = 1
								BEGIN
									INSERT INTO @tblTypeServiceCharge
									SELECT NULL
									     , NULL
										 , CB.intEntityCustomerId
										 , NULL
										 , 'Customer Budget Due As Of: ' + CONVERT(NVARCHAR(50), @asOfDate, 101)
										 , SUM(CB.dblBudgetAmount)
										 , dblTotalAmount = SUM(CASE WHEN strCalculationType = 'Percent'
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
															END)
									FROM tblARCustomerBudget CB
										INNER JOIN tblARCustomer C ON CB.intEntityCustomerId = C.intEntityCustomerId	
										INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
										INNER JOIN tblEntityLocation EL ON CB.intEntityCustomerId = EL.intEntityId AND EL.ysnDefaultLocation = 1	
									WHERE CB.intEntityCustomerId = @entityId
										AND dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId) <= @asOfDate
										AND CB.dblBudgetAmount > 0.000000
										AND DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, EL.intTermsId), @asOfDate) > intGracePeriod
										AND (CB.ysnCalculated = 0 OR CB.ysnForgiven = 1)
									GROUP BY CB.intEntityCustomerId
								END
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