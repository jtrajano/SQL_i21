CREATE PROCEDURE [dbo].[uspARReComputeInvoicesAmounts]
	@InvoiceIds		InvoiceId	READONLY
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal	DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

UPDATE ARID
SET
	 ARID.[dblCurrencyExchangeRate]	= CASE WHEN ISNULL(ARID.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ARID.[dblCurrencyExchangeRate] END
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	(SELECT [intInvoiceId], [intCurrencyId] FROM tblARInvoice) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
	@InvoiceIds IID
		ON ARID.[intInvoiceId] = IID.[intHeaderId]

UPDATE ARI	
SET
	 ARI.[dblCurrencyExchangeRate]	= [dbo].fnRoundBanker(ISNULL(T.[dblCurrencyExchangeRate], 1.000000) / ISNULL(T.[intCount], 1.000000), 6)
FROM
	tblARInvoice ARI
LEFT OUTER JOIN
	(
		SELECT 
			 [dblCurrencyExchangeRate]	= SUM([dblCurrencyExchangeRate])
			,[intCount]					= COUNT([intInvoiceId])
			,[intInvoiceId]				= [intInvoiceId]
		FROM
			tblARInvoiceDetail
		GROUP BY
			[intInvoiceId]
	)
	 T
	 ON ARI.[intInvoiceId] = T.[intInvoiceId] 
INNER JOIN
	@InvoiceIds IID
		ON ARI.[intInvoiceId] = IID.[intHeaderId]
						
UPDATE ARIDT
SET
	 ARIDT.[dblRate]			= ISNULL(ARIDT.[dblRate], @ZeroDecimal)
	,ARIDT.[dblBaseRate]		= ISNULL(ARIDT.[dblBaseRate], ISNULL(ARIDT.[dblRate], @ZeroDecimal))
	,ARIDT.[dblTax]				= ISNULL(ARIDT.[dblTax], @ZeroDecimal)
	,ARIDT.[dblAdjustedTax]		= [dbo].fnRoundBanker(ISNULL(ARIDT.[dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,ARIDT.[dblBaseAdjustedTax]	= [dbo].fnRoundBanker(ISNULL(ARIDT.[dblBaseAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,ARIDT.[ysnTaxAdjusted]		= ISNULL(ARIDT.[ysnTaxAdjusted], 0)
FROM
	tblARInvoiceDetailTax ARIDT
INNER JOIN
	(SELECT [intInvoiceDetailId], [intInvoiceId] FROM tblARInvoiceDetail) ARID
		ON ARIDT.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN
	@InvoiceIds IID
		ON ARID.[intInvoiceId] = IID.[intHeaderId]
	
	
UPDATE ARID
SET
	 ARID.[dblQtyOrdered]					= ISNULL(ARID.[dblQtyOrdered], @ZeroDecimal)
	,ARID.[dblQtyShipped]					= ISNULL(ARID.[dblQtyShipped], @ZeroDecimal)
	,ARID.[dblDiscount]						= ISNULL(ARID.[dblDiscount], @ZeroDecimal)
	,ARID.[dblItemWeight]					= ISNULL(ARID.[dblItemWeight], 1.000000)
	,ARID.[dblShipmentGrossWt]				= ISNULL(ARID.[dblShipmentGrossWt], @ZeroDecimal)
	,ARID.[dblShipmentTareWt]				= ISNULL(ARID.[dblShipmentTareWt], @ZeroDecimal)
	,ARID.[dblShipmentNetWt]				= ISNULL(ARID.[dblShipmentGrossWt], @ZeroDecimal) - ISNULL(ARID.[dblShipmentTareWt], @ZeroDecimal)
	,ARID.[dblPrice]						= ISNULL(ARID.[dblPrice], @ZeroDecimal)
	,ARID.[dblBasePrice]					= ISNULL(ISNULL(ARID.[dblPrice], @ZeroDecimal) * ARID.[dblCurrencyExchangeRate], @ZeroDecimal)
	,ARID.[dblUnitPrice] 					= ISNULL(ISNULL(ARID.[dblUnitPrice], ARID.[dblPrice]), @ZeroDecimal)
	,ARID.[dblBaseUnitPrice]				= ISNULL(ISNULL(ISNULL(ARID.[dblUnitPrice], ARID.[dblPrice]), @ZeroDecimal) * ARID.[dblCurrencyExchangeRate], @ZeroDecimal)
	,ARID.[intPriceUOMId]					= CASE WHEN (ISNULL(ARID.[intLoadDetailId],0) <> 0) THEN ISNULL(ARID.[intPriceUOMId], ARID.[intItemWeightUOMId]) ELSE ISNULL(ARID.[intPriceUOMId], ARID.[intItemUOMId]) END
	,ARID.[dblUnitQuantity]					= CASE WHEN (ISNULL(ARID.[dblUnitQuantity],@ZeroDecimal) <> @ZeroDecimal) THEN ARID.[dblUnitQuantity] ELSE (CASE WHEN (ISNULL(ARID.[intLoadDetailId],0) <> 0) THEN ISNULL(ARID.[dblShipmentGrossWt], @ZeroDecimal) - ISNULL(ARID.[dblShipmentTareWt], @ZeroDecimal) ELSE ISNULL(ARID.[dblQtyShipped], @ZeroDecimal) END) END
	,ARID.[dblTotalTax]						= ISNULL(ARID.[dblTotalTax], @ZeroDecimal)
	,ARID.[dblBaseTotalTax]					= ISNULL(ARID.[dblBaseTotalTax], @ZeroDecimal)
	,ARID.[dblTotal]						= ISNULL(ARID.[dblTotal], @ZeroDecimal)
	,ARID.[dblBaseTotal]					= ISNULL(ARID.[dblBaseTotal], @ZeroDecimal)
	,ARID.[dblItemTermDiscount]				= ISNULL(ARID.[dblItemTermDiscount], @ZeroDecimal)
	,ARID.[strItemTermDiscountBy]			= ISNULL(ARID.[strItemTermDiscountBy], 'Amount')
	,ARID.[dblItemTermDiscountAmount]		= [dbo].[fnARGetItemTermDiscount](	ISNULL(ARID.[strItemTermDiscountBy], 'Amount')
																				,ARID.[dblItemTermDiscount]
																				,ARID.[dblQtyShipped]
																				,ARID.[dblPrice]
																				,1.000000)
	,ARID.[dblBaseItemTermDiscountAmount]	= [dbo].[fnARGetItemTermDiscount](	ISNULL(ARID.[strItemTermDiscountBy], 'Amount')
																				,ARID.[dblItemTermDiscount]
																				,ARID.[dblQtyShipped]
																				,ARID.[dblPrice]
																				,ARI.[dblCurrencyExchangeRate])
	,ARID.[dblItemTermDiscountExemption]	= [dbo].[fnARGetItemTermDiscountExemption](	ARID.[ysnTermDiscountExempt]
																						,ARID.[dblTermDiscountRate]
																						,ARID.[dblQtyShipped]
																						,ARID.[dblPrice]
																						,1.000000)
	,ARID.[dblBaseItemTermDiscountExemption] = [dbo].[fnARGetItemTermDiscountExemption](	ARID.[ysnTermDiscountExempt]
																						,ARID.[dblTermDiscountRate]
																						,ARID.[dblQtyShipped]
																						,ARID.[dblPrice]
																						,ARI.[dblCurrencyExchangeRate])
	,ARID.[dblTermDiscountRate]				= ISNULL(ARID.[dblTermDiscountRate], @ZeroDecimal)
	,ARID.[ysnTermDiscountExempt]			= ISNULL(ARID.[ysnTermDiscountExempt], 0)
	,ARID.[intSubCurrencyId]				= ISNULL(ARID.[intSubCurrencyId], ARI.[intCurrencyId])
	,ARID.[dblSubCurrencyRate]				= CASE WHEN ISNULL(ARID.[dblSubCurrencyRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ARID.[dblSubCurrencyRate] END
	,ARID.[dblLicenseAmount]				= ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal)
	,ARID.[dblBaseLicenseAmount]			= ISNULL(ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal) * ARID.[dblCurrencyExchangeRate], @ZeroDecimal)
	,ARID.[dblMaintenanceAmount]			= ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal)
	,ARID.[dblBaseMaintenanceAmount]		= ISNULL(ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblCurrencyExchangeRate], @ZeroDecimal)
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	(SELECT [intInvoiceId], [intCurrencyId], [dblCurrencyExchangeRate] FROM tblARInvoice) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
	@InvoiceIds IID
		ON ARID.[intInvoiceId] = IID.[intHeaderId]
	
	
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
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = [intInvoiceId])


UPDATE ARI
SET
	 [dblDiscountAvailable]					= CASE WHEN ARI.strType NOT IN ('CF Invoice','CF Tran') THEN ISNULL(([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblInvoiceTotal])  + T.[dblItemTermDiscountAmount]) - T.[dblItemTermDiscountExemption], @ZeroDecimal) ELSE ISNULL(T.[dblItemTermDiscountAmount], @ZeroDecimal) END
	,[dblBaseDiscountAvailable]				= CASE WHEN ARI.strType NOT IN ('CF Invoice','CF Tran') THEN ISNULL(([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblBaseInvoiceTotal])  + T.[dblBaseItemTermDiscountAmount]) - T.[dblBaseItemTermDiscountExemption], @ZeroDecimal) ELSE ISNULL(T.[dblBaseItemTermDiscountAmount], @ZeroDecimal) END
	,[dblTotalTermDiscount]					= ISNULL(T.[dblItemTermDiscountAmount], @ZeroDecimal)
	,[dblBaseTotalTermDiscount]				= ISNULL(T.[dblBaseItemTermDiscountAmount], @ZeroDecimal)
	,[dblTotalTermDiscountExemption]		= ISNULL(T.[dblItemTermDiscountExemption], @ZeroDecimal)
	,[dblBaseTotalTermDiscountExemption]	= ISNULL(T.[dblBaseItemTermDiscountExemption], @ZeroDecimal)
FROM
	tblARInvoice ARI
LEFT OUTER JOIN
	(
	SELECT 
		 [dblItemTermDiscountAmount]		= SUM([dblItemTermDiscountAmount])
		,[dblBaseItemTermDiscountAmount]	= SUM([dblBaseItemTermDiscountAmount])
		,[dblItemTermDiscountExemption]		= SUM([dblItemTermDiscountExemption])
		,[dblBaseItemTermDiscountExemption]	= SUM([dblBaseItemTermDiscountExemption])
		,[intInvoiceId]						= [intInvoiceId]
	FROM
		tblARInvoiceDetail
	GROUP BY
		[intInvoiceId]
	)
	 T
	ON ARI.[intInvoiceId] = T.[intInvoiceId]
	AND ARI.[ysnPaid] = 0
INNER JOIN
	@InvoiceIds IID
		ON ARI.[intInvoiceId] = IID.[intHeaderId]



UPDATE ARID
SET
	  ARID.[dblTotalTax]		= ISNULL(T.[dblAdjustedTax], @ZeroDecimal)
	 ,ARID.[dblBaseTotalTax]	= ISNULL(T.[dblBaseAdjustedTax], @ZeroDecimal)
FROM
	tblARInvoiceDetail ARID
LEFT OUTER JOIN
	(
		SELECT
			 SUM(ISNULL([dblAdjustedTax], @ZeroDecimal)) [dblAdjustedTax]
			,SUM(ISNULL([dblBaseAdjustedTax], @ZeroDecimal)) [dblBaseAdjustedTax]
			,[intInvoiceDetailId]
		FROM
			tblARInvoiceDetailTax
		GROUP BY
			[intInvoiceDetailId]	
	)
	 T
	 ON ARID.[intInvoiceDetailId] = T.[intInvoiceDetailId] 
INNER JOIN
	@InvoiceIds IID
		ON ARID.[intInvoiceId] = IID.[intHeaderId]
		AND ISNULL(IID.[ysnUpdateAvailableDiscountOnly],0) = 0

UPDATE
	ARID
SET
	ARID.[dblTotal]		= (CASE WHEN ISNULL(ICI.[strType], '') = 'Comment' THEN @ZeroDecimal
							ELSE
								--[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblUnitQuantity]), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblUnitQuantity]) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
								(	CASE WHEN (ISNULL(ARID.[intLoadDetailId],0) <> 0 AND ISNULL(ARID.[intItemWeightUOMId],0) <> 0)
										THEN
											[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblShipmentNetWt]), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblUnitPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblShipmentNetWt]) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
										ELSE
											[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * ARID.[dblQtyShipped]) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
									END							
								  )
							END)
	
