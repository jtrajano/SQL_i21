CREATE PROCEDURE [dbo].[uspARReComputeInvoicesTaxes]
	@InvoiceIds		InvoiceId	READONLY
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6)
SET @ZeroDecimal = 0.000000


DECLARE @InvoiceDetail AS TABLE(
	 [intInvoiceDetailId]				INT PRIMARY KEY
	,[intInvoiceId]						INT
	,[intItemId]						INT
	,[intEntityCustomerId]				INT
	,[intCurrencyId]					INT
	,[intCompanyLocationId]				INT
	,[dtmTransactionDate]				DATETIME
	,[intDistributionHeaderId]			INT
	,[intCustomerLocationId]			INT
	,[dblSubCurrencyRate]				DECIMAL(18,6)
	,[intFreightTermId]					INT
	,[dblPrice]							DECIMAL(18,6) 
	,[dblQtyShipped]					DECIMAL(18,6) 
	,[intCurrencyExchangeRateTypeId]	INT
	,[dblCurrencyExchangeRate]			DECIMAL(18,6) 	
	,[intTaxGroupId]					INT
	,[strItemType]						NVARCHAR(100)
	,[intSiteId]						INT
	,[intItemUOMId]						INT
	UNIQUE ([intInvoiceDetailId])
);


INSERT INTO @InvoiceDetail
	([intInvoiceDetailId]
	,[intInvoiceId]
	,[intItemId]
	,[intEntityCustomerId]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[dtmTransactionDate]
	,[intDistributionHeaderId]
	,[intCustomerLocationId]
	,[dblSubCurrencyRate]
	,[intFreightTermId]
	,[dblPrice]
	,[dblQtyShipped]
	,[intCurrencyExchangeRateTypeId]
	,[dblCurrencyExchangeRate]
	,[intTaxGroupId]
	,[strItemType]
	,[intSiteId]
	,[intItemUOMId])
SELECT
	 [intInvoiceDetailId]				= ARID.[intInvoiceDetailId]
	,[intInvoiceId]						= ARI.[intInvoiceId]
	,[intItemId]						= ARID.[intItemId]
	,[intEntityCustomerId]				= ARI.[intEntityCustomerId]
	,[intCurrencyId]					= ARI.[intCurrencyId]
	,[intCompanyLocationId]				= ARI.[intCompanyLocationId]
	,[dtmTransactionDate]				= ARI.[dtmDate]
	,[intDistributionHeaderId]			= ARI.[intDistributionHeaderId]
	,[intCustomerLocationId]			= (CASE WHEN ISNULL(SMFT.[strFobPoint],'Destination') = 'Origin ' THEN ARI.[intBillToLocationId] ELSE ARI.[intShipToLocationId] END)
	,[dblSubCurrencyRate]				= ISNULL(ARID.[dblSubCurrencyRate], 1)
	,[intFreightTermId]					= ARI.[intFreightTermId]
	,[dblPrice]							= (CASE WHEN ISNULL(ARID.[intLoadDetailId],0) = 0 THEN ARID.[dblPrice] ELSE ISNULL(ARID.[dblUnitPrice], @ZeroDecimal) END) / ISNULL(ARID.[dblSubCurrencyRate], 1)
	,[dblQtyShipped]					= (CASE WHEN ISNULL(ARID.[intLoadDetailId],0) = 0 THEN ARID.[dblQtyShipped] ELSE ISNULL(ARID.[dblShipmentNetWt], @ZeroDecimal) END)
	,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
	,[dblCurrencyExchangeRate]			= ISNULL(ARID.[dblCurrencyExchangeRate], 1)
	,[intTaxGroupId]					= CASE WHEN ISNULL(ARID.[intTaxGroupId],0) = 0 THEN NULL ELSE ARID.[intTaxGroupId] END
	,[strItemType]						= ICI.[strType]
	,[intSiteId]						= ARID.[intSiteId]
	,[intItemUOMId]						= ARID.[intItemUOMId] 
FROM
	tblARInvoiceDetail ARID WITH (NOLOCK)
INNER JOIN
	(SELECT [intEntityCustomerId], [intCompanyLocationId], [dtmDate], [intDistributionHeaderId], [intFreightTermId], [intBillToLocationId],[intShipToLocationId], [intInvoiceId], [intCurrencyId] FROM tblARInvoice WITH (NOLOCK)) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
LEFT OUTER JOIN
	(SELECT [intFreightTermId], [strFobPoint] FROM tblSMFreightTerms WITH (NOLOCK)) SMFT
		ON ARI.[intFreightTermId] = SMFT.[intFreightTermId]
LEFT OUTER JOIN
	(SELECT [intItemId], [strType] FROM tblICItem WITH (NOLOCK)) ICI
		ON ARID.[intItemId] = ICI.[intItemId]	 
