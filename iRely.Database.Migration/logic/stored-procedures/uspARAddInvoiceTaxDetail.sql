--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARAddInvoiceTaxDetail]
	 @InvoiceDetailId		INT
    ,@TaxGroupId			INT				= NULL
    ,@TaxCodeId				INT
    ,@TaxClassId			INT				= NULL
	,@TaxableByOtherTaxes	NVARCHAR(MAX)	= NULL
    ,@CalculationMethod		NVARCHAR(15)	= NULL
    ,@Rate					NUMERIC(18, 6)	= 0.000000 
    ,@BaseRate				NUMERIC(18, 6)	= 0.000000 
    ,@SalesTaxAccountId		INT				= NULL
    ,@Tax					NUMERIC(18, 6)	= 0.000000
    ,@AdjustedTax			NUMERIC(18, 6)	= 0.000000
	,@TaxAdjusted			BIT				= 0
	,@SeparateOnInvoice		BIT				= 0
	,@CheckoffTax			BIT				= 0 
	,@TaxExempt				BIT				= 0 
	,@InvalidSetup			BIT				= 0 
	,@Notes					NVARCHAR(500)	= NULL
	,@RaiseError			BIT				= 0			
	,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
	,@NewInvoiceTaxDetailId	INT				= NULL	OUTPUT 
AS
BEGIN

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON
	
DECLARE  @ZeroDecimal					NUMERIC(18, 6)	
		,@InvoiceDate					DATETIME
		,@ItemUOMId						INT
		,@InitTranCount					INT
		,@Savepoint						NVARCHAR(32)
		,@CurrencyId					INT				= NULL
		,@CurrencyExchangeRateTypeId	INT				= NULL
		,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInvoiceTaxDetail' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

SET @ZeroDecimal = 0.000000

SELECT 
	@InvoiceDate					= ARI.[dtmDate]
	,@ItemUOMId						= ARID.[intItemUOMId]
	,@CurrencyId					= ARI.[intCurrencyId]
	,@CurrencyExchangeRateTypeId	= ARID.[intCurrencyExchangeRateTypeId]
	,@CurrencyExchangeRate			= ISNULL(ARID.[dblCurrencyExchangeRate], 1.000000)
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoiceDetail ARID 
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
WHERE
	ARID.[intInvoiceDetailId] = @InvoiceDetailId 

IF NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Invoice line item does not exists!', 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMTaxCode WHERE [intTaxCodeId] = @TaxCodeId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Tax Code does not exists!', 16, 1);
		RETURN 0;
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
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Tax Code %s does not have a Sales Account!', 16, 1, @TaxCode);
		RETURN 0;
	END

DECLARE @CalcMethod NVARCHAR(100)
SELECT TOP 1
	 @CalcMethod = TRD.[strCalculationMethod] 
FROM
	tblSMTaxCode
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails]([intTaxCodeId], @InvoiceDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) TRD		
WHERE
	[intTaxCodeId] = @TaxCodeId
	AND [ysnInvalidSetup] = 0

IF UPPER(LTRIM(RTRIM(ISNULL(@CalculationMethod,'')))) NOT IN (UPPER('Unit'),UPPER('Percentage'),UPPER('Percentage of Tax Only')) AND UPPER(LTRIM(RTRIM(ISNULL(@CalcMethod,'')))) NOT IN (UPPER('Unit'),UPPER('Percentage'),UPPER('Percentage of Tax Only')) AND ISNULL(@InvalidSetup, 0) = 0
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('%s is not a valid calculation method!', 16, 1, @CalculationMethod);
		RETURN 0;
	END
	
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
		,[ysnInvalidSetup]
		,[strNotes]
		,[ysnAddToCost]
		,[intSalesTaxExemptionAccountId]
		,[intConcurrencyId])
	SELECT
		 intInvoiceDetailId				= @InvoiceDetailId
		,intTaxGroupId					= @TaxGroupId
		,intTaxCodeId					= @TaxCodeId
		,intTaxClassId					= CASE WHEN ISNULL(@TaxClassId,0) <> 0 THEN @TaxClassId ELSE [intTaxClassId] END
		,strTaxableByOtherTaxes			= CASE WHEN ISNULL(@TaxableByOtherTaxes,'') <> '' THEN ISNULL(@TaxableByOtherTaxes,'') ELSE ISNULL([strTaxableByOtherTaxes],'') END
		,strCalculationMethod			= CASE WHEN ISNULL(@CalculationMethod,'') <> '' THEN @CalculationMethod ELSE TRD.[strCalculationMethod] END
		,dblRate						= CASE WHEN ISNULL(@Rate,0) <> 0 THEN @Rate ELSE TRD.dblRate END
		,dblBaseRate					= CASE WHEN ISNULL(@BaseRate,0) <> 0 THEN @BaseRate ELSE (CASE WHEN @CurrencyExchangeRate = 1.000000 THEN TRD.dblRate ELSE TRD.dblBaseRate END) END
		,intSalesTaxAccountId			= CASE WHEN ISNULL(@SalesTaxAccountId,0) <> 0 THEN @SalesTaxAccountId ELSE intSalesTaxAccountId END
		,dblTax							= ISNULL(@Tax, @ZeroDecimal)
		,dblAdjustedTax					= ISNULL(@AdjustedTax, ISNULL(@Tax, @ZeroDecimal))
		,dblBaseAdjustedTax				= [dbo].fnRoundBanker(ISNULL(@AdjustedTax, ISNULL(@Tax, @ZeroDecimal)) * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
		,ysnTaxAdjusted					= CASE WHEN ISNULL(@TaxAdjusted, 0) = 1 THEN ISNULL(@TaxAdjusted, 0) ELSE (CASE WHEN ISNULL(@Tax, @ZeroDecimal) <> ISNULL(@AdjustedTax,0) THEN 1 ELSE 0 END) END
		,ysnSeparateOnInvoice			= ISNULL(@SeparateOnInvoice, 0)
		,ysnCheckoffTax					= ISNULL(@CheckoffTax, [ysnCheckoffTax])
		,ysnTaxExempt					= ISNULL(@TaxExempt, 0)
		,[ysnInvalidSetup]				= ISNULL(@InvalidSetup, 0)
		,strNotes						= @Notes
		,ysnAddToCost					= ysnAddToCost
		,intSalesTaxExemptionAccountId	= intSalesTaxExemptionAccountId
		,1
	FROM
		tblSMTaxCode
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails]([intTaxCodeId], @InvoiceDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) TRD		
	WHERE
		[intTaxCodeId] = @TaxCodeId
		AND [ysnInvalidSetup] = 0
			
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
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
	
		
SET @NewInvoiceTaxDetailId = @NewId

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




END