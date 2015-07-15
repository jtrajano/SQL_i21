CREATE PROCEDURE [dbo].[uspARCalculateServiceCharge]
	@customers			NVARCHAR(MAX) = '',
	@calculation        NVARCHAR(25) = '',
	@asOfDate			DATE,
	@isIncludeBudget	BIT = 0,
	@arAccountId		INT = 0,
	@scAccountId		INT = 0,
	@currencyId			INT = 0,
	@locationId			INT = 0
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

	--GET SELECTED CUSTOMERS
	IF (@customers = '')
		BEGIN
			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId) 
			SELECT E.intEntityCustomerId, C.intServiceChargeId FROM vyuARCustomerSearch E
				INNER JOIN tblARCustomer C ON E.intEntityCustomerId = C.intEntityCustomerId
				WHERE E.ysnActive = 1
				  AND (C.intServiceChargeId <> 0
				  OR C.intServiceChargeId <> NULL)
		END
	ELSE
		BEGIN
			DECLARE @name NVARCHAR(255),
					@pos INT

			WHILE CHARINDEX(',', @customers) > 0
			BEGIN
				SELECT @pos  = CHARINDEX(',', @customers)  
				SELECT @name = SUBSTRING(@customers, 1, @pos-1)

				INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId) 
				SELECT @name, 0

				SELECT @customers = SUBSTRING(@customers, @pos + 1, LEN(@customers) - @pos)
			END

			INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId)
			SELECT @customers, 0

			UPDATE #tmpCustomers SET intServiceChargeId = ISNULL((SELECT intServiceChargeId FROM tblARCustomer WHERE intEntityCustomerId = #tmpCustomers.intEntityId), 0)
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
								 , strInvoiceNumber
								 , dblSCAmount = dblPercentage
								 , dblAmountDue
								 , dblTotalAmount = CASE WHEN strCalculationType = 'Percent'
														THEN 
															CASE WHEN dblMinimumCharge > dblAmountDue * (1 + (dblPercentage/100))
								  								THEN dblMinimumCharge
								  								ELSE dblAmountDue * (1 + (dblPercentage/100))
															END
														ELSE 
															dblAmountDue + dblPercentage
													END
								, dblAPRAmount = CASE WHEN dblServiceChargeAPR > 0
													 THEN
														((dblServiceChargeAPR/365) * 0.01) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue
													 ELSE 0
												 END
							FROM tblARInvoice I
								INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
							WHERE I.ysnPosted = 1 
							  AND I.ysnPaid = 0
							  AND I.strTransactionType = 'Invoice'
							  AND I.intEntityCustomerId = @entityId
							  AND DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) > intGracePeriod
							  AND I.ysnCalculated = 0
						END
					ELSE
						BEGIN
							--GET AMOUNT DUE PER CUSTOMER
							INSERT INTO @tblTypeServiceCharge
							SELECT intInvoiceId
								 , strInvoiceNumber
								 , dblSCAmount = dblPercentage
								 , dblAmountDue
								 , dblTotalAmount = CASE WHEN strCalculationType = 'Percent'
														THEN 
															CASE WHEN dblMinimumCharge > dblAmountDue * (1 + (dblPercentage/100))
								  								THEN dblMinimumCharge
								  								ELSE dblAmountDue * (1 + (dblPercentage/100))
															END
														ELSE 
															dblAmountDue + dblPercentage
													END
								, dblAPRAmount = CASE WHEN dblServiceChargeAPR > 0
													 THEN
														((dblServiceChargeAPR/365) * 0.01) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue
													 ELSE 0
												 END
							FROM tblARInvoice I
								INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
								INNER JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
							WHERE I.ysnPosted = 1 
							  AND I.ysnPaid = 0
							  AND I.strTransactionType = 'Invoice'
							  AND I.intEntityCustomerId = @entityId
							  AND DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) > intGracePeriod
							  AND I.ysnCalculated = 0
						END
					
					IF EXISTS(SELECT TOP 1 1 FROM @tblTypeServiceCharge)
						BEGIN
							EXEC dbo.uspARInsertInvoiceServiceCharge @entityId, @locationId, @currencyId, @arAccountId, @scAccountId, @tblTypeServiceCharge
						END
					
				END
			DELETE FROM #tmpCustomers WHERE intEntityId = @entityId
		END

	DROP TABLE #tmpCustomers