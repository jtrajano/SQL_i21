CREATE PROCEDURE [dbo].[uspARReComputeInvoiceAmounts]
	 @InvoiceId				AS INT
	,@AvailableDiscountOnly	AS BIT = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal			DECIMAL(18,6)
		,@InvoiceIdLocal		INT
		,@CurrencyId			INT
		,@strTransType			NVARCHAR(50)
		,@OriginalInvoiceId		INT
		,@CurrencyExchangeRate	DECIMAL(18,6)

SET @ZeroDecimal = 0.000000	
SET @InvoiceIdLocal = @InvoiceId

UPDATE ARID
SET
	  dblCurrencyExchangeRate	= CASE WHEN ISNULL(ARID.dblCurrencyExchangeRate, @ZeroDecimal) = @ZeroDecimal 
									THEN 1.000000 
									ELSE ARID.dblCurrencyExchangeRate
								  END
	,dblPercentage				= ISNULL(CTCH.dblProvisionalInvoicePct, 100)
	,dblProvisionalTotal		= (ISNULL(CTCH.dblProvisionalInvoicePct, 100) / 100) * dblTotal
FROM tblARInvoiceDetail ARID
LEFT JOIN (
	SELECT
		 intContractHeaderId
		,dblProvisionalInvoicePct
	FROM tblCTContractHeader 
) CTCH ON CTCH.intContractHeaderId = ARID.intContractHeaderId

UPDATE tblARInvoice
SET
	 dblCurrencyExchangeRate= dbo.fnRoundBanker(ISNULL(T.dblCurrencyExchangeRate, 1.000000) / ISNULL(T.intCount, 1.000000), 6)
	,dblPercentage			= T.dblPercentage
FROM (
	SELECT 
		 dblCurrencyExchangeRate= SUM(dblCurrencyExchangeRate)
		,intCount				= COUNT(intInvoiceId)
		,dblPercentage			= AVG(dblPercentage)
		,intInvoiceId			= intInvoiceId
	FROM tblARInvoiceDetail
	WHERE
		intInvoiceId = @InvoiceIdLocal
	GROUP BY
		 intInvoiceId
) T
WHERE tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal
						
