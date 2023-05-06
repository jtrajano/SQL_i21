CREATE PROCEDURE [dbo].[uspARReComputeInvoicesTaxes]
	@InvoiceIds		InvoiceId	READONLY
	,@SkipRecompute     BIT                 = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

IF ISNULL(@SkipRecompute, 0) = 0
BEGIN

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
		,[strTaxPoint]						NVARCHAR(50)
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
		,[intItemUOMId]
		,[strTaxPoint]
	)
	SELECT DISTINCT
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
		,[dblQtyShipped]					= (CASE WHEN ISNULL(ARID.[intLoadDetailId],0) = 0 
												    THEN CASE WHEN ARID.intPriceUOMId IS NOT NULL AND ARID.intPriceUOMId <> ARID.intItemUOMId 
															  THEN dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ARID.intPriceUOMId, ARID.dblQtyShipped)
															  ELSE ARID.[dblQtyShipped] 
														  END
													ELSE ISNULL(ARID.[dblShipmentNetWt], @ZeroDecimal) 
											   END)
		,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
		,[dblCurrencyExchangeRate]			= ISNULL(ARID.[dblCurrencyExchangeRate], 1)
		,[intTaxGroupId]					= CASE WHEN ISNULL(ARID.[intTaxGroupId],0) = 0 THEN NULL ELSE ARID.[intTaxGroupId] END
		,[strItemType]						= ICI.[strType]
		,[intSiteId]						= ARID.[intSiteId]
		,[intItemUOMId]						= ARID.[intItemUOMId]
		,[strTaxPoint]						= ARI.[strTaxPoint]
	FROM tblARInvoiceDetail ARID WITH (NOLOCK)
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN @InvoiceIds ID ON ID.[intHeaderId] = ARI.[intInvoiceId] --((ID.[intHeaderId] = ARI.[intInvoiceId] AND ISNULL(ID.[intDetailId],0) = 0) OR ID.[intDetailId] = ARID.[intInvoiceDetailId])
	LEFT OUTER JOIN tblSMFreightTerms SMFT WITH (NOLOCK) ON ARI.[intFreightTermId] = SMFT.[intFreightTermId]
	LEFT OUTER JOIN tblICItem ICI WITH (NOLOCK) ON ARID.[intItemId] = ICI.[intItemId]
	ORDER BY ARID.[intInvoiceDetailId]

	DELETE IDT 
	FROM tblARInvoiceDetailTax IDT
	INNER JOIN @InvoiceDetail ID ON ID.[intInvoiceDetailId] =  IDT.[intInvoiceDetailId]

	UPDATE tblARInvoiceDetail
	SET [dblTotalTax]	= @ZeroDecimal
	  , [intTaxGroupId]	= IDs.[intTaxGroupId]
	FROM @InvoiceDetail IDs
	WHERE tblARInvoiceDetail.[intInvoiceDetailId] = IDs.[intInvoiceDetailId]
	  AND (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)

	INSERT INTO [tblARInvoiceDetailTax](
		 [intInvoiceDetailId]
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
		,[ysnInvalidSetup]
		,[ysnTaxOnly]
		,[ysnAddToCost]
		,[strNotes] 
		,[intUnitMeasureId]
		,[intConcurrencyId]
	)		
	SELECT
		 [intInvoiceDetailId]				= IDs.[intInvoiceDetailId] 
		,[intTaxGroupId]					= TD.[intTaxGroupId]
		,[intTaxCodeId]						= TD.[intTaxCodeId]
		,[intTaxClassId]					= TD.[intTaxClassId]
		,[strTaxableByOtherTaxes]			= TD.[strTaxableByOtherTaxes]
		,[strCalculationMethod]				= TD.[strCalculationMethod]
		,[dblRate]							= TD.[dblRate]
		,[dblBaseRate]						= TD.[dblBaseRate]
		,[dblExemptionPercent]				= TD.[dblExemptionPercent]
		,[intTaxAccountId]					= TD.[intTaxAccountId]
		,[intSalesTaxExemptionAccountId]	= TD.[intSalesTaxExemptionAccountId]
		,[dblTax]							= TD.[dblTax]
		,[dblAdjustedTax]					= TD.[dblAdjustedTax]
		,[dblBaseAdjustedTax]				= [dbo].fnRoundBanker(TD.[dblAdjustedTax] * IDs.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
		,[ysnTaxAdjusted]					= TD.[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]				= TD.[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]					= TD.[ysnCheckoffTax]
		,[ysnTaxExempt]						= TD.[ysnTaxExempt]
		,[ysnInvalidSetup]          		= TD.[ysnInvalidSetup]
		,[ysnTaxOnly]						= TD.[ysnTaxOnly]
		,[ysnAddToCost]						= TD.[ysnAddToCost]
		,[strNotes]							= TD.[strNotes]
		,[intUnitMeasureId]					= TD.[intUnitMeasureId]
		,[intConcurrencyId]					= 1
	FROM
		@InvoiceDetail IDs
	CROSS APPLY
		[dbo].[fnGetItemTaxComputationForCustomer](IDs.[intItemId], IDs.[intEntityCustomerId], IDs.[dtmTransactionDate], IDs.[dblPrice], IDs.[dblQtyShipped], IDs.[intTaxGroupId], IDs.[intCompanyLocationId], IDs.[intCustomerLocationId], 1, 1, NULL, IDs.[intSiteId], IDs.[intFreightTermId], NULL, NULL, 0, 1, NULL, 1, 0, IDs.[intItemUOMId], IDs.[intCurrencyId], IDs.[intCurrencyExchangeRateTypeId], IDs.[dblCurrencyExchangeRate], IDs.[strTaxPoint]) TD
	WHERE
		NOT (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)

	UPDATE ID 
	SET intTaxGroupId = DT.intTaxGroupId
	FROM tblARInvoiceDetail ID 
	INNER JOIN @InvoiceDetail IDs ON ID.intInvoiceDetailId = IDs.intInvoiceDetailId
	INNER JOIN (
		SELECT intInvoiceDetailId
			 , intTaxGroupId	=  MAX(intTaxGroupId)
		FROM tblARInvoiceDetailTax WITH (NOLOCK) 
		GROUP BY intInvoiceDetailId
	) DT ON IDs.[intInvoiceDetailId] = DT.[intInvoiceDetailId]
	WHERE NOT (ISNULL(IDs.[intDistributionHeaderId], 0) <> 0 AND ISNULL(IDs.[strItemType],'') = 'Other Charge') OR (ISNULL(IDs.[intDistributionHeaderId],0) <> 0 AND ISNULL(IDs.[dblPrice], 0) = 0)

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


END