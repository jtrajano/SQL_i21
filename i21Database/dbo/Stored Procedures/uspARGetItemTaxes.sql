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
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
AS
	-- DECLARE @UOMId INT = 0;
	-- SELECT @UOMId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @ItemUOMId

	IF(ISNULL(@TaxGroupId,0) = 0)
		SELECT @TaxGroupId = [dbo].[fnGetTaxGroupIdForCustomer](@CustomerId, @LocationId, @ItemId, @CustomerLocationId, @SiteId, @FreightTermId)			

	DECLARE @IsCustomerSiteTaxable	BIT

	IF ISNULL(@TaxGroupId, 0) <> 0 AND ISNULL(@SiteId, 0) <> 0
		SELECT @IsCustomerSiteTaxable = ISNULL(ysnTaxable,0) FROM tblTMSite WHERE intSiteID = @SiteId
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
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblBaseRate]
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[dblAdjustedTax]				AS [dblBaseAdjustedTax]
				,[intTaxAccountId]				AS [intSalesTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup] 
				,[strTaxGroup]
				,[strNotes]
				,ISNULL([intUnitMeasureId],0)	AS [intUnitMeasureId]
				,[strUnitMeasure] AS [strUnitMeasure]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId, @CustomerLocationId, 1, @IsCustomerSiteTaxable, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, @ItemUOMId, @LocationId, @FreightTermId, @CFSiteId, @IsDeliver, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate)
				
			RETURN 1
		END
							
	RETURN 0