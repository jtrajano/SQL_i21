CREATE FUNCTION [dbo].[fnConstructLineItemTaxDetail]
(
	 @Quantity				NUMERIC(18,6)					= 0
	,@GrossAmount			NUMERIC(18,6)					= 0
	,@LineItemTaxEntries	LineItemTaxDetailStagingTable	READONLY
	,@IsReversal			BIT								= 0	
	,@ItemId				INT								= NULL	
	,@EntityCustomerId		INT								= NULL
	,@CompanyLocationId		INT								= NULL
	,@TaxGroupId			INT								= NULL
	,@Price					NUMERIC(18,6)					= 0	
	,@TransactionDate		DATE							= NULL	
	,@ShipToLocationId		INT								= NULL
	,@IncludeExemptedCodes	BIT								= 0
	,@SiteId				INT								= NULL
)
RETURNS @returntable TABLE
(
	 [intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblExemptionPercent]			NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnCheckoffTax]				BIT
	,[ysnTaxExempt]					BIT
	,[ysnInvalidSetup]				BIT
	,[strNotes]						NVARCHAR(500)
)
AS
BEGIN

	IF ISNULL(@IsReversal,0) = 0 AND NOT EXISTS(SELECT TOP 1 NULL FROM @LineItemTaxEntries)
		BEGIN
			INSERT INTO @returntable(
				 [intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[ysnTaxExempt]
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
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[ysnTaxExempt]
				,[ysnInvalidSetup]
				,[strNotes]
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
					) 	
			RETURN		
		END

	DECLARE @ZeroDecimal		NUMERIC(18, 6)
			,@TaxAmount			NUMERIC(18,6)
			
	SET @ZeroDecimal = 0.000000
	SET @GrossAmount = ISNULL(@GrossAmount, @ZeroDecimal)
	SET @Quantity = ISNULL(@Quantity, @ZeroDecimal)
	SET @Price = ISNULL(@Price, @ZeroDecimal)

	DECLARE @ItemTaxes AS TABLE(
		 [Id]							INT IDENTITY(1,1)
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblExemptionPercent]			NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strNotes]						NVARCHAR(500)
		,[ysnTaxAdjusted]				BIT
		,[ysnComputed]					BIT
		)


	INSERT INTO @ItemTaxes(
		 [intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxAdjusted]
		,[ysnComputed]
	)
	SELECT

		 [intTaxGroupId]			= LITE.[intTaxGroupId]
		,[intTaxCodeId]				= LITE.[intTaxCodeId]
		,[intTaxClassId]			= ISNULL(LITE.[intTaxClassId], SMTC.[intTaxClassId])
		,[strTaxableByOtherTaxes]	= ISNULL(LITE.[strTaxableByOtherTaxes], SMTC.[strTaxableByOtherTaxes])
		,[strCalculationMethod]		= ISNULL(LITE.[strCalculationMethod], (SELECT [strCalculationMethod] FROM [dbo].[fnGetTaxCodeRateDetails](LITE.[intTaxCodeId], @TransactionDate)))
		,[dblRate]					= ISNULL(ISNULL(LITE.[dblRate], (SELECT [dblRate] FROM [dbo].[fnGetTaxCodeRateDetails](LITE.[intTaxCodeId], @TransactionDate))), @ZeroDecimal)
		,[dblExemptionPercent]		= @ZeroDecimal
		,[dblTax]					= LITE.[dblTax]
		,[dblAdjustedTax]			= LITE.[dblAdjustedTax]
		,[intTaxAccountId]			= ISNULL(LITE.[intTaxAccountId], SMTC.[intSalesTaxAccountId])
		,[ysnCheckoffTax]			= ISNULL(LITE.[ysnCheckoffTax], SMTC.[ysnCheckoffTax])
		,[ysnTaxExempt]				= LITE.[ysnTaxExempt] 
		,[ysnTaxAdjusted]			= LITE.[ysnTaxAdjusted] 
		,[ysnComputed]				= 0
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
				,[dblExemptionPercent]			NUMERIC(18,6)
				,[dblTax]						NUMERIC(18,6)
				,[dblAdjustedTax]				NUMERIC(18,6)
				,[intTaxAccountId]				INT
				,[ysnCheckoffTax]				BIT
				,[strTaxCode]					NVARCHAR(100)						
				,[ysnTaxExempt]					BIT
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
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
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
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
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
				AND [ysnTaxExempt] = 0

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


					SELECT
						@TBOTRegularRate = SUM((@TBOTRate * @Quantity) * (ISNULL([dblRate], @ZeroDecimal)/100.00))
					FROM
						@ItemTaxes
					WHERE
						[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodes))
						AND [ysnCheckoffTax] = 0
						AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'	

					SELECT
						@TBOTCheckOffRate = SUM((@TBOTRate * @Quantity) * (ISNULL([dblRate], @ZeroDecimal)/100.00))
					FROM
						@ItemTaxes
					WHERE
						[intTaxCodeId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TBOTTaxCodes))
						AND [ysnCheckoffTax] = 1
						AND LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'	

					SET @TaxableByOtherUnitTax = @TaxableByOtherUnitTax + ((ISNULL(@TBOTRegularRate, @ZeroDecimal) - ISNULL(@TBOTCheckOffRate, @ZeroDecimal)) * (CASE WHEN @TBOTCheckOff = 1 THEN -1 ELSE 1 END))
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
				
			SELECT
				@CheckOffUnitTax = SUM(@Quantity * [dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'unit'
				AND [ysnCheckoffTax] = 1
				AND [ysnTaxExempt] = 0
				
			SET @TotalUnitTax = ((ISNULL(@UnitTax, @ZeroDecimal) - ISNULL(@CheckOffUnitTax, @ZeroDecimal)) + ISNULL(@TaxableByOtherUnitTax, @ZeroDecimal))
			
			SELECT
				@RegularRate = SUM([dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'
				AND [ysnCheckoffTax] = 0
				AND [ysnTaxExempt] = 0
				
			SELECT
				@CheckOffRate = SUM([dblRate])
			FROM
				@ItemTaxes
			WHERE
				LOWER(RTRIM(LTRIM([strCalculationMethod]))) = 'percentage'
				AND [ysnCheckoffTax] = 1
				AND [ysnTaxExempt] = 0
				
			SET @TotalTaxRate = ISNULL(@RegularRate, @ZeroDecimal) - ISNULL(@CheckOffRate, @ZeroDecimal)
			
			----t = pq + (pqr)
			----t/(q + qr) = p		
			SET @ItemPrice = (@GrossAmount - @TotalUnitTax) / (@Quantity + (@Quantity * (@TotalTaxRate/100.00)))
					
		END		
	
		
		

	-- Calculate Item Tax
	WHILE EXISTS(SELECT TOP 1 NULL FROM @ItemTaxes WHERE ISNULL([ysnComputed], 0) = 0)
		BEGIN
			DECLARE  @Id				INT
					,@TaxableAmount		NUMERIC(18,6)
					,@TaxCodeId			INT
					,@TaxAdjusted		BIT
					,@AdjustedTax		NUMERIC(18,6)
					,@Tax				NUMERIC(18,6)
					,@Rate				NUMERIC(18,6)
					,@ExemptionPercent	NUMERIC(18,6)
					,@CalculationMethod	NVARCHAR(30)
					,@CheckoffTax		BIT
					,@TaxExempt			BIT
					
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
			FROM
				@ItemTaxes
			WHERE
				Id <> @Id 
				AND @TaxCodeId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(strTaxableByOtherTaxes))						
			
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
						
						
						
					IF(@TaxTaxableByOtherTaxes IS NOT NULL AND RTRIM(LTRIM(@TaxTaxableByOtherTaxes)) <> '')
					BEGIN
						IF(@TaxAdjustedTax = 1)
						BEGIN
							SET @TaxableAmount = @TaxableAmount + @TaxAdjustedTax
						END
						ELSE
							BEGIN
								IF(@TaxCalculationMethod = 'Percentage')
									BEGIN
										SET @TaxableAmount = @TaxableAmount + ((CASE WHEN @TaxTaxExempt = 1 THEN 0.00 ELSE (@ItemPrice * @Quantity) * (@TaxRate/100.00) END))
									END
								ELSE
									BEGIN
										SET @TaxableAmount = (@ItemPrice * @Quantity) + ((CASE WHEN @TaxTaxExempt = 1 THEN 0.00 ELSE (@Quantity * @TaxRate) END))
									END
							END
					END 
						
					DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
				END
				
			
			DECLARE @ItemTaxAmount NUMERIC(18,6) = 0.00
			IF(@CalculationMethod = 'Percentage')
				SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
			ELSE
				SET @ItemTaxAmount = (@Quantity * @Rate);
				
			IF(@TaxExempt = 1 AND @ExemptionPercent = 0.00)
				SET @ItemTaxAmount = 0.00;

			IF(@TaxExempt = 1 AND @ExemptionPercent <> 0.00)
				SET @ItemTaxAmount = @ItemTaxAmount - (@ItemTaxAmount * (@ExemptionPercent/100) );
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;
			
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
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
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
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
		,[strNotes]
	FROM
		@ItemTaxes 	
	RETURN		

END