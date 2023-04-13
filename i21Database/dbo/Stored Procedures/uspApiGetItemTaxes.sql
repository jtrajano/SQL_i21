CREATE PROCEDURE [dbo].[uspApiGetItemTaxes]
	 @ItemId						INT				= NULL
	,@LocationId					INT
	,@TransactionDate				DATETIME
	,@TransactionType				NVARCHAR(20) -- Purchase/Sale
	,@EntityId						INT				= NULL
	,@TaxGroupId					INT				= NULL
	,@EntityLocationId  			INT				= NULL
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
	,@TaxLocationId					INT				= NULL
AS

BEGIN
	DECLARE	 @OriginalTaxGroupId	INT	= 0
			,@NewTaxGroupId			INT = 0
			,@IsOverrideTaxGroup	BIT = 0

    DECLARE @ItemUOMId INT

    DECLARE @strUnitMeasure NVARCHAR(200)

    SELECT @ItemUOMId = i.intItemUOMId, @strUnitMeasure = u.strUnitMeasure
    FROM tblICItemUOM i
    JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
    WHERE i.intItemId = @ItemId
        AND u.intUnitMeasureId = @UOMId

	IF ISNULL(@TaxGroupId,0) = 0
	BEGIN				
		IF (@TransactionType = 'Sale')
		BEGIN
			SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @LocationId, @ItemId, @EntityLocationId, @SiteId, @FreightTermId, NULL), 0)

			IF(@FOB IS NOT NULL)
				SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @TaxLocationId, @ItemId, @TaxLocationId, @SiteId, @FreightTermId, @FOB), 0)
		END
		ELSE
		BEGIN
			SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @EntityLocationId, @FreightTermId, NULL), 0)

			IF(@FOB IS NOT NULL)
				SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @TaxLocationId, @ItemId, @TaxLocationId, @FreightTermId, @FOB), 0)
		END

		IF @NewTaxGroupId <> 0
			SET @TaxGroupId = @NewTaxGroupId
		ELSE 
			SET @TaxGroupId = @OriginalTaxGroupId

		SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> @TaxGroupId THEN 1 ELSE 0 END
	END
	ELSE
	BEGIN
		SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> ISNULL(@TaxGroupId, 0) THEN 1 ELSE 0 END
	END

    DECLARE @TaxDetails TABLE ( 
          [intTransactionDetailId] INT
        , [intTransactionDetailTaxId] INT
        , [intInvoiceDetailId] INT
        , [intTaxGroupMasterId] INT
        , [intTaxGroupId] INT
        , [intTaxCodeId] INT
        , [intTaxClassId] INT
        , [strTaxableByOtherTaxes] NVARCHAR(MAX)
        , [strCalculationMethod] NVARCHAR(30)
        , [intTaxAccountId] INT
        , [dblRate] NUMERIC(18, 6)
        , [dblBaseRate] NUMERIC(18, 6)
        , [dblExemptionPercent] NUMERIC(18, 6)
        , [dblTax] NUMERIC(18, 6)
        , [dblAdjustedTax] NUMERIC(18, 6)
        , [dblBaseAdjustedTax] NUMERIC(18, 6)
        , [intSalesTaxAccountId] INT
        , [intSalesTaxExemptionAccountId] INT
        , [ysnSeparateOnInvoice] BIT
        , [ysnCheckoffTax] BIT
        , [strTaxCode] NVARCHAR(100)
        , [ysnTaxExempt] BIT
        , [ysnTaxOnly] BIT
        , [ysnInvalidSetup]  BIT
        , [strTaxGroup] NVARCHAR(100)
        , [strNotes] NVARCHAR(500)
        , [intUnitMeasureId] INT
        , [strUnitMeasure] NVARCHAR(100)
        , [strTaxClass] NVARCHAR(100)
        , [ysnAddToCost] BIT
        , [ysnBookToExemptionAccount] BIT
        , [ysnOverrideTaxGroup] BIT
    )

	IF (@TransactionType = 'Sale')
		BEGIN
            DECLARE  @IsCustomerSiteTaxable	BIT
            IF ISNULL(@TaxGroupId, 0) <> 0 AND ISNULL(@SiteId, 0) <> 0
                SELECT @IsCustomerSiteTaxable = ISNULL(ysnTaxable, 0) FROM tblTMSite WHERE intSiteID = @SiteId
            ELSE
                SET @IsCustomerSiteTaxable = NULL

            INSERT INTO @TaxDetails (
                  [intTransactionDetailId]
                , [intTransactionDetailTaxId]
                , [intInvoiceDetailId]
                , [intTaxGroupMasterId]
                , [intTaxGroupId]
                , [intTaxCodeId]
                , [intTaxClassId]
                , [strTaxableByOtherTaxes]
                , [strCalculationMethod]
                , [intTaxAccountId]
                , [dblRate]
                , [dblBaseRate]
                , [dblExemptionPercent]
                , [dblTax]
                , [dblAdjustedTax]
                , [dblBaseAdjustedTax]
                , [intSalesTaxAccountId]
                , [intSalesTaxExemptionAccountId]
                , [ysnSeparateOnInvoice]
                , [ysnCheckoffTax]
                , [strTaxCode]
                , [ysnTaxExempt]
                , [ysnTaxOnly]
                , [ysnInvalidSetup]
                , [strTaxGroup]
                , [strNotes]
                , [intUnitMeasureId]
                , [strUnitMeasure]
                , [strTaxClass]
                , [ysnAddToCost]
                , [ysnBookToExemptionAccount]
                , [ysnOverrideTaxGroup]
            )
			SELECT
                  [intTransactionDetailId]
                , [intTransactionDetailTaxId]
                , [intTransactionDetailId]
                , NULL
                , [intTaxGroupId]
                , [intTaxCodeId]
                , CT.[intTaxClassId]
                , [strTaxableByOtherTaxes]
                , [strCalculationMethod]
                , [intTaxAccountId]
                , [dblRate]
                , [dblBaseRate]
                , [dblExemptionPercent]
                , [dblTax]
                , [dblAdjustedTax]
                , [dblAdjustedTax]
                , [intTaxAccountId]
                , [intSalesTaxExemptionAccountId]
                , [ysnSeparateOnInvoice]
                , [ysnCheckoffTax]
                , [strTaxCode]
                , [ysnTaxExempt]
                , [ysnTaxOnly]
                , [ysnInvalidSetup] 
                , [strTaxGroup]
                , [strNotes]
                , ISNULL([intUnitMeasureId],0)
                , [strUnitMeasure]
                , [strTaxClass]	
                , [ysnAddToCost]
                , 0
                , @IsOverrideTaxGroup
			FROM [dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @EntityLocationId, 1,1, @IsCustomerSiteTaxable, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, @ItemUOMId, @LocationId, @FreightTermId, @CFSiteId, @IsDeliver, @IsCFQuote, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate) CT
            INNER JOIN tblICCategoryTax ICT ON CT.intTaxClassId = ICT.intTaxClassId
	        INNER JOIN tblICItem IT ON IT.intCategoryId = ICT.intCategoryId AND IT.intItemId = @ItemId
					
            SELECT 
                  intTransactionDetailTaxId
                , intInvoiceDetailId
                , intTaxGroupMasterId
                , intTaxGroupId
                , intTaxCodeId
                , intTaxClassId
                , strTaxableByOtherTaxes
                , strCalculationMethod
                , dblRate
                , dblBaseRate
                , dblExemptionPercent
                , dblTax
                , dblAdjustedTax
                , dblBaseAdjustedTax
                , intSalesTaxAccountId
                , intSalesTaxExemptionAccountId
                , ysnSeparateOnInvoice
                , ysnCheckoffTax
                , strTaxCode
                , ysnTaxExempt
                , ysnTaxOnly
                , ysnInvalidSetup
                , strTaxGroup
                , strNotes
                , intUnitMeasureId
                , strUnitMeasure
                , strTaxClass
                , ysnAddToCost
                , ysnOverrideTaxGroup
            FROM @TaxDetails

			RETURN 1
		END
	ELSE
		BEGIN
            
            IF ISNULL(@TaxGroupId,0) = 0
            BEGIN				
                SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @EntityLocationId, @FreightTermId, NULL), 0)

                IF(@FOB IS NOT NULL)
                    SELECT @NewTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @TaxLocationId, @ItemId, @TaxLocationId, @FreightTermId, @FOB), 0)

                IF @NewTaxGroupId <> 0
                    SET @TaxGroupId = @NewTaxGroupId
                ELSE 
                    SET @TaxGroupId = @OriginalTaxGroupId

                SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> @TaxGroupId THEN 1 ELSE 0 END
            END
            ELSE
            BEGIN
                SET @IsOverrideTaxGroup = CASE WHEN @OriginalTaxGroupId <> ISNULL(@TaxGroupId, 0) THEN 1 ELSE 0 END
            END

            INSERT INTO @TaxDetails (
                  [intTransactionDetailId]
                , [intTransactionDetailTaxId]
                , [intInvoiceDetailId]
                , [intTaxGroupMasterId]
                , [intTaxGroupId]
                , [intTaxCodeId]
                , [intTaxClassId]
                , [strTaxableByOtherTaxes]
                , [strCalculationMethod]
                , [intTaxAccountId]
                , [dblRate]
                , [dblBaseRate]
                , [dblExemptionPercent]
                , [dblTax]
                , [dblAdjustedTax]
                , [dblBaseAdjustedTax]
                , [intSalesTaxAccountId]
                , [intSalesTaxExemptionAccountId]
                , [ysnSeparateOnInvoice]
                , [ysnCheckoffTax]
                , [strTaxCode]
                , [ysnTaxExempt]
                , [ysnTaxOnly]
                , [ysnInvalidSetup]
                , [strTaxGroup]
                , [strNotes]
                , [intUnitMeasureId]
                , [strUnitMeasure]
                , [strTaxClass]
                , [ysnAddToCost]
                , [ysnBookToExemptionAccount]
                , [ysnOverrideTaxGroup]
            )
			SELECT
				  [intTransactionDetailId]
                , [intTransactionDetailTaxId]
                , [intTransactionDetailId]
                , NULL
                , [intTaxGroupId]
                , [intTaxCodeId]
                , [intTaxClassId]
                , [strTaxableByOtherTaxes]
                , [strCalculationMethod]
                , [intTaxAccountId]
                , [dblRate]
                , [dblBaseRate]
                , 0
                , [dblTax]
                , [dblAdjustedTax]
                , [dblAdjustedTax]
                , [intTaxAccountId]
                , [intTaxAccountId]
                , [ysnSeparateOnInvoice]
                , [ysnCheckoffTax]
                , [strTaxCode]
                , [ysnTaxExempt]
                , [ysnTaxOnly]
                , [ysnInvalidSetup]
                , [strTaxGroup]
                , [strNotes]
                , NULL
                , NULL
                , NULL
                , [ysnAddToCost]
                , [ysnBookToExemptionAccount]
                , @IsOverrideTaxGroup
			FROM [dbo].[fnGetTaxGroupTaxCodesForVendor](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @EntityLocationId, @IncludeExemptedCodes, @IncludeInvalidCodes, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate, @LocationId)
					
            SELECT 
                  intTransactionDetailTaxId
                , intInvoiceDetailId
                , intTaxGroupMasterId
                , intTaxGroupId
                , intTaxCodeId
                , intTaxClassId
                , strTaxableByOtherTaxes
                , strCalculationMethod
                , dblRate
                , dblBaseRate
                , dblExemptionPercent
                , dblTax
                , dblAdjustedTax
                , dblBaseAdjustedTax
                , intSalesTaxAccountId
                , intSalesTaxExemptionAccountId
                , ysnSeparateOnInvoice
                , ysnCheckoffTax
                , strTaxCode
                , ysnTaxExempt
                , ysnTaxOnly
                , ysnInvalidSetup
                , strTaxGroup
                , strNotes
                , intUnitMeasureId
                , strUnitMeasure
                , strTaxClass
                , ysnAddToCost
                , ysnOverrideTaxGroup
            FROM @TaxDetails

			RETURN 1
		END
				
	RETURN 0
END