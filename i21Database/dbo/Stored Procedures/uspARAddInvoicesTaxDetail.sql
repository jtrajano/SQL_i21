CREATE PROCEDURE [dbo].[uspARAddInvoicesTaxDetail]
	 @TaxDetails			LineItemTaxDetailStagingTable READONLY	
	,@RaiseError			BIT				= 0			
	,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
DECLARE  @ZeroDecimal NUMERIC(18, 6)	
SET @ZeroDecimal = 0.000000
	
BEGIN TRY
	INSERT INTO [tblARInvoiceDetailTax]
		([intInvoiceDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[intSalesTaxAccountId]
		,[dblTax]
		,[dblAdjustedTax]
		,[dblBaseAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
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
		,intSalesTaxAccountId	= CASE WHEN ISNULL(TD.[intTaxAccountId],0) <> 0 THEN TD.[intTaxAccountId] ELSE SMTC.[intSalesTaxAccountId] END
		,dblTax					= ISNULL(TD.[dblTax], @ZeroDecimal)
		,dblAdjustedTax			= ISNULL(TD.[dblAdjustedTax], ISNULL(TD.[dblTax], @ZeroDecimal))
		,dblBaseAdjustedTax		= [dbo].fnRoundBanker(ISNULL(TD.[dblAdjustedTax], ISNULL(TD.[dblTax], @ZeroDecimal)) * (CASE WHEN ISNULL(TD.[dblCurrencyExchangeRate], 0) = 0 THEN 1 ELSE TD.[dblCurrencyExchangeRate] END), [dbo].[fnARGetDefaultDecimal]())
		,ysnTaxAdjusted			= CASE WHEN ISNULL(TD.[ysnTaxAdjusted], 0) = 1 THEN ISNULL(TD.[ysnTaxAdjusted], 0) ELSE (CASE WHEN ISNULL(TD.[dblTax], @ZeroDecimal) <> ISNULL(TD.[dblAdjustedTax],0) THEN 1 ELSE 0 END) END
		,ysnSeparateOnInvoice	= ISNULL(TD.[ysnSeparateOnInvoice], 0)
		,ysnCheckoffTax			= ISNULL(TD.[ysnCheckoffTax], SMTC.[ysnCheckoffTax])
		,ysnTaxExempt			= ISNULL(TD.[ysnTaxExempt], 0)
		,strNotes				= TD.[strNotes]
		,1
	FROM
		@TaxDetails TD
	INNER JOIN
		tblSMTaxCode SMTC
			ON TD.[intTaxCodeId] = SMTC.[intTaxCodeId]
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](SMTC.[intTaxCodeId], TD.[dtmDate]) TRD		
			
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
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END