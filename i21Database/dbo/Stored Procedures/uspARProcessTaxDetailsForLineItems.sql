CREATE PROCEDURE [dbo].[uspARProcessTaxDetailsForLineItems]
	 @TaxDetails		LineItemTaxDetailStagingTable READONLY	
	,@IntegrationLogId	INT
	,@UserId			INT
	,@ReComputeInvoices	BIT				= 0
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL			OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage NVARCHAR(250)
		,@ZeroDecimal NUMERIC(18, 6)
		,@DateOnly DATETIME = CAST(GETDATE() AS DATE)
		
SET @ZeroDecimal = 0.000000


DECLARE @TaxDetailItems LineItemTaxDetailStagingTable
DELETE FROM @TaxDetailItems
INSERT INTO @TaxDetailItems
SELECT * FROM @TaxDetails

DECLARE @InvalidRecords AS TABLE (
	 [intId]					INT
	,[strErrorMessage]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]		NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[intSourceId]				INT												NULL
	,[strSourceId]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceId]				INT												NULL
	,[intInvoiceDetailId]		INT												NULL
	,[intTempDetailIdForTaxes]	INT												NULL											
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strErrorMessage]		
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[intInvoiceDetailId]
	,[intTempDetailIdForTaxes]
)
SELECT
	 [intId]					= TD.[intId]
	,[strErrorMessage]			= 'Invoice line(' + CAST(TD.[intDetailId] AS NVARCHAR(50)) + ') item does not exists!'
	,[strTransactionType]		= TD.[strTransactionType]
	,[strType]					= TD.[strType]
	,[strSourceTransaction]		= TD.[strSourceTransaction]
	,[intSourceId]				= TD.[intSourceId]
	,[strSourceId]				= TD.[strSourceId]
	,[intInvoiceId]				= TD.[intHeaderId]
	,[intInvoiceDetailId]		= TD.[intDetailId]
	,[intTempDetailIdForTaxes]	= TD.[intTempDetailIdForTaxes]
FROM
	@TaxDetailItems TD
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID WITH (NOLOCK) WHERE ARID.[intInvoiceDetailId] = TD.[intDetailId]) 

UNION ALL

SELECT
	 [intId]					= TD.[intId]
	,[strErrorMessage]			= 'Tax Code(' + CAST(TD.[intTaxCodeId] AS NVARCHAR(50)) + ') does not exists!'
	,[strTransactionType]		= TD.[strTransactionType]
	,[strType]					= TD.[strType]
	,[strSourceTransaction]		= TD.[strSourceTransaction]
	,[intSourceId]				= TD.[intSourceId]
	,[strSourceId]				= TD.[strSourceId]
	,[intInvoiceId]				= TD.[intHeaderId]
	,[intInvoiceDetailId]		= TD.[intDetailId]
	,[intTempDetailIdForTaxes]	= TD.[intTempDetailIdForTaxes]
FROM
	@TaxDetailItems TD
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMTaxCode SMTC WITH (NOLOCK) WHERE SMTC.[intTaxCodeId] = TD.[intTaxCodeId]) 

UNION ALL

SELECT
	 [intId]					= TD.[intId]
	,[strErrorMessage]			= 'Tax Code(' + CAST(TD.[intTaxCodeId] AS NVARCHAR(50)) + ') does not have a Sales Account!'
	,[strTransactionType]		= TD.[strTransactionType]
	,[strType]					= TD.[strType]
	,[strSourceTransaction]		= TD.[strSourceTransaction]
	,[intSourceId]				= TD.[intSourceId]
	,[strSourceId]				= TD.[strSourceId]
	,[intInvoiceId]				= TD.[intHeaderId]
	,[intInvoiceDetailId]		= TD.[intDetailId]
	,[intTempDetailIdForTaxes]	= TD.[intTempDetailIdForTaxes]
FROM
	@TaxDetailItems TD
WHERE
	EXISTS(SELECT NULL FROM tblSMTaxCode SMTC WITH (NOLOCK) WHERE SMTC.[intTaxCodeId] = TD.[intTaxCodeId] AND (SMTC.[intSalesTaxAccountId] IS NULL AND TD.[intTaxAccountId] IS NULL)) 
	
UNION ALL

SELECT
	 [intId]					= TD.[intId]
	,[strErrorMessage]			= ISNULL(TD.[strCalculationMethod],'') + ' is not a valid calculation method!'
	,[strTransactionType]		= TD.[strTransactionType]
	,[strType]					= TD.[strType]
	,[strSourceTransaction]		= TD.[strSourceTransaction]
	,[intSourceId]				= TD.[intSourceId]
	,[strSourceId]				= TD.[strSourceId]
	,[intInvoiceId]				= TD.[intHeaderId]
	,[intInvoiceDetailId]		= TD.[intDetailId]
	,[intTempDetailIdForTaxes]	= TD.[intTempDetailIdForTaxes]
FROM
	@TaxDetailItems TD
WHERE
	EXISTS(SELECT NULL FROM tblSMTaxCode SMTC WITH (NOLOCK) WHERE SMTC.[intTaxCodeId] = TD.[intTaxCodeId] AND UPPER(LTRIM(RTRIM(ISNULL(TD.[strCalculationMethod],'')))) NOT IN (UPPER('Unit'),UPPER('Percentage')))

IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strErrorMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END

DELETE FROM V
FROM @TaxDetailItems V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])
	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @IntegrationLog InvoiceIntegrationLogStagingTable
