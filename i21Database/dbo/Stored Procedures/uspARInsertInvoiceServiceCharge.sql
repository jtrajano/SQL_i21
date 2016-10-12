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

	IF ISNULL(@intCurrencyId, 0) = 0
		SELECT TOP 1 @intCurrencyId = intCurrencyId FROM tblARCustomer WHERE intEntityCustomerId = @intEntityCustomerId

	DECLARE @tempServiceChargeTable TABLE (
		 [intServiceChargeId]	INT
		,[intInvoiceId]			INT
		,[intBudgetId]			INT
		,[intEntityCustomerId]	INT
		,[strInvoiceNumber]		NVARCHAR(25)
		,[strBudgetDescription] NVARCHAR(100)
		,[dblAmountDue]			NUMERIC(18,6)
		,[dblTotalAmount]		NUMERIC(18,6))

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
				,[intEntityContactId]
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
				,ISNULL(@dtmAsOfDate, @dateNow)
				,@intCurrencyId
				,@intCompanyLocationId
				,[intSalespersonId]
				,[intEntityContactId]
				,ISNULL(@dtmAsOfDate, @dateNow)
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
				,NULL
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

				DECLARE @intInvoiceIdToUpdate INT = 0,
					    @intBudgetIdToUpdate  INT = 0

					SELECT @intInvoiceIdToUpdate = intInvoiceId
					     , @intBudgetIdToUpdate  = intBudgetId 
					FROM @tblTypeServiceCharge 
					WHERE intServiceChargeId = @intServiceChargeId

					INSERT INTO [tblARInvoiceDetail]
						([intInvoiceId]
						,[intSCInvoiceId]
						,[intSCBudgetId]
						,[strSCInvoiceNumber]
						,[strSCBudgetDescription]
						,[intServiceChargeAccountId]
						,[dblQtyOrdered]
						,[dblQtyShipped]
						,[dblPrice]
						,[dblTotal]
						,[intConcurrencyId])
					SELECT 	
						 @NewInvoiceId
						,[intInvoiceId]
						,[intBudgetId]
						,[strInvoiceNumber]
						,[strBudgetDesciption]
						,@intSCAccountId
						,1.000000
						,1.000000
						,[dblTotalAmount]
						,[dblTotalAmount]
						,0
					FROM @tblTypeServiceCharge WHERE intServiceChargeId = @intServiceChargeId

					DELETE FROM @tempServiceChargeTable WHERE intServiceChargeId = @intServiceChargeId
										
					IF ISNULL(@intInvoiceIdToUpdate, 0) > 0
						UPDATE tblARInvoice SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intInvoiceId = @intInvoiceIdToUpdate

					IF ISNULL(@intBudgetIdToUpdate, 0) > 0
						UPDATE tblARCustomerBudget SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intCustomerBudgetId = @intBudgetIdToUpdate

			END

			EXEC dbo.uspARReComputeInvoiceAmounts @NewInvoiceId
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
					,[strBudgetDescription]
					,[dblAmount]
					,[intConcurrencyId])
				SELECT 	
					 @newRecapId
					,[strInvoiceNumber]
					,[strBudgetDescription]				
					,[dblTotalAmount]
					,0
				FROM @tempServiceChargeTable 
				WHERE intServiceChargeId = @intServiceChargeId

				DELETE FROM @tempServiceChargeTable WHERE intServiceChargeId = @intServiceChargeId
			END			
		END