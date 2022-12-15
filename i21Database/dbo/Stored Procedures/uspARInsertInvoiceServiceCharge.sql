CREATE PROCEDURE [dbo].[uspARInsertInvoiceServiceCharge]
	@ysnRecap					BIT = 0,
	@batchId					NVARCHAR(100) = NULL,
	@intEntityCustomerId		INT = 0,
	@intEntityUserId			INT = 0,
	@intCompanyLocationId		INT = 0,
	@intCurrencyId				INT = 0,
	@intARAccountId				INT = 0,
	@intSCAccountId				INT = 0,
	@dtmAsOfDate				DATETIME = NULL,
	@strCalculation				NVARCHAR(25) = '',
	@dtmServiceChargeDate		DATETIME = NULL,
	@dtmServiceChargePostDate	DATETIME = NULL,
	@tblTypeServiceCharge		[dbo].[ServiceChargeTableType] READONLY,
	@tblTypeServiceChargeByCB	[dbo].[ServiceChargeTableType] READONLY
AS 
	DECLARE @dateNow							DATE = CAST(GETDATE() AS DATE),			
			@dblInvoiceTotal					NUMERIC(18,6) = 0,
			@NewInvoiceId						INT,
			@newComment							NVARCHAR(500) = NULL,
			@intServiceChargeId					INT,
			@intServiceChargeIdByCB				INT,
			@intCompTermsId						INT,
			@intDefaultCurrencyId				INT = 0,
			@intAccountsReceivableRateTypeId	INT = 0

	SELECT TOP 1 @intCompTermsId = intServiceChargeTermId FROM tblARCompanyPreference

	EXEC [dbo].[uspARGetDefaultComment] @intCompanyLocationId, @intEntityCustomerId, 'Invoice', 'Service Charge', @newComment OUT

	SELECT @dblInvoiceTotal    = SUM(dblTotalAmount)
	FROM @tblTypeServiceCharge

	IF ISNULL(@intCurrencyId, 0) = 0
		SELECT TOP 1 @intCurrencyId = intCurrencyId FROM tblARCustomer WHERE [intEntityId] = @intEntityCustomerId

	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	SELECT TOP 1 @intAccountsReceivableRateTypeId = intAccountsReceivableRateTypeId FROM tblSMMultiCurrency

	DECLARE @tempServiceChargeTable TABLE (
		 [intServiceChargeId]	INT
		,[intInvoiceId]			INT
		,[intBudgetId]			INT
		,[intEntityCustomerId]	INT
		,[strInvoiceNumber]		NVARCHAR(25)
		,[strBudgetDescription] NVARCHAR(100)
		,[dblAmountDue]			NUMERIC(18,6)
		,[dblTotalAmount]		NUMERIC(18,6)
		,[intServiceChargeDays]	INT NULL
		,intContractDetailId	INT NULL
		,dblServiceChargeAPR	NUMERIC(18,6)
	)

	DECLARE @tempServiceChargeTableByCB TABLE (
		 [intServiceChargeId]	INT
		,[intInvoiceId]			INT
		,[intBudgetId]			INT
		,[intEntityCustomerId]	INT
		,[strInvoiceNumber]		NVARCHAR(25)
		,[strBudgetDescription] NVARCHAR(100)
		,[dblAmountDue]			NUMERIC(18,6)
		,[dblTotalAmount]		NUMERIC(18,6)
		,[intServiceChargeDays]	INT NULL
		,intContractDetailId	INT NULL
		,dblServiceChargeAPR	NUMERIC(18,6)
	)

	INSERT INTO @tempServiceChargeTable
	SELECT * FROM @tblTypeServiceCharge 
	WHERE intEntityCustomerId = @intEntityCustomerId

	INSERT INTO @tempServiceChargeTableByCB
	SELECT * FROM @tblTypeServiceChargeByCB

	IF @ysnRecap = 0
	BEGIN
		--INSERT INVOICE HEADER
		INSERT INTO tblARInvoice(
			 [intEntityCustomerId]
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
			,[strComments]
		)
		SELECT 
			 @intEntityCustomerId
			,NULL --[strInvoiceOriginId]
			,ISNULL(@dtmServiceChargeDate, @dateNow)
			,[dbo].fnGetDueDateBasedOnTerm(ISNULL(@dtmServiceChargeDate, @dateNow), ISNULL(@intCompTermsId, intTermsId))
			,ISNULL(@dtmServiceChargePostDate, @dateNow)
			,@intCurrencyId
			,@intCompanyLocationId
			,[intSalespersonId]
			,[intEntityContactId]
			,ISNULL(@dtmAsOfDate, ISNULL(@dtmServiceChargeDate, @dateNow))
			,[intShipViaId]
			,NULL --[strPONumber]
			,ISNULL(@intCompTermsId, intTermsId)
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
			,@intEntityUserId
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
			WHERE [intEntityId] = @intEntityCustomerId

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

			INSERT INTO [tblARInvoiceDetail] (
				 [intInvoiceId]
				,[intSCInvoiceId]
				,[intSCBudgetId]
				,[strSCInvoiceNumber]
				,[strSCBudgetDescription]
				,[intServiceChargeAccountId]
				,[intSalesAccountId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblPrice]
				,[dblTotal]
				,[dblServiceChargeAmountDue]
				,[intContractDetailId]
				,[dblServiceChargeAPR]
				,[intConcurrencyId]
				,[intSubCurrencyId]
				,[dblCurrencyExchangeRate]
				,[intCurrencyExchangeRateId]
				,[intCurrencyExchangeRateTypeId]
			)
			SELECT 	
				 @NewInvoiceId
				,[intInvoiceId]
				,[intBudgetId]
				,[strInvoiceNumber]
				,[strBudgetDesciption]
				,@intSCAccountId
				,@intSCAccountId
				,1.000000
				,1.000000
				,[dblTotalAmount]
				,[dblTotalAmount]
				,[dblAmountDue]
				,[intContractDetailId]
				,[dblServiceChargeAPR]
				,0
				,@intCurrencyId
				,CASE WHEN @intDefaultCurrencyId = @intCurrencyId THEN 1 ELSE ISNULL(CE.dblRate, 1) END
				,CASE WHEN @intDefaultCurrencyId = @intCurrencyId THEN NULL ELSE CE.intCurrencyExchangeRateId END
				,CASE WHEN @intDefaultCurrencyId = @intCurrencyId THEN NULL ELSE CE.intCurrencyExchangeRateTypeId END
			FROM @tblTypeServiceCharge 
			OUTER APPLY (
				SELECT TOP 1 
					 SMCERD.dblRate
					,SMCERD.intCurrencyExchangeRateId
					,SMCERT.intCurrencyExchangeRateTypeId
				FROM tblSMCurrencyExchangeRateDetail SMCERD
				INNER JOIN tblSMCurrencyExchangeRate SMCER 
				ON SMCERD.intCurrencyExchangeRateId = SMCER.intCurrencyExchangeRateId 
				AND SMCER.intFromCurrencyId = @intCurrencyId
				AND SMCER.intToCurrencyId = @intDefaultCurrencyId
				INNER JOIN tblSMCurrencyExchangeRateType AS SMCERT 
				ON SMCERD.intRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
				AND SMCERT.intCurrencyExchangeRateTypeId = @intAccountsReceivableRateTypeId
				WHERE SMCERD.dtmValidFromDate <= @dateNow
				ORDER BY SMCERD.dtmValidFromDate DESC
			) CE
			WHERE intServiceChargeId = @intServiceChargeId


			DELETE FROM @tempServiceChargeTable WHERE intServiceChargeId = @intServiceChargeId
			
			IF (@strCalculation = 'By Invoice')
			BEGIN					
				IF ISNULL(@intInvoiceIdToUpdate, 0) > 0
					UPDATE tblARInvoice SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intInvoiceId = @intInvoiceIdToUpdate

				IF ISNULL(@intBudgetIdToUpdate, 0) > 0
					UPDATE tblARCustomerBudget SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intCustomerBudgetId = @intBudgetIdToUpdate
			END
		END

		IF (@strCalculation = 'By Customer Balance')
			BEGIN
				WHILE EXISTS(SELECT NULL FROM @tempServiceChargeTableByCB)
					BEGIN
						SELECT TOP 1 @intServiceChargeIdByCB = intServiceChargeId FROM @tempServiceChargeTableByCB ORDER BY intServiceChargeId ASC
						DECLARE @intInvoiceIdByCB INT = 0
								, @intBudgetIdByCB  INT = 0

						SELECT @intInvoiceIdByCB = intInvoiceId
								, @intBudgetIdByCB  = intBudgetId 
						FROM @tempServiceChargeTableByCB 
						WHERE intServiceChargeId = @intServiceChargeIdByCB

						IF ISNULL(@intServiceChargeIdByCB, 0) > 0
							UPDATE tblARInvoice SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intInvoiceId = @intInvoiceIdByCB

						IF ISNULL(@intBudgetIdByCB, 0) > 0
							UPDATE tblARCustomerBudget SET ysnCalculated = 1, dtmCalculated = @dtmAsOfDate WHERE intCustomerBudgetId = @intBudgetIdByCB

						DELETE FROM @tempServiceChargeTableByCB WHERE intServiceChargeId = @intServiceChargeIdByCB
					END
			END

		EXEC dbo.uspARReComputeInvoiceAmounts @NewInvoiceId
	END
	ELSE
	BEGIN
		DECLARE @newRecapId		 INT			       
		
		--INSERT INTO RECAP TABLE
		INSERT INTO tblARServiceChargeRecap(
			 [strBatchId]
			,[intEntityId]
			,[intServiceChargeAccountId]
			,[dtmServiceChargeDate]
			,[dblTotalAmount]
			,[intCurrencyId]
			,[intCompanyLocationId]
		)
		SELECT 
			 @batchId
			,@intEntityCustomerId
			,@intSCAccountId
			,@dtmServiceChargeDate
			,@dblInvoiceTotal
			,@intCurrencyId
			,@intCompanyLocationId

		--INSERT INTO RECAP DETAIL TABLE
		SET @newRecapId = SCOPE_IDENTITY()
		
		WHILE EXISTS(SELECT NULL FROM @tempServiceChargeTable)
		BEGIN
			SELECT TOP 1 @intServiceChargeId = intServiceChargeId FROM @tempServiceChargeTable ORDER BY intServiceChargeId ASC

			INSERT INTO [tblARServiceChargeRecapDetail](
				 [intSCRecapId]
				,[intInvoiceId]
				,[strInvoiceNumber]
				,[strBudgetDescription]
				,[dblAmount]
				,[intServiceChargeDays]
				,[intConcurrencyId]
			)
			SELECT 	
				 @newRecapId
				,[intInvoiceId]
				,[strInvoiceNumber]
				,[strBudgetDescription]				
				,[dblTotalAmount]
				,[intServiceChargeDays]
				,0
			FROM @tempServiceChargeTable 
			WHERE intServiceChargeId = @intServiceChargeId

			DELETE FROM @tempServiceChargeTable WHERE intServiceChargeId = @intServiceChargeId
		END			
	END