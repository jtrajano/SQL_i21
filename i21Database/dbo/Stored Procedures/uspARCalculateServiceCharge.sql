﻿CREATE PROCEDURE [dbo].[uspARCalculateServiceCharge]
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
	CREATE TABLE #tmpCustomers (intEntityId INT, intServiceChargeId INT, intTermId INT)	
	DECLARE @tblTypeServiceCharge	  [dbo].[ServiceChargeTableType]
	DECLARE @tempTblTypeServiceCharge [dbo].[ServiceChargeTableType]
	DECLARE @temp_aging_table TABLE(
		 [strCustomerName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[strCustomerNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[strRecordNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[intInvoiceId]				INT	
		,[strBOLNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[intEntityCustomerId]		INT	
		,[dblCreditLimit]			NUMERIC(18,6)
		,[dblTotalAR]				NUMERIC(18,6)
		,[dblFuture]				NUMERIC(18,6)
		,[dbl0Days]					NUMERIC(18,6)
		,[dbl10Days]				NUMERIC(18,6)
		,[dbl30Days]				NUMERIC(18,6)
		,[dbl60Days]				NUMERIC(18,6)
		,[dbl90Days]				NUMERIC(18,6)
		,[dbl91Days]				NUMERIC(18,6)
		,[dblTotalDue]				NUMERIC(18,6)
		,[dblAmountPaid]			NUMERIC(18,6)
		,[dblInvoiceTotal]			NUMERIC(18,6)
		,[dblCredits]				NUMERIC(18,6)
		,[dblPrepayments]			NUMERIC(18,6)
		,[dblPrepaids]				NUMERIC(18,6)
		,[dtmDate]					DATETIME
		,[dtmDueDate]				DATETIME
		,[dtmAsOfDate]				DATETIME
		,[strSalespersonName]		NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,[intCompanyLocationId]		INT
		,[strSourceTransaction]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
	DECLARE @zeroDecimal		NUMERIC(18, 6) = 0
	      , @dblMinimumSC		NUMERIC(18, 6) = 0

	--VALIDATION
	IF ISNULL(@arAccountId, 0) = 0
		BEGIN
			RAISERROR('There is no setup for AR Account in the Company Configuration.', 16, 1) 
			RETURN 0
		END

	IF ISNULL(@scAccountId, 0) = 0
		BEGIN
			RAISERROR('There is no setup for Service Charge Account in the Company Configuration!', 16, 1) 
			RETURN 0
		END

	IF ISNULL(@locationId, 0) = 0
		BEGIN
			RAISERROR('Please setup your Default Location!', 16, 1) 
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
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId, intTermId) 
			SELECT E.intEntityCustomerId, C.intServiceChargeId, C.intTermsId FROM vyuARCustomerSearch E
				INNER JOIN tblARCustomer C ON E.intEntityCustomerId = C.intEntityCustomerId
				WHERE E.ysnActive = 1 AND ISNULL(C.intServiceChargeId, 0) <> 0
		END
	ELSE
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId, intTermId)
			SELECT intEntityCustomerId, intServiceChargeId, intTermsId FROM tblARCustomer WHERE intEntityCustomerId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@customerIds)) AND ISNULL(intServiceChargeId, 0) <> 0
		END

	--GET SELECTED STATUS CODES
	IF (@statusIds <> '')
		BEGIN
			DELETE FROM #tmpCustomers
			WHERE intEntityId NOT IN (SELECT intEntityCustomerId FROM tblARCustomerAccountStatus WHERE intAccountStatusId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@statusIds)))
		END

	--GET CUSTOMER AGING IF CALCULATION IS BY CUSTOMER BALANCE
	IF (@calculation = 'By Customer Balance')
		BEGIN
			INSERT INTO @temp_aging_table
			EXEC dbo.uspARCustomerAgingDetailAsOfDateReport NULL, @asOfDate, NULL

			DELETE FROM @temp_aging_table
			WHERE [strInvoiceNumber] IN (SELECT strInvoiceNumber FROM tblARInvoice WHERE strType IN ('CF Tran'))
		END

	IF EXISTS(SELECT TOP 1 NULL FROM #tmpCustomers WHERE ISNULL(intTermId, 0) = 0) AND @isRecap = 0
		BEGIN
			RAISERROR(120042, 16, 1)
			RETURN 0
		END

	--PROCESS EACH CUSTOMER
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomers)
		BEGIN
			DECLARE @entityId			INT,
					@serviceChargeId	INT

			SELECT TOP 1 @entityId = intEntityId,
						 @serviceChargeId = intServiceChargeId
			FROM #tmpCustomers

			DELETE FROM @tempTblTypeServiceCharge

			IF (@serviceChargeId > 0)
				BEGIN
					--GET INVOICES DUE
					IF (@calculation = 'By Invoice')
						BEGIN
							INSERT INTO @tempTblTypeServiceCharge
							SELECT I.intInvoiceId
								 , NULL
								 , @entityId
								 , I.strInvoiceNumber
								 , NULL
								 , dblAmountDue = I.dblInvoiceTotal - ISNULL(PD.dblAmountPaid, @zeroDecimal)
								 , dblTotalAmount = CASE WHEN SC.strCalculationType = 'Percent'
						 								THEN
						 									CASE WHEN SC.dblServiceChargeAPR > 0
						 										THEN
						 											CASE WHEN SC.dblMinimumCharge > ((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																							THEN I.dtmDueDate 
																																							ELSE I.dtmCalculated 
																																						 END, ISNULL(PAYMENTDATE.dtmDatePaid, @asOfDate)) * (I.dblInvoiceTotal - ISNULL(PD.dblAmountPaid, @zeroDecimal))
						 		  										THEN SC.dblMinimumCharge
						 		  										ELSE (((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0  AND ISNULL(I.ysnCalculated, 0) = 0
																																	  THEN I.dtmDueDate 
																																	  ELSE I.dtmCalculated 
																																   END, ISNULL(PAYMENTDATE.dtmDatePaid, @asOfDate)) * (I.dblInvoiceTotal - ISNULL(PD.dblAmountPaid, @zeroDecimal)))
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
										   FROM tblARPaymentDetail PD 
												INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId 
												INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
										   WHERE P.ysnPosted = 1 
											 AND P.dtmDatePaid <= @asOfDate
											 AND P.dtmDatePaid <= I.dtmDueDate
										   GROUP BY PD.intInvoiceId
								) AS PD ON PD.intInvoiceId = I.intInvoiceId
								LEFT JOIN (SELECT PD.intInvoiceId					
												, dtmDatePaid   = MAX(dtmDatePaid)
										   FROM tblARPaymentDetail PD 
												INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId 
												INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
										   WHERE P.ysnPosted = 1 
											 AND P.dtmDatePaid <= @asOfDate
										   GROUP BY PD.intInvoiceId
								) AS PAYMENTDATE ON PAYMENTDATE.intInvoiceId = I.intInvoiceId 
							WHERE I.ysnPosted = 1 							  
								AND (I.strTransactionType = 'Invoice' OR (I.strTransactionType = 'Debit Memo' AND I.strType = 'CF Invoice'))
								AND I.strType NOT IN ('CF Tran')
								AND I.intEntityCustomerId = @entityId
								AND DATEADD(DAY, SC.intGracePeriod, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END) < @asOfDate
								AND (PAYMENTDATE.dtmDatePaid IS NOT NULL AND DATEADD(DAY, SC.intGracePeriod, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END) < PAYMENTDATE.dtmDatePaid OR PAYMENTDATE.dtmDatePaid IS NULL)
								AND I.dblInvoiceTotal - ISNULL(PD.dblAmountPaid, @zeroDecimal) > @zeroDecimal					
						END
					ELSE
						BEGIN
							DECLARE @dblTotalAR			NUMERIC(18, 6) = 0								  

							SELECT @dblTotalAR = SUM(dbl10Days) + SUM(dbl30Days) + SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl91Days) + SUM(dblCredits) + SUM(dblPrepayments) FROM @temp_aging_table WHERE intEntityCustomerId = @entityId							
							SELECT TOP 1 @dblMinimumSC = dblMinimumCharge FROM tblARCustomer C 
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId WHERE C.intEntityCustomerId = @entityId
			
							IF ISNULL(@dblTotalAR, 0) > 0
								BEGIN
									INSERT INTO @tempTblTypeServiceCharge
									SELECT intInvoiceId			= AGING.intInvoiceId
										 , intBudgetId			= NULL
										 , intEntityCustomerId	= AGING.intEntityCustomerId
										 , strInvoiceNumber		= AGING.strInvoiceNumber
										 , strBudgetDescription = NULL
										 , dblAmountDue			= @dblTotalAR
										 , dblTotalAmount       = CASE WHEN SC.strCalculationType = 'Percent'
																		THEN
																			CASE WHEN SC.dblServiceChargeAPR > 0
																				THEN
																					((SC.dblServiceChargeAPR/12) * @dblTotalAR) / 100
																				ELSE 0
																			END
																		ELSE
																			SC.dblPercentage
						 											END
									FROM @temp_aging_table AGING
										INNER JOIN tblARCustomer C ON AGING.intEntityCustomerId = C.intEntityCustomerId
										INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId										
									WHERE AGING.intEntityCustomerId = @entityId
								END					
						END

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
								 									CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermsId), @asOfDate) * CB.dblBudgetAmount
								 											THEN dblMinimumCharge
								 											ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermsId), @asOfDate) * CB.dblBudgetAmount)
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
								AND DATEADD(DAY, SC.intGracePeriod, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 AND ISNULL(CB.ysnCalculated, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermsId)) < @asOfDate
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
								 , AVG(dblAmountDue)
								 , CASE WHEN ISNULL(@dblMinimumSC, 0) > AVG(dblTotalAmount) THEN @dblMinimumSC ELSE AVG(dblTotalAmount) END
							FROM @tempTblTypeServiceCharge 
								GROUP BY intEntityCustomerId 
								HAVING AVG(dblAmountDue) > @zeroDecimal 
								   AND AVG(dblTotalAmount) > @zeroDecimal
						END
					
					IF EXISTS(SELECT TOP 1 1 FROM @tblTypeServiceCharge)
						BEGIN
							SET @totalAmount = @totalAmount + CASE WHEN @calculation = 'By Invoice' 
																THEN 
																	(SELECT SUM(dblTotalAmount) FROM @tblTypeServiceCharge)
																ELSE 
																	(SELECT AVG(dblTotalAmount) FROM @tblTypeServiceCharge)
																END

							DELETE FROM @tempTblTypeServiceCharge WHERE ISNULL(dblAmountDue, @zeroDecimal) = @zeroDecimal OR ISNULL(dblTotalAmount, @zeroDecimal) = @zeroDecimal

							EXEC dbo.uspARInsertInvoiceServiceCharge @isRecap, @batchId, @entityId, @locationId, @currencyId, @arAccountId, @scAccountId, @asOfDate, @calculation, @tblTypeServiceCharge, @tempTblTypeServiceCharge

							DELETE FROM @tblTypeServiceCharge WHERE intEntityCustomerId = @entityId
						END
					
				END
			DELETE FROM #tmpCustomers WHERE intEntityId = @entityId
		END

	DROP TABLE #tmpCustomers