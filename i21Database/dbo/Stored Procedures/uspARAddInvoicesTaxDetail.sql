CREATE PROCEDURE [dbo].[uspARAddInvoicesTaxDetail]
	 @TaxDetails			LineItemTaxDetailStagingTable READONLY	
	,@RaiseError			BIT				= 0			
	,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON
	
DECLARE  @ZeroDecimal NUMERIC(18, 6)
		,@InitTranCount	INT
		,@Savepoint		NVARCHAR(32)

SET @ZeroDecimal = 0.000000
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInvoicesTaxDetail' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

	
BEGIN TRY
	INSERT INTO [tblARInvoiceDetailTax]
		([intInvoiceDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[intSalesTaxAccountId]
		,[dblTax]
		,[dblAdjustedTax]
		,[dblBaseAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[strNotes]
		,[intConcurrencyId])
	SELECT
		 intInvoiceDetailId		= TD.[intDetailId]
		,intTaxGroupId			= TD.[intTaxGroupId]
		,intTaxCodeId			= SMTC.[intTaxCodeId]
		,intTaxClassId			= CASE WHEN ISNULL(TD.[intTaxClassId],0) <> 0 THEN TD.[intTaxClassId] ELSE SMTC.[intTaxClassId] END
		,strTaxableByOtherTaxes	= CASE WHEN ISNULL(TD.[strTaxableByOtherTaxes],'') <> '' THEN ISNULL(TD.[strTaxableByOtherTaxes],'') ELSE ISNULL(SMTC.[strTaxableByOtherTaxes],'') END
		,strCalculationMethod	= CASE WHEN ISNULL(TD.[strCalculationMethod],'') <> '' THEN TD.[strCalculationMethod] ELSE TRD.[strCalculationMethod] END
		,dblRate				= CASE WHEN ISNULL(TD.[dblRate],0) <> 0 THEN TD.[dblRate] ELSE TRD.dblRate END
		,dblBaseRate			= CASE WHEN ISNULL(TD.[dblBaseRate],0) <> 0 THEN TD.[dblBaseRate] ELSE TRD.dblBaseRate END
		,intSalesTaxAccountId	= CASE WHEN ISNULL(TD.[intTaxAccountId],0) <> 0 THEN TD.[intTaxAccountId] ELSE SMTC.[intSalesTaxAccountId] END
		,dblTax					= ISNULL(TD.[dblTax], @ZeroDecimal)
		,dblAdjustedTax			= ISNULL(TD.[dblAdjustedTax], ISNULL(TD.[dblTax], @ZeroDecimal))
		,dblBaseAdjustedTax		= [dbo].fnRoundBanker(ISNULL(TD.[dblAdjustedTax], ISNULL(TD.[dblTax], @ZeroDecimal)) * (CASE WHEN ISNULL(TD.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE TD.[dblCurrencyExchangeRate] END), [dbo].[fnARGetDefaultDecimal]())
		,ysnTaxAdjusted			= CASE WHEN ISNULL(TD.[ysnTaxAdjusted], 0) = 1 THEN ISNULL(TD.[ysnTaxAdjusted], 0) ELSE (CASE WHEN ISNULL(TD.[dblTax], @ZeroDecimal) <> ISNULL(TD.[dblAdjustedTax],0) THEN 1 ELSE 0 END) END
		,ysnSeparateOnInvoice	= ISNULL(TD.[ysnSeparateOnInvoice], 0)
		,ysnCheckoffTax			= ISNULL(TD.[ysnCheckoffTax], SMTC.[ysnCheckoffTax])
		,ysnTaxExempt			= ISNULL(TD.[ysnTaxExempt], 0)
		,[ysnTaxOnly]			= ISNULL(TD.[ysnTaxOnly], 0)
		,strNotes				= TD.[strNotes]
		,1
	FROM
		@TaxDetails TD
	INNER JOIN
		(SELECT [intInvoiceDetailId], [intInvoiceId], [intItemUOMId], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate] FROM tblARInvoiceDetail WITH(NOLOCK)) ARID
			ON TD.[intDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN
		(SELECT [intInvoiceId], [intCurrencyId] FROM tblARInvoice WITH(NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
	INNER JOIN
		(SELECT [intTaxCodeId], [intTaxClassId], [strTaxableByOtherTaxes], [intSalesTaxAccountId], [ysnCheckoffTax] FROM tblSMTaxCode WITH(NOLOCK))  SMTC
			ON TD.[intTaxCodeId] = SMTC.[intTaxCodeId]
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](SMTC.[intTaxCodeId], TD.[dtmDate], ARID.[intItemUOMId], ARI.[intCurrencyId], ARID.[intCurrencyExchangeRateTypeId], ARID.[dblCurrencyExchangeRate]) TRD		
			
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

SET @ErrorMessage = NULL;
RETURN 1;
	
	
END