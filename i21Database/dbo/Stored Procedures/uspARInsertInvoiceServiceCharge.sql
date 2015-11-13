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
			@intServiceChargeId INT

	EXEC [dbo].[uspARGetDefaultComment] @intCompanyLocationId, @intEntityCustomerId, 'Invoice', 'Service Charge', @newComment OUT

	SELECT @dblInvoiceTotal    = SUM(dblTotalAmount)
	FROM @tblTypeServiceCharge

	DECLARE @tempServiceChargeTable TABLE (
		 [intServiceChargeId]  INT
		,[intInvoiceId]		   INT
		,[intEntityCustomerId] INT
		,[strInvoiceNumber]    NVARCHAR(25)
		,[dblAmountDue]		   NUMERIC(18,6)
		,[dblTotalAmount]	   NUMERIC(18,6))

	INSERT INTO @tempServiceChargeTable
	SELECT * FROM @tblTypeServiceCharge 
	WHERE intEntityCustomerId = @intEntityCustomerId

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
			
			WHILE EXISTS(SELECT NULL FROM @tempServiceChargeTable)
			BEGIN
				SELECT TOP 1 @intServiceChargeId = intServiceChargeId FROM @tempServiceChargeTable ORDER BY intServiceChargeId ASC

				DECLARE @intInvoiceIdToUpdate INT = 0

					SELECT @intInvoiceIdToUpdate = intInvoiceId FROM @tblTypeServiceCharge WHERE intServiceChargeId = @intServiceChargeId

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
					FROM @tblTypeServiceCharge WHERE intServiceChargeId = @intServiceChargeId

					UPDATE tblARInvoice SET ysnCalculated = 1 WHERE intInvoiceId = @intInvoiceIdToUpdate
			END
		END
	ELSE
		BEGIN
			DECLARE @newRecapId		 INT			       
			
			--INSERT INTO RECAP TABLE
			INSERT INTO tblARServiceChargeRecap
				([strBatchId]
				,[intEntityId]
				,[intServiceChargeAccountId]
				,[dtmServiceChargeDate]
				,[dblTotalAmount])
			SELECT @batchId
				 , @intEntityCustomerId
				 , @intSCAccountId
				 , @dtmAsOfDate
				 , @dblInvoiceTotal

			--INSERT INTO RECAP DETAIL TABLE
			SET @newRecapId = SCOPE_IDENTITY()
			
			WHILE EXISTS(SELECT NULL FROM @tempServiceChargeTable)
			BEGIN
				SELECT TOP 1 @intServiceChargeId = intServiceChargeId FROM @tempServiceChargeTable ORDER BY intServiceChargeId ASC

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
				FROM @tempServiceChargeTable 
				WHERE intServiceChargeId = @intServiceChargeId

				DELETE FROM @tempServiceChargeTable WHERE intServiceChargeId = @intServiceChargeId
			END			
		END