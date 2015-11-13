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
				WHERE E.ysnActive = 1
				  AND (C.intServiceChargeId <> 0
				  OR C.intServiceChargeId IS NOT NULL)
		END
	ELSE
		BEGIN
			DECLARE @customerId INT,
					@pos INT
			
			SELECT @customerIds = @customerIds + ','
			WHILE CHARINDEX(',', @customerIds) > 0
			BEGIN
				SELECT @pos  = CHARINDEX(',', @customerIds)  
				SELECT @customerId = SUBSTRING(@customerIds, 1, @pos-1)

				INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId) 
				SELECT intEntityCustomerId, intServiceChargeId FROM tblARCustomer WHERE intEntityCustomerId = @customerId AND (intServiceChargeId <> 0 OR intServiceChargeId IS NOT NULL)

				SELECT @customerIds = SUBSTRING(@customerIds, @pos + 1, LEN(@customerIds) - @pos)
			END			
		END

	--GET SELECTED STATUS CODES
	IF (@statusIds <> '')
		BEGIN
			DECLARE @statusId INT,
					@pos2 INT
			
			SELECT @statusIds = @statusIds + ','
			WHILE CHARINDEX(',', @statusIds) > 0
			BEGIN
				SELECT @pos2  = CHARINDEX(',', @statusIds)  				
				SELECT @statusId = CONVERT(INT, SUBSTRING(@statusIds, 1, @pos2-1))

				INSERT INTO #tmpCustomers (intEntityId, intServiceChargeId) 
				SELECT intEntityCustomerId, intServiceChargeId FROM tblARCustomer WHERE intAccountStatusId = @statusId AND (intServiceChargeId <> 0 OR intServiceChargeId IS NOT NULL)

				SELECT @statusIds = SUBSTRING(@statusIds, @pos2 + 1, LEN(@statusIds) - @pos2)
			END
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
								 , @entityId
								 , strInvoiceNumber
								 , dblAmountDue
								 , dblTotalAmount = CASE WHEN strCalculationType = 'Percent'
														THEN
															CASE WHEN dblServiceChargeAPR > 0
																THEN
																	CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue
								  										THEN dblMinimumCharge
								  										ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue)
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
							  AND DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) > intGracePeriod
							  AND I.ysnCalculated = 0
						END
					ELSE
						BEGIN
							--GET AMOUNT DUE PER CUSTOMER
							INSERT INTO @tblTypeServiceCharge
							SELECT NULL
							     , @entityId
								 , 'Customer Balance'
								 , dblAmountDue = SUM(dblAmountDue)
								 , dblTotalAmount = SUM(CASE WHEN strCalculationType = 'Percent'
													    	THEN 
													    		CASE WHEN dblServiceChargeAPR > 0
																THEN
																	CASE WHEN dblMinimumCharge > ((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue
								  										THEN dblMinimumCharge
								  										ELSE (((dblServiceChargeAPR/365) / 100) * DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) * dblAmountDue)
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
							  AND DATEDIFF(DAY, I.[dtmDueDate], @asOfDate) > intGracePeriod
							  AND I.ysnCalculated = 0
							GROUP BY I.intEntityCustomerId
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