FROM
	tblARInvoiceDetail ARID
LEFT OUTER JOIN
	(SELECT [intItemId], [strType] FROM tblICItem) ICI
		ON ARID.[intItemId] = ICI.[intItemId] 
INNER JOIN
	@InvoiceIds IID
		ON ARID.[intInvoiceId] = IID.[intHeaderId]

UPDATE
	ARID
SET
	ARID.[dblBaseTotal]	= [dbo].fnRoundBanker(ARID.[dblTotal] * ARI.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())	
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	(SELECT [intInvoiceId], [dblCurrencyExchangeRate] FROM tblARInvoice) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARID.[intInvoiceId] AND ISNULL([ysnUpdateAvailableDiscountOnly],0) = 0)
		
	
UPDATE ARI	
SET
	 ARI.[dblTax]					= ISNULL(T.[dblTotalTax], @ZeroDecimal)
	,ARI.[dblBaseTax]				= ISNULL(T.[dblBaseTotalTax], @ZeroDecimal)
	,ARI.[dblInvoiceSubtotal]		= ISNULL(T.[dblTotal], @ZeroDecimal)
	,ARI.[dblBaseInvoiceSubtotal]	= ISNULL(T.[dblBaseTotal], @ZeroDecimal)
FROM
	tblARInvoice ARI
