CREATE FUNCTION [dbo].[fnAPRecomputeTaxes]
(
	@taxes AS VoucherDetailTax READONLY,
	@cost DECIMAL(38,20),
	@quantity DECIMAL(38,20)
)
RETURNS @returntable TABLE
(
	[intTaxGroupId]					INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[ysnSeparateOnBill]			BIT DEFAULT 0
	,[intTaxAccountId]				INT
	,[ysnTaxAdjusted]				BIT DEFAULT 0
	,[ysnCheckoffTax]				BIT DEFAULT 0
	,[ysnTaxExempt]					BIT DEFAULT 0
	,[ysnTaxOnly]					BIT DEFAULT 0
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
	SET @ZeroDecimal = 0.000000
	DECLARE @ExcludeCheckOff BIT = 0;
	
	DECLARE @ItemTaxes AS TABLE(
		[Id]							INT IDENTITY(1,1)
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnBill]			BIT DEFAULT 0
		,[ysnCheckoffTax]				BIT DEFAULT 0
		,[ysnTaxExempt]					BIT
		,[ysnTaxOnly]					BIT DEFAULT 0
		,[ysnTaxAdjusted]				BIT DEFAULT 0
		,[ysnComputed]					BIT
	)

	INSERT INTO @ItemTaxes(
		[intTaxGroupId]				
		,[intTaxCodeId]					
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]		
		,[strCalculationMethod]			
		,[dblRate]						
		,[dblTax]						
		,[dblAdjustedTax]				
		,[intTaxAccountId]				
		,[ysnSeparateOnBill]			
		,[ysnCheckoffTax]				
		,[ysnTaxExempt]					
		,[ysnTaxOnly]					
		,[ysnTaxAdjusted]				
	)
	SELECT
		[intTaxGroupId]				= A.intTaxGroupId
		,[intTaxCodeId]				= A.intTaxCodeId
		,[intTaxClassId]			= A.intTaxClassId
		,[strTaxableByOtherTaxes]	= A.[strTaxableByOtherTaxes]
		,[strCalculationMethod]		= A.[strCalculationMethod]
		,[dblRate]					= A.[dblRate]	
		,[dblTax]					= A.[dblTax]	
		,[dblAdjustedTax]			= A.[dblAdjustedTax]	
		,[intTaxAccountId]			= A.[intAccountId]	
		,[ysnSeparateOnBill]		= A.[ysnSeparateOnBill]	
		,[ysnCheckoffTax]			= A.[ysnCheckOffTax]	
		,[ysnTaxExempt]				= A.[ysnTaxExempt]	
		,[ysnTaxOnly]				= A.[ysnTaxOnly]	
		,[ysnTaxAdjusted]		    = A.[ysnTaxAdjusted]
	FROM @taxes A

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
			,@TaxableAmount	= ISNULL(@cost, @ZeroDecimal) * ISNULL(@quantity, @ZeroDecimal)
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
						
				SET @TaxableAmount = ISNULL(@cost, @ZeroDecimal) * ISNULL(@quantity, @ZeroDecimal)	
						
				IF(@TaxTaxableByOtherTaxes IS NOT NULL AND RTRIM(LTRIM(@TaxTaxableByOtherTaxes)) <> '')
				BEGIN						
					IF(@TaxAdjustedTax = 1)
					BEGIN
						SET @OtherTaxAmount = @OtherTaxAmount + @TaxAdjustedTax
					END
					ELSE
						BEGIN
							IF(@TaxCalculationMethod = 'Percentage')
								BEGIN
									SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@cost * @quantity) * (@TaxRate/100.000000) END))
								END
							ELSE IF(@TaxCalculationMethod = 'Percentage of Tax Only')
								BEGIN
									SET @OtherTaxAmount = 0.00;
								END
							ELSE
								BEGIN
									SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@quantity * @TaxRate) END))
								END
						END
				END 

					
						
				DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
			END
				
		-- IF @TaxOnly = 1
		-- 	SET @TaxableAmount = @ZeroDecimal
		-- ELSE
		-- 	SET @TaxableAmount	= ISNULL(@cost, @ZeroDecimal) * ISNULL(@quantity, @ZeroDecimal)

		SET @TaxableAmount = @TaxableAmount + @OtherTaxAmount

		DECLARE @ItemTaxAmount NUMERIC(18,6) = 0.00
		IF(@CalculationMethod = 'Percentage')
			SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
		ELSE
			SET @ItemTaxAmount = (@quantity * @Rate);
				
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
		[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnBill]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
	)
	SELECT
		 [intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnBill]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
	FROM
		@ItemTaxes
	
	RETURN;
END
