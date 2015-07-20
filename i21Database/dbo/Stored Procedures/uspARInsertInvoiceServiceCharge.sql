﻿CREATE PROCEDURE [dbo].[uspARInsertInvoiceServiceCharge]
	@intEntityCustomerId	INT = 0,
	@intCompanyLocationId	INT = 0,
	@intCurrencyId			INT = 0,
	@intARAccountId			INT = 0,
	@intSCAccountId			INT = 0,	
	@tblTypeServiceCharge   [dbo].[ServiceChargeTableType] READONLY
AS
	DECLARE @dateNow		    DATE = CAST(GETDATE() AS DATE),
			@dblInvoiceSubtotal NUMERIC(18,6) = 0,
			@dblInvoiceTotal    NUMERIC(18,6) = 0,
			@dblAmountDue		NUMERIC(18,6) = 0,
			@dblAPRAmount       NUMERIC(18,6) = 0,
			@NewInvoiceId		INT
	
	SELECT @dblInvoiceSubtotal = SUM(dblSCAmount)
	     , @dblInvoiceTotal    = SUM(dblTotalAmount)
		 , @dblAmountDue       = SUM(dblAmountDue)
		 , @dblAPRAmount	   = SUM(dblAPRAmount)
	FROM @tblTypeServiceCharge

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
		,[strBillToCountry])
	SELECT 
		 @intEntityCustomerId
		,NULL --[strInvoiceOriginId]
		,@dateNow
		,[dbo].fnGetDueDateBasedOnTerm(@dateNow, intTermsId)
		,NULL --[dtmPostDate]
		,@intCurrencyId
		,@intCompanyLocationId
		,[intSalespersonId]
		,NULL --[dtmShipDate]
		,[intShipViaId]
		,NULL --[strPONumber]
		,[intTermsId]
		,@dblInvoiceSubtotal
		,0
		,0
		,@dblInvoiceTotal
		,0
		,@dblAmountDue
		,0
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
	FROM vyuARCustomerSearch
		WHERE intEntityCustomerId = @intEntityCustomerId

		--INSERT INVOICE DETAILS
	SET @NewInvoiceId = SCOPE_IDENTITY()

	DECLARE @totalCount INT = 0,
			@counter INT = 1

	SELECT @totalCount = COUNT(*) FROM @tblTypeServiceCharge
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
				,[dblAmountDue]
				,[dblTotalAmount]
				,0
			FROM @tblTypeServiceCharge WHERE intServiceChargeId = @counter

			UPDATE tblARInvoice SET ysnCalculated = 1 WHERE intInvoiceId = @intInvoiceIdToUpdate

			SET @counter += 1
		END	