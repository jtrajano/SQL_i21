﻿CREATE PROCEDURE [dbo].[uspARProcessPayments] 
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
	,@RaiseError					BIT								= 0
	,@ErrorMessage					NVARCHAR(250)					= NULL			OUTPUT
	,@LogId							INT								= NULL			OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage	NVARCHAR(250)
		,@ZeroDecimal			NUMERIC(18, 6)
		,@DateNow				DATETIME
		
SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

BEGIN TRY
	IF OBJECT_ID('tempdb..#TempPaymentEntries') IS NOT NULL DROP TABLE #TempPaymentEntries	
	SELECT * INTO #TempPaymentEntries FROM @PaymentEntries 	
	
	IF OBJECT_ID('tempdb..#EntriesForProcessing') IS NOT NULL DROP TABLE #EntriesForProcessing	
	CREATE TABLE #EntriesForProcessing(
		 [intId]						INT												NOT NULL
		,[intEntityCustomerId]			INT												NULL
		,[intCompanyLocationId]			INT												NULL
		,[intCurrencyId]				INT												NULL
		,[dtmDatePaid]					DATETIME										NULL				
		,[intPaymentMethodId]			INT												NULL		
		,[strPaymentInfo]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS	NULL
		,[strNotes]						NVARCHAR (250)	COLLATE Latin1_General_CI_AS	NULL		
		,[strPaymentOriginalId]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
		,[ysnProcessed]					BIT												NULL		
		,[ysnForInsert]					BIT												NULL
		,[ysnForUpdate]					BIT												NULL
		,[ysnRecap]						BIT												NULL
		,[ysnPost]						BIT												NULL
	)

	DECLARE  @QueryString AS VARCHAR(MAX)
			,@Columns AS VARCHAR(MAX)
			
	SET @Columns =	(CASE 
						WHEN @GroupingOption = 0 THEN '[intId]'
						WHEN @GroupingOption = 1 THEN '[intEntityCustomerId]'
						WHEN @GroupingOption = 2 THEN '[intEntityCustomerId], [intCompanyLocationId]'
						WHEN @GroupingOption = 3 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId]'
						WHEN @GroupingOption = 4 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid]'
						WHEN @GroupingOption = 5 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId]'
						WHEN @GroupingOption = 6 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo]'		
						WHEN @GroupingOption = 7 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes]'
						WHEN @GroupingOption = 8 THEN '[intEntityCustomerId], [intCompanyLocationId], [intCurrencyId], [dtmDatePaid], [intPaymentMethodId], [strPaymentInfo], [strNotes], [strPaymentOriginalId]'
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
		ROLLBACK TRANSACTION
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
		ROLLBACK TRANSACTION
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
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH	   
		
	IF (EXISTS(SELECT TOP 1 NULL FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK) WHERE [intIntegrationLogId] = @IntegrationLogId AND ISNULL([ysnSuccess],0) = 1 AND ISNULL([ysnHeader],0) = 1  AND ISNULL([ysnInsert], 0) = 1) AND @GroupingOption > 0)
	BEGIN

		UPDATE EFP
		SET EFP.[intPaymentId] = IL.[intPaymentId]
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
			,[strPaymentOriginalId]					= IE.[strPaymentOriginalId]
			,[ysnUseOriginalIdAsPaymentNumber]		= IE.[ysnUseOriginalIdAsPaymentNumber]
			,[ysnApplytoBudget]						= IE.[ysnApplytoBudget]
			,[ysnApplyOnAccount]					= IE.[ysnApplyOnAccount]
			,[ysnInvoicePrepayment]					= IE.[ysnInvoicePrepayment]
			,[ysnImportedFromOrigin]				= IE.[ysnImportedFromOrigin]
			,[ysnImportedAsPosted]					= IE.[ysnImportedAsPosted]
			,[ysnAllowPrepayment]					= IE.[ysnAllowPrepayment]
			,[ysnPost]								= ITG.[ysnPost]
			,[ysnRecap]								= ITG.[ysnRecap]
			,[ysnUnPostAndUpdate]					= ITG.[ysnUnPostAndUpdate]
			,[intEntityId]							= IE.[intEntityId]
			--Detail																																															
			,[intPaymentDetailId]					= IE.[intPaymentDetailId]
			,[intInvoiceId]							= ITG.[intInvoiceId]
			,[strTransactionType]					= IE.[strTransactionType]
			,[intBillId]							= ITG.[intBillId]
			,[strTransactionNumber]					= ITG.[strTransactionNumber]
			,[intTermId]							= ITG.[intTermId]
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
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @CurrentErrorMessage;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END

	END	

	DECLARE @InsertedInvoiceIds InvoiceId	
	DELETE FROM @InsertedInvoiceIds

	--INSERT INTO @InsertedInvoiceIds(
	--	 [intHeaderId]
	--	,[ysnUpdateAvailableDiscountOnly]
	--	,[intDetailId]
	--	,[ysnForDelete]
	--	,[ysnFromPosting]
	--	,[ysnPost]
	--	,[ysnAccrueLicense]
	--	,[strTransactionType]
	--	,[strSourceTransaction]
	--	,[ysnProcessed])
	--SELECT
	--	 [intHeaderId]						= ARIILD.[intInvoiceId]
	--	,[ysnUpdateAvailableDiscountOnly]	= IFI.[ysnUpdateAvailableDiscount]
	--	,[intDetailId]						= NULL
	--	,[ysnForDelete]						= 0
	--	,[ysnFromPosting]					= 0
	--	,[ysnPost]							= ARIILD.[ysnPost]
	--	,[ysnAccrueLicense]					= ARIILD.[ysnAccrueLicense]
	--	,[strTransactionType]				= ARIILD.[strTransactionType]
	--	,[strSourceTransaction]				= IFI.[strSourceTransaction]
	--	,[ysnProcessed]						= 0
	--	FROM
	--	(SELECT [intInvoiceId], [ysnHeader], [ysnSuccess], [intId], [intIntegrationLogId], [strTransactionType], [ysnPost], [ysnAccrueLicense] FROM tblARPaymentIntegrationLogDetail WITH (NOLOCK)) ARIILD
	--	INNER JOIN
	--	(SELECT [intId], [ysnUpdateAvailableDiscount], [strSourceTransaction] FROM @PaymentsForInsert) IFI
	--		ON IFI. [intId] = ARIILD.[intId] 
	--WHERE
	--		ISNULL(ARIILD.[ysnHeader], 0) = 1
	--		AND ISNULL(ARIILD.[ysnSuccess], 0) = 1
	--		AND ISNULL(ARIILD.[intInvoiceId], 0) <> 0


	EXEC	[dbo].[uspARUpdateInvoicesIntegrations]
				 @InvoiceIds			= @InsertedInvoiceIds
				,@UserId				= @UserId

	EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @InsertedInvoiceIds
		
END

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END