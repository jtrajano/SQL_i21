﻿CREATE PROCEDURE [dbo].[uspARReComputeInvoiceTaxes]
	 @InvoiceId	INT
	,@DetailId	INT	= NULL
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6)
       ,@InvoiceIdLocal INT

SET @ZeroDecimal = 0.000000
SET @InvoiceIdLocal = @InvoiceId	

DECLARE  @CustomerId					INT
		,@LocationId					INT
		,@TransactionDate				DATETIME
		,@DistributionHeaderId			INT
		,@CustomerLocationId			INT
		,@SubCurrencyRate				DECIMAL(18,6)
		,@FreightTermId					INT
		,@CurrencyId					INT
		,@FOB							NVARCHAR(100)
						
SELECT
	 @CustomerId			= I.[intEntityCustomerId]
	,@LocationId			= I.[intCompanyLocationId]
	,@TransactionDate		= I.[dtmDate]
	,@DistributionHeaderId	= I.[intDistributionHeaderId]
	,@CustomerLocationId	= (CASE WHEN ISNULL(F.[strFobPoint],'Destination') = 'Origin ' THEN I.[intBillToLocationId] ELSE I.[intShipToLocationId] END)
	,@FreightTermId			= I.[intFreightTermId] 
	,@CurrencyId			= I.[intCurrencyId]
	,@FOB					= I.[strTaxPoint]
FROM
	tblARInvoice I
LEFT OUTER JOIN
	tblSMFreightTerms F
		ON I.[intFreightTermId] = F.[intFreightTermId] 
WHERE
	I.[intInvoiceId] = @InvoiceIdLocal


DECLARE @InvoiceDetail AS TABLE  (
	intInvoiceDetailId	INT PRIMARY KEY,
	intItemId			INT,
	UNIQUE (intInvoiceDetailId)
);

