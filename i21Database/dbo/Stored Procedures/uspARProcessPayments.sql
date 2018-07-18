CREATE PROCEDURE [dbo].[uspARProcessPayments] 
	 @PaymentEntries				PaymentIntegrationStagingTable					READONLY	
	,@UserId						INT
	,@GroupingOption				INT								= 0	
																	-- 0 = [intId] - A Payment will be created for each record in @PaymentEntries												
																	-- 1 = [intEntityCustomerId]
																	-- 2 = [intEntityCustomerId], [intCompanyLocationId]
																	-- 3 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId]
																	-- 4 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid]
																	-- 5 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId]
																	-- 6 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo]
																	-- 7 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes]
																	-- 8 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId]
																	-- 9 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId], [intExchangeRateTypeId]'
																	--10 = [intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId], [intExchangeRateTypeId], [dblExchangeRate]
	,@RaiseError					BIT								= 0
	,@ErrorMessage					NVARCHAR(250)					= NULL			OUTPUT
	,@LogId							INT								= NULL			OUTPUT
AS

BEGIN 

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @CurrentErrorMessage	NVARCHAR(250)
		,@ZeroDecimal			NUMERIC(18, 6)
		,@DateNow				DATETIME
		,@InitTranCount			INT
		,@Savepoint				NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARProcessPayments' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
		
SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
		
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY
	IF OBJECT_ID('tempdb..#TempPaymentEntries') IS NOT NULL DROP TABLE #TempPaymentEntries	
	SELECT * INTO #TempPaymentEntries FROM @PaymentEntries 	
	
	IF OBJECT_ID('tempdb..#EntriesForProcessing') IS NOT NULL DROP TABLE #EntriesForProcessing	
	CREATE TABLE #EntriesForProcessing(
		 [intId]						INT												NOT NULL
		,[intPaymentId]					INT												NULL
		,[intPaymentDetailId]			INT												NULL
		,[intEntityCustomerId]			INT												NULL
		,[intCompanyLocationId]			INT												NULL
		,[intCurrencyId]				INT												NULL
		,[dtmDatePaid]					DATETIME										NULL				
		,[intPaymentMethodId]			INT												NULL		
		,[strPaymentInfo]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NULL
		,[strNotes]						NVARCHAR (250)	COLLATE Latin1_General_CI_AS	NULL		
		,[strPaymentOriginalId]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,[strReceivePaymentType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,[intExchangeRateTypeId]		INT												NULL
		,[dblExchangeRate]				NUMERIC(18, 6)									NULL
		,[ysnProcessed]					BIT												NULL		
		,[ysnForInsert]					BIT												NULL
		,[ysnForUpdate]					BIT												NULL
		,[ysnRecap]						BIT												NULL
		,[ysnPost]						BIT												NULL
	)

	DECLARE  @QueryString AS VARCHAR(MAX)
			,@Columns AS VARCHAR(MAX)
			
	SET @Columns =	(CASE 
						WHEN @GroupingOption = 0  THEN '[intId]'
						WHEN @GroupingOption = 1  THEN '[intEntityCustomerId]'
						WHEN @GroupingOption = 2  THEN '[intEntityCustomerId], [intCompanyLocationId]'
						WHEN @GroupingOption = 3  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId]'
						WHEN @GroupingOption = 4  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid]'
						WHEN @GroupingOption = 5  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId]'
						WHEN @GroupingOption = 6  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo]'		
						WHEN @GroupingOption = 7  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes]'
						WHEN @GroupingOption = 8  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId]'
						WHEN @GroupingOption = 9  THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId], [intExchangeRateTypeId]'
						WHEN @GroupingOption = 10 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId], [intExchangeRateTypeId], [dblExchangeRate]'
						WHEN @GroupingOption = 11 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId], [intExchangeRateTypeId], [dblExchangeRate], [strReceivePaymentType]'
					END)
					
				
	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], ' +  @Columns + ', [ysnForInsert]) SELECT MIN([intId]), ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) = 0 GROUP BY ' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing(' +  @Columns + ', [ysnForInsert]) SELECT ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) = 0 GROUP BY ' + @Columns

	EXECUTE(@QueryString);

	IF @GroupingOption > 0
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intPaymentId], [intPaymentDetailId], ' + @Columns + ', [ysnForUpdate]) SELECT DISTINCT [intId], [intPaymentId], [intPaymentDetailId], ' + @Columns + ', 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) <> 0 GROUP BY [intId], [intPaymentId], [intPaymentDetailId],' + @Columns
	ELSE
		SET @QueryString = 'INSERT INTO #EntriesForProcessing([intId], [intPaymentId], [intPaymentDetailId], [ysnForUpdate]) SELECT DISTINCT [intId], [intPaymentId], [intPaymentDetailId], 1 FROM #TempPaymentEntries WHERE ISNULL([intPaymentId],0) <> 0 GROUP BY [intId], [intPaymentId], [intPaymentDetailId]'

	EXECUTE(@QueryString);

	IF OBJECT_ID('tempdb..#TempPaymentEntries') IS NOT NULL DROP TABLE #TempPaymentEntries	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

