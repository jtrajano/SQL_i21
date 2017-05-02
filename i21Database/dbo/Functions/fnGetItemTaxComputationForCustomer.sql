CREATE FUNCTION [dbo].[fnGetItemTaxComputationForCustomer]
(
	 @ItemId					INT
	,@CustomerId				INT
	,@TransactionDate			DATETIME
	,@ItemPrice					NUMERIC(18,6)
	,@QtyShipped				NUMERIC(18,6)
	,@TaxGroupId				INT
	,@CompanyLocationId			INT
	,@CustomerLocationId		INT	
	,@IncludeExemptedCodes		BIT
	,@IsCustomerSiteTaxable		BIT
	,@SiteId					INT
	,@FreightTermId				INT
	,@CardId					INT
	,@VehicleId					INT
	,@DisregardExemptionSetup	BIT
	,@ExcludeCheckOff			BIT
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
	,[dblExemptionPercent]			NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[ysnSeparateOnInvoice]			BIT
	,[intTaxAccountId]				INT
	,[ysnTaxAdjusted]				BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnInvalidSetup]				BIT
	,[strTaxGroup]					NVARCHAR(100)
	,[strNotes]						NVARCHAR(500)
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
	SET @ZeroDecimal = 0.000000

	DECLARE @ItemType NVARCHAR(50)
	SET @ItemType = ISNULL((SELECT strType FROM tblICItem WHERE [intItemId] = @ItemId),'')
	
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
			,[dblExemptionPercent]			NUMERIC(18,6)
			,[dblTax]						NUMERIC(18,6)
			,[dblAdjustedTax]				NUMERIC(18,6)
			,[intTaxAccountId]				INT
			,[ysnSeparateOnInvoice]			BIT
			,[ysnCheckoffTax]				BIT
			,[strTaxCode]					NVARCHAR(100)						
			,[ysnTaxExempt]					BIT
			,[ysnInvalidSetup]				BIT
			,[strTaxGroup]					NVARCHAR(100)
			,[strNotes]						NVARCHAR(500)
			,[ysnTaxAdjusted]				BIT
			,[ysnComputed]					BIT
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
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
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
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
	FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId, @CustomerLocationId, @IncludeExemptedCodes, @IsCustomerSiteTaxable, @CardId, @VehicleId, @DisregardExemptionSetup)
															
			
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
						,@OtherTaxAmount			= 0.000000
					FROM
						@TaxableByOtherTaxes
					WHERE
						[Id] = @TaxId
						
						
						
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
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@ItemPrice * @QtyShipped) * (@TaxRate/100.000000) END))
									END
								ELSE
									BEGIN
										SET @OtherTaxAmount = @OtherTaxAmount + ((CASE WHEN (@TaxTaxExempt = 1 OR (@ExcludeCheckOff = 1 AND @CheckoffTax = 1)) THEN 0.000000 ELSE (@QtyShipped * @TaxRate) END))
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
				SET @ItemTaxAmount = (@QtyShipped * @Rate);
				
			IF(@TaxExempt = 1 AND @ExemptionPercent = 0.00)
				SET @ItemTaxAmount = 0.00;

			IF(@TaxExempt = 1 AND @ExemptionPercent <> 0.00)
				SET @ItemTaxAmount = @ItemTaxAmount - (@ItemTaxAmount * (@ExemptionPercent/100) );
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;

			IF(@ExcludeCheckOff = 1 AND @CheckoffTax = 1)
				SET @ItemTaxAmount = @ZeroDecimal;

			IF @ItemType = 'Comment'
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
		[intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
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
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
	FROM
		@ItemTaxes 	
	RETURN				
END