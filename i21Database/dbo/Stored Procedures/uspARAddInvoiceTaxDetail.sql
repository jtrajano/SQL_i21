﻿CREATE PROCEDURE [dbo].[uspARAddInvoiceTaxDetail]
	 @InvoiceDetailId		INT
    ,@TaxGroupId			INT				= NULL
    ,@TaxCodeId				INT
    ,@TaxClassId			INT				= NULL
	,@TaxableByOtherTaxes	NVARCHAR(MAX)	= NULL
    ,@CalculationMethod		NVARCHAR(15)	= NULL
    ,@Rate					NUMERIC(18, 6)	= 0.000000 
    ,@SalesTaxAccountId		INT				= NULL
    ,@Tax					NUMERIC(18, 6)	= 0.000000
    ,@AdjustedTax			NUMERIC(18, 6)	= 0.000000
	,@TaxAdjusted			BIT				= 0
	,@SeparateOnInvoice		BIT				= 0
	,@CheckoffTax			BIT				= 0 
	,@TaxExempt				BIT				= 0 
	,@Notes					NVARCHAR(500)	= NULL
	,@RaiseError			BIT				= 0			
	,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
	,@NewInvoiceTaxDetailId	INT				= NULL	OUTPUT 
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
DECLARE  @ZeroDecimal NUMERIC(18, 6)	
		,@InvoiceDate DATETIME

SET @ZeroDecimal = 0.000000

IF NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId)
	BEGIN
		SET @ErrorMessage = 'Invoice line item does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMTaxCode WHERE [intTaxCodeId] = @TaxCodeId)
	BEGIN
		SET @ErrorMessage = 'Tax Code does not exists!'
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END	
	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
SELECT 
	@InvoiceDate = [dtmDate]
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoiceDetail ARID 
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
	ARID.[intInvoiceDetailId] = @InvoiceDetailId 	
	
	
BEGIN TRY

	INSERT INTO [tblARInvoiceDetailTax]
		([intInvoiceDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[intSalesTaxAccountId]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[strNotes]
		,[intConcurrencyId])
	SELECT
		 intInvoiceDetailId		= @InvoiceDetailId
		,intTaxGroupId			= @TaxGroupId
		,intTaxCodeId			= @TaxCodeId
		,intTaxClassId			= CASE WHEN ISNULL(@TaxClassId,0) <> 0 THEN @TaxClassId ELSE [intTaxClassId] END
		,strTaxableByOtherTaxes	= CASE WHEN ISNULL(@TaxableByOtherTaxes,'') <> '' THEN @TaxableByOtherTaxes ELSE [strTaxableByOtherTaxes] END
		,strCalculationMethod	= CASE WHEN ISNULL(@CalculationMethod,'') <> '' THEN @CalculationMethod ELSE TRD.[strCalculationMethod] END
		,numRate				= CASE WHEN ISNULL(@Rate,0) <> 0 THEN @Rate ELSE TRD.numRate END
		,intSalesTaxAccountId	= CASE WHEN ISNULL(@SalesTaxAccountId,0) <> 0 THEN @SalesTaxAccountId ELSE intSalesTaxAccountId END
		,dblTax					= ISNULL(@Tax, @ZeroDecimal)
		,dblAdjustedTax			= ISNULL(@AdjustedTax, @ZeroDecimal)
		,ysnTaxAdjusted			= ISNULL(@TaxAdjusted, 0)
		,ysnSeparateOnInvoice	= ISNULL(@SeparateOnInvoice, 0)
		,ysnCheckoffTax			= ISNULL(@CheckoffTax, [ysnCheckoffTax])
		,ysnTaxExempt			= ISNULL(@TaxExempt, 0)
		,strNotes				= @Notes
		,1
	FROM
		tblSMTaxCode
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails]([intTaxCodeId], @InvoiceDate) TRD		
	WHERE
		[intTaxCodeId] = @TaxCodeId 
			
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
	
		
SET @NewInvoiceTaxDetailId = @NewId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END