LEFT OUTER JOIN
	(
		SELECT 
			 [dblTotalTax]				= SUM([dblTotalTax])
			,[dblBaseTotalTax]			= SUM([dblBaseTotalTax])
			,[dblTotal]					= SUM([dblTotal])
			,[dblBaseTotal]				= SUM([dblBaseTotal])
			,[intInvoiceId]				= [intInvoiceId]
		FROM
			tblARInvoiceDetail
		GROUP BY
			[intInvoiceId]
	)
	 T
	 ON ARI.[intInvoiceId] = T.[intInvoiceId] 
INNER JOIN
	@InvoiceIds IID
		ON ARI.[intInvoiceId] = IID.[intHeaderId]
	
UPDATE ARI	
SET
	 ARI.[dblInvoiceTotal]		= (ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping])
	,ARI.[dblBaseInvoiceTotal]	= (ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping])
	,[dblAmountDue]			= ISNULL(ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping] + ARI.[dblInterest], @ZeroDecimal) - ISNULL(ARI.dblPayment + ARI.[dblDiscount], @ZeroDecimal)
								-
								CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
								THEN CASE WHEN ISNULL(ARI.ysnExcludeFromPayment, 0) = 0 THEN PRO.dblPayment ELSE 0 END
								ELSE 0
								END
	,[dblBaseAmountDue]		= ISNULL(ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping] + ARI.[dblBaseInterest], @ZeroDecimal) - ISNULL(ARI.dblBasePayment + ARI.[dblBaseDiscount], @ZeroDecimal)
								-
								CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
								THEN CASE WHEN ISNULL(ARI.ysnExcludeFromPayment, 0) = 0 THEN PRO.dblBasePayment ELSE 0 END
								ELSE 0
								END
FROM tblARInvoice ARI
INNER JOIN tblARInvoice PRO ON ARI.[intOriginalInvoiceId] = PRO.[intInvoiceId]
INNER JOIN
	@InvoiceIds IID
		ON ARI.[intInvoiceId] = IID.[intHeaderId]

END