WHERE
	EXISTS(SELECT NULL FROM  @InvoiceIds IDs WHERE (IDs.[intHeaderId] = ARI.[intInvoiceId] AND ISNULL(IDs.[intDetailId],0) = 0) OR IDs.[intDetailId] = ARID.[intInvoiceDetailId])
ORDER BY
	ARID.[intInvoiceDetailId]


DELETE FROM 
	tblARInvoiceDetailTax
WHERE
	EXISTS(SELECT NULL FROM @InvoiceDetail IDs WHERE IDs.[intInvoiceDetailId] =  tblARInvoiceDetailTax.[intInvoiceDetailId])

UPDATE
	tblARInvoiceDetail
SET
	 [dblTotalTax]		= @ZeroDecimal
	,[intTaxGroupId]	= IDs.[intTaxGroupId]
FROM
	@InvoiceDetail IDs
WHERE
	tblARInvoiceDetail.[intInvoiceDetailId] = IDs.[intInvoiceDetailId]
	AND (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)


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
    ,[dblTax]
    ,[dblAdjustedTax]
	,[dblBaseAdjustedTax]
    ,[ysnTaxAdjusted]
    ,[ysnSeparateOnInvoice]
    ,[ysnCheckoffTax]
    ,[ysnTaxExempt]
	,[ysnTaxOnly]
	,[strNotes] 
	,[intUnitMeasureId]
    ,[intConcurrencyId])		
SELECT
	 [intInvoiceDetailId]		= IDs.[intInvoiceDetailId] 
	,[intTaxGroupId]			= TD.[intTaxGroupId]
	,[intTaxCodeId]				= TD.[intTaxCodeId]
	,[intTaxClassId]			= TD.[intTaxClassId]
	,[strTaxableByOtherTaxes]	= TD.[strTaxableByOtherTaxes]
	,[strCalculationMethod]		= TD.[strCalculationMethod]
	,[dblRate]					= TD.[dblRate]
	,[dblBaseRate]				= TD.[dblBaseRate]
	,[dblExemptionPercent]		= TD.[dblExemptionPercent]
	,[intTaxAccountId]			= TD.[intTaxAccountId]
	,[dblTax]					= TD.[dblTax]
	,[dblAdjustedTax]			= TD.[dblAdjustedTax]
	,[dblBaseAdjustedTax]		= [dbo].fnRoundBanker(TD.[dblAdjustedTax] * IDs.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,[ysnTaxAdjusted]			= TD.[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]		= TD.[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]			= TD.[ysnCheckoffTax]
	,[ysnTaxExempt]				= TD.[ysnTaxExempt]
	,[ysnTaxOnly]				= TD.[ysnTaxOnly]
	,[strNotes]					= TD.[strNotes]
	,[intUnitMeasureId]			= TD.[intUnitMeasureId]
	,[intConcurrencyId]			= 1
FROM
	@InvoiceDetail IDs
CROSS APPLY
	[dbo].[fnGetItemTaxComputationForCustomer](IDs.[intItemId], IDs.[intEntityCustomerId], IDs.[dtmTransactionDate], IDs.[dblPrice], IDs.[dblQtyShipped], IDs.[intTaxGroupId], IDs.[intCompanyLocationId], IDs.[intCustomerLocationId], 1, NULL, IDs.[intSiteId], IDs.[intFreightTermId], NULL, NULL, 0, 1, NULL, 1, IDs.[intItemUOMId], IDs.[intCurrencyId], IDs.[intCurrencyExchangeRateTypeId], IDs.[dblCurrencyExchangeRate]) TD
WHERE
	NOT (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)
		

UPDATE
	tblARInvoiceDetail 
SET
	[intTaxGroupId]	= DT.[intTaxGroupId]
FROM
	@InvoiceDetail IDs
INNER JOIN
	(
	SELECT MAX([intTaxGroupId]) [intTaxGroupId], [intInvoiceDetailId] FROM [tblARInvoiceDetailTax] WITH (NOLOCK) GROUP BY [intInvoiceDetailId]
	) DT
		ON IDs.[intInvoiceDetailId] = DT.[intInvoiceDetailId]
WHERE
	tblARInvoiceDetail.[intInvoiceDetailId] = IDs.intInvoiceDetailId
	AND NOT (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)

	
DECLARE @CreatedInvoiceIds InvoiceId	
DELETE FROM @CreatedInvoiceIds

INSERT INTO @CreatedInvoiceIds(
	 [intHeaderId]
	,[ysnUpdateAvailableDiscountOnly]
	,[intDetailId])
SELECT 
	 [intHeaderId]						= [intInvoiceId]
	,[ysnUpdateAvailableDiscountOnly]	= 0
	,[intDetailId]						= [intInvoiceDetailId]
FROM
	@InvoiceDetail IDs
WHERE
	NOT (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)

EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @CreatedInvoiceIds


END