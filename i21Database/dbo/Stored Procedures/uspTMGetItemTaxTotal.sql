
CREATE PROCEDURE [dbo].[uspTMGetItemTaxTotal]
	 @ItemId			INT
	,@LocationId		INT	
	,@TransactionDate	DATETIME
	,@ItemPrice			NUMERIC(18,6)
	,@Quantity			NUMERIC(18,6)
	,@TaxMasterId		INT	
	,@TotalItemTax	NUMERIC(18,6) = 0.00 OUTPUT	
	
AS
BEGIN

--declare @ItemId			INT 
--	declare @LocationId		INT	
--	declare @TransactionDate	DATETIME  
--	declare @ItemPrice			NUMERIC(18,6) 
--	declare @Quantity			NUMERIC(18,6)
--	declare @TaxMasterId		INT	
--	declare @TotalItemTax	NUMERIC(18,6) 

--SET @ItemId =4
--set @LocationId= 3
--set @TransactionDate = '2015-07-09 00:00:00.000'
--set @ItemPrice = 20.200000
--SET @Quantity = 400.000000
--set @TaxMasterId = 1
--set @TotalItemTax = 0


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
,ysnTaxExempt			BIT
)

DECLARE @ZeroDecimal	DECIMAL(18,6)

SET @ZeroDecimal = 0.000000	

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
	,ysnTaxExempt	
)

EXEC dbo.[uspARGetItemTaxes]  
		 @ItemId  
		,@LocationId  
		,NULL
		,@TransactionDate
		,@TaxMasterId
		
--EXEC dbo.[uspARGetItemTaxes]  4 ,3,NULL,'2015-07-09 00:00:00.000',1
 			

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
			,@TaxableAmount	= ISNULL(@ItemPrice,@ZeroDecimal) * ISNULL(@Quantity,@ZeroDecimal)
		FROM
			@ItemTaxes
		WHERE
			[intInvoiceDetailId] IS NULL OR [intInvoiceDetailId] = 0
			
		UPDATE @ItemTaxes SET [intInvoiceDetailId] = 1, ysnTaxAdjusted = 0 WHERE [Id] = @Id
		
		SELECT 
			 @TaxClassId		= [intTaxClassId]
			,@TaxAdjusted		= [ysnTaxAdjusted]
			,@AdjustedTax		= [dblAdjustedTax]
			,@Tax				= [dblTax]
			,@Rate				= [numRate]
			,@CalculationMethod	= [strCalculationMethod]
			,@CheckoffTax		= [ysnCheckoffTax]
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
			[intInvoiceDetailId] = 1
		
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
										SET @TaxableAmount = @TaxableAmount + ((@ItemPrice * @Quantity) * (@TaxRate/100.00))
									END
								ELSE
									BEGIN
										SET @TaxableAmount = @TaxableAmount + (@Quantity * @TaxRate)
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
			SET @ItemTaxAmount = (@Quantity * @Rate);
			
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
		
		SELECT * FROM @ItemTaxes
		SELECT
			@TotalItemTax = @TotalItemTax + dblAdjustedTax
		FROM
			@ItemTaxes
		WHERE
			[Id] = @Id
	END
	
	
END
GO