IF(OBJECT_ID('tempdb..#ADJUSTEDTAXCODE') IS NOT NULL) DROP TABLE #ADJUSTEDTAXCODE 
CREATE TABLE #ADJUSTEDTAXCODE (
	intTaxCodeId		INT,
	dblAdjustedTax		NUMERIC(18,6)
);
CREATE NONCLUSTERED INDEX [idx_#ADJUSTEDTAXCODE_intTaxCodeId] ON [#ADJUSTEDTAXCODE] (intTaxCodeId)

INSERT INTO @InvoiceDetail (intInvoiceDetailId, intItemId)
SELECT
	 [intInvoiceDetailId]
	,[intItemId]
FROM
	tblARInvoiceDetail
WHERE
	[intInvoiceId] = @InvoiceIdLocal
	AND (
		ISNULL(@DetailId,0) = 0
			OR
		[intInvoiceDetailId] = @DetailId
		)
ORDER BY
	[intInvoiceDetailId]
	
	
WHILE EXISTS(SELECT NULL FROM @InvoiceDetail)
	BEGIN
		DECLARE  @InvoiceDetailId				INT
				,@ItemId						INT
				,@ItemPrice						DECIMAL(18,6) 
				,@QtyShipped					DECIMAL(18,6) 
				,@TotalItemTax					DECIMAL(18,6)
				,@TotalBaseItemTax				DECIMAL(18,6)
				,@CurrencyExchangeRateTypeId	INT
				,@CurrencyExchangeRate			NUMERIC(18,6)
				,@TaxGroupId					INT
				,@ItemType						NVARCHAR(100)
				,@SiteId						INT
				,@ItemUOMId						INT

		SELECT TOP 1
			 @InvoiceDetailId		= [intInvoiceDetailId]
		FROM
			@InvoiceDetail
		ORDER BY
			[intInvoiceDetailId]
			
		SELECT
			 @ItemId						= tblARInvoiceDetail.[intItemId]
			,@ItemPrice						= 
												(CASE WHEN ISNULL(tblARInvoiceDetail.[intLoadDetailId],0) = 0 
													THEN 
														tblARInvoiceDetail.[dblPrice] - (tblARInvoiceDetail.[dblPrice] * (tblARInvoiceDetail.[dblDiscount] / 100.00))
													ELSE 
														ISNULL(tblARInvoiceDetail.[dblUnitPrice], @ZeroDecimal) 
												END) / ISNULL(tblARInvoiceDetail.[dblSubCurrencyRate], 1)
			,@QtyShipped					= (CASE WHEN ISNULL(tblARInvoiceDetail.[intLoadDetailId],0) = 0 THEN tblARInvoiceDetail.[dblQtyShipped] ELSE ISNULL(tblARInvoiceDetail.[dblShipmentNetWt], @ZeroDecimal) END)
			,@TaxGroupId					= tblARInvoiceDetail.[intTaxGroupId]
			,@SiteId						= tblARInvoiceDetail.[intSiteId]
			,@SubCurrencyRate				= ISNULL(tblARInvoiceDetail.[dblSubCurrencyRate], 1)
			,@CurrencyExchangeRateTypeId	= tblARInvoiceDetail.[intCurrencyExchangeRateTypeId]
			,@CurrencyExchangeRate			= ISNULL(tblARInvoiceDetail.[dblCurrencyExchangeRate], 1)
			,@ItemUOMId						= tblARInvoiceDetail.intItemUOMId 
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceDetailId] = @InvoiceDetailId
			
		SELECT @ItemType = [strType] FROM tblICItem WHERE intItemId = @ItemId
			
		IF @TaxGroupId = 0
			SET @TaxGroupId = NULL

		DELETE FROM #ADJUSTEDTAXCODE
		INSERT INTO #ADJUSTEDTAXCODE([intTaxCodeId], [dblAdjustedTax]) SELECT [intTaxCodeId], [dblAdjustedTax] FROM tblARInvoiceDetailTax WHERE [intInvoiceDetailId] = @InvoiceDetailId AND ysnTaxAdjusted = 1
		DELETE FROM tblARInvoiceDetailTax WHERE [intInvoiceDetailId] = @InvoiceDetailId

		IF (ISNULL(@DistributionHeaderId,0) <> 0 AND ISNULL(@ItemType,'') = 'Other Charge') OR (ISNULL(@DistributionHeaderId,0) <> 0 AND ISNULL(@ItemPrice,0) = 0)
			BEGIN
				UPDATE tblARInvoiceDetail SET dblTotalTax = @ZeroDecimal, intTaxGroupId = @TaxGroupId WHERE [intInvoiceDetailId] = @InvoiceDetailId					
				DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
				CONTINUE
			END
												
		
		INSERT INTO [tblARInvoiceDetailTax]
           ([intInvoiceDetailId]
           ,[intTaxGroupId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strTaxableByOtherTaxes]
           ,[strCalculationMethod]
           ,[dblRate]
		   ,[dblBaseRate]
		   ,[dblExemptionPercent]
           ,[intSalesTaxAccountId]
		   ,[intSalesTaxExemptionAccountId]
           ,[dblTax]
           ,[dblAdjustedTax]
		   ,[dblBaseAdjustedTax]
           ,[ysnTaxAdjusted]
           ,[ysnSeparateOnInvoice]
           ,[ysnCheckoffTax]
           ,[ysnTaxExempt]
		   ,[ysnTaxOnly]
		   ,[ysnAddToCost]
		   ,[ysnInvalidSetup]
		   ,[strNotes]
		   ,[intUnitMeasureId] 
           ,[intConcurrencyId])		
		SELECT
			 @InvoiceDetailId
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[dblRate]
			,[dblBaseRate]
			,[dblExemptionPercent]
			,[intTaxAccountId]
			,[intSalesTaxExemptionAccountId]
			,[dblTax]
			,[dblAdjustedTax]
			,[dblBaseAdjustedTax] = [dbo].fnRoundBanker([dblAdjustedTax] * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
			,[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]
			,[ysnTaxExempt]
			,[ysnTaxOnly]
			,[ysnAddToCost]
			,[ysnInvalidSetup]
			,[strNotes]
			,[intUnitMeasureId] 
			,1
		FROM
			[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @LocationId, @CustomerLocationId, 1, 1, NULL, @SiteId, @FreightTermId, NULL, NULL, 0, 1, NULL, 1, 0, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate, @FOB)
		
		
		UPDATE IDT			
		SET  [ysnTaxAdjusted]		= 1
			,[dblAdjustedTax]		= ATC.[dblAdjustedTax]
			,[dblBaseAdjustedTax]	= [dbo].fnRoundBanker(ATC.[dblAdjustedTax] * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
		FROM [tblARInvoiceDetailTax] IDT
		INNER JOIN #ADJUSTEDTAXCODE ATC ON IDT.[intTaxCodeId] = ATC.[intTaxCodeId] 
		WHERE IDT.[intInvoiceDetailId] = @InvoiceDetailId
				
		SELECT
			 @TotalItemTax		= SUM([dblAdjustedTax])
			,@TotalBaseItemTax	= SUM([dblBaseAdjustedTax])
			,@TaxGroupId		= MAX([intTaxGroupId]) FROM [tblARInvoiceDetailTax] WHERE [intInvoiceDetailId] = @InvoiceDetailId

		IF @TaxGroupId = 0
			SET @TaxGroupId = NULL
								
		UPDATE tblARInvoiceDetail 
		SET
			 dblTotalTax		= @TotalItemTax
			,dblBaseTotalTax	= @TotalBaseItemTax
		--	,intTaxGroupId		= @TaxGroupId
		WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceIdLocal


END