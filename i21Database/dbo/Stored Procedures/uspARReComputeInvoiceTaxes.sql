CREATE PROCEDURE [dbo].[uspARReComputeInvoiceTaxes]
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

DECLARE  @CustomerId				INT
		,@LocationId				INT
		,@TransactionDate			DATETIME
		,@DistributionHeaderId		INT
		,@CustomerLocationId		INT
		,@SubCurrencyRate			DECIMAL(18,6)
		,@FreightTermId				INT
						
SELECT
	@CustomerId				= I.[intEntityCustomerId]
	,@LocationId			= I.[intCompanyLocationId]
	,@TransactionDate		= I.[dtmDate]
	,@DistributionHeaderId	= I.[intDistributionHeaderId]
	,@CustomerLocationId	= (CASE WHEN ISNULL(F.[strFobPoint],'Destination') = 'Origin ' THEN I.[intBillToLocationId] ELSE I.[intShipToLocationId] END)
	,@FreightTermId			= I.[intFreightTermId] 
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
		DECLARE  @InvoiceDetailId		INT
				,@ItemId				INT
				,@ItemPrice				DECIMAL(18,6) 
				,@QtyShipped			DECIMAL(18,6) 
				,@TotalItemTax			DECIMAL(18,6)
				,@TotalBaseItemTax		DECIMAL(18,6)
				,@CurrencyExchangeRate	DECIMAL(18,6) 
				,@TaxGroupId			INT
				,@ItemType				NVARCHAR(100)
				,@SiteId				INT

		SELECT TOP 1
			 @InvoiceDetailId		= [intInvoiceDetailId]
		FROM
			@InvoiceDetail
		ORDER BY
			[intInvoiceDetailId]
			
		SELECT
			 @ItemId				= tblARInvoiceDetail.[intItemId]
			,@ItemPrice				= tblARInvoiceDetail.[dblPrice] / ISNULL(tblARInvoiceDetail.[dblSubCurrencyRate], 1)
			,@QtyShipped			= tblARInvoiceDetail.[dblQtyShipped]
			,@TaxGroupId			= tblARInvoiceDetail.[intTaxGroupId]
			,@SiteId				= tblARInvoiceDetail.[intSiteId]
			,@SubCurrencyRate		= ISNULL(tblARInvoiceDetail.[dblSubCurrencyRate], 1)
			,@CurrencyExchangeRate	= ISNULL(tblARInvoiceDetail.[dblCurrencyExchangeRate], 1)
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceDetailId] = @InvoiceDetailId
			
		SELECT @ItemType = [strType] FROM tblICItem WHERE intItemId = @ItemId
			
		IF @TaxGroupId = 0
			SET @TaxGroupId = NULL
			
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
		   ,[dblExemptionPercent]
           ,[intSalesTaxAccountId]
           ,[dblTax]
           ,[dblAdjustedTax]
		   ,[dblBaseAdjustedTax]
           ,[ysnTaxAdjusted]
           ,[ysnSeparateOnInvoice]
           ,[ysnCheckoffTax]
           ,[ysnTaxExempt]
		   ,[strNotes] 
           ,[intConcurrencyId])		
		SELECT
			 @InvoiceDetailId
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[dblRate]
			,[dblExemptionPercent]
			,[intTaxAccountId]
			,[dblTax]
			,[dblAdjustedTax]
			,[dblBaseAdjustedTax] = [dbo].fnRoundBanker([dblAdjustedTax] * @CurrencyExchangeRate, [dbo].[fnARGetDefaultDecimal]())
			,[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]
			,[ysnTaxExempt]
			,[strNotes] 
			,1
		FROM
			[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @LocationId, @CustomerLocationId, 1, NULL, @SiteId, @FreightTermId, NULL, NULL, 0, 1)
		
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
			,intTaxGroupId		= @TaxGroupId
		WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceIdLocal


END