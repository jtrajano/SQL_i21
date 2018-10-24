﻿CREATE FUNCTION [dbo].[fnConstructLineItemTaxDetail]
(
	 @Quantity						NUMERIC(18,6)					= 0
	,@GrossAmount					NUMERIC(18,6)					= 0
	,@LineItemTaxEntries			LineItemTaxDetailStagingTable	READONLY
	,@IsReversal					BIT								= 0	
	,@ItemId						INT								= NULL	
	,@EntityCustomerId				INT								= NULL
	,@CompanyLocationId				INT								= NULL
	,@TaxGroupId					INT								= NULL
	,@Price							NUMERIC(18,6)					= 0	
	,@TransactionDate				DATE							= NULL	
	,@ShipToLocationId				INT								= NULL
	,@IncludeExemptedCodes			BIT								= 0
	,@SiteId						INT								= NULL
	,@FreightTermId					INT								= NULL
	,@CardId						INT								= NULL
	,@VehicleId						INT								= NULL
	,@DisregardExemptionSetup		BIT								= 0
	,@ExcludeCheckOff				BIT								= 0
	,@ItemUOMId						INT								= NULL
	,@CFSiteId						INT								= NULL
	,@IsDeliver						BIT								= 0
	,@IsCFQuote					    BIT                             = 0
	,@CurrencyId					INT								= NULL
	,@CurrencyExchangeRateTypeId	INT								= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)					= NULL
)
RETURNS @returntable TABLE
(
	 [intTaxGroupId]				INT
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
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[strNotes]						NVARCHAR(500)
)
AS
BEGIN


	DECLARE @ItemTaxes AS TABLE(
		 [Id]							INT IDENTITY(1,1)
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
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnTaxOnly]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strNotes]						NVARCHAR(500)
		,[ysnTaxAdjusted]				BIT
		,[intUnitMeasureId]				INT
		,[ysnComputed]					BIT
		,[ysnTaxableFlagged]			BIT
		)

	IF NOT EXISTS(SELECT TOP 1 NULL FROM @LineItemTaxEntries)
		BEGIN
			INSERT INTO @ItemTaxes(
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strNotes]
				,[intUnitMeasureId]
				,[ysnComputed]
				,[ysnTaxableFlagged]
			)
			SELECT
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strNotes]
				,[intUnitMeasureId]
				,CAST(0 AS BIT)
				,CAST(0 AS BIT)
			FROM
				[dbo].[fnGetItemTaxComputationForCustomer]
					(
						 @ItemId				--@ItemId
						,@EntityCustomerId		--@CustomerId
						,@TransactionDate		--@TransactionDate
						,@Price					--@ItemPrice
						,@Quantity				--@QtyShipped
						,@TaxGroupId			--@TaxGroupId
						,@CompanyLocationId		--@CompanyLocationId
						,@ShipToLocationId		--@CustomerLocationId
						,@IncludeExemptedCodes	--@IncludeExemptedCodes
						,NULL					--@IsCustomerSiteTaxable
						,@SiteId				--@SiteId
						,@FreightTermId
						,@CardId
						,@VehicleId
						,@DisregardExemptionSetup
						,@ExcludeCheckOff
						,@CFSiteId
						,@IsDeliver
						,@IsCFQuote
						,@ItemUOMId
						,@CurrencyId
						,@CurrencyExchangeRateTypeId
						,@CurrencyExchangeRate
					) 	
		END

	DECLARE @ZeroDecimal		NUMERIC(18, 6)
			,@TaxAmount			NUMERIC(18,6)
			
	SET @ZeroDecimal = 0.000000
	SET @GrossAmount = ISNULL(@GrossAmount, @ZeroDecimal)
	SET @Quantity = ISNULL(@Quantity, @ZeroDecimal)
	SET @Price = ISNULL(@Price, @ZeroDecimal)


	INSERT INTO @ItemTaxes(
		 [intTaxGroupId]
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
		,[ysnCheckoffTax]		
		,[strTaxCode]
		,[ysnTaxExempt]	
		,[ysnTaxOnly]	
		,[ysnTaxAdjusted]
		,[intUnitMeasureId]
		,[ysnComputed]
		,[ysnTaxableFlagged]
	)
	SELECT

		 [intTaxGroupId]			= LITE.[intTaxGroupId]
		,[intTaxCodeId]				= LITE.[intTaxCodeId]
		,[intTaxClassId]			= ISNULL(LITE.[intTaxClassId], SMTC.[intTaxClassId])
		,[strTaxableByOtherTaxes]	= ISNULL(LITE.[strTaxableByOtherTaxes], SMTC.[strTaxableByOtherTaxes])
		,[strCalculationMethod]		= ISNULL(LITE.[strCalculationMethod], (SELECT [strCalculationMethod] FROM [dbo].[fnGetTaxCodeRateDetails](LITE.[intTaxCodeId], @TransactionDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate)))
		,[dblRate]					= ISNULL(ISNULL(LITE.[dblRate], (SELECT [dblRate] FROM [dbo].[fnGetTaxCodeRateDetails](LITE.[intTaxCodeId], @TransactionDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate))), @ZeroDecimal)
		,[dblBaseRate]				= ISNULL(ISNULL(LITE.[dblBaseRate], (SELECT [dblBaseRate] FROM [dbo].[fnGetTaxCodeRateDetails](LITE.[intTaxCodeId], @TransactionDate, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate))), @ZeroDecimal)
		,[dblExemptionPercent]		= @ZeroDecimal
		,[dblTax]					= LITE.[dblTax]
		,[dblAdjustedTax]			= LITE.[dblAdjustedTax]
		,[intTaxAccountId]			= ISNULL(LITE.[intTaxAccountId], SMTC.[intSalesTaxAccountId])
		,[ysnCheckoffTax]			= ISNULL(LITE.[ysnCheckoffTax], SMTC.[ysnCheckoffTax])
		,[strTaxCode]				= SMTC.[strTaxCode]
		,[ysnTaxExempt]				= LITE.[ysnTaxExempt]
		,[ysnTaxOnly]				= LITE.[ysnTaxOnly]
		,[ysnTaxAdjusted]			= LITE.[ysnTaxAdjusted] 
		,[intUnitMeasureId]         = NULL
		,[ysnComputed]              = CAST(0 AS BIT)
		,[ysnTaxableFlagged]        = CAST(0 AS BIT)
	FROM
		@LineItemTaxEntries LITE
	INNER JOIN
		tblSMTaxCode SMTC
			ON LITE.[intTaxCodeId] = SMTC.[intTaxCodeId]
		
		
	DECLARE @TotalUnitTax			NUMERIC(18,6)
			,@UnitTax				NUMERIC(18,6)
			,@CheckOffUnitTax		NUMERIC(18,6)
			,@TaxableByOtherUnitTax	NUMERIC(18,6)
			,@TotalTaxRate			NUMERIC(18,6)
			,@RegularRate			NUMERIC(18,6)
			,@CheckOffRate			NUMERIC(18,6)
			,@TaxableByOtherRate	NUMERIC(18,6)
			,@ItemPrice				NUMERIC(18,6)
	
	
	

	IF ISNULL(@IsReversal,0) = 0
		BEGIN
			SET @ItemPrice = @Price
		END
	ELSE
		BEGIN

			DECLARE @TaxableByOtherTaxUnit AS TABLE(
				 [Id]							INT IDENTITY(1,1)
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
				,[ysnCheckoffTax]				BIT
				,[strTaxCode]					NVARCHAR(100)						
				,[ysnTaxExempt]					BIT
				,[ysnTaxOnly]					BIT
				,[ysnInvalidSetup]				BIT
				,[strTaxGroup]					NVARCHAR(100)
				,[strNotes]						NVARCHAR(500)
				,[ysnTaxAdjusted]				BIT
				,[ysnComputed]					BIT
				)

			INSERT INTO @TaxableByOtherTaxUnit(
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
				,[ysnTaxAdjusted]
				,[ysnComputed]
			)
			SELECT
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
				,[ysnTaxAdjusted]
				,0
			FROM 
				@ItemTaxes
			WHERE
				LEN(RTRIM(LTRIM(ISNULL([strTaxableByOtherTaxes], '')))) > 0
				AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'unit'
				AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)

			DECLARE @TBOTTaxCodesTable TABLE
				([intTaxCodeId] INT PRIMARY KEY,
				UNIQUE ([intTaxCodeId]));

			SET @TaxableByOtherUnitTax = @ZeroDecimal
			WHILE EXISTS(SELECT TOP 1 NULL FROM @TaxableByOtherTaxUnit WHERE [ysnComputed] = 0)
				BEGIN
					DECLARE  @TBOTID			INT
							,@TBOTCheckOff		BIT
							,@TBOTRate			NUMERIC(18,6)
							,@TBOTTotalRate		NUMERIC(18,6)
							,@TBOTRegularRate	NUMERIC(18,6)
							,@TBOTCheckOffRate	NUMERIC(18,6)
							,@TBOTTaxCodes		NVARCHAR(MAX)

					SELECT TOP 1 
						 @TBOTID		= [Id]
						,@TBOTRate		= ISNULL([dblRate], @ZeroDecimal)
						,@TBOTTaxCodes	= [strTaxableByOtherTaxes]
						,@TBOTCheckOff	= ISNULL([ysnCheckoffTax],0)
					FROM
						@TaxableByOtherTaxUnit
					WHERE
						[ysnComputed] = 0

					DELETE FROM @TBOTTaxCodesTable
					INSERT INTO @TBOTTaxCodesTable SELECT DISTINCT [intID] AS [intTaxCodeId] FROM [dbo].fnGetRowsFromDelimitedValues(@TBOTTaxCodes)

					SELECT
						@TBOTRegularRate = SUM((@TBOTRate * @Quantity) * (ISNULL(IT.[dblRate], @ZeroDecimal)/100.00))
					FROM
						@ItemTaxes IT
					INNER JOIN
						@TBOTTaxCodesTable TBO
							ON IT.[intTaxCodeId] = TBO.[intTaxCodeId]
					WHERE
						--[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodes))
						--AND IT.[ysnCheckoffTax] = 0
						--AND 
						LOWER(RTRIM(LTRIM(IT.[strCalculationMethod]))) = 'percentage'	

					--SELECT
					--	@TBOTCheckOffRate = SUM((@TBOTRate * @Quantity) * (ISNULL([dblRate], @ZeroDecimal)/100.00))
					--FROM
					--	@ItemTaxes
					--WHERE
					--	[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodes))
					--	AND [ysnCheckoffTax] = 1
					--	AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'	

					SET @TaxableByOtherUnitTax = @TaxableByOtherUnitTax + ((ISNULL(@TBOTRegularRate, @ZeroDecimal) - ISNULL(@TBOTCheckOffRate, @ZeroDecimal))) --* (CASE WHEN @TBOTCheckOff = 1 THEN -1 ELSE 1 END))
					UPDATE @TaxableByOtherTaxUnit SET [ysnComputed] = 1 WHERE [Id] = @TBOTID
				END

			SELECT
				@UnitTax = SUM(@Quantity * [dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'unit'
				AND [ysnCheckoffTax] = 0
				AND [ysnTaxExempt] = 0
				-- AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)
				
			SELECT
				@CheckOffUnitTax = SUM(@Quantity * [dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'unit'
				AND [ysnCheckoffTax] = 1
				AND [ysnTaxExempt] = 0
				-- AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)
				AND @ExcludeCheckOff = 0
				
			SET @TotalUnitTax = ((ISNULL(@UnitTax, @ZeroDecimal) - ISNULL(@CheckOffUnitTax, @ZeroDecimal)) + ISNULL(@TaxableByOtherUnitTax, @ZeroDecimal))
			
			SELECT
				@RegularRate = SUM([dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'
				AND [ysnCheckoffTax] = 0
				AND [ysnTaxExempt] = 0
				-- AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)
				
			SELECT
				@CheckOffRate = SUM([dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'
				AND [ysnCheckoffTax] = 1
				AND [ysnTaxExempt] = 0
				-- AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)
				AND @ExcludeCheckOff = 0

			DELETE FROM @TaxableByOtherTaxUnit
			INSERT INTO @TaxableByOtherTaxUnit(
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
				,[ysnTaxAdjusted]
				,[ysnComputed]
			)
			SELECT
				 [intTaxGroupId]
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
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
				,[ysnTaxAdjusted]
				,0
			FROM 
				@ItemTaxes
			WHERE
				LEN(RTRIM(LTRIM(ISNULL([strTaxableByOtherTaxes], '')))) > 0
				AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'
				AND ([ysnTaxExempt] = 0 OR @DisregardExemptionSetup = 1)

			DECLARE @TBOTTaxCodesRTable TABLE
				([intTaxCodeId] INT PRIMARY KEY,
				UNIQUE ([intTaxCodeId]));

			SET @TaxableByOtherRate = @ZeroDecimal
			WHILE EXISTS(SELECT TOP 1 NULL FROM @TaxableByOtherTaxUnit WHERE [ysnComputed] = 0)
				BEGIN
					DECLARE  @TBOTIDR			INT
							,@TBOTCheckOffR		BIT
							,@TBOTRateR			NUMERIC(18,6)
							,@TBOTTotalRateR		NUMERIC(18,6)
							,@TBOTRegularRateR	NUMERIC(18,6)
							,@TBOTCheckOffRateR	NUMERIC(18,6)
							,@TBOTTaxCodesR		NVARCHAR(MAX)

					SELECT TOP 1 
						 @TBOTIDR		= [Id]
						,@TBOTRateR		= ISNULL([dblRate], @ZeroDecimal)
						,@TBOTTaxCodesR	= [strTaxableByOtherTaxes]
						,@TBOTCheckOffR	= ISNULL([ysnCheckoffTax],0)
					FROM
						@TaxableByOtherTaxUnit
					WHERE
						[ysnComputed] = 0

					DELETE FROM @TBOTTaxCodesRTable
					INSERT INTO @TBOTTaxCodesRTable SELECT DISTINCT [intID] AS [intTaxCodeId] FROM [dbo].fnGetRowsFromDelimitedValues(@TBOTTaxCodesR)

					SELECT
						@TBOTRegularRateR = SUM((@TBOTRateR) * (ISNULL(IT.[dblRate], @ZeroDecimal)/100.00))
					FROM
						@ItemTaxes IT
					INNER JOIN
						@TBOTTaxCodesRTable TBOR
							ON IT.[intTaxCodeId] = TBOR.[intTaxCodeId]
					WHERE
						--IT.[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodesR))
						--AND 
						NOT (IT.[ysnCheckoffTax] = 1 AND @ExcludeCheckOff = 1)
						AND LOWER(RTRIM(LTRIM(IT.[strCalculationMethod]))) = 'percentage'	

					--SELECT
					--	@TBOTCheckOffRate = SUM((@TBOTRate * @Quantity) * (ISNULL([dblRate], @ZeroDecimal)/100.00))
					--FROM
					--	@ItemTaxes
					--WHERE
					--	[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodes))
					--	AND [ysnCheckoffTax] = 1
					--	AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'	

					SET @TaxableByOtherRate = @TaxableByOtherRate + ((ISNULL(@TBOTRegularRateR, @ZeroDecimal) - ISNULL(@TBOTCheckOffRateR, @ZeroDecimal))) --* (CASE WHEN @TBOTCheckOff = 1 THEN -1 ELSE 1 END))
					UPDATE @TaxableByOtherTaxUnit SET [ysnComputed] = 1 WHERE [Id] = @TBOTIDR
				END
				
			SET @TotalTaxRate = (ISNULL(@RegularRate, @ZeroDecimal) - ISNULL(@CheckOffRate, @ZeroDecimal)) + ISNULL(@TaxableByOtherRate, @ZeroDecimal)
			
			----t = pq + (pqr)
			----t/(q + qr) = p		
			SET @ItemPrice = (@GrossAmount - @TotalUnitTax) / (@Quantity + (@Quantity * (@TotalTaxRate/100.00)))
					
		END		
	
		
	
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
			DECLARE  @Id					INT
					,@TaxableAmount			NUMERIC(18,6)
					,@OtherTaxAmount		NUMERIC(18,6)
					,@TaxCodeId				INT
					,@TaxAdjusted			BIT
					,@AdjustedTax			NUMERIC(18,6)
					,@Tax					NUMERIC(18,6)
					,@Rate					NUMERIC(18,6)
					,@ExemptionPercent		NUMERIC(18,6)
					,@CalculationMethod		NVARCHAR(30)
					,@CheckoffTax			BIT
					,@TaxExempt				BIT
					
			SELECT TOP 1 
				 @Id			= [Id]
				,@TaxableAmount	= ISNULL(@ItemPrice, @ZeroDecimal) * ISNULL(@Quantity, @ZeroDecimal)
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
				,[ysnTaxOnly]	
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
							,@TaxTaxOnly				BIT
							
					SELECT TOP 1 @TaxId	= [Id] FROM @TaxableByOtherTaxes
								
					SELECT TOP 1
						 @TaxTaxableByOtherTaxes	= [strTaxableByOtherTaxes]
						,@TaxTaxAdjusted			= ISNULL([ysnTaxAdjusted],0)
						,@TaxAdjustedTax			= [dblAdjustedTax]
						,@TaxRate					= [dblRate]
						,@TaxCalculationMethod		= [strCalculationMethod]
						,@TaxTaxExempt				= ISNULL([ysnTaxExempt],0)
						,@TaxTaxOnly				= ISNULL([ysnTaxOnly],0)
						,@OtherTaxAmount			= 0.000000
					FROM
						@TaxableByOtherTaxes
					WHERE
						[Id] = @TaxId
						
						
						
					IF(@TaxTaxableByOtherTaxes IS NOT NULL AND RTRIM(LTRIM(@TaxTaxableByOtherTaxes)) <> '')
					BEGIN
						IF @TaxTaxOnly = 1
							SET @TaxableAmount = @ZeroDecimal
						ELSE
							SET @TaxableAmount	= ISNULL(@ItemPrice, @ZeroDecimal) * ISNULL(@Quantity, @ZeroDecimal)

						IF(@TaxAdjustedTax = 1)
						BEGIN
							SET @OtherTaxAmount = @OtherTaxAmount + @TaxAdjustedTax
						END
						ELSE
							BEGIN
								IF(@TaxCalculationMethod = 'Percentage')
									BEGIN
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.00 ELSE (@ItemPrice * @Quantity) * (@TaxRate/100.00) END))
									END
								ELSE
									BEGIN
										SET @OtherTaxAmount = (@OtherTaxAmount) + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.00 ELSE (@Quantity * @TaxRate) END))
									END
							END
					END 
						
					SET @TaxableAmount = @TaxableAmount + @OtherTaxAmount

					DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
				END
				
			
			DECLARE @ItemTaxAmount NUMERIC(18,6) = 0.00
			IF(@CalculationMethod = 'Percentage')
				SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
			ELSE
				SET @ItemTaxAmount = (@Quantity * @Rate);
				
			IF(@TaxExempt = 1 AND @ExemptionPercent = 0.00) AND @DisregardExemptionSetup = 0
				SET @ItemTaxAmount = 0.00;

			IF(@TaxExempt = 1 AND @ExemptionPercent <> 0.00) OR @DisregardExemptionSetup = 1
				SET @ItemTaxAmount = @ItemTaxAmount - (@ItemTaxAmount * (@ExemptionPercent/100) );
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;

			IF(@ExcludeCheckOff = 1 AND @CheckoffTax = 1)
				SET @ItemTaxAmount = @ZeroDecimal;
			
			UPDATE
				@ItemTaxes
			SET
				dblTax			= ROUND(ROUND(@ItemTaxAmount,3),[dbo].[fnARGetDefaultDecimal]())
				,dblAdjustedTax = ROUND(ROUND(@ItemTaxAmount,3),[dbo].[fnARGetDefaultDecimal]())
				,ysnComputed	= 1 
			WHERE
				[Id] = @Id				
		END
				
	INSERT INTO @returntable(
		 [intTaxGroupId]
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
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strNotes]
	)
	SELECT
		 [intTaxGroupId]
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
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strNotes]
	FROM
		@ItemTaxes 	
	RETURN		

END