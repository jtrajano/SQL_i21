CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodesForCustomer]
(
	 @TaxGroupId					INT
	,@CustomerId					INT
	,@TransactionDate				DATETIME
	,@ItemId						INT
	,@ShipToLocationId				INT
	,@IncludeExemptedCodes			BIT
	,@IsCustomerSiteTaxable			BIT
	,@CardId						INT
	,@VehicleId						INT
	,@DisregardExemptionSetup		BIT
	,@ItemUOMId						INT = NULL
	,@CompanyLocationId				INT
	,@FreightTermId					INT
	,@CFSiteId						INT
	,@IsDeliver						BIT
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
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@ItemCategoryId INT

	SET @ZeroDecimal = 0.000000
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
		,[ysnSeparateOnInvoice]			= 0
		,[ysnCheckoffTax]				= TC.[ysnCheckoffTax]
		,[strTaxCode]					= TC.[strTaxCode]
		,[ysnTaxExempt]					= E.[ysnTaxExempt]
		,[ysnTaxOnly]					= ISNULL(TC.[ysnTaxOnly], 0)
		,[ysnInvalidSetup]				= E.[ysnInvalidSetup]
		,[strTaxGroup]					= TG.[strTaxGroup]
		,[strNotes]						= E.[strExemptionNotes]
		,[intUnitMeasureId]				= R.[intUnitMeasureId]
		,[strUnitMeasure]				= R.[strUnitMeasure]
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	CROSS APPLY
		[dbo].[fnGetCustomerTaxCodeExemptionDetails](@CustomerId, @TransactionDate, TG.[intTaxGroupId], TC.[intTaxCodeId], TC.[intTaxClassId], TC.[strState], @ItemId, @ItemCategoryId, @ShipToLocationId, @IsCustomerSiteTaxable, @CardId, @VehicleId, @DisregardExemptionSetup, @CompanyLocationId, @FreightTermId, @CFSiteId, @IsDeliver) E
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](TC.[intTaxCodeId], @TransactionDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) R			
	WHERE
		TG.intTaxGroupId = @TaxGroupId
		AND (ISNULL(E.ysnTaxExempt,0) = 0 OR ISNULL(@IncludeExemptedCodes,0) = 1)
	ORDER BY
		TGC.[intTaxGroupCodeId]

	RETURN				
END