DECLARE @IntegrationLogId INT
BEGIN TRY
		EXEC [dbo].[uspARInsertPaymentIntegrationLog]
			 @EntityId						= @UserId
			,@GroupingOption				= @GroupingOption
			,@ErrorMessage					= ''
			,@BatchIdForNewPost				= ''
			,@PostedNewCount				= 0
			,@BatchIdForNewPostRecap		= ''
			,@RecapNewCount					= 0
			,@BatchIdForExistingPost		= ''
			,@PostedExistingCount			= 0
			,@BatchIdForExistingRecap		= ''
			,@RecapPostExistingCount		= 0
			,@BatchIdForExistingUnPost		= ''
			,@UnPostedExistingCount			= 0
			,@BatchIdForExistingUnPostRecap	= ''
			,@RecapUnPostedExistingCount	= 0
			,@NewIntegrationLogId			= @IntegrationLogId	OUTPUT


		SET @LogId = @IntegrationLogId
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

BEGIN TRY
IF EXISTS(SELECT TOP 1 NULL FROM #EntriesForProcessing WITH (NOLOCK) WHERE ISNULL([ysnForInsert],0) = 1)
BEGIN
	DECLARE @PaymentsForInsert	PaymentIntegrationStagingTable			
	INSERT INTO @PaymentsForInsert(
		 [intId]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[intPaymentId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intCurrencyId]
		,[dtmDatePaid]
		,[intPaymentMethodId]
		,[strPaymentMethod]
		,[strPaymentInfo]
		,[strNotes]
		,[intAccountId]
		,[intBankAccountId]
		,[intWriteOffAccountId]		
		,[dblAmountPaid]
		,[intExchangeRateTypeId]
		,[dblExchangeRate]
		,[strReceivePaymentType]
		,[strPaymentOriginalId]
		,[ysnUseOriginalIdAsPaymentNumber]
		,[ysnApplytoBudget]
		,[ysnApplyOnAccount]
		,[ysnInvoicePrepayment]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		,[ysnAllowPrepayment]		
		,[ysnPost]
		,[ysnRecap]
		,[ysnUnPostAndUpdate]
		,[intEntityId]
		--Detail																																															
		,[intPaymentDetailId]
		,[intInvoiceId]
		,[strTransactionType]
		,[intBillId]
		,[strTransactionNumber]
		,[intTermId]
		,[intInvoiceAccountId]
		,[ysnApplyTermDiscount]
		,[dblDiscount]
		,[dblDiscountAvailable]
		,[dblInterest]
		,[dblPayment]
		,[strInvoiceReportNumber]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[ysnAllowOverpayment]
		,[ysnFromAP]
	)								
	SELECT		 	
		 [intId]								= IE.[intId]
		,[strSourceTransaction]					= IE.[strSourceTransaction]
		,[intSourceId]							= IE.[intSourceId]
		,[strSourceId]							= IE.[strSourceId]
		,[intPaymentId]							= IE.[intPaymentId]
		,[intEntityCustomerId]					= IE.[intEntityCustomerId]
		,[intCompanyLocationId]					= IE.[intCompanyLocationId]
		,[intCurrencyId]						= IE.[intCurrencyId]
		,[dtmDatePaid]							= CAST(ISNULL(IE.[dtmDatePaid], @DateNow) AS DATE)
		,[intPaymentMethodId]					= IE.[intPaymentMethodId]
		,[strPaymentMethod]						= IE.[strPaymentMethod]
		,[strPaymentInfo]						= IE.[strPaymentInfo]
		,[strNotes]								= IE.[strNotes]
		,[intAccountId]							= IE.[intAccountId]
		,[intBankAccountId]						= IE.[intBankAccountId]
		,[intWriteOffAccountId]					= IE.[intWriteOffAccountId]		
		,[dblAmountPaid]						= IE.[dblAmountPaid]
		,[intExchangeRateTypeId]				= IE.[intExchangeRateTypeId]
		,[dblExchangeRate]						= IE.[dblExchangeRate]
		,[strReceivePaymentType]				= IE.[strReceivePaymentType]
		,[strPaymentOriginalId]					= IE.[strPaymentOriginalId]
		,[ysnUseOriginalIdAsPaymentNumber]		= IE.[ysnUseOriginalIdAsPaymentNumber]
		,[ysnApplytoBudget]						= IE.[ysnApplytoBudget]
		,[ysnApplyOnAccount]					= IE.[ysnApplyOnAccount]
		,[ysnInvoicePrepayment]					= IE.[ysnInvoicePrepayment]
		,[ysnImportedFromOrigin]				= IE.[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]					= IE.[ysnImportedAsPosted]
		,[ysnAllowPrepayment]					= IE.[ysnAllowPrepayment]
		,[ysnPost]								= IE.[ysnPost]
		,[ysnRecap]								= IE.[ysnRecap]
		,[ysnUnPostAndUpdate]					= IE.[ysnUnPostAndUpdate]
		,[intEntityId]							= IE.[intEntityId]
		--Detail																																															
		,[intPaymentDetailId]					= IE.[intPaymentDetailId]
		,[intInvoiceId]							= (CASE WHEN @GroupingOption = 0 THEN IE.[intInvoiceId] ELSE NULL END)
		,[strTransactionType]					= (CASE WHEN @GroupingOption = 0 THEN IE.[strTransactionType] ELSE NULL END)
		,[intBillId]							= (CASE WHEN @GroupingOption = 0 THEN IE.[intBillId] ELSE NULL END) 
		,[strTransactionNumber]					= (CASE WHEN @GroupingOption = 0 THEN IE.[strTransactionNumber] ELSE NULL END) 
		,[intTermId]							= (CASE WHEN @GroupingOption = 0 THEN IE.[intTermId] ELSE NULL END) 
		,[intInvoiceAccountId]					= (CASE WHEN @GroupingOption = 0 THEN IE.[intInvoiceAccountId] ELSE NULL END) 
		,[ysnApplyTermDiscount]					= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnApplyTermDiscount] ELSE NULL END) 
		,[dblDiscount]							= (CASE WHEN @GroupingOption = 0 THEN IE.[dblDiscount] ELSE NULL END) 
		,[dblDiscountAvailable]					= (CASE WHEN @GroupingOption = 0 THEN IE.[dblDiscountAvailable] ELSE NULL END) 
		,[dblInterest]							= (CASE WHEN @GroupingOption = 0 THEN IE.[dblInterest] ELSE NULL END) 
		,[dblPayment]							= (CASE WHEN @GroupingOption = 0 THEN IE.[dblPayment] ELSE NULL END) 
		,[strInvoiceReportNumber]				= (CASE WHEN @GroupingOption = 0 THEN IE.[strInvoiceReportNumber] ELSE NULL END) 
		,[intCurrencyExchangeRateTypeId]		= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateTypeId] ELSE NULL END) 
		,[intCurrencyExchangeRateId]			= (CASE WHEN @GroupingOption = 0 THEN IE.[intCurrencyExchangeRateId] ELSE NULL END) 
		,[dblCurrencyExchangeRate]				= (CASE WHEN @GroupingOption = 0 THEN IE.[dblCurrencyExchangeRate] ELSE NULL END) 
		,[ysnAllowOverpayment]					= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnAllowOverpayment] ELSE NULL END) 
		,[ysnFromAP]							= (CASE WHEN @GroupingOption = 0 THEN IE.[ysnFromAP] ELSE NULL END) 
	FROM
		@PaymentEntries IE
	INNER JOIN
		#EntriesForProcessing EFP WITH (NOLOCK)
			ON IE.[intId] = EFP.[intId]
	WHERE
		ISNULL(EFP.[ysnForInsert],0) = 1
	ORDER BY
		[intId]
			
	BEGIN TRY		
		EXEC [dbo].[uspARCreateCustomerPayments]
			 	 @PaymentEntries	= @PaymentsForInsert
				,@IntegrationLogId	= @IntegrationLogId
				,@GroupingOption	= @GroupingOption
				,@UserId			= @UserId
				,@RaiseError		= @RaiseError
				,@ErrorMessage		= @CurrentErrorMessage
			
	
		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
				BEGIN
					IF @InitTranCount = 0
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					ELSE
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @Savepoint
				END

				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END

		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH	   
		
	IF (EXISTS(SELECT TOP 1 NULL FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1  AND ISNULL([ysnInsert], 0) = 1) AND @GroupingOption > 0)
	BEGIN

		UPDATE EFP
		SET 
			EFP.[intPaymentId] = IL.[intPaymentId]

		FROM
			#EntriesForProcessing EFP
		INNER JOIN
			(SELECT [intId], [intPaymentId], [ysnSuccess], [ysnHeader] FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId) IL
				ON EFP.[intId] = IL.[intId]
				AND ISNULL(IL.[ysnHeader], 0) = 1
				AND ISNULL(IL.[ysnSuccess], 0) = 1		
			
		
		DECLARE @LineItems PaymentIntegrationStagingTable
		INSERT INTO @LineItems
			([intId]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intPaymentId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[dtmDatePaid]
			,[intPaymentMethodId]
			,[strPaymentMethod]
			,[strPaymentInfo]
			,[strNotes]
			,[intAccountId]
			,[intBankAccountId]
			,[intWriteOffAccountId]		
			,[dblAmountPaid]
			,[intExchangeRateTypeId]
			,[dblExchangeRate]
			,[strReceivePaymentType]
			,[strPaymentOriginalId]
			,[ysnUseOriginalIdAsPaymentNumber]
			,[ysnApplytoBudget]
			,[ysnApplyOnAccount]
			,[ysnInvoicePrepayment]
			,[ysnImportedFromOrigin]
			,[ysnImportedAsPosted]
			,[ysnAllowPrepayment]
			,[ysnPost]
			,[ysnRecap]
			,[ysnUnPostAndUpdate]
			,[intEntityId]
			--Detail																																															
			,[intPaymentDetailId]
			,[intInvoiceId]
			,[strTransactionType]
			,[intBillId]
			,[strTransactionNumber]
			,[intTermId]
			,[intInvoiceAccountId]
			,[ysnApplyTermDiscount]
			,[dblDiscount]
			,[dblDiscountAvailable]
			,[dblInterest]
			,[dblPayment]
			,[strInvoiceReportNumber]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[ysnAllowOverpayment]
			,[ysnFromAP])
		SELECT
			 [intId]								= ITG.[intId]
			,[strSourceTransaction]					= ITG.[strSourceTransaction]
			,[intSourceId]							= ITG.[intSourceId]
			,[strSourceId]							= ITG.[strSourceId]
			,[intPaymentId]							= EFP.[intPaymentId]
			,[intEntityCustomerId]					= ITG.[intEntityCustomerId]
			,[intCompanyLocationId]					= ITG.[intCompanyLocationId]
			,[intCurrencyId]						= ITG.[intCurrencyId]
			,[dtmDatePaid]							= CAST(ISNULL(ITG.[dtmDatePaid], @DateNow) AS DATE)
			,[intPaymentMethodId]					= ITG.[intPaymentMethodId]
			,[strPaymentMethod]						= ITG.[strPaymentMethod]
			,[strPaymentInfo]						= ITG.[strPaymentInfo]
			,[strNotes]								= ITG.[strNotes]
			,[intAccountId]							= ITG.[intAccountId]
			,[intBankAccountId]						= ITG.[intBankAccountId]
			,[intWriteOffAccountId]					= ITG.[intWriteOffAccountId]		
			,[dblAmountPaid]						= ITG.[dblAmountPaid]
			,[intExchangeRateTypeId]				= ITG.[intExchangeRateTypeId]
			,[dblExchangeRate]						= EFP.[dblExchangeRate]
			,[strReceivePaymentType]				= ITG.[strReceivePaymentType]
			,[strPaymentOriginalId]					= EFP.[strPaymentOriginalId]
			,[ysnUseOriginalIdAsPaymentNumber]		= ITG.[ysnUseOriginalIdAsPaymentNumber]
			,[ysnApplytoBudget]						= ITG.[ysnApplytoBudget]
			,[ysnApplyOnAccount]					= ITG.[ysnApplyOnAccount]
			,[ysnInvoicePrepayment]					= ITG.[ysnInvoicePrepayment]
			,[ysnImportedFromOrigin]				= ITG.[ysnImportedFromOrigin]
			,[ysnImportedAsPosted]					= ITG.[ysnImportedAsPosted]
			,[ysnAllowPrepayment]					= ITG.[ysnAllowPrepayment]
			,[ysnPost]								= ITG.[ysnPost]
			,[ysnRecap]								= ITG.[ysnRecap]
			,[ysnUnPostAndUpdate]					= ITG.[ysnUnPostAndUpdate]
			,[intEntityId]							= ITG.[intEntityId]
			--Detail																																															
			,[intPaymentDetailId]					= ITG.[intPaymentDetailId]
			,[intInvoiceId]							= ITG.[intInvoiceId]
			,[strTransactionType]					= ITG.[strTransactionType]
			,[intBillId]							= ITG.[intBillId]
			,[strTransactionNumber]					= ITG.[strTransactionNumber]
			,[intTermId]							= ITG.[intTermId]
			,[intInvoiceAccountId]					= ITG.[intInvoiceAccountId]
			,[ysnApplyTermDiscount]					= ITG.[ysnApplyTermDiscount]
			,[dblDiscount]							= ITG.[dblDiscount]
			,[dblDiscountAvailable]					= ITG.[dblDiscountAvailable]
			,[dblInterest]							= ITG.[dblInterest]
			,[dblPayment]							= ITG.[dblPayment]
			,[strInvoiceReportNumber]				= ITG.[strInvoiceReportNumber]
			,[intCurrencyExchangeRateTypeId]		= ITG.[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]			= ITG.[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]				= ITG.[dblCurrencyExchangeRate]
			,[ysnAllowOverpayment]					= ITG.[ysnAllowOverpayment]
			,[ysnFromAP]							= ITG.[ysnFromAP]
		FROM
			@PaymentEntries ITG
		INNER JOIN
			#EntriesForProcessing EFP WITH (NOLOCK)
				ON (ISNULL(ITG.[intId], 0) = ISNULL(EFP.[intId], 0) OR @GroupingOption > 0)
				AND (ISNULL(ITG.[intEntityCustomerId], 0) = ISNULL(EFP.[intEntityCustomerId], 0) OR (EFP.[intEntityCustomerId] IS NULL AND @GroupingOption < 1))
				AND (ISNULL(ITG.[intCompanyLocationId], 0) = ISNULL(EFP.[intCompanyLocationId], 0) OR (EFP.[intCompanyLocationId] IS NULL AND @GroupingOption < 2))
				AND (ISNULL(ITG.[intCurrencyId],0) = ISNULL(EFP.[intCurrencyId],0) OR (EFP.[intCurrencyId] IS NULL AND @GroupingOption < 3))
				AND (CAST(ISNULL(ITG.[dtmDatePaid], @DateNow) AS DATE) = CAST(ISNULL(EFP.[dtmDatePaid], @DateNow) AS DATE) OR (EFP.[dtmDatePaid] IS NULL AND @GroupingOption < 4))
				AND (ISNULL(ITG.[intPaymentMethodId],0) = ISNULL(EFP.[intPaymentMethodId],0) OR (EFP.[intPaymentMethodId] IS NULL AND @GroupingOption < 5))            
				AND (ISNULL(ITG.[strPaymentInfo],'') = ISNULL(EFP.[strPaymentInfo],'') OR (EFP.[strPaymentInfo] IS NULL AND @GroupingOption < 6))        
				AND (ISNULL(ITG.[strNotes],0) = ISNULL(EFP.[strNotes],0) OR (EFP.[strNotes] IS NULL AND @GroupingOption < 7))        							
				AND (ISNULL(ITG.[strPaymentOriginalId],'') = ISNULL(EFP.[strPaymentOriginalId],'') OR (EFP.[strPaymentOriginalId] IS NULL AND @GroupingOption < 8))
				AND (ISNULL(ITG.[intExchangeRateTypeId],0) = ISNULL(EFP.[intExchangeRateTypeId],0) OR (EFP.[intExchangeRateTypeId] IS NULL AND @GroupingOption < 9))
				AND (ISNULL(ITG.[dblExchangeRate],0) = ISNULL(EFP.[dblExchangeRate],0) OR (EFP.[dblExchangeRate] IS NULL AND @GroupingOption < 10))
				AND (ISNULL(ITG.[strReceivePaymentType],'') = ISNULL(EFP.[strReceivePaymentType],'') OR (EFP.[strReceivePaymentType] IS NULL AND @GroupingOption < 11))
		WHERE
		ISNULL(EFP.[ysnForInsert],0) = 1


		EXEC [dbo].[uspARAddToInvoicesToPayments]
			 @PaymentEntries	= @LineItems
			,@IntegrationLogId	= @IntegrationLogId
			,@UserId			= @UserId
			,@RaiseError		= @RaiseError
			,@ErrorMessage		= @CurrentErrorMessage	OUTPUT

		IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
				BEGIN
					IF @InitTranCount = 0
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					ELSE
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @Savepoint
				END

				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END

	END		
		
