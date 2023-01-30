CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	 @ItemId						INT				= NULL
	,@LocationId					INT
	,@CustomerId					INT				= NULL	
	,@CustomerLocationId			INT				= NULL
	,@TransactionDate				DATETIME
	,@TaxGroupId					INT				= NULL		
	,@SiteId						INT				= NULL
	,@FreightTermId					INT				= NULL
	,@CardId						INT				= NULL
	,@VehicleId						INT				= NULL
	,@DisregardExemptionSetup		BIT				= 0
	,@ItemUOMId						INT				= NULL
	,@CFSiteId						INT				= NULL
	,@IsDeliver						BIT				= NULL
	,@IsCFQuote						BIT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
	,@FOB							NVARCHAR(100)	= NULL
	,@TaxLocationId					INT				= NULL
AS
DECLARE  @IsCustomerSiteTaxable	BIT
		,@OriginalTaxGroupId	INT	= 0
		,@NewTaxGroupId			INT = 0
		,@IsOverrideTaxGroup	BIT = 0

SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@CustomerId, @LocationId, @ItemId, @CustomerLocationId, @SiteId, @FreightTermId, NULL), 0)

IF(ISNULL(@TaxGroupId,0) = 0)
BEGIN
	IF(@FOB IS NOT NULL AND @TaxLocationId IS NOT NULL)
		SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@CustomerId, @TaxLocationId, @ItemId, @TaxLocationId, @SiteId, @FreightTermId, @FOB), 0)

	IF(ISNULL(@TaxLocationId, 0) <> 0)
	BEGIN
		IF @NewTaxGroupId <> 0
			SET @TaxGroupId = @NewTaxGroupId
	END
	ELSE
	BEGIN
		SET @TaxGroupId = CASE WHEN @NewTaxGroupId = 0 THEN @OriginalTaxGroupId ELSE @NewTaxGroupId END
	END

	SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> @NewTaxGroupId AND ISNULL(@TaxLocationId, 0) <> 0 THEN 1 ELSE 0 END
END
ELSE
BEGIN
	SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> ISNULL(@TaxGroupId, 0) THEN 1 ELSE 0 END
END

IF ISNULL(@TaxGroupId, 0) <> 0 AND ISNULL(@SiteId, 0) <> 0
	SELECT @IsCustomerSiteTaxable = ISNULL(ysnTaxable, 0) FROM tblTMSite WHERE intSiteID = @SiteId
ELSE
	SET @IsCustomerSiteTaxable = NULL
	
IF @TaxGroupId IS NOT NULL AND @TaxGroupId <> 0
BEGIN						
	SELECT
		 [intTransactionDetailTaxId]
		,[intTransactionDetailId]		AS [intInvoiceDetailId]
		,NULL							AS [intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,CT.[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[dblAdjustedTax]				AS [dblBaseAdjustedTax]
		,[intTaxAccountId]				AS [intSalesTaxAccountId]
		,[intSalesTaxExemptionAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup] 
		,[strTaxGroup]
		,[strNotes]
		,ISNULL([intUnitMeasureId],0)	AS [intUnitMeasureId]
		,[strUnitMeasure] 				AS [strUnitMeasure]
		,[strTaxClass]					AS [strTaxClass]
		,[ysnAddToCost]					AS [ysnAddToCost]
		,@IsOverrideTaxGroup			AS [ysnOverrideTaxGroup]
	FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId, @CustomerLocationId, 1,1, @IsCustomerSiteTaxable, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, @ItemUOMId, @LocationId, @FreightTermId, @CFSiteId, @IsDeliver, @IsCFQuote, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) CT 
	INNER JOIN tblICCategoryTax ICT ON CT.intTaxClassId = ICT.intTaxClassId
	INNER JOIN tblICItem IT ON IT.intCategoryId = ICT.intCategoryId AND IT.intItemId = @ItemId

	RETURN 1
END
							
RETURN 0