SELECT
	 @CurrencyId			= [intCurrencyId]
	,@OriginalInvoiceId		= [intOriginalInvoiceId]
	,@strTransType			= [strTransactionType]
	,@CurrencyExchangeRate	= (CASE WHEN ISNULL([dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE [dblCurrencyExchangeRate] END)
FROM tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceIdLocal

UPDATE ARIDT
SET
	 [dblRate]				= ISNULL([dblRate], @ZeroDecimal)
	,[dblBaseRate]			= ISNULL([dblBaseRate], ISNULL([dblRate], @ZeroDecimal))
	,[dblTax]				= ISNULL([dblTax], @ZeroDecimal)
	,[dblAdjustedTax]		= dbo.fnRoundBanker(ISNULL([dblAdjustedTax], @ZeroDecimal), dbo.fnARGetDefaultDecimal())
	,[dblBaseAdjustedTax]	= dbo.fnRoundBanker(ISNULL([dblBaseAdjustedTax], @ZeroDecimal), dbo.fnARGetDefaultDecimal())
	,[ysnTaxAdjusted]		= ISNULL(ysnTaxAdjusted, 0)
	,dblProvisionalTax		= (ARID.dblPercentage / 100) * ISNULL(dblAdjustedTax, 0)
FROM tblARInvoiceDetailTax ARIDT
INNER JOIN (
	SELECT 
		 intInvoiceId
		,intInvoiceDetailId
		,dblPercentage
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceIdLocal
) ARID ON ARIDT.intInvoiceDetailId = ARID.intInvoiceDetailId
	
UPDATE ARID
SET
	 [dblQtyOrdered]					= ISNULL([dblQtyOrdered], @ZeroDecimal)
	,[dblQtyShipped]					= ISNULL([dblQtyShipped], @ZeroDecimal)
	,[dblDiscount]						= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblItemWeight]					= ISNULL([dblItemWeight], 1.00)
	,[dblStandardWeight]				= ISNULL([dblStandardWeight], 0.00)
	,[dblShipmentGrossWt]				= ISNULL([dblShipmentGrossWt], @ZeroDecimal)
	,[dblShipmentTareWt]				= ISNULL([dblShipmentTareWt], @ZeroDecimal)
	,[dblShipmentNetWt]					= ISNULL([dblShipmentGrossWt], @ZeroDecimal) - ISNULL([dblShipmentTareWt], @ZeroDecimal)		
	,[dblPrice]							= ISNULL([dblPrice], @ZeroDecimal)
	,[dblBasePrice]						= ISNULL(ISNULL([dblPrice], @ZeroDecimal) * [dblCurrencyExchangeRate], @ZeroDecimal)
	,[dblUnitPrice] 					= CASE WHEN ISNULL([dblOptionalityPremium], 0) <> 0 OR ISNULL([dblQualityPremium], 0) <> 0 
											   THEN (ISNULL([dblPrice], @ZeroDecimal) + ISNULL([dblOptionalityPremium], @ZeroDecimal) + ISNULL([dblQualityPremium], @ZeroDecimal)) * dbo.fnCalculateQtyBetweenUOM([intItemWeightUOMId], ISNULL(LGACFDDV.[intSeqPriceUOMId], [intPriceUOMId]), 1) 
											   ELSE ISNULL(ISNULL([dblUnitPrice], [dblPrice]), @ZeroDecimal)
										  END
	,[dblBaseUnitPrice]					= ISNULL(ISNULL(ISNULL([dblUnitPrice], [dblPrice]), @ZeroDecimal) * [dblCurrencyExchangeRate], @ZeroDecimal)
	,[intPriceUOMId]					= CASE WHEN (ISNULL([intLoadDetailId],0) <> 0) THEN ISNULL([intPriceUOMId], [intItemWeightUOMId]) ELSE ISNULL([intPriceUOMId], [intItemUOMId]) END
	,[dblUnitQuantity]					= CASE WHEN (ISNULL([dblUnitQuantity],@ZeroDecimal) <> @ZeroDecimal) THEN [dblUnitQuantity] ELSE (CASE WHEN (ISNULL([intLoadDetailId],0) <> 0) THEN ISNULL([dblShipmentGrossWt], @ZeroDecimal) - ISNULL([dblShipmentTareWt], @ZeroDecimal) ELSE ISNULL([dblQtyShipped], @ZeroDecimal) END) END
	,[dblTotalTax]						= ISNULL([dblTotalTax], @ZeroDecimal)
	,[dblBaseTotalTax]					= ISNULL([dblBaseTotalTax], @ZeroDecimal)
	,[dblTotal]							= ISNULL([dblTotal], @ZeroDecimal)
	,[dblBaseTotal]						= ISNULL([dblBaseTotal], @ZeroDecimal)
	,[dblItemTermDiscount]				= ISNULL([dblItemTermDiscount], @ZeroDecimal)
	,[strItemTermDiscountBy]			= ISNULL([strItemTermDiscountBy], 'Amount')
	,[dblItemTermDiscountAmount]		= [dbo].[fnARGetItemTermDiscount](	ISNULL([strItemTermDiscountBy], 'Amount')
																				,[dblItemTermDiscount]
																				,[dblQtyShipped]
																				,[dblPrice]
																				,1.000000)
	,[dblBaseItemTermDiscountAmount]	= [dbo].[fnARGetItemTermDiscount](	ISNULL([strItemTermDiscountBy], 'Amount')
																				,[dblItemTermDiscount]
																				,[dblQtyShipped]
																				,[dblPrice]
																				,@CurrencyExchangeRate)
	,[dblItemTermDiscountExemption]		= [dbo].[fnARGetItemTermDiscountExemption](	[ysnTermDiscountExempt]
																					,[dblTermDiscountRate]
																					,[dblQtyShipped]
																					,[dblPrice]
																					,1.000000)
	,[dblBaseItemTermDiscountExemption]	= [dbo].[fnARGetItemTermDiscountExemption](	[ysnTermDiscountExempt]
																					,[dblTermDiscountRate]
																					,[dblQtyShipped]
																					,[dblPrice]
																					,@CurrencyExchangeRate)
	,[dblTermDiscountRate]				= ISNULL([dblTermDiscountRate], @ZeroDecimal)
	,[ysnTermDiscountExempt]			= ISNULL([ysnTermDiscountExempt], 0)
	,[intSubCurrencyId]					= ISNULL([intSubCurrencyId], @CurrencyId)
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL([dblSubCurrencyRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE [dblSubCurrencyRate] END
	,[dblLicenseAmount]					= ISNULL([dblLicenseAmount], @ZeroDecimal)
	,[dblBaseLicenseAmount]				= ISNULL(ISNULL([dblLicenseAmount], @ZeroDecimal) * [dblCurrencyExchangeRate], @ZeroDecimal)
	,[dblMaintenanceAmount]				= ISNULL([dblMaintenanceAmount], @ZeroDecimal)
	,[dblBaseMaintenanceAmount]			= ISNULL(ISNULL([dblMaintenanceAmount], @ZeroDecimal) * [dblCurrencyExchangeRate], @ZeroDecimal)
FROM tblARInvoiceDetail ARID
LEFT JOIN vyuLGAdditionalColumnForContractDetailView LGACFDDV ON LGACFDDV.intContractDetailId = ARID.intContractDetailId
WHERE
	[intInvoiceId] = @InvoiceIdLocal
	
	
UPDATE
	tblARInvoice
SET
	 [dblInvoiceSubtotal]					= ISNULL([dblInvoiceSubtotal], @ZeroDecimal)
	,[dblBaseInvoiceSubtotal]				= ISNULL([dblBaseInvoiceSubtotal], @ZeroDecimal)
	,[dblShipping]							= ISNULL([dblShipping], @ZeroDecimal)
	,[dblBaseShipping]						= ISNULL([dblBaseShipping], @ZeroDecimal)
	,[dblTax]								= ISNULL([dblTax], @ZeroDecimal)
	,[dblBaseTax]							= ISNULL([dblBaseTax], @ZeroDecimal)
	,[dblInvoiceTotal]						= ISNULL([dblInvoiceTotal], @ZeroDecimal)
	,[dblBaseInvoiceTotal]					= ISNULL([dblBaseInvoiceTotal], @ZeroDecimal)
	,[dblDiscount]							= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblBaseDiscount]						= ISNULL([dblBaseDiscount], @ZeroDecimal)
	,[dblAmountDue]							= ISNULL([dblAmountDue], @ZeroDecimal)
	,[dblBaseAmountDue]						= ISNULL([dblBaseAmountDue], @ZeroDecimal)
	,[dblPayment]							= ISNULL([dblPayment], @ZeroDecimal)
	,[dblBasePayment]						= ISNULL([dblBasePayment], @ZeroDecimal)
	,[dblDiscountAvailable]					= ISNULL([dblDiscountAvailable], @ZeroDecimal)
	,[dblBaseDiscountAvailable]				= ISNULL([dblBaseDiscountAvailable], @ZeroDecimal)
	,[dblTotalTermDiscount]					= ISNULL([dblTotalTermDiscount], @ZeroDecimal)
	,[dblBaseTotalTermDiscount]				= ISNULL([dblBaseTotalTermDiscount], @ZeroDecimal)
	,[dblTotalTermDiscountExemption]		= ISNULL([dblTotalTermDiscountExemption], @ZeroDecimal)
	,[dblBaseTotalTermDiscountExemption]	= ISNULL([dblBaseTotalTermDiscountExemption], @ZeroDecimal)
	,[dblInterest]							= ISNULL([dblInterest], @ZeroDecimal)
	,[dblBaseInterest]						= ISNULL([dblBaseInterest], @ZeroDecimal)
	,[dblProvisionalAmount]					= ISNULL([dblProvisionalAmount], @ZeroDecimal)
	,[dblBaseProvisionalAmount]				= ISNULL([dblBaseProvisionalAmount], @ZeroDecimal)
	,[dblSplitPercent] 						= CASE WHEN ISNULL([ysnSplitted],0) = 0 OR [intSplitId] IS NULL THEN 1 ELSE ISNULL([dblSplitPercent],1) END
	,[ysnFromProvisional]					= ISNULL([ysnFromProvisional], CAST(0 AS BIT))
	,[ysnProvisionalWithGL]					= ISNULL([ysnProvisionalWithGL], CAST(0 AS BIT))
	,[ysnImpactInventory]					= ISNULL([ysnImpactInventory], CAST(1 AS BIT))
	,[dblLoanAmount]						= CASE WHEN ISNULL(strTransactionNo, '') <> '' THEN ISNULL([dblInvoiceSubtotal], @ZeroDecimal) ELSE NULL END
WHERE [intInvoiceId] = @InvoiceIdLocal

UPDATE I
SET [dblDiscountAvailable]					= ROUND(CASE WHEN I.strType NOT IN ('CF Invoice','CF Tran', 'Service Charge') AND strTransactionType !='Credit Memo' THEN ISNULL(([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], CASE WHEN TERM.ysnIncludeTaxOnDiscount = 1 THEN [dblInvoiceTotal] ELSE [dblInvoiceSubtotal] + [dblShipping] END)  + T.[dblItemTermDiscountAmount]) - T.[dblItemTermDiscountExemption], @ZeroDecimal) ELSE ISNULL(T.[dblItemTermDiscountAmount], @ZeroDecimal) END, 2)
	,[dblBaseDiscountAvailable]				= ROUND(CASE WHEN I.strType NOT IN ('CF Invoice','CF Tran', 'Service Charge') AND strTransactionType !='Credit Memo' THEN ISNULL(([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], CASE WHEN TERM.ysnIncludeTaxOnDiscount = 1 THEN [dblBaseInvoiceTotal] ELSE [dblBaseInvoiceSubtotal] + [dblBaseShipping] END)  + T.[dblBaseItemTermDiscountAmount]) - T.[dblBaseItemTermDiscountExemption], @ZeroDecimal) ELSE ISNULL(T.[dblBaseItemTermDiscountAmount], @ZeroDecimal) END, 2)
	,[dblTotalTermDiscount]					= ISNULL(T.[dblItemTermDiscountAmount], @ZeroDecimal)
	,[dblBaseTotalTermDiscount]				= ISNULL(T.[dblBaseItemTermDiscountAmount], @ZeroDecimal)
	,[dblTotalTermDiscountExemption]		= ISNULL(T.[dblItemTermDiscountExemption], @ZeroDecimal)
	,[dblBaseTotalTermDiscountExemption]	= ISNULL(T.[dblBaseItemTermDiscountExemption], @ZeroDecimal)
