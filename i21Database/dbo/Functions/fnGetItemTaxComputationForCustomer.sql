CREATE FUNCTION [dbo].[fnGetItemTaxComputationForCustomer]
(
	 @ItemId			INT
	,@CustomerId		INT
	,@TransactionDate	DATETIME
	,@ItemPrice			NUMERIC(18,6)
	,@QtyShipped		NUMERIC(18,6)
	,@TaxGroupId		INT
	,@ShipToLocationId	INT
	,@CompanyLocationId	INT
)
RETURNS @returntable TABLE
(
	 [intTransactionDetailTaxId]	INT
	,[intTransactionDetailId]		INT
	,[intTaxGroupMasterId]			INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[numRate]						NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[ysnSeparateOnInvoice]			BIT
	,[intTaxAccountId]				INT
	,[ysnTaxAdjusted]				BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[strTaxGroup]					NVARCHAR(100)
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
	SET @ZeroDecimal = 0.000000
	
	DECLARE @ItemTaxes AS TABLE(
			 [Id]							INT IDENTITY(1,1)
			,[intTransactionDetailTaxId]	INT
			,[intTransactionDetailId]		INT
			,[intTaxGroupMasterId]			INT
			,[intTaxGroupId]				INT
			,[intTaxCodeId]					INT
			,[intTaxClassId]				INT
			,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
			,[strCalculationMethod]			NVARCHAR(30)
			,[numRate]						NUMERIC(18,6)
			,[dblTax]						NUMERIC(18,6)
			,[dblAdjustedTax]				NUMERIC(18,6)
			,[intTaxAccountId]				INT
			,[ysnSeparateOnInvoice]			BIT
			,[ysnCheckoffTax]				BIT
			,[strTaxCode]					NVARCHAR(100)						
			,[ysnTaxExempt]					BIT
			,[strTaxGroup]					NVARCHAR(100)
			,[ysnTaxAdjusted]				BIT
			,[ysnComputed]					BIT
			)
			
	DECLARE @TaxGroupMasterId INT
			
	IF ISNULL(@TaxGroupId, 0) = 0
		SELECT @TaxGroupMasterId = [dbo].[fnGetTaxMasterIdForCustomer](@CustomerId, @CompanyLocationId, @ItemId)
		

	IF ISNULL(@TaxGroupMasterId, 0) <> 0 AND ISNULL(@TaxGroupId, 0) = 0
		BEGIN			
			DECLARE @Country NVARCHAR(MAX)
					,@County NVARCHAR(MAX)
					,@City NVARCHAR(MAX)
					,@State NVARCHAR(MAX)				
					
			IF ISNULL(@ShipToLocationId,0) <> 0
				BEGIN
					SELECT TOP 1
						 @Country	= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCountry], EL.[strCountry]),''))))
						,@State		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strState], EL.[strState]),''))))
						,@County	= UPPER(RTRIM(LTRIM(ISNULL(TC.[strCounty],'')))) 
						,@City		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCity], EL.[strCity]),''))))
					FROM
						tblEntityLocation SL
					LEFT OUTER JOIN
						tblARCustomer C
							ON SL.[intEntityLocationId] = C.[intShipToId] 							
					LEFT OUTER JOIN
						(	SELECT
								[intEntityLocationId]
								,[intEntityId] 
								,[strCountry]
								,[strState]
								,[strCity]
							FROM 
							tblEntityLocation
							WHERE
								ysnDefaultLocation = 1
						) EL
							ON C.[intEntityCustomerId] = EL.[intEntityId]
					LEFT OUTER JOIN
						tblSMTaxCode TC
							ON C.[intTaxCodeId] = TC.[intTaxCodeId] 								
					WHERE
						SL.[intEntityLocationId] = @ShipToLocationId
				END
				ELSE
				BEGIN
					SELECT TOP 1
						 @Country	= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCountry], EL.[strCountry]),''))))
						,@State		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strState], EL.[strState]),''))))
						,@County	= UPPER(RTRIM(LTRIM(ISNULL(TC.[strCounty],'')))) 
						,@City		= UPPER(RTRIM(LTRIM(ISNULL(ISNULL(SL.[strCity], EL.[strCity]),''))))
					FROM
						tblARCustomer C
					LEFT OUTER JOIN
						(	SELECT
								 [intEntityLocationId]
								,[intEntityId] 
								,[strCountry]
								,[strState]
								,[strCity]
							FROM 
							tblEntityLocation
							WHERE
								ysnDefaultLocation = 1
						) EL
							ON C.[intEntityCustomerId] = EL.[intEntityId]
					LEFT OUTER JOIN
						tblEntityLocation SL
							ON C.[intShipToId] = SL.[intEntityLocationId]
					LEFT OUTER JOIN
						tblSMTaxCode TC
							ON C.[intTaxCodeId] = TC.[intTaxCodeId] 								
					WHERE
						C.[intEntityCustomerId] = @CustomerId	
				END
										
			SELECT @TaxGroupId = [dbo].[fnGetTaxGroupForLocation](@TaxGroupMasterId, @Country, @County, @City, @State)			
		END
			
	INSERT INTO @ItemTaxes (
		 [intTransactionDetailTaxId] 
		,[intTransactionDetailId]
		,[intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
	)
	SELECT
		 [intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
	FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId)
					
	
	UPDATE @ItemTaxes SET intTaxGroupMasterId = NULL WHERE intTaxGroupMasterId NOT IN (SELECT intTaxGroupMasterId FROM tblSMTaxGroupMaster)
									
			
	-- Calculate Item Tax
	WHILE EXISTS(SELECT TOP 1 NULL FROM @ItemTaxes WHERE ISNULL([ysnComputed], 0) = 0)
		BEGIN
			DECLARE  @Id				INT
					,@TaxableAmount		NUMERIC(18,6)
					,@TaxClassId		INT
					,@TaxAdjusted		BIT
					,@AdjustedTax		NUMERIC(18,6)
					,@Tax				NUMERIC(18,6)
					,@Rate				NUMERIC(18,6)
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
				 @TaxClassId		= [intTaxClassId]
				,@TaxAdjusted		= ISNULL([ysnTaxAdjusted],0)
				,@AdjustedTax		= [dblAdjustedTax]
				,@Tax				= [dblTax]
				,@Rate				= [numRate]
				,@CalculationMethod	= [strCalculationMethod]
				,@CheckoffTax		= ISNULL([ysnCheckoffTax],0)
				,@TaxExempt			= ISNULL([ysnTaxExempt],0)
			FROM
				@ItemTaxes
			WHERE [Id] = @Id
							
			
			DECLARE @TaxableByOtherTaxes AS TABLE(
				 [Id]						INT
				,[intTaxClassId]			INT
				,[strTaxableByOtherTaxes]	NVARCHAR(MAX)
				,[strCalculationMethod]		NVARCHAR(30)
				,[numRate]					NUMERIC(18,6)
				,[dblAdjustedTax]			NUMERIC(18,6)
				,[ysnTaxAdjusted]			BIT
				,[ysnTaxExempt]				BIT
				)
				
			INSERT INTO @TaxableByOtherTaxes (
				Id
				,intTaxClassId
				,strTaxableByOtherTaxes
				,strCalculationMethod
				,numRate
				,dblAdjustedTax
				,ysnTaxAdjusted	
				,ysnTaxExempt	
				)
			SELECT
				 Id
				,intTaxClassId
				,strTaxableByOtherTaxes
				,strCalculationMethod
				,numRate
				,dblAdjustedTax
				,ysnTaxAdjusted
				,ysnTaxExempt
			FROM
				@ItemTaxes
			WHERE
				Id <> @Id 
				AND @TaxClassId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(strTaxableByOtherTaxes))						
			
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
						,@TaxRate					= [numRate]
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
										SET @TaxableAmount = @TaxableAmount + ((CASE WHEN @TaxTaxExempt = 1 THEN 0.00 ELSE (@ItemPrice * @QtyShipped) * (@TaxRate/100.00) END))
									END
								ELSE
									BEGIN
										SET @TaxableAmount = (@ItemPrice * @QtyShipped) + ((CASE WHEN @TaxTaxExempt = 1 THEN 0.00 ELSE (@QtyShipped * @TaxRate) END))
									END
							END
					END 
						
					DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
				END
				
			
			DECLARE @ItemTaxAmount NUMERIC(18,6) = 0.00
			IF(@CalculationMethod = 'Percentage')
				SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
			ELSE
				SET @ItemTaxAmount = (@QtyShipped * @Rate);
				
			IF(@TaxExempt = 1)
				SET @ItemTaxAmount = 0.00;
				
			IF(@CheckoffTax = 1)
				SET @ItemTaxAmount = @ItemTaxAmount * -1;
			
			UPDATE
				@ItemTaxes
			SET
				 dblTax			= @ItemTaxAmount
				,dblAdjustedTax = @ItemTaxAmount
				,ysnComputed	= 1 
			WHERE
				[Id] = @Id				
		END
				
	INSERT INTO @returntable(
		[intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
	)
	SELECT
		 [intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupMasterId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
	FROM
		@ItemTaxes 	
	RETURN				
END