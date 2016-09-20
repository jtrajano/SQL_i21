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
	,[dblAdjustedTax]	= ROUND(ISNULL([dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,[ysnTaxAdjusted]	= ROUND(ISNULL([ysnTaxAdjusted], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
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
	,[dblSubCurrencyRate]		= ISNULL([dblSubCurrencyRate], 1.000000)
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
	tblARInvoiceDetail
SET
	[dblTotal]		= (	CASE WHEN ((ISNULL([intShipmentId],0) <> 0 OR ISNULL([intShipmentPurchaseSalesContractId],0) <> 0) AND ISNULL([intItemWeightUOMId],0) <> 0)
							THEN
								ROUND(ROUND((([dblPrice] / [dblSubCurrencyRate]) * ([dblItemWeight] * [dblShipmentNetWt])), [dbo].[fnARGetDefaultDecimal]()) - ROUND(((([dblPrice] / [dblSubCurrencyRate]) * ([dblItemWeight] * [dblShipmentNetWt])) * (dblDiscount/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
							ELSE
								ROUND(ROUND((([dblPrice] / [dblSubCurrencyRate]) * [dblQtyShipped]), [dbo].[fnARGetDefaultDecimal]()) - ROUND(((([dblPrice] / [dblSubCurrencyRate]) * [dblQtyShipped]) * (dblDiscount/100.00)), [dbo].[fnARGetDefaultDecimal]()), [dbo].[fnARGetDefaultDecimal]())
						END							
					  )
WHERE
	tblARInvoiceDetail.[intInvoiceId] = @InvoiceIdLocal
		
	
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