FROM tblARInvoice I
INNER JOIN (
	SELECT [dblItemTermDiscountAmount]		= SUM([dblItemTermDiscountAmount])
		,[dblBaseItemTermDiscountAmount]	= SUM([dblBaseItemTermDiscountAmount])
		,[dblItemTermDiscountExemption]		= SUM([dblItemTermDiscountExemption])
		,[dblBaseItemTermDiscountExemption]	= SUM([dblBaseItemTermDiscountExemption])
		,[intInvoiceId]						= [intInvoiceId]
	FROM tblARInvoiceDetail
	WHERE [intInvoiceId] = @InvoiceIdLocal
	GROUP BY [intInvoiceId]
) T ON I.[intInvoiceId] = T.[intInvoiceId]
	AND I.[intInvoiceId] = @InvoiceIdLocal
INNER JOIN tblSMTerm TERM ON I.intTermId = TERM.intTermID		

IF (@AvailableDiscountOnly = 1)
	RETURN 1;

	
UPDATE tblARInvoiceDetail
SET
	  dblTotalTax				= ISNULL(T.dblAdjustedTax, @ZeroDecimal)
	 ,dblBaseTotalTax			= ISNULL(T.dblBaseAdjustedTax, @ZeroDecimal)
	 ,dblProvisionalTotalTax	= ISNULL(dblProvisionalTax, @ZeroDecimal)
	 ,dblBaseProvisionalTotalTax= dblProvisionalTax * dblCurrencyExchangeRate
