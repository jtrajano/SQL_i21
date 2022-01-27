CREATE FUNCTION [dbo].[fnGetItemTaxComputationForCustomer]
(
	 @ItemId						INT
	,@CustomerId					INT
	,@TransactionDate				DATETIME
	,@ItemPrice						NUMERIC(18,6)
	,@QtyShipped					NUMERIC(18,6)
	,@TaxGroupId					INT
	,@CompanyLocationId				INT
	,@CustomerLocationId			INT	
	,@IncludeExemptedCodes			BIT
	,@IncludeInvalidCodes			BIT
	,@IsCustomerSiteTaxable			BIT
	,@SiteId						INT
	,@FreightTermId					INT
	,@CardId						INT
	,@VehicleId						INT
	,@DisregardExemptionSetup		BIT
	,@ExcludeCheckOff				BIT
	,@CFSiteId						INT
	,@IsDeliver						BIT
	,@IsCFQuote					    BIT
	,@ItemUOMId						INT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
)
RETURNS @returntable TABLE
(
	 [intTransactionDetailTaxId]		INT
	,[intTransactionDetailId]			INT
	,[intTaxGroupId]					INT
	,[intTaxCodeId]						INT
	,[intTaxClassId]					INT
	,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
	,[strCalculationMethod]				NVARCHAR(30)
	,[dblRate]							NUMERIC(18,6)
	,[dblBaseRate]						NUMERIC(18,6)
	,[dblExemptionPercent]				NUMERIC(18,6)
	,[dblTax]							NUMERIC(18,6)
	,[dblAdjustedTax]					NUMERIC(18,6)
	,[ysnSeparateOnInvoice]				BIT
	,[intTaxAccountId]					INT
	,[intSalesTaxExemptionAccountId]	INT
	,[ysnTaxAdjusted]					BIT
	,[ysnCheckoffTax]					BIT
	,[strTaxCode]						NVARCHAR(100)						
	,[ysnTaxExempt]						BIT
	,[ysnTaxOnly]						BIT
	,[ysnInvalidSetup]					BIT
	,[ysnAddToCost]						BIT
	,[strTaxGroup]						NVARCHAR(100)
	,[strNotes]							NVARCHAR(500)
	,[intUnitMeasureId]					INT
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@HundredDecimal	NUMERIC(18, 6)
	SET @ZeroDecimal = 0.000000
	SET @HundredDecimal = 100.000000

	DECLARE @ItemType NVARCHAR(50)
	SET @ItemType = ISNULL((SELECT strType FROM tblICItem WHERE [intItemId] = @ItemId),'')
	
	DECLARE @ItemTaxes AS TABLE(
			 [Id]								INT IDENTITY(1,1)
			,[intTransactionDetailTaxId]		INT
			,[intTransactionDetailId]			INT
			,[intTaxGroupId]					INT
			,[intTaxCodeId]						INT
			,[intTaxClassId]					INT
			,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
			,[strCalculationMethod]				NVARCHAR(30)
			,[dblRate]							NUMERIC(18,6)
			,[dblBaseRate]						NUMERIC(18,6)
			,[dblExemptionPercent]				NUMERIC(18,6)
			,[dblTax]							NUMERIC(18,6)
			,[dblAdjustedTax]					NUMERIC(18,6)
			,[intTaxAccountId]					INT
			,[intSalesTaxExemptionAccountId] 	INT
			,[ysnSeparateOnInvoice]				BIT
			,[ysnCheckoffTax]					BIT
			,[strTaxCode]						NVARCHAR(100)						
			,[ysnTaxExempt]						BIT
			,[ysnTaxOnly]						BIT
			,[ysnInvalidSetup]					BIT
			,[strTaxGroup]						NVARCHAR(100)
			,[strNotes]							NVARCHAR(500)
			,[ysnTaxAdjusted]					BIT
			,[intUnitMeasureId]					INT
			,[ysnComputed]						BIT
			,[ysnTaxableFlagged]				BIT
			,[ysnAddToCost]						BIT
			)
			
			
	IF ISNULL(@TaxGroupId, 0) = 0
		SELECT @TaxGroupId = [dbo].[fnGetTaxGroupIdForCustomer](@CustomerId, @CompanyLocationId, @ItemId, @CustomerLocationId, @SiteId, @FreightTermId)		
		
	IF ISNULL(@SiteId,0) <> 0 AND  ISNULL(@TaxGroupId, 0) <> 0
		SELECT 	@IsCustomerSiteTaxable = ISNULL(ysnTaxable,0) FROM tblTMSite WHERE intSiteID = @SiteId
	ELSE
		SELECT 	@IsCustomerSiteTaxable = NULL

	INSERT INTO @ItemTaxes (
		 [intTransactionDetailTaxId] 
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
		,[intSalesTaxExemptionAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
        ,[ysnComputed]
        ,[ysnTaxableFlagged]
		,[ysnAddToCost]
	)
	SELECT
		 [intTransactionDetailTaxId]
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
		,[intSalesTaxExemptionAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
        ,CAST(0 AS BIT)
        ,CAST(0 AS BIT)
		,[ysnAddToCost]
	FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId, @CustomerLocationId, @IncludeExemptedCodes, @IncludeInvalidCodes, @IsCustomerSiteTaxable, @CardId, @VehicleId, @SiteId, @DisregardExemptionSetup, @ItemUOMId, @CompanyLocationId, @FreightTermId, @CFSiteId, @IsDeliver, @IsCFQuote, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate)
															
    DECLARE @TaxableByOtherTaxesTable TABLE
        ([intTaxCodeId] INT
		,[intTaxableTaxCodeId] INT)

	WHILE EXISTS(SELECT TOP 1 NULL FROM @ItemTaxes WHERE ISNULL([ysnTaxableFlagged], 0) = 0 AND RTRIM(LTRIM(ISNULL(strTaxableByOtherTaxes, ''))) <> '' AND [ysnTaxExempt] = 0)
	BEGIN
		DECLARE @TaxableId INT
				,@TaxableTaxCodeId INT
				,@TaxableByOther    NVARCHAR(MAX)
		SELECT TOP 1 
			 @TaxableId         = [Id]
			,@TaxableTaxCodeId  = [intTaxCodeId]
			,@TaxableByOther    = RTRIM(LTRIM(ISNULL(strTaxableByOtherTaxes, '')))
		FROM
			@ItemTaxes
		WHERE
			ISNULL([ysnTaxableFlagged], 0) = 0 AND RTRIM(LTRIM(ISNULL(strTaxableByOtherTaxes, ''))) <> '' AND [ysnTaxExempt] = 0

		INSERT INTO @TaxableByOtherTaxesTable
			([intTaxCodeId]
			,[intTaxableTaxCodeId])
		SELECT DISTINCT
			[intTaxCodeId]         = @TaxableTaxCodeId
			,[intTaxableTaxCodeId] = [intID]
		FROM
			[dbo].fnGetRowsFromDelimitedValues(@TaxableByOther)		

		UPDATE @ItemTaxes SET [ysnTaxableFlagged] = CAST(1 AS BIT) WHERE [Id] = @TaxableId
	END

	-- Calculate Item Tax
	WHILE EXISTS(SELECT TOP 1 NULL FROM @ItemTaxes WHERE ISNULL([ysnComputed], 0) = 0)
		BEGIN
			DECLARE  @Id				INT
					,@TaxableAmount		NUMERIC(18,6)
					,@OtherTaxAmount	NUMERIC(18,6)
					,@TaxCodeId			INT
					,@TaxAdjusted		BIT
					,@AdjustedTax		NUMERIC(18,6)
					,@Tax				NUMERIC(18,6)
					,@Rate				NUMERIC(18,6)
					,@ExemptionPercent	NUMERIC(18,6)
					,@CalculationMethod	NVARCHAR(30)
					,@CheckoffTax		BIT
					,@TaxExempt			BIT
					,@TaxOnly			BIT
					
				
			SELECT TOP 1 
				 @Id			= [Id]
				,@TaxableAmount	= ISNULL(@ItemPrice, @ZeroDecimal) * ISNULL(@QtyShipped, @ZeroDecimal)
			FROM
				@ItemTaxes
			WHERE
				ISNULL([ysnComputed], 0) = 0
															
			SELECT 
				 @TaxCodeId			= [intTaxCodeId]
				,@TaxAdjusted		= ISNULL([ysnTaxAdjusted],0)
				,@AdjustedTax		= [dblAdjustedTax]
				,@Tax				= [dblTax]
				,@Rate				= [dblRate]
				,@ExemptionPercent	= [dblExemptionPercent]
				,@CalculationMethod	= [strCalculationMethod]
				,@CheckoffTax		= ISNULL([ysnCheckoffTax],0)
				,@TaxExempt			= ISNULL([ysnTaxExempt],0)
				,@TaxOnly			= ISNULL([ysnTaxOnly],0)
				,@OtherTaxAmount	= @ZeroDecimal
			FROM
				@ItemTaxes
			WHERE [Id] = @Id
			
			DECLARE @TaxableByOtherTaxes AS TABLE(
				 [Id]						INT
				,[intTaxCodeId]				INT
				,[strTaxableByOtherTaxes]	NVARCHAR(MAX)
				,[strCalculationMethod]		NVARCHAR(30)
				,[dblRate]					NUMERIC(18,6)
				,[dblAdjustedTax]			NUMERIC(18,6)
				,[ysnTaxAdjusted]			BIT
				,[ysnTaxExempt]				BIT
				,[ysnTaxOnly]				BIT
				)
				
			INSERT INTO @TaxableByOtherTaxes (
				Id
				,intTaxCodeId
				,strTaxableByOtherTaxes
				,strCalculationMethod
				,dblRate
				,dblAdjustedTax
				,ysnTaxAdjusted	
				,ysnTaxExempt
				,ysnTaxOnly
				)
			SELECT
				 IT.[Id]
				,IT.[intTaxCodeId]
				,IT.[strTaxableByOtherTaxes]
				,IT.[strCalculationMethod]
				,IT.[dblRate]
				,IT.[dblAdjustedTax]
				,IT.[ysnTaxAdjusted]
				,IT.[ysnTaxExempt]
				,IT.[ysnTaxOnly]
			FROM
				@ItemTaxes IT
			INNER JOIN
				@TaxableByOtherTaxesTable TBOT
					ON IT.[intTaxCodeId] = TBOT.[intTaxCodeId]
			WHERE
				TBOT.[intTaxableTaxCodeId] = @TaxCodeId 
			
			--Calculate Taxable Amount	
			WHILE EXISTS(SELECT NULL FROM @TaxableByOtherTaxes)
				BEGIN
					DECLARE @TaxId						INT
							,@TaxTaxableByOtherTaxes	NVARCHAR(MAX)
							,@TaxTaxAdjusted			BIT
							,@TaxAdjustedTax			NUMERIC(18,6)
							,@TaxRate					NUMERIC(18,6)
							,@TaxCalculationMethod		NVARCHAR(30)
							,@TaxTaxExempt				BIT							
							
					SELECT TOP 1 @TaxId	= [Id] FROM @TaxableByOtherTaxes
								
					SELECT TOP 1
						 @TaxTaxableByOtherTaxes	= [strTaxableByOtherTaxes]
						,@TaxTaxAdjusted			= ISNULL([ysnTaxAdjusted],0)
						,@TaxAdjustedTax			= [dblAdjustedTax]
						,@TaxRate					= [dblRate]
						,@TaxCalculationMethod		= [strCalculationMethod]
						,@TaxTaxExempt				= ISNULL([ysnTaxExempt],0)						
					FROM
						@TaxableByOtherTaxes
					WHERE
						[Id] = @TaxId
						
					SET @TaxableAmount	= ISNULL(@ItemPrice, @ZeroDecimal) * ISNULL(@QtyShipped, @ZeroDecimal)	
						
					IF(@TaxTaxableByOtherTaxes IS NOT NULL AND RTRIM(LTRIM(@TaxTaxableByOtherTaxes)) <> '')
					BEGIN

						-- IF @TaxOnly = 1
						-- 	SET @TaxableAmount = @ZeroDecimal

						IF(@TaxAdjustedTax = 1)
						BEGIN
							SET @OtherTaxAmount = @OtherTaxAmount + @TaxAdjustedTax
						END
						ELSE
							BEGIN
								IF(@TaxCalculationMethod = 'Percentage')
									BEGIN
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN @ZeroDecimal ELSE (@ItemPrice * @QtyShipped) * (@TaxRate/@HundredDecimal) END))
									END
								ELSE
									BEGIN
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN @ZeroDecimal ELSE (@QtyShipped * @TaxRate) END))
									END
							END
					END 					
						
					DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
				END

							
			SET @TaxableAmount = @TaxableAmount + @OtherTaxAmount

			DECLARE @ItemTaxAmount NUMERIC(18,6) = @ZeroDecimal
			IF(@CalculationMethod = 'Percentage')
				SET @ItemTaxAmount = (@TaxableAmount * (@Rate/@HundredDecimal));
			ELSE IF(@CalculationMethod = 'Percentage of Tax Only')
				SET @ItemTaxAmount = (@OtherTaxAmount * @Rate);
			ELSE
				SET @ItemTaxAmount = (@QtyShipped * @Rate);
				
			IF(@TaxExempt = 1 AND @ExemptionPercent = @ZeroDecimal)
				SET @ItemTaxAmount = @ZeroDecimal;

			IF(@TaxExempt = 1 AND @ExemptionPercent <> @ZeroDecimal)
				SET @ItemTaxAmount = @ItemTaxAmount - (@ItemTaxAmount * (@ExemptionPercent/@HundredDecimal) );
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;

			IF(@ExcludeCheckOff = 1 AND @CheckoffTax = 1)
				SET @ItemTaxAmount = @ZeroDecimal;

			IF @ItemType = 'Comment'
				SET @ItemTaxAmount = @ZeroDecimal;
			
			UPDATE
				@ItemTaxes
			SET
				dblTax			= dbo.fnRoundBanker(@ItemTaxAmount,[dbo].[fnARGetDefaultDecimal]())
				,dblAdjustedTax = dbo.fnRoundBanker(@ItemTaxAmount,[dbo].[fnARGetDefaultDecimal]())
				,ysnComputed	= 1 
			WHERE
				[Id] = @Id				
		END
				
	INSERT INTO @returntable(
		[intTransactionDetailTaxId]
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
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[intSalesTaxExemptionAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
		,[ysnAddToCost] 
	)
	SELECT
		 [intTransactionDetailTaxId]
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
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[intSalesTaxExemptionAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
		,[ysnAddToCost] 
	FROM
		@ItemTaxes 	
	RETURN				
END