END

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--UnPosting posted Payments for update
BEGIN TRY
	DECLARE @IdsForUnPosting PaymentId

	INSERT INTO @IdsForUnPosting(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= EFP.[intPaymentId]
		,[intDetailId]			= EFP.[intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= IE.[intAccountId]
		,[intBankAccountId]		= IE.[intBankAccountId]
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= IE.[intWriteOffAccountId]
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= IE.[ysnPost]
		,[strTransactionType]	= IE.[strTransactionType]
		,[strSourceTransaction]	= IE.[strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		#EntriesForProcessing EFP
	INNER JOIN
		@PaymentEntries IE
			ON EFP.[intPaymentId] = IE.[intPaymentId] 
	WHERE
		ISNULL(EFP.[ysnForUpdate],0) = 1
		AND ISNULL(IE.[ysnUnPostAndUpdate],0) = 1
		AND ISNULL(EFP.[intPaymentId],0) <> 0
		AND ISNULL(EFP.[ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @IdsForUnPosting)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 0
			,@UserId			= @UserId
			,@PaymentIds		= @IdsForUnPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@RaiseError		= @RaiseError

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--Posting Newly Created Payments
BEGIN TRY
	DECLARE @NewIdsForPosting PaymentId
	INSERT INTO @NewIdsForPosting(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 1	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @NewIdsForPosting)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 0
			,@UserId			= @UserId
			,@PaymentIds		= @NewIdsForPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@RaiseError		= @RaiseError

	DECLARE @NewIdsForPostingRecap PaymentId
	INSERT INTO @NewIdsForPostingRecap(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 1	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @NewIdsForPostingRecap)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 1
			,@UserId			= @UserId
			,@PaymentIds		= @NewIdsForPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL			
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--Posting Updated Payments
BEGIN TRY
	DECLARE @UpdatedIdsForPosting PaymentId
	INSERT INTO @UpdatedIdsForPosting(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 0

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForPosting)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 0
			,@UserId			= @UserId
			,@PaymentIds		= @UpdatedIdsForPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@RaiseError		= @RaiseError

	DECLARE @UpdatedIdsForPostingRecap PaymentId
	INSERT INTO @UpdatedIdsForPostingRecap(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 1
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForPostingRecap)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 1
			,@Recap				= 1
			,@UserId			= @UserId
			,@PaymentIds		= @UpdatedIdsForPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--UnPosting Payments
BEGIN TRY
	DECLARE  @IntegrationLog PaymentIntegrationLogStagingTable
	INSERT INTO @IntegrationLog
		([intIntegrationLogId]
		,[dtmDate]
		,[intEntityId]
		,[intGroupingOption]
		,[strMessage]
		,[strBatchIdForNewPost]
		,[intPostedNewCount]
		,[strBatchIdForNewPostRecap]
		,[intRecapNewCount]
		,[strBatchIdForExistingPost]
		,[intPostedExistingCount]
		,[strBatchIdForExistingRecap]
		,[intRecapPostExistingCount]
		,[strBatchIdForExistingUnPost]
		,[intUnPostedExistingCount]
		,[strBatchIdForExistingUnPostRecap]
		,[intRecapUnPostedExistingCount]
		,[intIntegrationLogDetailId]
		,[intPaymentId]
		,[intPaymentDetailId]
		,[intId]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[ysnPost]
		,[ysnInsert]
		,[ysnHeader]
		,[ysnSuccess]
		,[ysnRecap])
	SELECT
		 [intIntegrationLogId]					= @IntegrationLogId
		,[dtmDate]								= @DateNow
		,[intEntityId]							= @UserId
		,[intGroupingOption]					= @GroupingOption
		,[strMessage]							= 'Invoice for Unpost.'
		,[strBatchIdForNewPost]					= ''
		,[intPostedNewCount]					= 0
		,[strBatchIdForNewPostRecap]			= ''
		,[intRecapNewCount]						= 0
		,[strBatchIdForExistingPost]			= ''
		,[intPostedExistingCount]				= 0
		,[strBatchIdForExistingRecap]			= ''
		,[intRecapPostExistingCount]			= 0
		,[strBatchIdForExistingUnPost]			= ''
		,[intUnPostedExistingCount]				= 0
		,[strBatchIdForExistingUnPostRecap]		= ''
		,[intRecapUnPostedExistingCount]		= 0
		,[intIntegrationLogDetailId]			= 0
		,[intPaymentId]							= [intPaymentId]
		,[intPaymentDetailId]					= [intPaymentDetailId]
		,[intId]								= [intId]				
		,[strSourceTransaction]					= [strSourceTransaction]
		,[intSourceId]							= [intSourceId]
		,[strSourceId]							= [strSourceId]
		,[ysnPost]								= [ysnPost]
		,[ysnInsert]							= 0
		,[ysnHeader]							= 1
		,[ysnSuccess]							= 1
		,[ysnRecap]								= [ysnRecap]
	FROM 
		@PaymentEntries
	WHERE
		ISNULL([ysnUnPostAndUpdate],0) = 0
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 0
		AND [intInvoiceId] IS NOT NULL
		

	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertPaymentIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog

	DECLARE @UpdatedIdsForUnPosting PaymentId
	INSERT INTO @UpdatedIdsForUnPosting(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 0
		AND ISNULL([ysnRecap], 0) = 0


		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForUnPosting)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 0
			,@UserId			= @UserId
			,@PaymentIds		= @UpdatedIdsForUnPosting
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL			
			,@RaiseError		= @RaiseError

	DECLARE @UpdatedIdsForUnPostingRecap PaymentId
	INSERT INTO @UpdatedIdsForUnPostingRecap(
		 [intHeaderId]
		,[intDetailId]
		,[strTransactionId]
		,[intARAccountId]
		,[intBankAccountId]
		,[intDiscountAccountId]
		,[intInterestAccountId]
		,[intWriteOffAccountId]
		,[intGainLossAccountId]
		,[intCFAccountId]
		,[ysnForDelete]
		,[ysnFromPosting]
		,[ysnPost]
		,[strTransactionType]
		,[strSourceTransaction]
		,[ysnProcessed]
	)
	SELECT DISTINCT
		 [intHeaderId]			= [intPaymentId]
		,[intDetailId]			= [intPaymentDetailId]
		,[strTransactionId]		= NULL
		,[intARAccountId]		= NULL
		,[intBankAccountId]		= NULL
		,[intDiscountAccountId]	= NULL
		,[intInterestAccountId]	= NULL
		,[intWriteOffAccountId]	= NULL
		,[intGainLossAccountId]	= NULL
		,[intCFAccountId]		= NULL
		,[ysnForDelete]			= 0
		,[ysnFromPosting]		= 0
		,[ysnPost]				= [ysnPost]
		,[strTransactionType]	= NULL
		,[strSourceTransaction]	= [strSourceTransaction]
		,[ysnProcessed]			= 0		 
	FROM
		tblARPaymentIntegrationLogDetail WITH (NOLOCK)
	WHERE
		[intIntegrationLogId] = @IntegrationLogId
		AND ISNULL([ysnSuccess], 0) = 1
		AND ISNULL([ysnHeader], 0) = 1	
		AND ISNULL([ysnInsert], 0) = 0	
		AND [ysnPost] IS NOT NULL
		AND [ysnPost] = 0
		AND ISNULL([ysnRecap], 0) = 1

		
	IF EXISTS(SELECT TOP 1 NULL FROM @UpdatedIdsForUnPostingRecap)
		EXEC [dbo].[uspARPostPaymentNew]
			 @BatchId			= NULL
			,@Post				= 0
			,@Recap				= 1
			,@UserId			= @UserId
			,@PaymentIds		= @UpdatedIdsForUnPostingRecap
			,@IntegrationLogId	= @IntegrationLogId
			,@BeginDate			= NULL
			,@EndDate			= NULL
			,@BeginTransaction	= NULL
			,@EndTransaction	= NULL
			,@Exclude			= NULL			
			,@RaiseError		= @RaiseError
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

END