FROM (
	SELECT
		 dblAdjustedTax		= SUM([dblAdjustedTax])
		,dblBaseAdjustedTax	= SUM([dblBaseAdjustedTax])
		,dblProvisionalTax	= SUM(dblProvisionalTax)
		,[intInvoiceDetailId]
	FROM
		tblARInvoiceDetailTax
	GROUP BY
		[intInvoiceDetailId]
) T
WHERE tblARInvoiceDetail.[intInvoiceDetailId] = T.[intInvoiceDetailId]AND tblARInvoiceDetail.[intInvoiceId] = @InvoiceIdLocal

UPDATE ARID
SET ARID.dblTotal	= CASE WHEN ISNULL(ICI.[strType], '') = 'Comment' 
						THEN @ZeroDecimal
						ELSE
							CASE 
								WHEN ISNULL(ARID.intLoadDetailId,0) <> 0 THEN dbo.fnRoundBanker(dbo.fnRoundBanker(((ARID.dblPrice / ARID.dblSubCurrencyRate) * dbo.fnCalculateQtyBetweenUOM(ARID.intItemWeightUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemWeightUOMId), ISNULL(ARID.dblShipmentNetWt, ARID.dblQtyShipped))), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ARID.dblPrice / ARID.[dblSubCurrencyRate]) * dbo.fnCalculateQtyBetweenUOM(ARID.intItemWeightUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemWeightUOMId), ISNULL(ARID.dblShipmentNetWt, ARID.dblQtyShipped))) * (ARID.dblDiscount / 100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())
								ELSE
									dbo.fnRoundBanker(dbo.fnRoundBanker(((ARID.dblPrice / ARID.dblSubCurrencyRate) * ARID.dblQtyShipped), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ARID.dblPrice / ARID.dblSubCurrencyRate) * ARID.dblQtyShipped) * (ARID.dblDiscount / 100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())											
							END
						END
