CREATE PROCEDURE [dbo].[uspARAddInvoiceTaxDetail]
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

SELECT 
	@InvoiceDate = [dtmDate]
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoiceDetail ARID 
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
	ARID.[intInvoiceDetailId] = @InvoiceDetailId 

IF NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId)
BEGIN
	RAISERROR(120008, 16, 1);
	GOTO _ExitTransaction
END
	
IF NOT EXISTS(SELECT NULL FROM tblSMTaxCode WHERE [intTaxCodeId] = @TaxCodeId)
BEGIN			
	RAISERROR(120009, 16, 1);
	GOTO _ExitTransaction
END

DECLARE @TaxCode NVARCHAR(100)
SELECT TOP 1
	@TaxCode = strTaxCode 
FROM
	tblSMTaxCode	
WHERE
	[intTaxCodeId] = @TaxCodeId
	AND ISNULL(@SalesTaxAccountId,0) = 0
	AND ISNULL(intSalesTaxAccountId,0) = 0

IF LEN(LTRIM(RTRIM(ISNULL(@TaxCode,'')))) > 0
BEGIN		
	RAISERROR(120056, 16, 1, @TaxCode);
	GOTO _ExitTransaction
END

DECLARE @CalcMethod NVARCHAR(100)
SELECT TOP 1
	 @CalcMethod = TRD.[strCalculationMethod] 
FROM
	tblSMTaxCode
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails]([intTaxCodeId], @InvoiceDate) TRD		
WHERE
	[intTaxCodeId] = @TaxCodeId

IF UPPER(LTRIM(RTRIM(ISNULL(@CalculationMethod,'')))) NOT IN (UPPER('Unit'),UPPER('Percentage')) AND UPPER(LTRIM(RTRIM(ISNULL(@CalcMethod,'')))) NOT IN (UPPER('Unit'),UPPER('Percentage'))
BEGIN		
	RAISERROR(120057, 16, 1, @CalculationMethod);
	GOTO _ExitTransaction
END
	
BEGIN TRANSACTION	
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
		,strTaxableByOtherTaxes	= CASE WHEN ISNULL(@TaxableByOtherTaxes,'') <> '' THEN ISNULL(@TaxableByOtherTaxes,'') ELSE ISNULL([strTaxableByOtherTaxes],'') END
		,strCalculationMethod	= CASE WHEN ISNULL(@CalculationMethod,'') <> '' THEN @CalculationMethod ELSE TRD.[strCalculationMethod] END
		,dblRate				= CASE WHEN ISNULL(@Rate,0) <> 0 THEN @Rate ELSE TRD.dblRate END
		,intSalesTaxAccountId	= CASE WHEN ISNULL(@SalesTaxAccountId,0) <> 0 THEN @SalesTaxAccountId ELSE intSalesTaxAccountId END
		,dblTax					= ISNULL(@Tax, @ZeroDecimal)
		,dblAdjustedTax			= ISNULL(@AdjustedTax, ISNULL(@Tax, @ZeroDecimal))
		,ysnTaxAdjusted			= CASE WHEN ISNULL(@TaxAdjusted, 0) = 1 THEN ISNULL(@TaxAdjusted, 0) ELSE (CASE WHEN ISNULL(@Tax, @ZeroDecimal) <> ISNULL(@AdjustedTax,0) THEN 1 ELSE 0 END) END
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
	IF @@ERROR <> 0	GOTO _RollBackTransaction
	SET @ErrorMessage = ERROR_MESSAGE()  
	RAISERROR (@ErrorMessage, 16, 1, 'WITH NOWAIT')  
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
	
		
SET @NewInvoiceTaxDetailId = @NewId

IF @@ERROR = 0 GOTO _CommitTransaction

_RollBackTransaction:
ROLLBACK TRANSACTION
GOTO _ExitTransaction

_CommitTransaction: 
COMMIT TRANSACTION
Goto _ExitTransaction

_ExitTransaction: 
	
END