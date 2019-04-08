CREATE PROCEDURE [dbo].[uspARPOSMixedTransaction]
	@intPOSId INT,
	@intEntityUserId INT,
	@ErrorMessage VARCHAR(MAX) OUTPUT,
	@CreatedInvoices VARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @EntriesForInvoice 		InvoiceIntegrationStagingTable
	DECLARE @TaxDetails 			LineItemTaxDetailStagingTable

	BEGIN TRANSACTION

	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CASH')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Cash'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END
	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CHECK')
		BEGIN
			INSERT INTO tblSMPaymentMethod (
				  strPaymentMethod
				, intNumber
				, ysnActive
				, intSort
				, intConcurrencyId
			)
			SELECT strPaymentMethod = 'Check'
				, intNumber		 	= 1
				, ysnActive			= 1
				, intSort			= 0
				, intConcurrencyId	= 1
		END
	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CREDIT CARD')
		BEGIN
			INSERT INTO tblSMPaymentMethod (
				  strPaymentMethod
				, intNumber
				, ysnActive
				, intSort
				, intConcurrencyId
			)
			SELECT strPaymentMethod = 'Credit Card'
				, intNumber		 	= 1
				, ysnActive			= 1
				, intSort			= 0
				, intConcurrencyId	= 1
		END
	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'DEBIT CARD')
		BEGIN
			INSERT INTO tblSMPaymentMethod (
				  strPaymentMethod
				, intNumber
				, ysnActive
				, intSort
				, intConcurrencyId
			)
			SELECT strPaymentMethod = 'Debit Card'
				, intNumber		 	= 1
				, ysnActive			= 1
				, intSort			= 0
				, intConcurrencyId	= 1
		END
	IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'DEBIT MEMOS AND PAYMENTS')
		BEGIN
			INSERT INTO tblSMPaymentMethod (
				  strPaymentMethod
				, intNumber
				, ysnActive
				, intSort
				, intConcurrencyId
			)
			SELECT strPaymentMethod = 'Debit Memos and Payments'
				, intNumber		 	= 1
				, ysnActive			= 1
				, intSort			= 0
				, intConcurrencyId	= 1
		END
	--INSERT POSITIVE TRANSACTION (INVOICE)
	INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[dtmDate]
	,[dtmShipDate]
	,[strComments]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[ysnRecomputeTax]
	,[ysnClearDetailTaxes]					
	,[intTempDetailIdForTaxes]
	,[dblCurrencyExchangeRate]
	,[dblSubCurrencyRate]
	,[intSalesAccountId]
	,[strPONumber]
	,[intFreightTermId]
	)
	SELECT
		 [strTransactionType]					= 'Invoice'
		,[strType]								= 'POS'
		,[strSourceTransaction]					= 'POS'
		,[intSourceId]							= @intPOSId
		,[strSourceId]							= POS.strReceiptNumber
		,[intEntityCustomerId]					= POS.intEntityCustomerId
		,[intCompanyLocationId]					= POS.intCompanyLocationId
		,[intCurrencyId]						= POS.intCurrencyId
		,[dtmDate]								= POS.dtmDate
		,[dtmShipDate]							= POS.dtmDate
		,[strComments]							= POS.strComment
		,[intEntityId]							= POS.intEntityUserId
		,[ysnPost]								= 1
		,[intItemId]							= DETAILS.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= DETAILS.strItemDescription 
		,[intItemUOMId]							= DETAILS.intItemUOMId
		,[dblQtyShipped]						= DETAILS.dblQuantity 
		,[dblDiscount]							= 0
		,[dblPrice]								= (DETAILS.dblExtendedPrice / DETAILS.dblQuantity)
		,[ysnRefreshPrice]						= 0
		,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @intPOSId
		,[dblCurrencyExchangeRate]				= 1.000000
		,[dblSubCurrencyRate]					= 1.000000
		,[intSalesAccountId]					= NULL
		,[strPONumber]							= POS.strPONumber
		,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
	FROM tblARPOS POS
	INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
	INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
	WHERE POS.intPOSId = @intPOSId
	AND DETAILS.dblQuantity > 0

	UNION ALL

	SELECT TOP 1
		 [strTransactionType]					= 'Invoice'
		,[strType]								= 'POS'
		,[strSourceTransaction]					= 'POS'
		,[intSourceId]							= @intPOSId
		,[strSourceId]							= POS.strReceiptNumber
		,[intEntityCustomerId]					= POS.intEntityCustomerId
		,[intCompanyLocationId]					= POS.intCompanyLocationId
		,[intCurrencyId]						= POS.intCurrencyId
		,[dtmDate]								= POS.dtmDate
		,[dtmShipDate]							= POS.dtmDate
		,[strComments]							= POS.strComment
		,[intEntityId]							= POS.intEntityUserId
		,[ysnPost]								= 1
		,[intItemId]							= NULL
		,[ysnInventory]							= 0
		,[strItemDescription]					= 'POS Discount - ' + CAST(CAST(POS.dblDiscountPercent AS INT) AS VARCHAR(3)) + '%'
		,[intItemUOMId]							= NULL
		,[dblQtyShipped]						= 1.000000
		,[dblDiscount]							= NULL
		,[dblPrice]								= POS.dblDiscount * -1
		,[ysnRefreshPrice]						= 0
		,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @intPOSId
		,[dblCurrencyExchangeRate]				= 1.000000
		,[dblSubCurrencyRate]					= 1.000000
		,[intSalesAccountId]					= ISNULL(COMPANYLOC.intDiscountAccountId, COMPANYPREF.intDiscountAccountId)
		,[strPONumber]							= POS.strPONumber
		,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN COMPANYLOC.intFreightTermId ELSE NULL END
	FROM tblARPOS POS
	OUTER APPLY (
		SELECT TOP 1 intDiscountAccountId 
		FROM tblARCompanyPreference WITH (NOLOCK)
	) COMPANYPREF
	LEFT JOIN (
		SELECT intDiscountAccountId
			 , intCompanyLocationId
			 , intFreightTermId
		FROM tblSMCompanyLocation WITH (NOLOCK)
	) COMPANYLOC ON POS.intCompanyLocationId = COMPANYLOC.intCompanyLocationId
	WHERE POS.intPOSId = @intPOSId
	  AND ISNULL(dblDiscountPercent, 0) > 0
	--END OF INSERT POSITIVE TRANSACTION

	--INSERT NEGATIVE TRANSACTION (CREDIT MEMO)
	INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[dtmDate]
	,[dtmShipDate]
	,[strComments]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[ysnRecomputeTax]
	,[ysnClearDetailTaxes]					
	,[intTempDetailIdForTaxes]
	,[dblCurrencyExchangeRate]
	,[dblSubCurrencyRate]
	,[intSalesAccountId]
	,[strPONumber]
	,[intFreightTermId]
	)
	SELECT
		 [strTransactionType]					= 'Credit Memo'
		,[strType]								= 'POS'
		,[strSourceTransaction]					= 'POS'
		,[intSourceId]							= @intPOSId
		,[strSourceId]							= POS.strReceiptNumber
		,[intEntityCustomerId]					= POS.intEntityCustomerId
		,[intCompanyLocationId]					= POS.intCompanyLocationId
		,[intCurrencyId]						= POS.intCurrencyId
		,[dtmDate]								= POS.dtmDate
		,[dtmShipDate]							= POS.dtmDate
		,[strComments]							= POS.strComment
		,[intEntityId]							= POS.intEntityUserId
		,[ysnPost]								= 1
		,[intItemId]							= DETAILS.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= DETAILS.strItemDescription 
		,[intItemUOMId]							= DETAILS.intItemUOMId
		,[dblQtyShipped]						= ABS(DETAILS.dblQuantity)
		,[dblDiscount]							= 0
		,[dblPrice]								= (DETAILS.dblExtendedPrice / DETAILS.dblQuantity)
		,[ysnRefreshPrice]						= 0
		,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @intPOSId
		,[dblCurrencyExchangeRate]				= 1.000000
		,[dblSubCurrencyRate]					= 1.000000
		,[intSalesAccountId]					= NULL
		,[strPONumber]							= POS.strPONumber
		,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
	FROM tblARPOS POS 
	INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
	INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
	WHERE POS.intPOSId = @intPOSId
	AND DETAILS.dblQuantity < 0

	UNION ALL

	SELECT TOP 1
		 [strTransactionType]					= 'Credit Memo'
		,[strType]								= 'POS'
		,[strSourceTransaction]					= 'POS'
		,[intSourceId]							= @intPOSId
		,[strSourceId]							= POS.strReceiptNumber
		,[intEntityCustomerId]					= POS.intEntityCustomerId
		,[intCompanyLocationId]					= POS.intCompanyLocationId
		,[intCurrencyId]						= POS.intCurrencyId
		,[dtmDate]								= POS.dtmDate
		,[dtmShipDate]							= POS.dtmDate
		,[strComments]							= POS.strComment
		,[intEntityId]							= POS.intEntityUserId
		,[ysnPost]								= 1
		,[intItemId]							= NULL
		,[ysnInventory]							= 0
		,[strItemDescription]					= 'POS Discount - ' + CAST(CAST(POS.dblDiscountPercent AS INT) AS VARCHAR(3)) + '%'
		,[intItemUOMId]							= NULL
		,[dblQtyShipped]						= 1.000000
		,[dblDiscount]							= NULL
		,[dblPrice]								= POS.dblDiscount * -1
		,[ysnRefreshPrice]						= 0
		,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= @intPOSId
		,[dblCurrencyExchangeRate]				= 1.000000
		,[dblSubCurrencyRate]					= 1.000000
		,[intSalesAccountId]					= ISNULL(COMPANYLOC.intDiscountAccountId, COMPANYPREF.intDiscountAccountId)
		,[strPONumber]							= POS.strPONumber
		,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN COMPANYLOC.intFreightTermId ELSE NULL END
	FROM tblARPOS POS
	OUTER APPLY (
		SELECT TOP 1 intDiscountAccountId 
		FROM tblARCompanyPreference WITH (NOLOCK)
	) COMPANYPREF
	LEFT JOIN (
		SELECT intDiscountAccountId
			 , intCompanyLocationId
			 , intFreightTermId
		FROM tblSMCompanyLocation WITH (NOLOCK)
	) COMPANYLOC ON POS.intCompanyLocationId = COMPANYLOC.intCompanyLocationId
	WHERE POS.intPOSId = @intPOSId
	  AND ISNULL(dblDiscountPercent, 0) > 0
	--END OF INSERT NEGATIVE TRANSACTION

	EXEC uspARProcessInvoices @InvoiceEntries		= @EntriesForInvoice
							, @LineItemTaxEntries	= @TaxDetails
							, @UserId				= @intEntityUserId
							, @GroupingOption		= 0
							, @RaiseError			= 1
							, @ErrorMessage			= @ErrorMessage OUTPUT
							, @CreatedIvoices		= @CreatedInvoices OUTPUT

	IF (ISNULL(@ErrorMessage,'')='')
	BEGIN
		COMMIT TRANSACTION

		IF(ISNULL(@CreatedInvoices, '') <> '')
		BEGIN

			DECLARE @cashPaymentMethodId	INT

			--Variables for Invoice
			DECLARE   @dblInvoiceTotal		NUMERIC(18,6) = 0
					, @dblTotalAmountPaid	NUMERIC(18,6) = 0
					, @dblCounter			NUMERIC(18,6) = 0
					, @intNewInvoiceId		INT = NULL
			
			--Variables for CreditMemo
			DECLARE	  @intNewCreditMemoId	INT = NULL
					, @dblCreditMemoTotal	NUMERIC(18,6) = 0
					
			SELECT TOP 1 @intNewInvoiceId = intInvoiceId
						,@dblInvoiceTotal = dblInvoiceTotal
			FROM tblARInvoice I
			INNER JOIN fnGetRowsFromDelimitedValues(@CreatedInvoices) CI ON I.intInvoiceId = CI.intID
			WHERE strTransactionType = 'Invoice'

			SELECT TOP 1 @intNewCreditMemoId = intInvoiceId
						,@dblCreditMemoTotal = dblInvoiceTotal
			FROM tblARInvoice I
			INNER JOIN fnGetRowsFromDelimitedValues(@CreatedInvoices) CI ON I.intInvoiceId = CI.intID
			WHERE strTransactionType = 'Credit Memo'
			
			SELECT TOP 1  @cashPaymentMethodId = intPaymentMethodID
			FROM tblSMPaymentMethod
			WHERE strPaymentMethod = 'Debit Memos and Payments'
					
			UPDATE tblARInvoice
			SET  ysnReturned = 1
				,ysnRefundProcessed = 1
			WHERE intInvoiceId = @intNewCreditMemoId

			UPDATE tblARPOS
			SET
				intInvoiceId = @intNewInvoiceId
				,intCreditMemoId = @intNewCreditMemoId
			WHERE intPOSId = @intPOSId
			
			DECLARE @EntriesForExchange		PaymentIntegrationStagingTable
				  , @LogId					INT			  = NULL
				  , @strPaymentIds			NVARCHAR(MAX) = NULL
				  , @dblOnAccountAmount		NUMERIC(18,6) = 0

			--CREATE RCV WITH INVOICE & CREDIT MEMO AS DETAILS
			IF (ISNULL(@intNewInvoiceId,0) <> 0 AND ISNULL(@intNewCreditMemoId, 0) <> 0)
			BEGIN
			
				INSERT INTO @EntriesForExchange(
				--Header
				 intId
				,strSourceTransaction
				,intSourceId
				,strSourceId
				,intEntityCustomerId
				,intCompanyLocationId
				,intCurrencyId
				,dtmDatePaid
				,intPaymentMethodId
				,strPaymentMethod
				,strPaymentInfo
				,intBankAccountId
				,dblAmountPaid
				,intEntityId
				,ysnPost
				,strNotes
			--Detail
				,intInvoiceId
				,strTransactionType
				,strTransactionNumber
				,intTermId
				,intInvoiceAccountId
				,dblInvoiceTotal
				,dblBaseInvoiceTotal
				,dblPayment
				,dblAmountDue
				,dblBaseAmountDue
				,strInvoiceReportNumber
				,intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId
				,dblCurrencyExchangeRate
				)
				SELECT 
				--Header
					 intId							= @intPOSId
					,strSourceTransaction			= 'Direct'
					,intSourceId					= INV.intInvoiceId
					,strSourceId					= INV.strInvoiceNumber
					,intEntityCustomerId			= INV.intEntityCustomerId
					,intCompanyLocationId			= INV.intCompanyLocationId
					,intCurrencyId					= INV.intCurrencyId
					,dtmDatePaid					= GETDATE()
					,intPaymentMethodId				= @cashPaymentMethodId
					,strPaymentMethod				= 'Debit Memos and Payments'
					,strPaymentInfo					= ''
					,intBankAccountId				= BA.intBankAccountId
					,dblAmountPaid					= 0
					,intEntityId					= @intEntityUserId
					,ysnPost						= 1
					,strNotes						= 'POS Exchange Item Transaction'
				--Detail
					,intInvoiceId					= INV.intInvoiceId
					,strTransactionType				= INV.strTransactionType
					,strTransactionNumber			= INV.strInvoiceNumber
					,intTermId						= INV.intTermId
					,intInvoiceAccountId			= INV.intAccountId
					,dblInvoiceTotal				= INV.dblInvoiceTotal
					,dblBaseInvoiceTotal			= INV.dblBaseInvoiceTotal
					,dblPayment						= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN @dblInvoiceTotal ELSE @dblCreditMemoTotal END
					,dblAmountDue					= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN 0 ELSE POS.dblTotal END 
					,dblBaseAmountDue				= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN 0 ELSE POS.dblTotal END
					,strInvoiceReportNumber			= INV.strInvoiceNumber
					,intCurrencyExchangeRateTypeId	= INV.intCurrencyExchangeRateTypeId
					,intCurrencyExchangeRateId		= INV.intCurrencyExchangeRateId
					,dblCurrencyExchangeRate		= INV.dblCurrencyExchangeRate
				FROM tblARPOS POS
				INNER JOIN vyuARInvoicesForPayment INV ON POS.intPOSId = INV.intSourceId
				INNER JOIN tblSMCompanyLocation CL ON INV.intCompanyLocationId = CL.intCompanyLocationId
				INNER JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
				WHERE INV.intInvoiceId = @intNewInvoiceId
				UNION
				SELECT 
				--Header
					 intId							= @intPOSId
					,strSourceTransaction			= 'Direct'
					,intSourceId					= CM.intInvoiceId
					,strSourceId					= CM.strInvoiceNumber
					,intEntityCustomerId			= CM.intEntityCustomerId
					,intCompanyLocationId			= CM.intCompanyLocationId
					,intCurrencyId					= CM.intCurrencyId
					,dtmDatePaid					= GETDATE()
					,intPaymentMethodId				= @cashPaymentMethodId
					,strPaymentMethod				= 'Debit Memos and Payments'
					,strPaymentInfo					= ''
					,intBankAccountId				= BA.intBankAccountId
					,dblAmountPaid					= 0
					,intEntityId					= @intEntityUserId
					,ysnPost						= 1
					,strNotes						= 'POS Exchange Item Transaction'
				--Detail
					,intInvoiceId					= CM.intInvoiceId
					,strTransactionType				= CM.strTransactionType
					,strTransactionNumber			= CM.strInvoiceNumber
					,intTermId						= CM.intTermId
					,intInvoiceAccountId			= CM.intAccountId
					,dblInvoiceTotal				= CM.dblInvoiceTotal
					,dblBaseInvoiceTotal			= CM.dblBaseInvoiceTotal
					,dblPayment						= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN @dblInvoiceTotal ELSE @dblCreditMemoTotal END
					,dblAmountDue					= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN 0 ELSE POS.dblTotal END
					,dblBaseAmountDue				= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN 0 ELSE POS.dblTotal END
					,strInvoiceReportNumber			= CM.strInvoiceNumber
					,intCurrencyExchangeRateTypeId	= CM.intCurrencyExchangeRateTypeId
					,intCurrencyExchangeRateId		= CM.intCurrencyExchangeRateId
					,dblCurrencyExchangeRate		= CM.dblCurrencyExchangeRate
				FROM tblARPOS POS
				INNER JOIN vyuARInvoicesForPayment CM ON POS.intPOSId = CM.intSourceId
				INNER JOIN tblSMCompanyLocation CL ON CM.intCompanyLocationId = CL.intCompanyLocationId
				INNER JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
				WHERE CM.intInvoiceId = @intNewCreditMemoId

				EXEC uspARProcessPayments @PaymentEntries	= @EntriesForExchange
										, @UserId			= @intEntityUserId
										, @GroupingOption	= 1
										, @RaiseError		= 1
										, @ErrorMessage		= @ErrorMessage OUTPUT

				IF(OBJECT_ID('tempdb..#MIXEDPOSPAYMENTS') IS NOT NULL)
				BEGIN
					DROP TABLE #MIXEDPOSPAYMENTS
				END

				SELECT
						intPOSId			= intPOSId
					   ,intPOSPaymentId		= intPOSPaymentId
					   ,strPaymentMethod	= CASE WHEN strPaymentMethod = 'Credit Card' THEN 'Manual Credit Card' ELSE strPaymentMethod END
					   ,strReferenceNo		= strReferenceNo
					   ,dblAmount			= dblAmount
					   ,ysnComputed			= CAST (0 AS BIT)
				INTO #MIXEDPOSPAYMENTS
				FROM tblARPOSPayment WITH (NOLOCK)
				WHERE intPOSId = @intPOSId
					AND ISNULL(strPaymentMethod,'') <> 'On Account'

				SELECT @dblTotalAmountPaid = SUM(dblAmount)
				FROM #MIXEDPOSPAYMENTS
				
				--UPDATE OVERPAYMENTS
				IF(@dblInvoiceTotal > ABS(@dblCreditMemoTotal))
				BEGIN
					DECLARE @dblTransactionAmountDue DECIMAL(18,6)
					SET @dblTransactionAmountDue = @dblInvoiceTotal - ABS(@dblCreditMemoTotal)

					IF (ABS(ISNULL(@dblTotalAmountPaid, 0)) > ISNULL(@dblTransactionAmountDue, 0))
					BEGIN
						SET @dblCounter = 0

						WHILE EXISTS (SELECT TOP 1 NULL FROM #MIXEDPOSPAYMENTS WHERE ysnComputed = 0)
						BEGIN
							DECLARE @intPOSPaymentId	INT
								  , @dblAmount			NUMERIC(18, 6)	= 0
								  , @dblDiscrepancy		NUMERIC(18, 6)	= 0

							SELECT TOP 1 @intPOSPaymentId = intPOSPaymentId
									   , @dblAmount		  = dblAmount
							FROM #MIXEDPOSPAYMENTS
							WHERE ysnComputed = 0

							IF @dblCounter + @dblAmount <= @dblTransactionAmountDue
								BEGIN
									SET @dblCounter = @dblCounter + @dblAmount
									UPDATE #MIXEDPOSPAYMENTS SET ysnComputed = 1 WHERE intPOSPaymentId = @intPOSPaymentId
								END
							ELSE 
								BEGIN
									SET @dblDiscrepancy = (@dblCounter + @dblAmount) - @dblTransactionAmountDue

									UPDATE #MIXEDPOSPAYMENTS SET ysnComputed = 1, dblAmount = (@dblAmount - @dblDiscrepancy) WHERE intPOSPaymentId = @intPOSPaymentId
									UPDATE tblARPOSPayment SET dblAmount = (@dblAmount - @dblDiscrepancy) WHERE intPOSPaymentId = @intPOSPaymentId

									DELETE FROM tblARPOSPayment WHERE intPOSPaymentId IN (SELECT intPOSPaymentId FROM #MIXEDPOSPAYMENTS WHERE ysnComputed = 0)
									DELETE FROM #MIXEDPOSPAYMENTS WHERE ysnComputed = 0
								END
						END
					END
				END
				--END OF UPDATE OVERPAYMENTS

				--CREATE PAYMENTS FOR AMOUNT DUE
				IF(EXISTS(SELECT TOP 1 NULL FROM #MIXEDPOSPAYMENTS))
				BEGIN
				
					DECLARE @EntriesForAmountDuePayment		PaymentIntegrationStagingTable

					SELECT @dblOnAccountAmount = SUM(dblAmount)
					FROM tblARPOSPayment WITH (NOLOCK)
					WHERE intPOSId = @intPOSId
					AND ISNULL(strPaymentMethod,'') = 'On Account'

					INSERT INTO @EntriesForAmountDuePayment(
						--Header
						 intId
						,strSourceTransaction
						,intSourceId
						,strSourceId
						,intEntityCustomerId
						,intCompanyLocationId
						,intCurrencyId
						,dtmDatePaid
						,intPaymentMethodId
						,strPaymentMethod
						,strPaymentInfo
						,intBankAccountId
						,dblAmountPaid
						,intEntityId
						,ysnPost
						,strNotes
					--Detail
						,intInvoiceId
						,strTransactionType
						,strTransactionNumber
						,intTermId
						,intInvoiceAccountId
						,dblInvoiceTotal
						,dblBaseInvoiceTotal
						,dblPayment
						,dblAmountDue
						,dblBaseAmountDue
						,strInvoiceReportNumber
						,intCurrencyExchangeRateTypeId
						,intCurrencyExchangeRateId
						,dblCurrencyExchangeRate
						)
						SELECT 
						--Header
							 intId							= POSPAYMENTS.intPOSPaymentId
							,strSourceTransaction			= 'Direct'
							,intSourceId					= INV.intInvoiceId
							,strSourceId					= INV.strInvoiceNumber
							,intEntityCustomerId			= INV.intEntityCustomerId
							,intCompanyLocationId			= INV.intCompanyLocationId
							,intCurrencyId					= INV.intCurrencyId
							,dtmDatePaid					= GETDATE()
							,intPaymentMethodId				= PM.intPaymentMethodID
							,strPaymentMethod				= PM.strPaymentMethod
							,strPaymentInfo					= CASE WHEN POSPAYMENTS.strPaymentMethod IN ('Check', 'Debit Card', 'Manual Credit Card') THEN strReferenceNo ELSE NULL END
							,intBankAccountId				= BA.intBankAccountId
							,dblAmountPaid					= ISNULL(POSPAYMENTS.dblAmount,0)
							,intEntityId					= @intEntityUserId
							,ysnPost						= 1
							,strNotes						= 'POS Settle Amount Due of Exchange Transaction'
						--Detail
							,intInvoiceId					= INV.intInvoiceId
							,strTransactionType				= INV.strTransactionType
							,strTransactionNumber			= INV.strInvoiceNumber
							,intTermId						= INV.intTermId
							,intInvoiceAccountId			= INV.intAccountId
							,dblInvoiceTotal				= INV.dblInvoiceTotal
							,dblBaseInvoiceTotal			= INV.dblBaseInvoiceTotal
							,dblPayment						= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN ABS(ISNULL(POSPAYMENTS.dblAmount,0)) * -1 ELSE ISNULL(POSPAYMENTS.dblAmount,0) END
							,dblAmountDue					= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN ISNULL(INV.dblAmountDue,0) ELSE ISNULL(@dblOnAccountAmount, 0) END 
							,dblBaseAmountDue				= CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal THEN ISNULL(INV.dblAmountDue,0) ELSE ISNULL(@dblOnAccountAmount, 0) END
							,strInvoiceReportNumber			= INV.strInvoiceNumber
							,intCurrencyExchangeRateTypeId	= INV.intCurrencyExchangeRateTypeId
							,intCurrencyExchangeRateId		= INV.intCurrencyExchangeRateId
							,dblCurrencyExchangeRate		= INV.dblCurrencyExchangeRate
						FROM #MIXEDPOSPAYMENTS POSPAYMENTS
						INNER JOIN tblARPOS	POS ON POSPAYMENTS.intPOSId = POS.intPOSId
						INNER JOIN vyuARInvoicesForPayment INV ON (--IF RETURN IS GREATER THAN PAYMENT THEN GET CREDITMEMO
																		CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal
																		THEN POS.intCreditMemoId
																		ELSE POS.intInvoiceId
																		END
																	 ) = INV.intInvoiceId
						INNER JOIN tblSMCompanyLocation CL ON INV.intCompanyLocationId = CL.intCompanyLocationId
						INNER JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
						CROSS APPLY(
							SELECT TOP 1 intPaymentMethodID
										,strPaymentMethod
							FROM tblSMPaymentMethod WITH (NOLOCK)
							WHERE ((POSPAYMENTS.strPaymentMethod = 'Debit Card' AND strPaymentMethod = 'Debit Card') OR (POSPAYMENTS.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENTS.strPaymentMethod))
						)PM
						WHERE INV.intInvoiceId = (--IF RETURN IS GREATER THAN PAYMENT THEN GET CREDITMEMO
													CASE WHEN ABS(@dblCreditMemoTotal) > @dblInvoiceTotal
													THEN @intNewCreditMemoId
													ELSE @intNewInvoiceId
													END
												 )

				EXEC uspARProcessPayments @PaymentEntries	= @EntriesForAmountDuePayment
										, @UserId			= @intEntityUserId
										, @GroupingOption	= 0
										, @RaiseError		= 1
										, @ErrorMessage		= @ErrorMessage OUTPUT
				END

				--END OF CREATE PAYMENTS FOR AMOUNT DUE

				--UPDATE POSPAYMENTS REFERENCE
				UPDATE POSPAYMENT
				SET intPaymentId = CREATEDPAYMENTS.intPaymentId
				FROM tblARPOSPayment POSPAYMENT
				INNER JOIN(
					SELECT
						intPaymentId
						,strPaymentMethod = CASE WHEN strPaymentMethod = 'Manual Credit Card' THEN 'Credit Card' ELSE strPaymentMethod END
					FROM tblARPayment P
					INNER JOIN fnGetRowsFromDelimitedValues(@strPaymentIds) CP ON P.intPaymentId = CP.intID
				)CREATEDPAYMENTS ON POSPAYMENT.strPaymentMethod = CREATEDPAYMENTS.strPaymentMethod
				INNER JOIN #MIXEDPOSPAYMENTS PP ON POSPAYMENT.intPOSPaymentId = PP.intPOSPaymentId
				
				--UPDATE POS ENDING BALANCE
				DECLARE @dblCashReceipt DECIMAL(18,6) = 0.000000

				SELECT @dblCashReceipt = ABS(SUM(dblAmount))
				FROM #MIXEDPOSPAYMENTS
				WHERE intPOSId = @intPOSId
				AND strPaymentMethod IN ('Cash', 'Check')

				--VARIABLE FOR REPLACE IN TEMPLATE
				DECLARE  @COLUMN VARCHAR(30) = NULL
				SET @COLUMN = CASE WHEN ABS(@dblCreditMemoTotal) < @dblInvoiceTotal THEN 'dblExpectedEndingBalance' ELSE 'dblCashReturn' END

				--UPDATE TEMPLATE FOR REPLACE
				DECLARE @UPDATEENDINGBALANCE_TEMPLATE VARCHAR(MAX)
				SET @UPDATEENDINGBALANCE_TEMPLATE = '
														UPDATE tblARPOSEndOfDay
														SET {COLUMNNAMETOUPDATE} = ISNULL({COLUMNNAMETOUPDATE}, 0) + ISNULL({CASHRECEIPT},0)
														FROM tblARPOSEndOfDay EOD
														INNER JOIN(
															SELECT intPOSLogId, intPOSEndOfDayId
															FROM tblARPOSLog
														)POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
														INNER JOIN(
															SELECT intPOSLogId, intPOSId
															FROM tblARPOS
														)POS ON POSLOG.intPOSLogId = POS.intPOSLogId
														WHERE intPOSId = {POSID}
													'
				--UPDATE SCRIPT TO BE EXECUTED
				DECLARE @UPDATEENDINGBALANCE_SCRIPT VARCHAR(MAX)
				
				--REPLACE VALUES IN TEMPLATE
				SET @UPDATEENDINGBALANCE_SCRIPT = REPLACE(@UPDATEENDINGBALANCE_TEMPLATE, '{COLUMNNAMETOUPDATE}',@COLUMN)
				SET @UPDATEENDINGBALANCE_SCRIPT = REPLACE(@UPDATEENDINGBALANCE_SCRIPT, '{CASHRECEIPT}', @dblCashReceipt)
				SET @UPDATEENDINGBALANCE_SCRIPT = REPLACE(@UPDATEENDINGBALANCE_SCRIPT, '{POSID}', @intPOSId)
				
				--UPDATE EOD CASH SALE/RETURN
				EXECUTE(@UPDATEENDINGBALANCE_SCRIPT)


		END
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
	END
END
