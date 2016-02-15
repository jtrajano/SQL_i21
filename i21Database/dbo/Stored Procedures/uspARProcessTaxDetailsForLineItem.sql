﻿CREATE PROCEDURE [dbo].[uspARProcessTaxDetailsForLineItem]
	 @TaxDetails		LineItemTaxDetailStagingTable READONLY	
	,@UserId			INT
	,@ClearExisting		BIT				= 0
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL			OUTPUT
	,@AddedTaxDetails	NVARCHAR(MAX)	= NULL			OUTPUT
	,@UpdatedTaxDetails	NVARCHAR(MAX)	= NULL			OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage NVARCHAR(250)
		,@ZeroDecimal NUMERIC(18, 6)
		
SET @ZeroDecimal = 0.000000

CREATE TABLE #EntriesForProcessing(
	 [intId]						INT												NOT NULL
	,[intInvoiceDetailId]			INT												NULL
	,[intDetailTaxId]				INT												NULL
	,[intTaxGroupId]				INT												NULL
	,[intTaxCodeId]					INT												NULL
	,[intTaxClassId]				INT												NULL
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[strCalculationMethod]			NVARCHAR(15)	COLLATE Latin1_General_CI_AS	NULL
	,[numRate]						NUMERIC(18, 6)									NULL
	,[intTaxAccountId]				INT												NULL
	,[dblTax]						NUMERIC(18, 6)									NULL
	,[dblAdjustedTax]				NUMERIC(18, 6)									NULL
	,[ysnTaxAdjusted]				BIT												NULL
	,[ysnSeparateOnInvoice]			BIT												NULL
	,[ysnCheckoffTax]				BIT												NULL
	,[ysnTaxExempt]					BIT												NULL
	,[strNotes]						NVARCHAR(15)	COLLATE Latin1_General_CI_AS	NULL
	,[ysnAdded]						BIT												NULL	
	,[ysnUpdated]					BIT												NULL	
)
		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION
	
	
