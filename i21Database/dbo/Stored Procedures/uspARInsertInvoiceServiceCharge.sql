CREATE PROCEDURE [dbo].[uspARInsertInvoiceServiceCharge]
	@ysnRecap				BIT = 0,
	@batchId				NVARCHAR(100) = NULL,
	@intEntityCustomerId	INT = 0,
	@intCompanyLocationId	INT = 0,
	@intCurrencyId			INT = 0,
	@intARAccountId			INT = 0,
	@intSCAccountId			INT = 0,
	@dtmAsOfDate			DATETIME = NULL,
	@tblTypeServiceCharge   [dbo].[ServiceChargeTableType] READONLY
AS
	DECLARE @dateNow		    DATE = CAST(GETDATE() AS DATE),			
			@dblInvoiceTotal    NUMERIC(18,6) = 0,
			@NewInvoiceId		INT,
			@newComment         NVARCHAR(500) = NULL,
			@totalCount			INT = 0,
			@counter			INT = 1

	EXEC [dbo].[uspARGetDefaultComment] @intCompanyLocationId, @intEntityCustomerId, 'Invoice', 'Service Charge', @newComment OUT

	SELECT @dblInvoiceTotal    = SUM(dblTotalAmount)
	FROM @tblTypeServiceCharge

	IF @ysnRecap = 0
		BEGIN
			--INSERT INVOICE HEADER
			INSERT INTO tblARInvoice
				([intEntityCustomerId]
				,[strInvoiceOriginId]
				,[dtmDate]
				,[dtmDueDate]
				,[dtmPostDate]
				,[intCurrencyId]
				,[intCompanyLocationId]
				,[intEntitySalespersonId]
				,[dtmShipDate]
				,[intShipViaId]
				,[strPONumber]
				,[intTermId]
				,[dblInvoiceSubtotal]
				,[dblShipping]
				,[dblTax]
				,[dblInvoiceTotal]
				,[dblDiscount]
				,[dblAmountDue]
				,[dblPayment]
				,[strTransactionType]
				,[strType]
				,[intPaymentMethodId]
				,[intAccountId]
				,[intFreightTermId]
				,[intEntityId]
				,[intShipToLocationId]
				,[strShipToLocationName]
				,[strShipToAddress]
				,[strShipToCity]
				,[strShipToState]
				,[strShipToZipCode]
				,[strShipToCountry]
				,[intBillToLocationId]
				,[strBillToLocationName]
				,[strBillToAddress]
				,[strBillToCity]
				,[strBillToState]
				,[strBillToZipCode]
				,[strBillToCountry]
				,[strComments])
			SELECT 
				 @intEntityCustomerId
				,NULL --[strInvoiceOriginId]
				,ISNULL(@dtmAsOfDate, @dateNow)
				,[dbo].fnGetDueDateBasedOnTerm(ISNULL(@dtmAsOfDate, @dateNow), intTermsId)
				,NULL --[dtmPostDate]
				,@intCurrencyId
				,@intCompanyLocationId
				,[intSalespersonId]
				,NULL --[dtmShipDate]
				,[intShipViaId]
				,NULL --[strPONumber]
				,[intTermsId]
				,@dblInvoiceTotal
				,0
				,0
				,@dblInvoiceTotal
				,0
				,@dblInvoiceTotal
				,0
				,'Invoice'
				,'Service Charge'
				,0
				,@intARAccountId
				,[intFreightTermId]
				,[intEntityId]
				,[intShipToId]
				,[strShipToLocationName]
				,[strShipToAddress]
				,[strShipToCity]
				,[strShipToState]
				,[strShipToZipCode]
				,[strShipToCountry]
				,[intBillToId]
				,[strBillToLocationName]
				,[strBillToAddress]
				,[strBillToCity]
				,[strBillToState]
				,[strBillToZipCode]
				,[strBillToCountry]
				,@newComment
			FROM vyuARCustomerSearch
				WHERE intEntityCustomerId = @intEntityCustomerId

			--INSERT INVOICE DETAILS
			SET @NewInvoiceId = SCOPE_IDENTITY()

			SELECT @totalCount = COUNT(*) FROM @tblTypeServiceCharge WHERE intEntityCustomerId = @intEntityCustomerId
			WHILE (@counter <= @totalCount)
				BEGIN
					DECLARE @intInvoiceIdToUpdate INT = 0

					SELECT @intInvoiceIdToUpdate = intInvoiceId FROM @tblTypeServiceCharge WHERE intServiceChargeId = @counter

					INSERT INTO [tblARInvoiceDetail]
						([intInvoiceId]
						,[intSCInvoiceId]
						,[strSCInvoiceNumber]
						,[intServiceChargeAccountId]
						,[dblPrice]
						,[dblTotal]
						,[intConcurrencyId])
					SELECT 	
						 @NewInvoiceId
						,[intInvoiceId]
						,[strInvoiceNumber]				
						,@intSCAccountId
						,[dblTotalAmount]
						,[dblTotalAmount]
						,0
					FROM @tblTypeServiceCharge WHERE intServiceChargeId = @counter

					UPDATE tblARInvoice SET ysnCalculated = 1 WHERE intInvoiceId = @intInvoiceIdToUpdate

					SET @counter += 1
				END
		END
	ELSE
		BEGIN
			DECLARE @calculationType NVARCHAR(50) = NULL
				  , @frequency		 NVARCHAR(50) = NULL
				  , @newRecapId		 INT
			
			SELECT TOP 1 @calculationType = strServiceChargeCalculation
						,@frequency = strServiceChargeFrequency
			FROM tblARCompanyPreference

			--INSERT INTO RECAP TABLE
			INSERT INTO tblARServiceChargeRecap
				([strBatchId]
				,[intEntityId]
				,[intServiceChargeAccountId]
				,[strCalculationType]
				,[strFrequency]
				,[dtmServiceChargeDate]
				,[dblTotalAmount])
			SELECT @batchId
				 , @intEntityCustomerId
				 , @intSCAccountId
				 , @calculationType
				 , @frequency
				 , @dtmAsOfDate
				 , @dblInvoiceTotal

			SET @newRecapId = SCOPE_IDENTITY()

			SELECT @totalCount = COUNT(*) FROM @tblTypeServiceCharge WHERE intEntityCustomerId = @intEntityCustomerId
			WHILE (@counter <= @totalCount)
				BEGIN
					INSERT INTO [tblARServiceChargeRecapDetail]
						([intSCRecapId]
						,[strInvoiceNumber]
						,[dblAmount]
						,[intConcurrencyId])
					SELECT 	
						 @newRecapId
						,[strInvoiceNumber]				
						,[dblTotalAmount]
						,0
					FROM @tblTypeServiceCharge WHERE intServiceChargeId = @counter
					
					SET @counter += 1
				END
		END