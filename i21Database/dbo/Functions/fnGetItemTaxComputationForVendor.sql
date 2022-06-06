﻿CREATE FUNCTION [dbo].[fnGetItemTaxComputationForVendor]
(
	 @ItemId						INT
	,@VendorId						INT
	,@TransactionDate				DATETIME
	,@ItemCost						NUMERIC(38,20)
	,@Quantity						NUMERIC(38,20)
	,@TaxGroupId					INT
	,@CompanyLocationId				INT
	,@VendorLocationId				INT
	,@IncludeExemptedCodes			BIT
	,@IncludeInvalidCodes			BIT             = 0
	,@FreightTermId					INT
	,@ExcludeCheckOff				BIT
	,@ItemUOMId						INT				= NULL
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
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[ysnSeparateOnInvoice]			BIT DEFAULT 0
	,[intTaxAccountId]				INT
	,[ysnTaxAdjusted]				BIT DEFAULT 0
	,[ysnCheckoffTax]				BIT DEFAULT 0
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT DEFAULT 0
	,[ysnTaxOnly]					BIT DEFAULT 0
	,[ysnInvalidSetup]				BIT DEFAULT 0
	,[ysnAddToCost]  				BIT DEFAULT 0
	,[strTaxGroup]					NVARCHAR(100)
	,[strNotes]						NVARCHAR(500)
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
	SET @ZeroDecimal = 0.000000
	
	DECLARE @ItemTaxes AS TABLE(
			 [Id]							INT IDENTITY(1,1)
			,[intTransactionDetailTaxId]	INT
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
			,[ysnSeparateOnInvoice]			BIT DEFAULT 0
			,[ysnCheckoffTax]				BIT DEFAULT 0
			,[strTaxCode]					NVARCHAR(100)						
			,[ysnTaxExempt]					BIT
			,[ysnTaxOnly]					BIT DEFAULT 0
			,[ysnInvalidSetup]				BIT DEFAULT 0
			,[strTaxGroup]					NVARCHAR(100)
			,[strNotes]						NVARCHAR(500)
			,[ysnTaxAdjusted]				BIT DEFAULT 0
			,[ysnAddToCost]				    BIT DEFAULT 0			
			,[ysnComputed]					BIT
			)
					
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
	FROM
		[dbo].[fnGetTaxGroupTaxCodesForVendor](@TaxGroupId, @VendorId, @TransactionDate, @ItemId, @VendorLocationId, @IncludeExemptedCodes, @IncludeInvalidCodes, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate, @CompanyLocationId)
												
			
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
					,@CalculationMethod	NVARCHAR(30)
					,@CheckoffTax		BIT
					,@TaxExempt			BIT
					,@TaxOnly			BIT			
					
			SELECT TOP 1 
				 @Id			= [Id]
				,@TaxableAmount	= ISNULL(@ItemCost, @ZeroDecimal) * ISNULL(@Quantity, @ZeroDecimal)
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
				 Id
				,intTaxCodeId
				,strTaxableByOtherTaxes
				,strCalculationMethod
				,dblRate
				,dblAdjustedTax
				,ysnTaxAdjusted
				,ysnTaxExempt
				,ysnTaxOnly
			FROM
				@ItemTaxes
			WHERE
				Id <> @Id 
				AND @TaxCodeId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(strTaxableByOtherTaxes))						
				AND ysnTaxExempt = 0

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
						
					SET @TaxableAmount	= ISNULL(@ItemCost, @ZeroDecimal) * ISNULL(@Quantity, @ZeroDecimal)
						
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
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@ItemCost * @Quantity) * (@TaxRate/100.000000) END))
									END
								ELSE
									BEGIN
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@Quantity * @TaxRate) END))
									END
							END
					END 

					
						
					DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
				END
							

			SET @TaxableAmount = @TaxableAmount + @OtherTaxAmount

			DECLARE @ItemTaxAmount NUMERIC(18,6) = 0.00
			IF(@CalculationMethod = 'Percentage')
				SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
			ELSE IF(@CalculationMethod = 'Percentage of Tax Only')
				SET @ItemTaxAmount = (@OtherTaxAmount * @Rate);
			ELSE
				SET @ItemTaxAmount = (@Quantity * @Rate);
				
			IF(@TaxExempt = 1)
				SET @ItemTaxAmount = 0.00;
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;

			IF(@ExcludeCheckOff = 1 AND @CheckoffTax = 1)
				SET @ItemTaxAmount = @ZeroDecimal;
			
			UPDATE
				@ItemTaxes
			SET
				 dblTax			= ROUND(@ItemTaxAmount, [dbo].[fnARGetDefaultDecimal]())
				,dblAdjustedTax = ROUND(@ItemTaxAmount, [dbo].[fnARGetDefaultDecimal]())
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
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnAddToCost]
		,[strTaxGroup]
		,[strNotes]
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
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnAddToCost]
		,[strTaxGroup]
		,[strNotes]
	FROM
		@ItemTaxes 	
	RETURN				
END
