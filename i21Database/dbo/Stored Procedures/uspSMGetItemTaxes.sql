CREATE PROCEDURE [dbo].[uspSMGetItemTaxes]
	 @ItemId						INT				= NULL
	,@LocationId					INT
	,@TransactionDate				DATETIME
	,@TransactionType				NVARCHAR(20) -- Purchase/Sale
	,@EntityId						INT				= NULL
	,@TaxGroupId					INT				= NULL
	,@BillShipToLocationId			INT				= NULL
	,@IncludeExemptedCodes			BIT				= NULL
	,@IncludeInvalidCodes			BIT				= NULL
	,@SiteId						INT				= NULL
	,@FreightTermId					INT				= NULL
	,@CardId						INT				= NULL
	,@VehicleId						INT				= NULL
	,@DisregardExemptionSetup		BIT				= 0
	,@CFSiteId						INT				= NULL
	,@IsDeliver						BIT				= NULL
	,@IsCFQuote						BIT				= NULL
	,@UOMId							INT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
	,@FOB							NVARCHAR(100)	= NULL
AS

BEGIN

	IF ISNULL(@TaxGroupId,0) = 0
	BEGIN				
		IF (@TransactionType = 'Sale')
		BEGIN
			SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @LocationId, @ItemId, @BillShipToLocationId, @SiteId, @FreightTermId, NULL), 0)

			IF(@FOB IS NOT NULL)
				SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @TaxLocationId, @ItemId, @TaxLocationId, @SiteId, @FreightTermId, @FOB), 0)
		END
		ELSE
		BEGIN
			SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @BillShipToLocationId, @FreightTermId, NULL), 0)

			IF(@FOB IS NOT NULL)
				SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @TaxLocationId, @ItemId, @TaxLocationId, @FreightTermId, @FOB), 0)
		END

		IF @NewTaxGroupId <> 0
			SET @TaxGroupId = @NewTaxGroupId

		SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> @NewTaxGroupId THEN 1 ELSE 0 END
	END
	ELSE
	BEGIN
		SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> ISNULL(@TaxGroupId, 0) THEN 1 ELSE 0 END
	END
			
				
	IF (@TransactionType = 'Sale')
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intTransactionDetailId]
				--,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblBaseRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]				AS [intSalesTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
				,[ysnBookToExemptionAccount] = 0
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId, @IncludeExemptedCodes, @IncludeInvalidCodes, NULL, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, NULL, @LocationId, @FreightTermId, @CFSiteId, @IsDeliver, @IsCFQuote, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate)
					
			RETURN 1
		END
	ELSE
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intTransactionDetailId]
				--,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblBaseRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[ysnAddToCost]
				,[strTaxGroup]
				,[strNotes]
				,[ysnBookToExemptionAccount]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForVendor](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId, @IncludeExemptedCodes, @IncludeInvalidCodes, @UOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate, @LocationId)
					
			RETURN 1
		END
				
	RETURN 0
END