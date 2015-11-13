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

DECLARE @CustomerId					INT
		,@LocationId				INT
		,@TransactionDate			DATETIME
		,@DistributionHeaderId		INT
		,@ShipToLocationId			INT
						
SELECT
	@CustomerId				= [intEntityCustomerId]
	,@LocationId			= [intCompanyLocationId]
	,@TransactionDate		= [dtmDate]
	,@DistributionHeaderId	= [intDistributionHeaderId]
	,@ShipToLocationId		= [intShipToLocationId]
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
										
		
	INSERT INTO [tblARInvoiceDetailTax]
           ([intInvoiceDetailId]
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
		   ,[strNotes] 
           ,[intConcurrencyId])		
		SELECT
			 @InvoiceDetailId
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[numRate]
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
			[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @LocationId, @ShipToLocationId)
		
		SELECT @TotalItemTax = SUM([dblAdjustedTax]) FROM [tblARInvoiceDetailTax] WHERE [intInvoiceDetailId] = @InvoiceDetailId
								
		UPDATE tblARInvoiceDetail SET dblTotalTax = @TotalItemTax WHERE [intInvoiceDetailId] = @InvoiceDetailId
					
		DELETE FROM @InvoiceDetail WHERE [intInvoiceDetailId] = @InvoiceDetailId	
	END
	
	
EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId


END