DELETE FROM @IntegrationLog
INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strErrorMessage]
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
	,[intInvoiceId]
	,[intInvoiceDetailId]
	,[intTemporaryDetailIdForTax]
	,[intId]
	,[strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[ysnInsert]
	,[ysnHeader]
	,[ysnSuccess])
SELECT
	 [intIntegrationLogId]					= @IntegrationLogId
	,[dtmDate]								= @DateOnly
	,[intEntityId]							= @UserId
	,[intGroupingOption]					= 0
	,[strErrorMessage]						= [strErrorMessage]
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
	,[intInvoiceId]							= [intInvoiceId]
	,[intInvoiceDetailId]					= [intInvoiceDetailId]
	,[intTemporaryDetailIdForTax]			= [intTempDetailIdForTaxes]
	,[intId]								= [intId]
	,[strTransactionType]					= [strTransactionType]
	,[strType]								= [strType]
	,[strSourceTransaction]					= [strSourceTransaction]
	,[intSourceId]							= [intSourceId]
	,[strSourceId]							= [strSourceId]
	,[ysnPost]								= NULL
	,[ysnInsert]							= 1
	,[ysnHeader]							= 0
	,[ysnSuccess]							= 0
FROM
	@InvalidRecords
		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION
		
BEGIN TRY

	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertInvoiceIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog

	DELETE FROM
		tblARInvoiceDetailTax 
	WHERE 
		[intInvoiceDetailId] IN (SELECT DISTINCT [intDetailId] FROM @TaxDetailItems WHERE [intDetailId] IS NOT NULL AND ISNULL([ysnClearExisting],0) = 1)
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


--ADD
DECLARE @TaxesForInsert LineItemTaxDetailStagingTable
DELETE FROM @TaxesForInsert
INSERT INTO
@TaxesForInsert
SELECT * FROM @TaxDetailItems WHERE ISNULL([intDetailTaxId],0) = 0

BEGIN TRY
	IF EXISTS(SELECT TOP 1 NULL FROM @TaxesForInsert ORDER BY [intId])
	BEGIN
			
		EXEC [dbo].[uspARAddInvoicesTaxDetail]
			 @TaxDetailItems		= @TaxesForInsert
			,@RaiseError		= @RaiseError
			,@ErrorMessage		= @ErrorMessage OUTPUT
								
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


--UPDATE
DECLARE @TaxesForUpdate LineItemTaxDetailStagingTable
DELETE FROM @TaxesForUpdate
INSERT INTO
@TaxesForUpdate
SELECT * FROM @TaxDetailItems WHERE ISNULL([intDetailTaxId], 0) <> 0

BEGIN TRY
	UPDATE
		ARIDT
	SET
		 ARIDT.[intTaxGroupId]			= EFP.[intTaxGroupId]
		,ARIDT.[intTaxCodeId]			= EFP.[intTaxCodeId]
		,ARIDT.[intTaxClassId]			= EFP.[intTaxClassId]
		,ARIDT.[strTaxableByOtherTaxes]	= EFP.[strTaxableByOtherTaxes]
		,ARIDT.[strCalculationMethod]	= EFP.[strCalculationMethod]
		,ARIDT.[dblRate]				= EFP.[dblRate]
		,ARIDT.[intSalesTaxAccountId]	= EFP.[intTaxAccountId]
		,ARIDT.[dblTax]					= EFP.[dblTax]
		,ARIDT.[dblAdjustedTax]			= EFP.[dblAdjustedTax]
		,ARIDT.[dblBaseAdjustedTax]		= [dbo].fnRoundBanker(ISNULL(EFP.[dblAdjustedTax], @ZeroDecimal) * ISNULL(EFP.[dblCurrencyExchangeRate], 1), [dbo].[fnARGetDefaultDecimal]())
		,ARIDT.[ysnTaxAdjusted]			= EFP.[ysnTaxAdjusted]
		,ARIDT.[ysnSeparateOnInvoice]	= EFP.[ysnSeparateOnInvoice]
		,ARIDT.[ysnCheckoffTax]			= EFP.[ysnCheckoffTax]
		,ARIDT.[ysnTaxExempt]			= EFP.[ysnTaxExempt]
		,ARIDT.[strNotes]				= EFP.[strNotes]
		,ARIDT.[intConcurrencyId]		= ARIDT.[intConcurrencyId] + 1
	FROM
		tblARInvoiceDetailTax ARIDT
	INNER JOIN
		@TaxesForUpdate EFP
			ON ARIDT.[intInvoiceDetailId] = EFP.[intDetailId]
			AND ARIDT.[intInvoiceDetailTaxId] = EFP.[intDetailTaxId]
			AND ISNULL(EFP.[intDetailId],0) <> 0
			AND ISNULL(EFP.[intDetailTaxId],0) <> 0			
		
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

--Re-Compute
IF ISNULL(@ReComputeInvoices, 0) = 1
BEGIN
	BEGIN TRY
		DECLARE @RecomputeAmountIds InvoiceId	
		DELETE FROM @RecomputeAmountIds

		INSERT INTO @RecomputeAmountIds(
			 [intHeaderId]
			,[ysnUpdateAvailableDiscountOnly]
			,[intDetailId])
		SELECT 
			 [intHeaderId]						= [intHeaderId]
			,[ysnUpdateAvailableDiscountOnly]	= 0
			,[intDetailId]						= [intDetailId]
		 FROM
			@TaxDetailItems 


		EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @RecomputeAmountIds
	END TRY
	BEGIN CATCH
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION
		SET @ErrorMessage = ERROR_MESSAGE();
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH
END
	
IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END
