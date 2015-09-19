﻿CREATE PROCEDURE [dbo].[uspARReComputeInvoiceTaxes]
	 @InvoiceId		AS INT
	 ,@TaxMasterId	AS INT	= NULL	
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6)

SET @ZeroDecimal = 0.000000	

DECLARE @CustomerId					INT
		,@LocationId				INT
		,@TransactionDate			DATETIME
		,@DistributionHeaderId		INT

		
		
		
SELECT
	@CustomerId				= [intEntityCustomerId]
	,@LocationId			= [intCompanyLocationId]
	,@TransactionDate		= [dtmDate]
	,@DistributionHeaderId	= [intDistributionHeaderId]
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
				,@TaxGroupId		INT
				,@ItemType			NVARCHAR(100)
				

		SELECT TOP 1
			 @InvoiceDetailId		= [intInvoiceDetailId]
		FROM
			@InvoiceDetail
		ORDER BY
			[intInvoiceDetailId]
			
		SELECT
			 @ItemId				= tblARInvoiceDetail.[intItemId]
			,@ItemPrice				= tblARInvoiceDetail.[dblPrice]
			,@QtyShipped			= tblARInvoiceDetail.[dblQtyShipped]
			,@TaxGroupId			= tblARInvoiceDetail.[intTaxGroupId]
			,@ItemType				= tblICItem.[strType] 
		FROM
			tblARInvoiceDetail
		INNER JOIN
			tblICItem
				ON tblARInvoiceDetail.intItemId = tblICItem.intItemId 
		WHERE
			[intInvoiceDetailId] = @InvoiceDetailId
			
		IF @TaxGroupId = 0
			SET @TaxGroupId = NULL
			
		DELETE FROM tblARInvoiceDetailTax WHERE [intInvoiceDetailId] = @InvoiceDetailId

		IF ISNULL(@DistributionHeaderId,0) <> 0 AND ISNULL(@ItemType,'') = 'Other Charge'
			BEGIN
				UPDATE tblARInvoiceDetail SET dblTotalTax = @ZeroDecimal WHERE [intInvoiceDetailId] = @InvoiceDetailId					
				DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
				CONTINUE
			END			
			
		DECLARE @ItemTaxes AS TABLE(
			 Id						UNIQUEIDENTIFIER DEFAULT(NEWID())
			,intInvoiceDetailTaxId	INT
			,intInvoiceDetailId		INT	NULL
			,intTaxGroupMasterId	INT NULL
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
			,ysnTaxExempt			BIT
			,strTaxGroup			NVARCHAR(100)
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
				,[ysnTaxExempt]
				,[strTaxGroup]
			)
			EXEC dbo.[uspARGetItemTaxes]  
					 @ItemId			= @ItemId  
					,@LocationId		= @LocationId  
					,@CustomerId		= @CustomerId
					,@TransactionDate	= @TransactionDate
					,@TaxMasterId		= @TaxMasterId
					,@TaxGroupId		= @TaxGroupId
					
			UPDATE @ItemTaxes SET intTaxGroupMasterId = NULL WHERE intTaxGroupMasterId NOT IN (SELECT intTaxGroupMasterId FROM tblSMTaxGroupMaster)
									
			
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
							,@TaxExempt			BIT
							
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
						 Id						UNIQUEIDENTIFIER DEFAULT(NEWID())
						,intTaxClassId			INT
						,strTaxableByOtherTaxes	NVARCHAR(MAX)
						,strCalculationMethod	NVARCHAR(30)
						,numRate				DECIMAL(18,6)
						,dblAdjustedTax			DECIMAL(18,6)
						,ysnTaxAdjusted			BIT
						,ysnTaxExempt			BIT
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
							DECLARE @TaxId						UNIQUEIDENTIFIER
									,@TaxTaxableByOtherTaxes	NVARCHAR(MAX)
									,@TaxTaxAdjusted			BIT
									,@TaxAdjustedTax			DECIMAL(18,6)
									,@TaxRate					DECIMAL(18,6)
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
						
					
					DECLARE @ItemTaxAmount DECIMAL(18,6) = 0.00
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
					WHERE
						[Id] = @Id
									
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
           ,[ysnTaxExempt]
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
           ,[ysnTaxExempt]
           ,1
		FROM
			@ItemTaxes	
			
			
		DELETE FROM @ItemTaxes
		
		UPDATE tblARInvoiceDetail SET dblTotalTax = @TotalItemTax WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId


END