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
	SET NOCOUNT ON
	CREATE TABLE #tmpCustomers (intEntityId INT, intServiceChargeId INT, intTermId INT)	
	DECLARE @tblTypeServiceCharge	  [dbo].[ServiceChargeTableType]
	DECLARE @tempTblTypeServiceCharge [dbo].[ServiceChargeTableType]	
	DECLARE @zeroDecimal		NUMERIC(18, 6) = 0
	      , @dblMinimumSC		NUMERIC(18, 6) = 0
		  , @dblMinFinanceSC    NUMERIC(18, 6) = 0
		  , @ysnChargeonCharge	BIT = 1

	SELECT TOP 1 @ysnChargeonCharge = ISNULL(ysnChargeonCharge, 1) FROM dbo.tblARCompanyPreference WITH (NOLOCK)

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
			SELECT E.[intEntityId], C.intServiceChargeId, C.intTermsId FROM vyuARCustomerSearch E
				INNER JOIN tblARCustomer C ON E.[intEntityId] = C.[intEntityId]
				WHERE E.ysnActive = 1 AND ISNULL(C.intServiceChargeId, 0) <> 0
		END
	ELSE
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId, intTermId)
			SELECT [intEntityId], intServiceChargeId, intTermsId FROM tblARCustomer WHERE [intEntityId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@customerIds)) AND ISNULL(intServiceChargeId, 0) <> 0
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
			TRUNCATE TABLE tblARCustomerAgingStagingTable
			INSERT INTO tblARCustomerAgingStagingTable (
				   strCustomerName
				, strCustomerNumber
				, strInvoiceNumber
				, strRecordNumber
				, intInvoiceId
				, strBOLNumber
				, intEntityCustomerId
				, dblCreditLimit
				, dblTotalAR
				, dblFuture
				, dbl0Days
				, dbl10Days
				, dbl30Days
				, dbl60Days
				, dbl90Days
				, dbl120Days
				, dbl121Days
				, dblTotalDue
				, dblAmountPaid
				, dblInvoiceTotal
				, dblCredits
				, dblPrepayments
				, dblPrepaids
				, dtmDate
				, dtmDueDate
				, dtmAsOfDate
				, strSalespersonName
				, intCompanyLocationId
				, strSourceTransaction
				, strType
				, strCompanyName
				, strCompanyAddress
			)
			EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateTo = @asOfDate, @ysnInclude120Days = 0

			IF ISNULL(@ysnChargeonCharge, 1) = 0
				DELETE FROM tblARCustomerAgingStagingTable WHERE strType = 'Service Charge'

			IF (DATEPART(dd, @asOfDate) = 31)
				DELETE FROM tblARCustomerAgingStagingTable WHERE dtmDueDate = @asOfDate

			DELETE FROM tblARCustomerAgingStagingTable WHERE strType = 'CF Tran'
		END

	IF EXISTS(SELECT TOP 1 NULL FROM #tmpCustomers WHERE ISNULL(intTermId, 0) = 0) AND @isRecap = 0
		BEGIN
			RAISERROR(120042, 16, 1)
			RETURN 0
		END

	DECLARE @totalAR Table(
		intEntityId INT,
		dblTotalAR NUMERIC(18, 6)

	)
	INSERT INTO @totalAR(
		intEntityId,
		dblTotalAR
	)
	SELECT AGING.intEntityCustomerId,
		SUM(dbl10Days) + SUM(dbl30Days) + SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days) + SUM(dblCredits) + SUM(dblPrepayments) 
	FROM tblARCustomerAgingStagingTable AGING
	INNER JOIN (
		SELECT intEntityId
				, dtmLastServiceCharge = ISNULL(dtmLastServiceCharge, '01/01/1900')
		FROM tblARCustomer
	) C ON C.intEntityId = AGING.intEntityCustomerId	
	WHERE YEAR(dtmLastServiceCharge) * 100 + MONTH(dtmLastServiceCharge) < YEAR(@asOfDate) * 100 + MONTH(@asOfDate)

	GROUP BY AGING.intEntityCustomerId
	

	--SELECT * FROM @totalAR

	--PROCESS EACH CUSTOMER
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomers)
		BEGIN
			DECLARE @entityId			INT,
					@serviceChargeId	INT

			DECLARE @dblTotalAR			NUMERIC(18, 6) = 0		

			SELECT TOP 1 @entityId = C.intEntityId,
						 @serviceChargeId = C.intServiceChargeId,
						 @dblMinimumSC = ISNULL(SC.dblMinimumCharge, 0),
						 @dblMinFinanceSC = ISNULL(SC.dblMinimumFinanceCharge, 0),
						 @dblTotalAR = ISNULL(D.dblTotalAR, 0)
			FROM #tmpCustomers C
				LEFT JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId 
				LEFT JOIN  @totalAR D on C.intEntityId = D.intEntityId

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
								 , dblAmountDue = I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal)
								 , dblTotalAmount = dbo.fnRoundBanker(CASE WHEN SC.strCalculationType = 'Percent'
						 								THEN
						 									CASE WHEN SC.dblServiceChargeAPR > 0
						 										THEN
																	--MIN. CHARGE > INVOICE AMOUNT = MIN. CHARGE
						 											CASE WHEN SC.dblMinimumCharge > 
																			--MIN. FINANCE CHARGE BAL > INVOICE AMOUNT DUE = 0
																			CASE WHEN ISNULL(SC.dblMinimumFinanceCharge, 0) > I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal)
																				 THEN 0
																				 ELSE  ((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																				 THEN I.dtmDueDate 
																																				 ELSE I.dtmCalculated 
																																			END, ISNULL(ISNULL(PAYMENT.dtmDatePaid, PAYMENT2.dtmDatePaid), @asOfDate)) * (I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal))
																			END
						 		  										THEN SC.dblMinimumCharge
						 		  										ELSE 
																			CASE WHEN ISNULL(SC.dblMinimumFinanceCharge, 0) > I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal)
																				 THEN 0
																				 ELSE  ((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																				 THEN I.dtmDueDate 
																																				 ELSE I.dtmCalculated 
																																			END, ISNULL(ISNULL(PAYMENT.dtmDatePaid, PAYMENT2.dtmDatePaid), @asOfDate)) * (I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal))
																			END
						 											END
						 										ELSE 0
						 									END
						 								ELSE 
						 									SC.dblPercentage
						 							END, dbo.fnARGetDefaultDecimal())
							FROM tblARInvoice I
								INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.[intEntityId]
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
								LEFT JOIN (SELECT PD.intInvoiceId
												, dblAmountPaid = SUM(ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) + ISNULL(PD.dblInterest, @zeroDecimal))
												, dtmDatePaid   = MAX(dtmDatePaid)
											FROM tblARPaymentDetail PD 
												INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId 
												INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
											WHERE P.ysnPosted = 1 
												AND P.dtmDatePaid <= @asOfDate
												AND (PD.dblPayment + PD.dblDiscount <> PD.dblInvoiceTotal OR (PD.dblPayment + PD.dblDiscount = PD.dblInvoiceTotal AND P.dtmDatePaid <= CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END))
											GROUP BY PD.intInvoiceId
								) AS PAYMENT ON PAYMENT.intInvoiceId = I.intInvoiceId    
								LEFT JOIN (SELECT PD.intInvoiceId
												, dtmDatePaid   = MAX(dtmDatePaid)
											FROM tblARPaymentDetail PD 
												INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId 
												INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
											WHERE P.ysnPosted = 1 
												AND P.dtmDatePaid <= @asOfDate    
											GROUP BY PD.intInvoiceId
								) AS PAYMENT2 ON PAYMENT2.intInvoiceId = I.intInvoiceId AND I.ysnPaid = 1
							WHERE I.ysnPosted = 1 							  
								AND I.strTransactionType IN ('Invoice', 'Debit Memo')
								AND I.strType NOT IN ('CF Tran')
								AND I.intEntityCustomerId = @entityId
								AND DATEADD(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN SC.intGracePeriod ELSE 0 END, I.dtmDueDate) < @asOfDate
							    AND (ISNULL(PAYMENT.dtmDatePaid, PAYMENT2.dtmDatePaid) IS NOT NULL AND DATEADD(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN SC.intGracePeriod ELSE 0 END, I.dtmDueDate) < ISNULL(PAYMENT.dtmDatePaid, PAYMENT2.dtmDatePaid) OR ISNULL(PAYMENT.dtmDatePaid, PAYMENT2.dtmDatePaid) IS NULL)
                                AND ((I.strType = 'Service Charge' AND ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND ysnForgiven = 0)))
                                AND I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal) > @zeroDecimal
								AND ((@ysnChargeonCharge = 0 AND I.strType NOT IN ('Service Charge')) OR (@ysnChargeonCharge = 1))
						END
					ELSE
						BEGIN	
									
							IF ISNULL(@dblTotalAR, 0) > 0
								BEGIN
									--print 'goes here'
									INSERT INTO @tempTblTypeServiceCharge
									SELECT intInvoiceId			= AGING.intInvoiceId
										 , intBudgetId			= NULL
										 , intEntityCustomerId	= AGING.intEntityCustomerId
										 , strInvoiceNumber		= AGING.strInvoiceNumber
										 , strBudgetDescription = NULL
										 , dblAmountDue			= @dblTotalAR
										 , dblTotalAmount       = dbo.fnRoundBanker(CASE WHEN SC.strCalculationType = 'Percent'
																		THEN
																			CASE WHEN SC.dblServiceChargeAPR > 0
																				THEN
																					((SC.dblServiceChargeAPR/12) * @dblTotalAR) / 100
																				ELSE 0
																			END
																		ELSE
																			SC.dblPercentage
						 											END, dbo.fnARGetDefaultDecimal())
									FROM tblARCustomerAgingStagingTable AGING
										INNER JOIN #tmpCustomers C ON AGING.intEntityCustomerId = C.[intEntityId]
										INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId										
									WHERE AGING.intEntityCustomerId = @entityId

									IF ISNULL(@isRecap, 0) = 0
										BEGIN
											UPDATE tblARCustomer SET dtmLastServiceCharge = @asOfDate WHERE intEntityId = @entityId
										END
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
								 , dblTotalAmount = dbo.fnRoundBanker(CASE WHEN strCalculationType = 'Percent'
								 						THEN
								 							CASE WHEN dblServiceChargeAPR > 0
								 								THEN
								 									CASE WHEN dblMinimumCharge > 
																			CASE WHEN ISNULL(dblMinimumFinanceCharge, 0) > CB.dblBudgetAmount
																				 THEN 0
																				 ELSE ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermId), @asOfDate) * CB.dblBudgetAmount
																			END
								 										 THEN dblMinimumCharge
								 										 ELSE 
																			CASE WHEN ISNULL(dblMinimumFinanceCharge, 0) > CB.dblBudgetAmount
																				 THEN 0
																				 ELSE ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermId), @asOfDate) * CB.dblBudgetAmount
																			END
								 									END
								 								ELSE 0
								 							END
								 						ELSE 
								 							dblPercentage
								 					END, dbo.fnARGetDefaultDecimal())
							FROM tblARCustomerBudget CB
								INNER JOIN #tmpCustomers C ON CB.intEntityCustomerId = C.[intEntityId]	
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
								INNER JOIN [tblEMEntityLocation] EL ON CB.intEntityCustomerId = EL.intEntityId AND EL.ysnDefaultLocation = 1	
							WHERE CB.intEntityCustomerId = @entityId
								AND DATEADD(DAY, SC.intGracePeriod, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 AND ISNULL(CB.ysnCalculated, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermId)) < @asOfDate
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
								 , CASE WHEN ISNULL(@dblMinimumSC, 0) > 
											CASE WHEN ISNULL(@dblMinFinanceSC, 0) > AVG(dblAmountDue)
												 THEN 0
												 ELSE AVG(dblTotalAmount)
											END
										THEN @dblMinimumSC 
										ELSE 
											CASE WHEN ISNULL(@dblMinFinanceSC, 0) > AVG(dblAmountDue)
												 THEN 0
												 ELSE AVG(dblTotalAmount)
											END
								   END
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