FROM tblARInvoiceDetail ARID
LEFT OUTER JOIN tblICItem ICI ON ARID.[intItemId] = ICI.[intItemId] 
WHERE ARID.[intInvoiceId] = @InvoiceIdLocal

UPDATE ARID
SET ARID.[dblBaseTotal]		= (CASE WHEN ISNULL(ICI.[strType], '') = 'Comment' THEN @ZeroDecimal
							ELSE
								(	
									CASE WHEN (ISNULL(ARID.[intLoadDetailId],0) <> 0) AND ISNULL(ARID.[intItemWeightUOMId], 0) <> 0 THEN dbo.fnRoundBanker(dbo.fnRoundBanker(((ISNULL(ISNULL(ISNULL(CAST(ARID.[dblPrice] * dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemUOMId), 1) AS DECIMAL(18,7)), [dblPrice]), 0.000) * [dblCurrencyExchangeRate], 0.000) / ARID.[dblSubCurrencyRate]) * (CASE WHEN dblComputedGrossPrice > 0 THEN  dbo.fnCalculateQtyBetweenUOM(ARID.intItemWeightUOMId, ARID.intPriceUOMId, ARID.[dblShipmentNetWt]) ELSE ARID.[dblShipmentNetWt] END)), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ISNULL(ISNULL(ISNULL(CAST(ARID.[dblPrice] * dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemUOMId), 1) AS DECIMAL(18,7)), [dblPrice]), 0.000) * [dblCurrencyExchangeRate], 0.000) / ARID.[dblSubCurrencyRate]) * (CASE WHEN dblComputedGrossPrice > 0 THEN  dbo.fnCalculateQtyBetweenUOM(ARID.intItemWeightUOMId, ARID.intPriceUOMId, ARID.[dblShipmentNetWt]) ELSE ARID.[dblShipmentNetWt] END)) * (ARID.[dblDiscount]/100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())
										 WHEN (ISNULL(intContractDetailId,0) <> 0 OR ISNULL(intContractHeaderId,0) <> 0) THEN CASE WHEN ISNULL(ISNULL(ISNULL(ISNULL(CAST(ARID.[dblPrice] * dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemUOMId), 1) AS DECIMAL(18,7)), [dblPrice]), 0.000) * [dblCurrencyExchangeRate], 0.000),0) = 0 THEN dbo.fnRoundBanker(dbo.fnRoundBanker(((ARID.[dblBasePrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ARID.[dblBasePrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]) * (ARID.[dblDiscount]/100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal()) ELSE dbo.fnRoundBanker(dbo.fnRoundBanker(((ISNULL(ISNULL(ISNULL(CAST(ARID.[dblPrice] * dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemUOMId), 1) AS DECIMAL(18,7)), [dblPrice]), 0.000) * [dblCurrencyExchangeRate], 0.000) / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ISNULL(ISNULL(ISNULL(CAST(ARID.[dblPrice] * dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ISNULL(ARID.intPriceUOMId, ARID.intItemUOMId), 1) AS DECIMAL(18,7)), [dblPrice]), 0.000) * [dblCurrencyExchangeRate], 0.000) / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]) * (ARID.[dblDiscount]/100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal()) END
										ELSE
											dbo.fnRoundBanker(dbo.fnRoundBanker(((ARID.[dblBasePrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal()) - dbo.fnRoundBanker((((ARID.[dblBasePrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]) * (ARID.[dblDiscount]/100.00)), dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())											
									END							
								  )
							END)	
FROM tblARInvoiceDetail ARID
LEFT OUTER JOIN tblICItem ICI ON ARID.[intItemId] = ICI.[intItemId] 
WHERE ARID.[intInvoiceId] = @InvoiceIdLocal
		
	
UPDATE tblARInvoice
SET
	 [dblTax]					= ISNULL(T.[dblTotalTax], @ZeroDecimal)
	,[dblBaseTax]				= ISNULL(T.[dblBaseTotalTax], @ZeroDecimal)
	,[dblInvoiceSubtotal]		= ISNULL(T.[dblTotal], @ZeroDecimal)
	,[dblBaseInvoiceSubtotal]	= ISNULL(T.[dblBaseTotal], @ZeroDecimal)
	,[dblInvoiceTotal]			= CASE WHEN intSourceId = 5 THEN ISNULL(T.[dblTotal], @ZeroDecimal) - ISNULL(T.[dblTotalTax], @ZeroDecimal) ELSE [dblInvoiceTotal] END
	,[dblBaseInvoiceTotal]		= CASE WHEN intSourceId = 5 THEN ISNULL(T.[dblBaseTotal], @ZeroDecimal) - ISNULL(T.[dblBaseTotalTax], @ZeroDecimal) ELSE [dblBaseInvoiceTotal] END
	,[dblAmountDue]				= CASE WHEN intSourceId = 5 THEN ISNULL(T.[dblTotal], @ZeroDecimal) - ISNULL(T.[dblTotalTax], @ZeroDecimal) ELSE [dblAmountDue] END
	,[dblBaseAmountDue]			= CASE WHEN intSourceId = 5 THEN ISNULL(T.[dblBaseTotal], @ZeroDecimal) - ISNULL(T.[dblBaseTotalTax], @ZeroDecimal) ELSE [dblBaseAmountDue] END
	,[dblTotalStandardWeight]	= ISNULL(T.[dblTotalStandardWeight], @ZeroDecimal)
	,dblProvisionalTotal		= ISNULL(T.dblProvisionalTotal, @ZeroDecimal)
FROM (
	SELECT 
		 [dblTotalTax]				= SUM([dblTotalTax])
		,[dblBaseTotalTax]			= SUM([dblBaseTotalTax])
		,[dblTotal]					= SUM([dblTotal])
		,[dblBaseTotal]				= SUM([dblBaseTotal])
		,[dblTotalStandardWeight]	= SUM(dbo.fnRoundBanker(([dblStandardWeight] * [dblQtyShipped]), dbo.fnARGetDefaultDecimal()))
		,dblProvisionalTotal		= SUM(dblProvisionalTotal)
		,[intInvoiceId]				= [intInvoiceId]
	FROM
		tblARInvoiceDetail
	WHERE
		[intInvoiceId] = @InvoiceIdLocal
	GROUP BY
		[intInvoiceId]
) T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal

UPDATE ARI
SET
	 [dblInvoiceTotal]		= (ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping])
	,[dblBaseInvoiceTotal]	= (ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping])
	,[dblAmountDue]			= ISNULL(ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping] + ARI.[dblInterest], @ZeroDecimal) - ISNULL(ARI.dblPayment + ARI.[dblDiscount], @ZeroDecimal)
								-
								CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
								THEN CASE WHEN ISNULL(ARI.ysnExcludeFromPayment, 0) = 0 THEN PRO.dblPayment ELSE PRO.dblInvoiceTotal END
								ELSE 0
								END
	,[dblBaseAmountDue]		= ISNULL(ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping] + ARI.[dblBaseInterest], @ZeroDecimal) - ISNULL(ARI.dblBasePayment + ARI.[dblBaseDiscount], @ZeroDecimal)
								-
								CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
								THEN CASE WHEN ISNULL(ARI.ysnExcludeFromPayment, 0) = 0 THEN PRO.dblBasePayment ELSE PRO.dblBaseInvoiceTotal END
								ELSE 0
								END
FROM tblARInvoice ARI
LEFT JOIN tblARInvoice PRO ON ARI.[intOriginalInvoiceId] = PRO.[intInvoiceId]
WHERE
	ARI.[intInvoiceId] = @InvoiceIdLocal

END