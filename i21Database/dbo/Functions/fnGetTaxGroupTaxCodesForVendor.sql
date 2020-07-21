CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodesForVendor]
(
	 @TaxGroupId					INT
	,@VendorId						INT
	,@TransactionDate				DATETIME
	,@ItemId						INT
	,@ShipFromLocationId			INT
	,@IncludeExemptedCodes			BIT
	,@IncludeInvalidCodes			BIT             = 0
	,@UOMId							INT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
    ,@CompanyLocationId				INT				= NULL
)
RETURNS @returntable TABLE
(
	 [intTransactionDetailTaxId]	INT
	,[intTransactionDetailId]		INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblBaseRate]					NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[ysnAddToCost]					BIT
	,[strTaxGroup]					NVARCHAR(100)
	,[strNotes]						NVARCHAR(500)
	,[ysnBookToExemptionAccount]	BIT
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@ItemCategoryId INT
			,@ItemLocationId INT
			,@ExpenseAccountId INT
			,@ZeroBit BIT
			,@OneBit BIT

	SET @ZeroDecimal = 0.000000
	SET @ZeroBit = CAST(0 AS BIT)
	SET @OneBit = CAST(1 AS BIT)
	SELECT @ItemCategoryId = [intCategoryId] FROM tblICItem WHERE [intItemId] = @ItemId 
	SELECT @ItemLocationId = [intItemLocationId] FROM tblICItemLocation WHERE [intItemId] = @ItemId AND [intLocationId] = @CompanyLocationId
	SELECT @ExpenseAccountId = dbo.fnGetItemGLAccount(@ItemId, @ItemLocationId, 'Other Charge Expense')

	-- IF (ISNULL(@UOMId,0) = 0)
	-- 	SET @UOMId = [dbo].[fnGetItemStockUOM](@ItemId) 
	
	INSERT INTO @returntable
	SELECT
		 [intTransactionDetailTaxId]	= 0
		,[intTransactionDetailId]		= 0
		,[intTaxGroupId]				= TG.[intTaxGroupId] 
		,[intTaxCodeId]					= TC.[intTaxCodeId]
		,[intTaxClassId]				= TC.[intTaxClassId]				
		,[strTaxableByOtherTaxes]		= TC.[strTaxableByOtherTaxes]
		,[strCalculationMethod]			= R.[strCalculationMethod]
		,[dblRate]						= R.[dblRate]
		,[dblBaseRate]					= R.[dblBaseRate]
		,[dblTax]						= @ZeroDecimal
		,[dblAdjustedTax]				= @ZeroDecimal
		,[intTaxAccountId]				= CASE WHEN TC.[ysnExpenseAccountOverride] = @OneBit THEN ISNULL(@ExpenseAccountId,TC.[intPurchaseTaxAccountId]) ELSE TC.[intPurchaseTaxAccountId] END
		,[ysnSeparateOnInvoice]			= @ZeroBit
		,[ysnCheckoffTax]				= ISNULL(TC.[ysnCheckoffTax], @ZeroBit)
		,[strTaxCode]					= TC.[strTaxCode]
		,[ysnTaxExempt]					= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN @OneBit ELSE ISNULL(E.[ysnTaxExempt], @ZeroBit) END
		,[ysnTaxOnly]					= ISNULL(TC.[ysnTaxOnly], @ZeroBit)
		,[ysnInvalidSetup]				= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN @OneBit ELSE ISNULL(E.[ysnInvalidSetup], @ZeroBit) END
		,[ysnAddToCost]					= TC.[ysnAddToCost]
		,[strTaxGroup]					= TG.[strTaxGroup]
		,[strNotes]						= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN 'No Valid Tax Code Detail!' ELSE E.[strExemptionNotes] END
		,[ysnBookToExemptionAccount]	= CASE WHEN TC.intPurchaseTaxExemptionAccountId IS NOT NULL AND ISNULL(E.ysnTaxExempt, @ZeroBit) = @OneBit THEN @OneBit ELSE @ZeroBit END
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	CROSS APPLY
		[dbo].[fnGetVendorTaxCodeExemptionDetails](@VendorId, @TransactionDate, TG.[intTaxGroupId], TC.[intTaxCodeId], TC.[intTaxClassId], TC.[strState], @ItemId, @ItemCategoryId, @ShipFromLocationId) E
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](TC.[intTaxCodeId], @TransactionDate, @UOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) R		
	WHERE
		TG.intTaxGroupId = @TaxGroupId
		AND (ISNULL(E.ysnTaxExempt, @ZeroBit) = @ZeroBit OR ISNULL(@IncludeExemptedCodes, @ZeroBit) = @OneBit OR TC.intPurchaseTaxExemptionAccountId IS NOT NULL)
		AND ((ISNULL(E.[ysnInvalidSetup], @ZeroBit) = @ZeroBit AND ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @ZeroBit) OR ISNULL(@IncludeInvalidCodes, @ZeroBit) = @OneBit)
	ORDER BY
		TGC.[intTaxGroupCodeId]

	RETURN				
END