INSERT INTO #EntriesForProcessing
	(
	 [intId]
	,[intInvoiceDetailId]
	,[intDetailTaxId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[numRate]
	,[intTaxAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxExempt]
	,[strNotes]
	,[ysnAdded]
	,[ysnUpdated]
	)
SELECT
	 [intId]
	,[intDetailId]
	,[intDetailTaxId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[numRate]
	,[intTaxAccountId]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxExempt]
	,[strNotes]
	,0
	,0
FROM
	@TaxDetails 
	
	
	
--CLEAR
BEGIN TRY
	DELETE FROM
		tblARInvoiceDetailTax 
	WHERE 
		[intInvoiceDetailId] IN (SELECT DISTINCT [intDetailId] FROM @TaxDetails)
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

DECLARE	@Id					INT
	,@InvoiceDetailId		INT
	,@InvoiceDetailTaxId	INT
	,@TaxGroupId			INT
	,@TaxCodeId				INT
	,@TaxClassId			INT
	,@TaxableByOtherTaxes	NVARCHAR(MAX)
	,@CalculationMethod		NVARCHAR(15)
	,@Rate					NUMERIC(18, 6)
	,@TaxAccountId			INT
	,@Tax					NUMERIC(18, 6)
	,@AdjustedTax			NUMERIC(18, 6)
	,@TaxAdjusted			BIT
	,@SeparateOnInvoice		BIT
	,@CheckoffTax			BIT
	,@TaxExempt				BIT
	,@Notes					NVARCHAR(15)
	,@NewInvoiceTaxDetailId	INT

--ADD
BEGIN TRY
	WHILE EXISTS(SELECT NULL FROM #EntriesForProcessing WHERE ISNULL([ysnAdded],0) = 0 AND ISNULL([intDetailTaxId],0) = 0)
	BEGIN
	
		SELECT
			 @Id					= [intId]
			,@InvoiceDetailId		= [intInvoiceDetailId]
			,@InvoiceDetailTaxId	= [intDetailTaxId]
			,@TaxGroupId			= [intTaxGroupId]
			,@TaxCodeId				= [intTaxCodeId]
			,@TaxClassId			= [intTaxClassId]
			,@TaxableByOtherTaxes	= [strTaxableByOtherTaxes]
			,@CalculationMethod		= [strCalculationMethod]
			,@Rate					= [numRate]
			,@TaxAccountId			= [intTaxAccountId]
			,@Tax					= [dblTax]
			,@AdjustedTax			= [dblAdjustedTax]
			,@TaxAdjusted			= [ysnTaxAdjusted]
			,@SeparateOnInvoice		= [ysnSeparateOnInvoice]
			,@CheckoffTax			= [ysnCheckoffTax]
			,@TaxExempt				= [ysnTaxExempt]
			,@Notes					= [strNotes]
		FROM
			#EntriesForProcessing 
		WHERE
			ISNULL([ysnAdded],0) = 0 
			AND ISNULL([intDetailTaxId],0) = 0
		ORDER BY
			[intInvoiceDetailId]
			
		EXEC [dbo].[uspARAddInvoiceTaxDetail]
				 @InvoiceDetailId		= @InvoiceDetailId
				,@TaxGroupId			= @TaxGroupId
				,@TaxCodeId				= @TaxCodeId
				,@TaxClassId			= @TaxClassId
				,@TaxableByOtherTaxes	= @TaxableByOtherTaxes
				,@CalculationMethod		= @CalculationMethod
				,@Rate					= @Rate
				,@SalesTaxAccountId		= @TaxAccountId
				,@Tax					= @Tax
				,@AdjustedTax			= @AdjustedTax
				,@TaxAdjusted			= @TaxAdjusted
				,@SeparateOnInvoice		= @SeparateOnInvoice
				,@CheckoffTax			= @CheckoffTax
				,@TaxExempt				= @TaxExempt
				,@Notes					= @Notes
				,@RaiseError			= @RaiseError
				,@ErrorMessage			= @ErrorMessage				OUTPUT
				,@NewInvoiceTaxDetailId	= @NewInvoiceTaxDetailId	OUTPUT 
			

		UPDATE #EntriesForProcessing
		SET
			 [ysnAdded]					= 1
			,[intDetailTaxId]	= @NewInvoiceTaxDetailId
		WHERE
			[intId] = @Id
						
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
BEGIN TRY
	UPDATE
		tblARInvoiceDetailTax
	SET
		 [intTaxGroupId]			= EFP.[intTaxGroupId]
		,[intTaxCodeId]				= EFP.[intTaxCodeId]
		,[intTaxClassId]			= EFP.[intTaxClassId]
		,[strTaxableByOtherTaxes]	= EFP.[strTaxableByOtherTaxes]
		,[strCalculationMethod]		= EFP.[strCalculationMethod]
		,[numRate]					= EFP.[numRate]
		,[intSalesTaxAccountId]		= EFP.[intTaxAccountId]
		,[dblTax]					= EFP.[dblTax]
		,[dblAdjustedTax]			= EFP.[dblAdjustedTax]
		,[ysnTaxAdjusted]			= EFP.[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]		= EFP.[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]			= EFP.[ysnCheckoffTax]
		,[ysnTaxExempt]				= EFP.[ysnTaxExempt]
		,[strNotes]					= EFP.[strNotes]
		,[intConcurrencyId]			= tblARInvoiceDetailTax.[intConcurrencyId] + 1
	FROM
		tblARInvoiceDetailTax
	INNER JOIN
		#EntriesForProcessing EFP
			ON tblARInvoiceDetailTax.[intInvoiceDetailId] = EFP.[intInvoiceDetailId]
			AND tblARInvoiceDetailTax.[intInvoiceDetailTaxId] = EFP.[intDetailTaxId]
			AND ISNULL(EFP.[ysnUpdated],0) = 0
			AND ISNULL(EFP.[intInvoiceDetailId],0) <> 0
			AND ISNULL(EFP.[intDetailTaxId],0) <> 0
	INNER JOIN
		tblSMTaxCode SMTC
			ON EFP.[intTaxCodeId] = SMTC.[intTaxCodeId]
	INNER JOIN
		tblGLAccount GLA
			ON EFP.[intTaxAccountId] = GLA.[intAccountId]
			
	UPDATE
		#EntriesForProcessing
	SET
		[ysnUpdated] = 1
	FROM
		#EntriesForProcessing
	INNER JOIN
		tblARInvoiceDetailTax ARIDT
			ON #EntriesForProcessing.[intInvoiceDetailId] = ARIDT.[intInvoiceDetailId]
			AND #EntriesForProcessing.[intDetailTaxId] = ARIDT.[intInvoiceDetailTaxId]
			AND ISNULL(ARIDT.[intInvoiceDetailId],0) <> 0
			AND ISNULL(ARIDT.[intInvoiceDetailTaxId],0) <> 0			 			
	INNER JOIN
		tblSMTaxCode SMTC
			ON #EntriesForProcessing.[intTaxCodeId] = SMTC.[intTaxCodeId]
	INNER JOIN
		tblGLAccount GLA
			ON #EntriesForProcessing.[intTaxAccountId] = GLA.[intAccountId]
		
		
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
BEGIN TRY
	DECLARE @InvoiceIDs TABLE (intInvoiceId INT)
	INSERT INTO @InvoiceIDs
	SELECT DISTINCT
		ARID.[intInvoiceId]
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		#EntriesForProcessing EFP
			ON ARID.[intInvoiceDetailId] = EFP.[intInvoiceDetailId]
			AND (ISNULL(EFP.[ysnAdded],0) = 1 OR ISNULL(EFP.[ysnUpdated],0) = 1) 
	
	DECLARE @InvoiceId INT
	WHILE EXISTS(SELECT NULL FROM @InvoiceIDs)
	BEGIN
		SELECT TOP 1 @InvoiceId = [intInvoiceId]FROM @InvoiceIDs

		EXEC [dbo].[uspARReComputeInvoiceAmounts]
				@InvoiceId = @InvoiceId
			
		DELETE FROM @InvoiceIDs WHERE [intInvoiceId] = @InvoiceId
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


--OUTPUT
------ADDED
DECLARE @AddedIds VARCHAR(MAX)
SELECT
	@AddedIds = COALESCE(@AddedIds + ',' ,'') + CAST([intDetailTaxId] AS NVARCHAR(250))
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnAdded],0) = 1
	
SET @AddedTaxDetails = @AddedIds

------UPDATED
DECLARE @UpdatedIds VARCHAR(MAX)
SELECT
	@UpdatedIds = COALESCE(@UpdatedIds + ',' ,'') + CAST([intDetailTaxId] AS NVARCHAR(250))
FROM
	#EntriesForProcessing
WHERE
	ISNULL([ysnUpdated],0) = 1
	
SET @UpdatedTaxDetails = @UpdatedIds
		

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END