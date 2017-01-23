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

DECLARE  @ZeroDecimal		DECIMAL(18,6)
		,@InvoiceIdLocal	INT
		,@CurrencyId		INT

SET @ZeroDecimal = 0.000000	
SET @InvoiceIdLocal = @InvoiceId
						
SELECT
	@CurrencyId		= [intCurrencyId]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceIdLocal


UPDATE
	tblARInvoiceDetailTax
SET
	 [dblRate]			= ISNULL([dblRate], @ZeroDecimal)
	,[dblTax]			= ISNULL([dblTax], @ZeroDecimal)
	,[dblAdjustedTax]	= [dbo].fnRoundBanker(ISNULL([dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,[ysnTaxAdjusted]	= ISNULL([ysnTaxAdjusted], 0)
WHERE 
	intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceIdLocal)
	
	
UPDATE
	tblARInvoiceDetail
SET
	 [dblQtyOrdered]			= ISNULL([dblQtyOrdered], @ZeroDecimal)
	,[dblQtyShipped]			= ISNULL([dblQtyShipped], @ZeroDecimal)
	,[dblDiscount]				= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblItemWeight]			= ISNULL([dblItemWeight], 1.00)
	,[dblShipmentNetWt]			= ISNULL([dblShipmentNetWt], [dblQtyShipped])
	,[dblPrice]					= ISNULL([dblPrice], @ZeroDecimal)
	,[dblTotalTax]				= ISNULL([dblTotalTax], @ZeroDecimal)
	,[dblTotal]					= ISNULL([dblTotal], @ZeroDecimal)
	,[dblItemTermDiscount]		= ISNULL([dblItemTermDiscount], @ZeroDecimal)
	,[strItemTermDiscountBy]	= ISNULL([strItemTermDiscountBy], 'Amount') 
	,[intSubCurrencyId]			= ISNULL([intSubCurrencyId], @CurrencyId)
	,[dblSubCurrencyRate]		= CASE WHEN ISNULL([dblSubCurrencyRate], @ZeroDecimal) = @ZeroDecimal THEN 1 ELSE [dblSubCurrencyRate] END
WHERE
	[intInvoiceId] = @InvoiceIdLocal
	
	
UPDATE
	tblARInvoice
SET
	 [dblInvoiceSubtotal]	= ISNULL([dblInvoiceSubtotal], @ZeroDecimal)
	,[dblShipping]			= ISNULL([dblShipping], @ZeroDecimal)
	,[dblTax]				= ISNULL([dblTax], @ZeroDecimal)
	,[dblInvoiceTotal]		= ISNULL([dblInvoiceTotal], @ZeroDecimal)
	,[dblDiscount]			= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblAmountDue]			= ISNULL([dblAmountDue], @ZeroDecimal)
	,[dblPayment]			= ISNULL([dblPayment], @ZeroDecimal)
	,[dblDiscountAvailable]	= ISNULL([dblDiscountAvailable], @ZeroDecimal)
	,[dblTotalTermDiscount]	= ISNULL([dblTotalTermDiscount], @ZeroDecimal)
	,[dblInterest]			= ISNULL([dblInterest], @ZeroDecimal)
WHERE
	[intInvoiceId] = @InvoiceIdLocal


UPDATE
	tblARInvoice
SET
	  [dblDiscountAvailable]	= [dbo].[fnGetDiscountBasedOnTerm]([dtmDate], [dtmDate], [intTermId], [dblInvoiceTotal])  + T.[dblItemTermDiscountTotal]
	 ,[dblTotalTermDiscount]	= T.[dblItemTermDiscountTotal]
FROM
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
		WHERE
			[intInvoiceId] = @InvoiceIdLocal
		GROUP BY
			[intInvoiceId]
	)
	 T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal


IF (@AvailableDiscountOnly = 1)
	RETURN 1;

	
UPDATE
	tblARInvoiceDetail
SET
	 [dblTotalTax]	= T.[dblAdjustedTax]
FROM
	(
		SELECT
			 SUM([dblAdjustedTax]) [dblAdjustedTax]
			,[intInvoiceDetailId]
		FROM
			tblARInvoiceDetailTax
		GROUP BY
			[intInvoiceDetailId]	
	)
	 T
WHERE
	tblARInvoiceDetail.[intInvoiceDetailId] = T.[intInvoiceDetailId]
	AND tblARInvoiceDetail.[intInvoiceId] = @InvoiceIdLocal

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
	tblICItem ICI
		ON ARID.[intItemId] = ICI.[intItemId] 
WHERE
	ARID.[intInvoiceId] = @InvoiceIdLocal
		
	
UPDATE
	tblARInvoice
SET
	 [dblTax]				= T.[dblTotalTax]
	,[dblInvoiceSubtotal]	= T.[dblTotal]
FROM
	(
		SELECT 
			 SUM([dblTotalTax])		AS [dblTotalTax]
			,SUM([dblTotal])		AS [dblTotal]
			,[intInvoiceId]
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceId] = @InvoiceIdLocal
		GROUP BY
			[intInvoiceId]
	)
	 T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] = @InvoiceIdLocal
	
	
UPDATE
	tblARInvoice
SET
	[dblInvoiceTotal]	= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping])
	,[dblAmountDue]		= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping]) - ([dblPayment] + [dblDiscount])
WHERE
	[intInvoiceId] = @InvoiceIdLocal

END