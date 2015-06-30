CREATE PROCEDURE [dbo].[uspARReComputeInvoiceTaxes]
	 @InvoiceId		AS INT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6)

SET @ZeroDecimal = 0.000000	

DECLARE @CustomerId			INT
		,@LocationId		INT
		,@TransactionDate	DATETIME
		
		
SELECT
	@CustomerId			= [intEntityCustomerId]
	,@LocationId		= [intCompanyLocationId]
	,@TransactionDate	= [dtmDate]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId


DECLARE @InvoiceDetail AS TABLE  (
	intInvoiceDetailId	INT PRIMARY KEY,
	intItemId			INT,
	UNIQUE (intInvoiceDetailId)
);


INSERT INTO @InvoiceDetail (intInvoiceDetailId, intItemId)
SELECT
	 [intInvoiceDetailId]
	,[intItemId]
FROM
	tblARInvoiceDetail
WHERE
	[intInvoiceId] = @InvoiceId
ORDER BY
	[intInvoiceDetailId]
	
	
WHILE EXISTS(SELECT NULL FROM @InvoiceDetail)
	BEGIN
		DECLARE  @InvoiceDetailId	INT
				,@ItemId			INT
				,@ItemPrice			DECIMAL(18,6) 
				,@QtyShipped		DECIMAL(18,6) 
				,@TotalItemTax		DECIMAL(18,6) 
				

		SELECT TOP 1
			 @InvoiceDetailId		= [intInvoiceDetailId]
		FROM
			@InvoiceDetail
		ORDER BY
			[intInvoiceDetailId]
			
		SELECT
			 @ItemId				= [intItemId]
			,@ItemPrice				= [dblPrice]
			,@QtyShipped			= [dblQtyShipped]
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceDetailId] = @InvoiceDetailId
			
		DELETE FROM tblARInvoiceDetailTax WHERE [intInvoiceDetailId] = @InvoiceDetailId
			
		DECLARE @ItemTaxes AS TABLE(
			 Id						UNIQUEIDENTIFIER DEFAULT(NEWID())
			,intInvoiceDetailTaxId	INT
			,intInvoiceDetailId		INT	NULL
			,intTaxGroupMasterId	INT
			,intTaxGroupId			INT
			,intTaxCodeId			INT
			,intTaxClassId			INT
			,strTaxableByOtherTaxes	NVARCHAR(MAX)
			,strCalculationMethod	NVARCHAR(30)
			,numRate				DECIMAL(18,6)
			,intSalesTaxAccountId	INT
			,dblTax					DECIMAL(18,6)
			,dblAdjustedTax			DECIMAL(18,6)
			,ysnTaxAdjusted			BIT
			,ysnSeparateOnInvoice	BIT
			,ysnCheckoffTax			BIT
			,strTaxCode				NVARCHAR(30)
			)
			
			
			INSERT INTO @ItemTaxes (
				 [intInvoiceDetailTaxId] 
				,[intInvoiceDetailId]
				,[intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[numRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intSalesTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
			)
			EXEC dbo.[uspARGetItemTaxes]  
					 @ItemId  
					,@LocationId  
					,@CustomerId
					,@TransactionDate
									
			
			-- Calculate Item Tax
			WHILE EXISTS(SELECT NULL FROM @ItemTaxes WHERE [intInvoiceDetailId] IS NULL OR [intInvoiceDetailId] = 0)
				BEGIN
					DECLARE @Id					UNIQUEIDENTIFIER
							,@TaxableAmount		DECIMAL(18,6)
							,@TaxClassId		INT
							,@TaxAdjusted		BIT
							,@AdjustedTax		DECIMAL(18,6)
							,@Tax				DECIMAL(18,6)
							,@Rate				DECIMAL(18,6)
							,@CalculationMethod	NVARCHAR(30)
							,@CheckoffTax		BIT
							
					SELECT TOP 1 
						 @Id			= [Id]
						,@TaxableAmount	= ISNULL(@ItemPrice,@ZeroDecimal) * ISNULL(@QtyShipped,@ZeroDecimal)
					FROM
						@ItemTaxes
					WHERE
						[intInvoiceDetailId] IS NULL OR [intInvoiceDetailId] = 0
						
					UPDATE @ItemTaxes SET [intInvoiceDetailId] = @InvoiceDetailId, ysnTaxAdjusted = 0 WHERE [Id] = @Id
					
					SELECT 
						 @TaxClassId		= [intTaxClassId]
						,@TaxAdjusted		= [ysnTaxAdjusted]
						,@AdjustedTax		= [dblAdjustedTax]
						,@Tax				= [dblTax]
						,@Rate				= [numRate]
						,@CalculationMethod	= [strCalculationMethod]
					FROM
						@ItemTaxes
					WHERE [Id] = @Id
					
					
					DECLARE @TaxableByOtherTaxes AS TABLE(
						 Id						UNIQUEIDENTIFIER DEFAULT(NEWID())
						,intTaxClassId			INT
						,strTaxableByOtherTaxes	NVARCHAR(MAX)
						,strCalculationMethod	NVARCHAR(30)
						,numRate				DECIMAL(18,6)
						,dblAdjustedTax			DECIMAL(18,6)
						,ysnTaxAdjusted			BIT
						)
						
					INSERT INTO @TaxableByOtherTaxes (
						Id
						,intTaxClassId
						,strTaxableByOtherTaxes
						,strCalculationMethod
						,numRate
						,dblAdjustedTax
						,ysnTaxAdjusted	
						)
					SELECT
						 Id
						,intTaxClassId
						,strTaxableByOtherTaxes
						,strCalculationMethod
						,numRate
						,dblAdjustedTax
						,ysnTaxAdjusted
					FROM
						@ItemTaxes
					WHERE
						[intInvoiceDetailId] = @InvoiceDetailId
					
					--Calculate Taxable Amount	
					WHILE EXISTS(SELECT NULL FROM @TaxableByOtherTaxes)
						BEGIN
							DECLARE @TaxId						UNIQUEIDENTIFIER
									,@TaxTaxableByOtherTaxes	NVARCHAR(MAX)
									,@TaxTaxAdjusted			BIT
									,@TaxAdjustedTax			DECIMAL(18,6)
									,@TaxRate					DECIMAL(18,6)
									,@TaxCalculationMethod		NVARCHAR(30)
									
							SELECT TOP 1 @TaxId	= [Id] FROM @TaxableByOtherTaxes
										
							SELECT TOP 1
								 @TaxTaxableByOtherTaxes	= [strTaxableByOtherTaxes]
								,@TaxTaxAdjusted			= [ysnTaxAdjusted]
								,@TaxAdjustedTax			= [dblAdjustedTax]
								,@TaxRate					= [numRate]
								,@TaxCalculationMethod		= [strCalculationMethod]
							FROM
								@TaxableByOtherTaxes
							WHERE
								[Id] = @TaxId
								
								
								
							IF(@TaxTaxableByOtherTaxes IS NOT NULL AND RTRIM(LTRIM(@TaxTaxableByOtherTaxes)) <> '')
							BEGIN
								IF EXISTS(SELECT NULL FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId AND [intTaxClassId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TaxTaxableByOtherTaxes)))
								BEGIN
									IF(@TaxAdjustedTax = 1)
									BEGIN
										SET @TaxableAmount = @TaxableAmount + @TaxAdjustedTax
									END
									ELSE
										BEGIN
											IF(@TaxCalculationMethod = 'Percentage')
												BEGIN
													SET @TaxableAmount = @TaxableAmount + ((@ItemPrice * @QtyShipped) * (@TaxRate/100.00))
												END
											ELSE
												BEGIN
													SET @TaxableAmount = @TaxableAmount + (@QtyShipped * @TaxRate)
												END
										END
								END
							END 
								
							DELETE FROM @TaxableByOtherTaxes WHERE [Id] = @TaxId
						END
						
					
					DECLARE @ItemTaxAmount DECIMAL(18,6) = 0.00
					IF(@CalculationMethod = 'Percentage')
						SET @ItemTaxAmount = (@TaxableAmount * (@Rate/100));
					ELSE
						SET @ItemTaxAmount = (@QtyShipped * @Rate);
						
					IF(@CheckoffTax = 1)
						SET @ItemTaxAmount = @ItemTaxAmount * -1;
					
					--IF(@Tax = @AdjustedTax AND @TaxAdjusted = 0)
					--	BEGIN
							UPDATE
								@ItemTaxes
							SET
								 dblTax			= @ItemTaxAmount
								,dblAdjustedTax = @ItemTaxAmount
							WHERE
								[Id] = @Id
					--	END
					--ELSE
					--	BEGIN
					--		UPDATE
					--			@ItemTaxes
					--		SET
					--			 dblTax			= @ItemTaxAmount
					--			,dblAdjustedTax = @AdjustedTax
					--			,ysnTaxAdjusted	= 1
					--		WHERE
					--			[Id] = @Id
					--	END
					
					
					SELECT
						@TotalItemTax = @TotalItemTax + dblAdjustedTax
					FROM
						@ItemTaxes
					WHERE
						[Id] = @Id
				END
				
		
	INSERT INTO [tblARInvoiceDetailTax]
           ([intInvoiceDetailId]
           ,[intTaxGroupMasterId]
           ,[intTaxGroupId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strTaxableByOtherTaxes]
           ,[strCalculationMethod]
           ,[numRate]
           ,[intSalesTaxAccountId]
           ,[dblTax]
           ,[dblAdjustedTax]
           ,[ysnTaxAdjusted]
           ,[ysnSeparateOnInvoice]
           ,[ysnCheckoffTax]
           ,[intConcurrencyId])
		SELECT
			[intInvoiceDetailId]
           ,[intTaxGroupMasterId]
           ,[intTaxGroupId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strTaxableByOtherTaxes]
           ,[strCalculationMethod]
           ,[numRate]
           ,[intSalesTaxAccountId]
           ,[dblTax]
           ,[dblAdjustedTax]
           ,[ysnTaxAdjusted]
           ,[ysnSeparateOnInvoice]
           ,[ysnCheckoffTax]
           ,1
		FROM
			@ItemTaxes	
			
			
		DELETE FROM @ItemTaxes
		
		UPDATE tblARInvoiceDetail SET dblTotalTax = @TotalItemTax WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId


END