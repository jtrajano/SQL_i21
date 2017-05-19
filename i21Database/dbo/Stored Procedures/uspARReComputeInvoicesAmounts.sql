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
						
UPDATE ARIDT
SET
	 ARIDT.[dblRate]			= ISNULL(ARIDT.[dblRate], @ZeroDecimal)
	,ARIDT.[dblTax]				= ISNULL(ARIDT.[dblTax], @ZeroDecimal)
	,ARIDT.[dblAdjustedTax]		= [dbo].fnRoundBanker(ISNULL(ARIDT.[dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,ARIDT.[dblBaseAdjustedTax]	= [dbo].fnRoundBanker(ISNULL(ARIDT.[dblBaseAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,ARIDT.[ysnTaxAdjusted]		= ISNULL(ARIDT.[ysnTaxAdjusted], 0)
FROM
	tblARInvoiceDetailTax ARIDT
INNER JOIN
	(SELECT [intInvoiceDetailId], [intInvoiceId] FROM tblARInvoiceDetail) ARID
		ON ARIDT.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE 
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARID.[intInvoiceId])
	
	
UPDATE ARID
SET
	 ARID.[dblQtyOrdered]			= ISNULL(ARID.[dblQtyOrdered], @ZeroDecimal)
	,ARID.[dblQtyShipped]			= ISNULL(ARID.[dblQtyShipped], @ZeroDecimal)
	,ARID.[dblDiscount]				= ISNULL(ARID.[dblDiscount], @ZeroDecimal)
	,ARID.[dblItemWeight]			= ISNULL(ARID.[dblItemWeight], 1.00)
	,ARID.[dblShipmentNetWt]		= ISNULL(ARID.[dblShipmentNetWt], [dblQtyShipped])
	,ARID.[dblPrice]				= ISNULL(ARID.[dblPrice], @ZeroDecimal)
	,ARID.[dblBasePrice]			= CASE WHEN ARID.[dblBasePrice] <> ARID.[dblPrice] AND ARID.[dblBasePrice] = @ZeroDecimal THEN (ISNULL(ARID.[dblPrice], @ZeroDecimal) * (CASE WHEN ISNULL(ARID.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE ARID.[dblCurrencyExchangeRate] END)) ELSE ISNULL(ARID.[dblBasePrice], @ZeroDecimal) END
	,ARID.[dblTotalTax]				= ISNULL(ARID.[dblTotalTax], @ZeroDecimal)
	,ARID.[dblBaseTotalTax]			= ISNULL(ARID.[dblBaseTotalTax], @ZeroDecimal)
	,ARID.[dblTotal]				= ISNULL(ARID.[dblTotal], @ZeroDecimal)
	,ARID.[dblBaseTotal]			= ISNULL(ARID.[dblBaseTotal], @ZeroDecimal)
	,ARID.[dblItemTermDiscount]		= ISNULL(ARID.[dblItemTermDiscount], @ZeroDecimal)
	,ARID.[strItemTermDiscountBy]	= ISNULL(ARID.[strItemTermDiscountBy], 'Amount') 
	,ARID.[intSubCurrencyId]		= ISNULL(ARID.[intSubCurrencyId], ARI.[intCurrencyId])
	,ARID.[dblSubCurrencyRate]		= CASE WHEN ISNULL(ARID.[dblSubCurrencyRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE ARID.[dblSubCurrencyRate] END
	,ARID.[dblCurrencyExchangeRate]	= CASE WHEN ISNULL(ARID.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE ARID.[dblCurrencyExchangeRate] END
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	(SELECT [intInvoiceId], [intCurrencyId] FROM tblARInvoice) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARID.[intInvoiceId])
	
	
UPDATE
	tblARInvoice
SET
	 [dblInvoiceSubtotal]		= ISNULL([dblInvoiceSubtotal], @ZeroDecimal)
	,[dblBaseInvoiceSubtotal]	= ISNULL([dblBaseInvoiceSubtotal], @ZeroDecimal)
	,[dblShipping]				= ISNULL([dblShipping], @ZeroDecimal)
	,[dblBaseShipping]			= ISNULL([dblBaseShipping], @ZeroDecimal)
	,[dblTax]					= ISNULL([dblTax], @ZeroDecimal)
	,[dblBaseTax]				= ISNULL([dblBaseTax], @ZeroDecimal)
	,[dblInvoiceTotal]			= ISNULL([dblInvoiceTotal], @ZeroDecimal)
	,[dblBaseInvoiceTotal]		= ISNULL([dblBaseInvoiceTotal], @ZeroDecimal)
	,[dblDiscount]				= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblBaseDiscount]			= ISNULL([dblBaseDiscount], @ZeroDecimal)
	,[dblAmountDue]				= ISNULL([dblAmountDue], @ZeroDecimal)
	,[dblBaseAmountDue]			= ISNULL([dblBaseAmountDue], @ZeroDecimal)
	,[dblPayment]				= ISNULL([dblPayment], @ZeroDecimal)
	,[dblBasePayment]			= ISNULL([dblBasePayment], @ZeroDecimal)
	,[dblDiscountAvailable]		= ISNULL([dblDiscountAvailable], @ZeroDecimal)
	,[dblBaseDiscountAvailable]	= ISNULL([dblBaseDiscountAvailable], @ZeroDecimal)
	,[dblTotalTermDiscount]		= ISNULL([dblTotalTermDiscount], @ZeroDecimal)
	,[dblInterest]				= ISNULL([dblInterest], @ZeroDecimal)
	,[dblBaseInterest]			= ISNULL([dblBaseInterest], @ZeroDecimal)
	,[dblSplitPercent] 			= CASE WHEN ISNULL([ysnSplitted],0) = 0 OR [intSplitId] IS NULL THEN 1 ELSE ISNULL([dblSplitPercent],1) END
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = [intInvoiceId])


UPDATE ARI
SET
	  [dblDiscountAvailable]	= ISNULL([dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblInvoiceTotal])  + T.[dblItemTermDiscountTotal], @ZeroDecimal)
	 ,[dblTotalTermDiscount]	= ISNULL(T.[dblItemTermDiscountTotal], @ZeroDecimal)
FROM
	tblARInvoice ARI
LEFT OUTER JOIN
	(
	SELECT 
			SUM(
			CASE WHEN [strItemTermDiscountBy] = 'Percent'
				THEN
					([dblQtyShipped] * [dblPrice]) * ([dblItemTermDiscount]/100.000000)
				ELSE
					[dblItemTermDiscount]
			END
			)	AS [dblItemTermDiscountTotal]
		,[intInvoiceId]
	FROM
		tblARInvoiceDetail
	GROUP BY
		[intInvoiceId]
	)
	 T
	ON ARI.[intInvoiceId] = T.[intInvoiceId]
	AND ARI.[ysnPaid] = 0
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARI.[intInvoiceId])


UPDATE ARID
SET
	  ARID.[dblTotalTax]		= T.[dblAdjustedTax]
	 ,ARID.[dblBaseTotalTax]	= T.[dblBaseAdjustedTax]
FROM
	tblARInvoiceDetail ARID
LEFT OUTER JOIN
	(
		SELECT
			 SUM([dblAdjustedTax]) [dblAdjustedTax]
			,SUM([dblBaseAdjustedTax]) [dblBaseAdjustedTax]
			,[intInvoiceDetailId]
		FROM
			tblARInvoiceDetailTax
		GROUP BY
			[intInvoiceDetailId]	
	)
	 T
	 ON ARID.[intInvoiceDetailId] = T.[intInvoiceDetailId] 
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARID.[intInvoiceId] AND ISNULL([ysnUpdateAvailableDiscountOnly],0) = 0)

UPDATE
	ARID
SET
	ARID.[dblTotal]		= (CASE WHEN ISNULL(ICI.[strType], '') = 'Comment' THEN @ZeroDecimal
							ELSE
								(	CASE WHEN ((ISNULL(ARID.[intShipmentId],0) <> 0 OR ISNULL(ARID.[intShipmentPurchaseSalesContractId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0) AND ISNULL(ARID.[intItemWeightUOMId],0) <> 0)
										THEN
											[dbo].fnRoundBanker([dbo].fnRoundBanker(((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * (ARID.[dblItemWeight] * ARID.[dblShipmentNetWt])), [dbo].[fnARGetDefaultDecimal]()) - [dbo].fnRoundBanker((((ARID.[dblPrice] / ARID.[dblSubCurrencyRate]) * (ARID.[dblItemWeight] * ARID.[dblShipmentNetWt])) * (ARID.[dblDiscount]/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
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
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARID.[intInvoiceId])

UPDATE
	ARID
SET
	ARID.[dblBaseTotal]	= [dbo].fnRoundBanker(ARID.[dblTotal] * ARID.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())	
FROM
	tblARInvoiceDetail ARID
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
			 SUM([dblTotalTax])		AS [dblTotalTax]
			,SUM([dblBaseTotalTax])	AS [dblBaseTotalTax]
			,SUM([dblTotal])		AS [dblTotal]
			,SUM([dblBaseTotal])	AS [dblBaseTotal]
			,[intInvoiceId]
		FROM
			tblARInvoiceDetail
		GROUP BY
			[intInvoiceId]
	)
	 T
	 ON ARI.[intInvoiceId] = T.[intInvoiceId] 
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARI.[intInvoiceId] AND ISNULL([ysnUpdateAvailableDiscountOnly],0) = 0)
	
	
UPDATE ARI	
SET
	 ARI.[dblInvoiceTotal]		= (ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping])
	,ARI.[dblBaseInvoiceTotal]	= (ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping])
	,ARI.[dblAmountDue]			= (ARI.[dblInvoiceSubtotal] + ARI.[dblTax] + ARI.[dblShipping]) - (ARI.[dblPayment] + ARI.[dblDiscount])
	,ARI.[dblBaseAmountDue]		= (ARI.[dblBaseInvoiceSubtotal] + ARI.[dblBaseTax] + ARI.[dblBaseShipping]) - (ARI.[dblBasePayment] + ARI.[dblBaseDiscount])
FROM
	tblARInvoice ARI
WHERE
	EXISTS(SELECT NULL FROM @InvoiceIds WHERE [intHeaderId] = ARI.[intInvoiceId] AND ISNULL([ysnUpdateAvailableDiscountOnly],0) = 0)

END
