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
	@serviceChargeDate	DATE,
	@serviceChargePostDate	DATE,
	@batchId			NVARCHAR(100) = NULL OUTPUT,
	@totalAmount		NUMERIC(18,6) = NULL OUTPUT,
	@upToDateCustomer 	BIT = 0,
	@intEntityUserId	INT = NULL
AS
	SET NOCOUNT ON
	CREATE TABLE #tmpCustomers (intEntityId INT, intServiceChargeId INT, intTermId INT, ysnActive BIT)	
	DECLARE @tblComputedBalances TABLE (intEntityId INT, dblTotalAR NUMERIC(18, 6))
	DECLARE @tblTypeServiceCharge	  [dbo].[ServiceChargeTableType]
	DECLARE @tempTblTypeServiceCharge [dbo].[ServiceChargeTableType]	
	DECLARE @zeroDecimal		NUMERIC(18, 6) = 0
	      , @dblMinimumSC		NUMERIC(18, 6) = 0
		  , @dblMinFinanceSC    NUMERIC(18, 6) = 0
		  , @ysnChargeonCharge	BIT = 1		  

	SELECT TOP 1 @ysnChargeonCharge = ISNULL(ysnChargeonCharge, 1)
	FROM dbo.tblARCompanyPreference WITH (NOLOCK)

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
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId, intTermId, ysnActive) 
			SELECT E.intEntityId, C.intServiceChargeId, C.intTermsId, E.ysnActive
			FROM tblARCustomer C
			INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
			WHERE ISNULL(C.intServiceChargeId, 0) <> 0  and (C.ysnActive = 1 or (C.ysnActive = 0 and C.dblARBalance <> 0))
		END
	ELSE
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId, intTermId, ysnActive)
			SELECT E.intEntityId, C.intServiceChargeId, C.intTermsId, E.ysnActive
			FROM tblARCustomer C
			INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
			INNER JOIN (
				 SELECT intID 
				 FROM fnGetRowsFromDelimitedValues(@customerIds)
			) SELECTED ON C.intEntityId = SELECTED.intID
			WHERE ISNULL(intServiceChargeId, 0) <> 0 and (C.ysnActive = 1 or (C.ysnActive = 0 and C.dblARBalance <> 0))
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
			DECLARE @tblCustomersByBalance TABLE (intEntityCustomerId INT)
			DECLARE @tblServiceCharges TABLE (intServiceChargeId INT, intGracePeriod INT)

			--GET DISTINCT SERVICE CHARGE TO APPLY GRACE PERIOD
			INSERT INTO @tblServiceCharges (intServiceChargeId, intGracePeriod)
			SELECT SC.intServiceChargeId, SC.intGracePeriod
			FROM #tmpCustomers C
			INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
			GROUP BY SC.intServiceChargeId, SC.intGracePeriod

			WHILE EXISTS (SELECT TOP 1 NULL FROM @tblServiceCharges)
				BEGIN
					DECLARE @intSCtoCompute 		INT = NULL
						  , @intGracePeriod 		INT = 0
						  , @strCustomerIds			NVARCHAR(MAX) = NULL

					DELETE FROM @tblCustomersByBalance

					SELECT TOP 1 @intSCtoCompute = intServiceChargeId
							   , @intGracePeriod = intGracePeriod
					FROM @tblServiceCharges

					INSERT INTO @tblCustomersByBalance (intEntityCustomerId)
					SELECT DISTINCT intEntityId FROM #tmpCustomers WHERE intServiceChargeId = @intSCtoCompute

					SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
					FROM (
						SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(200))  + ', '
						FROM @tblCustomersByBalance
						FOR XML PATH ('')
					) C (intEntityCustomerId)

					--GET AGING DETAIL ADDING THE GRACE PERIOD 
					EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateTo = @asOfDate
														  	 	  , @ysnInclude120Days = 0
														  		  , @strCustomerIds = @strCustomerIds
														  		  , @intEntityUserId = @intEntityUserId
																  , @intGracePeriod	= @intGracePeriod

					IF ISNULL(@ysnChargeonCharge, 1) = 0
						DELETE FROM tblARCustomerAgingStagingTable WHERE strType = 'Service Charge' AND intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'

					IF (DATEPART(dd, @asOfDate) = 31)
						DELETE FROM tblARCustomerAgingStagingTable WHERE dtmDueDate = @asOfDate AND intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'

					DELETE FROM tblARCustomerAgingStagingTable WHERE strType = 'CF Tran' AND intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'

					--PROCESS BY AGING BALANCE	
					INSERT INTO @tblComputedBalances (
						intEntityId
						, dblTotalAR
					)
					SELECT intEntityId	= AGING.intEntityCustomerId
						, dblTotalAR   = SUM(dbl10Days) + SUM(dbl30Days) + SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days) + SUM(dblCredits) + SUM(dblPrepayments) 
					FROM tblARCustomerAgingStagingTable AGING
					INNER JOIN #tmpCustomers TC ON AGING.intEntityCustomerId = TC.intEntityId
					INNER JOIN (
						SELECT intEntityId
						FROM dbo.tblARCustomer WITH (NOLOCK)		
						WHERE YEAR(ISNULL(dtmLastServiceCharge, '01/01/1900')) * 100 + MONTH(ISNULL(dtmLastServiceCharge, '01/01/1900')) < YEAR(@asOfDate) * 100 + MONTH(@asOfDate)
					) C ON C.intEntityId = AGING.intEntityCustomerId	
					WHERE AGING.intEntityUserId = @intEntityUserId 
					AND AGING.strAgingType = 'Detail'	
					GROUP BY AGING.intEntityCustomerId
					HAVING SUM(dbl10Days) + SUM(dbl30Days) + SUM(dbl60Days) + SUM(dbl90Days) + SUM(dbl120Days) + SUM(dbl121Days) + SUM(dblCredits) + SUM(dblPrepayments) > @zeroDecimal

					DELETE FROM @tblServiceCharges WHERE intServiceChargeId = @intSCtoCompute
				END
		END

	IF EXISTS(SELECT TOP 1 NULL FROM #tmpCustomers WHERE ISNULL(intTermId, 0) = 0) AND @isRecap = 0
		BEGIN
			RAISERROR(120042, 16, 1)
			RETURN 0
		END
	
	--PROCESS EACH CUSTOMER
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomers)
		BEGIN
			DECLARE @entityId				INT
				  , @serviceChargeId		INT
			      , @strCalculationType 	NVARCHAR (100)
			      , @dblServiceChargeAPR 	NUMERIC(18, 6)
			      , @dblPercentage			NUMERIC(18, 6) = 0

			SELECT TOP 1 @entityId = C.intEntityId,
						 @serviceChargeId = C.intServiceChargeId,
						 @dblMinimumSC = ISNULL(SC.dblMinimumCharge, 0),
						 @dblMinFinanceSC = ISNULL(SC.dblMinimumFinanceCharge, 0),
						 @dblServiceChargeAPR = ISNULL(SC.dblServiceChargeAPR, 0),
						 @strCalculationType = SC.strCalculationType,
						 @dblPercentage  = SC.dblPercentage
			FROM #tmpCustomers C 
			INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId 
			
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
																				 ELSE  ((SC.dblServiceChargeAPR/365) / 100) *  DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																					THEN I.dtmDueDate 
																																					ELSE I.dtmCalculated 
																																					END, @asOfDate)
																															* (I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal))
																			END
						 		  										THEN SC.dblMinimumCharge
						 		  										ELSE 
																			CASE WHEN ISNULL(SC.dblMinimumFinanceCharge, 0) > I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal)
																				 THEN 0
																				 ELSE  ((SC.dblServiceChargeAPR/365) / 100) * DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																																					 THEN I.dtmDueDate 
																																					 ELSE I.dtmCalculated 
																																					 END, @asOfDate)
																															* (I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal))
																			END
						 											END
						 										ELSE 0
						 									END
						 								ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmCalculated, @asOfDate) <= 0
																		THEN 0
																		ELSE SC.dblPercentage
																		END
						 							END, dbo.fnARGetDefaultDecimal())
									, intServiceChargeDays	 = DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0
																THEN I.dtmDueDate 
																ELSE I.dtmCalculated 
																END, @asOfDate)
							FROM tblARInvoice I
								INNER JOIN #tmpCustomers C ON I.intEntityCustomerId = C.[intEntityId]
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
								LEFT JOIN (SELECT PD.intInvoiceId
												, dblAmountPaid = SUM(ISNULL(PD.dblPayment, 0) + ISNULL(PD.dblDiscount, 0) + ISNULL(PD.dblInterest, @zeroDecimal))
												, dtmDatePaid   = MAX(dtmDatePaid)
											FROM tblARPaymentDetail PD 
												INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId 
												INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
											WHERE P.ysnPosted = 1 
												AND P.dtmDatePaid <= @asOfDate
												--AND (PD.dblPayment + PD.dblDiscount <> PD.dblInvoiceTotal OR (PD.dblPayment + PD.dblDiscount = PD.dblInvoiceTotal AND P.dtmDatePaid <= CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN I.dtmDueDate ELSE I.dtmCalculated END))
											GROUP BY PD.intInvoiceId
								) AS PAYMENT ON PAYMENT.intInvoiceId = I.intInvoiceId    
							WHERE I.ysnPosted = 1
								AND I.ysnPaid = 0
								AND I.strTransactionType IN ('Invoice', 'Debit Memo')
								AND I.strType NOT IN ('CF Tran')
								AND I.intEntityCustomerId = @entityId
								AND DATEADD(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN SC.intGracePeriod ELSE 0 END, I.dtmDueDate) < @asOfDate
							    AND (
										(PAYMENT.dtmDatePaid IS NOT NULL 
											AND (DATEADD(DAYOFYEAR, CASE WHEN ISNULL(I.ysnForgiven, 0) = 0 AND ISNULL(I.ysnCalculated, 0) = 0 THEN SC.intGracePeriod ELSE 0 END, I.dtmDueDate) < PAYMENT.dtmDatePaid)
										OR  DATEDIFF(DAYOFYEAR, I.dtmDueDate, @asOfDate) > 0)
											OR PAYMENT.dtmDatePaid IS NULL
									)
                                AND ((I.strType = 'Service Charge' AND ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND ysnForgiven = 0)))
                                AND I.dblInvoiceTotal - ISNULL(PAYMENT.dblAmountPaid, @zeroDecimal) > @zeroDecimal
								AND ((@ysnChargeonCharge = 0 AND I.strType NOT IN ('Service Charge')) OR @ysnChargeonCharge = 1)
						END
					ELSE
						BEGIN
							IF EXISTS(SELECT TOP 1 NULL FROM @tblComputedBalances)
								BEGIN
									INSERT INTO @tempTblTypeServiceCharge
									SELECT intInvoiceId			= NULL
										 , intBudgetId			= NULL
										 , intEntityCustomerId	= BALANCE.intEntityId
										 , strInvoiceNumber		= NULL
										 , strBudgetDescription = NULL
										 , dblAmountDue			= BALANCE.dblTotalAR
										 , dblTotalAmount       = dbo.fnRoundBanker(CASE WHEN @strCalculationType = 'Percent'
																		THEN
																			CASE WHEN @dblServiceChargeAPR > 0
																				THEN
																					((@dblServiceChargeAPR/12) * BALANCE.dblTotalAR) / 100
																				ELSE 0
																			END
																		ELSE
																			@dblPercentage	
						 											END, dbo.fnARGetDefaultDecimal())
										, 0
									FROM @tblComputedBalances BALANCE
									WHERE BALANCE.intEntityId = @entityId

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
								, DATEDIFF(DAY, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermId), @asOfDate)
							FROM tblARCustomerBudget CB
								INNER JOIN #tmpCustomers C ON CB.intEntityCustomerId = C.[intEntityId]	
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
								INNER JOIN [tblEMEntityLocation] EL ON CB.intEntityCustomerId = EL.intEntityId AND EL.ysnDefaultLocation = 1	
							WHERE CB.intEntityCustomerId = @entityId
								AND DATEADD(DAY, SC.intGracePeriod, dbo.fnGetDueDateBasedOnTerm(CASE WHEN ISNULL(CB.ysnForgiven, 0) = 0 AND ISNULL(CB.ysnCalculated, 0) = 0 THEN CB.dtmBudgetDate ELSE CB.dtmCalculated END, C.intTermId)) < @asOfDate
								AND CB.dblBudgetAmount > @zeroDecimal
								AND (CB.ysnCalculated = 0 OR CB.ysnForgiven = 1)
						END

					--REMOVE INACTIVE CUSTOMERS WITH ZERO BALANCE
					DELETE SC
					FROM @tempTblTypeServiceCharge SC
					INNER JOIN #tmpCustomers C ON SC.intEntityCustomerId = C.intEntityId
					WHERE C.ysnActive = 0 AND ISNULL(SC.dblTotalAmount, 0) <= 0

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
								 , intServiceChargeDays 
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
								 , dblAmountDue
								 , CASE WHEN ISNULL(@dblMinimumSC, 0) > 
											CASE WHEN ISNULL(@dblMinFinanceSC, 0) > dblAmountDue
												 THEN 0
												 ELSE dblTotalAmount
											END
										THEN @dblMinimumSC 
										ELSE 
											CASE WHEN ISNULL(@dblMinFinanceSC, 0) > dblAmountDue
												 THEN 0
												 ELSE dblTotalAmount
											END
								   END
								 , intServiceChargeDays
							FROM @tempTblTypeServiceCharge 
							WHERE dblAmountDue > @zeroDecimal 
							  AND dblTotalAmount > @zeroDecimal
						END

					DELETE FROM @tblTypeServiceCharge WHERE dblAmountDue <= @dblMinFinanceSC
					
					IF EXISTS(SELECT TOP 1 1 FROM @tblTypeServiceCharge)
						BEGIN
							SET @totalAmount = @totalAmount + ISNULL((SELECT SUM(ISNULL(dblTotalAmount, 0)) FROM @tblTypeServiceCharge), 0)

							DELETE FROM @tempTblTypeServiceCharge WHERE ISNULL(dblAmountDue, @zeroDecimal) = @zeroDecimal OR ISNULL(dblTotalAmount, @zeroDecimal) = @zeroDecimal

							EXEC dbo.uspARInsertInvoiceServiceCharge @isRecap, @batchId, @entityId, @locationId, @currencyId, @arAccountId, @scAccountId, @asOfDate, @calculation, @serviceChargeDate, @serviceChargePostDate, @tblTypeServiceCharge, @tempTblTypeServiceCharge

							DELETE FROM @tblTypeServiceCharge WHERE intEntityCustomerId = @entityId
						END
					
				END
			DELETE FROM #tmpCustomers WHERE intEntityId = @entityId
		END

	DROP TABLE #tmpCustomers

	IF @isRecap = 0 and @upToDateCustomer = 1 and @calculation = 'By Customer Balance'
	BEGIN
		UPDATE tblARCustomer set dtmLastServiceCharge = @serviceChargeDate WHERE dtmLastServiceCharge is null or dtmLastServiceCharge < @asOfDate
	END
