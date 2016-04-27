﻿CREATE PROCEDURE [dbo].[uspARReComputeInvoiceTaxes]
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

DECLARE  @CustomerId				INT
		,@LocationId				INT
		,@TransactionDate			DATETIME
		,@DistributionHeaderId		INT
		,@CustomerLocationId		INT
		,@SubCurrencyCents			INT
						
SELECT
	@CustomerId				= I.[intEntityCustomerId]
	,@LocationId			= I.[intCompanyLocationId]
	,@TransactionDate		= I.[dtmDate]
	,@DistributionHeaderId	= I.[intDistributionHeaderId]
	,@CustomerLocationId	= (CASE WHEN ISNULL(F.[strFobPoint],'Destination') = 'Origin ' THEN I.[intBillToLocationId] ELSE I.[intShipToLocationId] END)
	,@SubCurrencyCents		= ISNULL(I.[intSubCurrencyCents],1)
FROM
	tblARInvoice I
LEFT OUTER JOIN
	tblSMFreightTerms F
		ON I.[intFreightTermId] = F.[intFreightTermId] 
WHERE
	I.[intInvoiceId] = @InvoiceId


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
				,@SiteId			INT
				,@SubCurrency		BIT

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
			,@SiteId				= tblARInvoiceDetail.[intSiteId]
			,@SubCurrency			= ISNULL(tblARInvoiceDetail.[ysnSubCurrency],0)
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
				UPDATE tblARInvoiceDetail SET dblTotalTax = @ZeroDecimal WHERE [intInvoiceDetailId] = @InvoiceDetailId					
				DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
				CONTINUE
			END
			
		IF @SubCurrency = 1
			SET @ItemPrice = @ItemPrice / @SubCurrencyCents		
										
		
	INSERT INTO [tblARInvoiceDetailTax]
           ([intInvoiceDetailId]
           ,[intTaxGroupId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strTaxableByOtherTaxes]
           ,[strCalculationMethod]
           ,[dblRate]
           ,[intSalesTaxAccountId]
           ,[dblTax]
           ,[dblAdjustedTax]
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
			,[intTaxAccountId]
			,[dblTax]
			,[dblAdjustedTax]
			,[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]
			,[ysnTaxExempt]
			,[strNotes] 
			,1
		FROM
			[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @LocationId, @CustomerLocationId, 1, NULL, @SiteId)
		
		SELECT @TotalItemTax = SUM([dblAdjustedTax]) FROM [tblARInvoiceDetailTax] WHERE [intInvoiceDetailId] = @InvoiceDetailId
								
		UPDATE tblARInvoiceDetail SET dblTotalTax = @TotalItemTax WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId


END