CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodesForCustomer]
(
	 @TaxGroupId					INT
	,@CustomerId					INT
	,@TransactionDate				DATETIME
	,@ItemId						INT
	,@ShipToLocationId				INT
	,@IncludeExemptedCodes			BIT
	,@IncludeInvalidCodes			BIT
	,@IsCustomerSiteTaxable			BIT
	,@CardId						INT
	,@VehicleId						INT
	,@SiteId					    INT
	,@DisregardExemptionSetup		BIT
	,@ItemUOMId						INT = NULL
	,@CompanyLocationId				INT
	,@FreightTermId					INT
	,@CFSiteId						INT
	,@IsDeliver						BIT
	,@IsCFQuote					    BIT
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
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
	,[dblExemptionPercent]			NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[strTaxGroup]					NVARCHAR(100)
	,[strNotes]						NVARCHAR(500)
	,[intUnitMeasureId]				INT NULL
	,[strUnitMeasure]				NVARCHAR(30)
	,[strTaxClass]					NVARCHAR(100)
	,[ysnAddToCost]					BIT
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@ItemCategoryId INT
			,@ZeroBit BIT
			,@OneBit BIT

	SET @ZeroDecimal = 0.000000
	SET @ZeroBit = CAST(0 AS BIT)
	SET @OneBit = CAST(1 AS BIT)
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId

	-- IF (ISNULL(@ItemUOMId,0) = 0)
	-- 	SET @ItemUOMId = [dbo].[fnGetItemStockUOM](@ItemId) 
	
	INSERT INTO @returntable
		([intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
		,[strUnitMeasure]
		,[strTaxClass]
		,[ysnAddToCost]
		)
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
		,[dblExemptionPercent]			= E.[dblExemptionPercent]
		,[dblTax]						= @ZeroDecimal
		,[dblAdjustedTax]				= @ZeroDecimal
		,[intTaxAccountId]				= TC.[intSalesTaxAccountId]
		,[ysnSeparateOnInvoice]			= @ZeroBit
		,[ysnCheckoffTax]				= ISNULL(TC.[ysnCheckoffTax], @ZeroBit)
		,[strTaxCode]					= TC.[strTaxCode]
		,[ysnTaxExempt]					= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN @OneBit ELSE ISNULL(E.[ysnTaxExempt], @ZeroBit) END
		,[ysnTaxOnly]					= ISNULL(TC.[ysnTaxOnly], @ZeroBit)
		,[ysnInvalidSetup]				= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN @OneBit ELSE ISNULL(E.[ysnInvalidSetup], @ZeroBit) END
		,[strTaxGroup]					= TG.[strTaxGroup]
		,[strNotes]						= CASE WHEN ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @OneBit THEN 'No Valid Tax Code Detail!' ELSE E.[strExemptionNotes] END
		,[intUnitMeasureId]				= R.[intUnitMeasureId]
		,[strUnitMeasure]				= R.[strUnitMeasure]
		,[strTaxClass]					= TCLASS.[strTaxClass]
		,[ysnAddToCost]					= ISNULL(TC.[ysnAddToCost], 0)
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	INNER JOIN
		tblSMTaxClass TCLASS
			ON TC.[intTaxClassId] = TCLASS.[intTaxClassId]
	CROSS APPLY
		[dbo].[fnGetCustomerTaxCodeExemptionDetails](@CustomerId, @TransactionDate, TG.[intTaxGroupId], TC.[intTaxCodeId], TC.[intTaxClassId], TC.[strState], @ItemId, @ItemCategoryId, @ShipToLocationId, @IsCustomerSiteTaxable, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, @CompanyLocationId, @FreightTermId, @CFSiteId, @IsDeliver, @IsCFQuote) E
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](TC.[intTaxCodeId], @TransactionDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) R			
	WHERE
		TG.intTaxGroupId = @TaxGroupId
		AND (ISNULL(E.ysnTaxExempt, @ZeroBit) = @ZeroBit OR ISNULL(@IncludeExemptedCodes, @ZeroBit) = @OneBit)
		AND ((ISNULL(E.[ysnInvalidSetup], @ZeroBit) = @ZeroBit AND ISNULL(R.[ysnInvalidSetup], @ZeroBit) = @ZeroBit) OR ISNULL(@IncludeInvalidCodes, @ZeroBit) = @OneBit)
	ORDER BY
		TGC.[intTaxGroupCodeId]

	RETURN				
END