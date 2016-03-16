﻿CREATE PROCEDURE [dbo].[uspARReComputeInvoiceAmounts]
	 @InvoiceId		AS INT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal		DECIMAL(18,6)
		,@SubCurrencyCents	INT

SET @ZeroDecimal = 0.000000	
						
SELECT
	@SubCurrencyCents		= ISNULL([intSubCurrencyCents], 1)
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId

UPDATE
	tblARInvoiceDetailTax
SET
	 [dblRate]			= ISNULL([dblRate], @ZeroDecimal)
	,[dblTax]			= ISNULL([dblTax], @ZeroDecimal)
	,[dblAdjustedTax]	= ROUND(ISNULL([dblAdjustedTax], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
	,[ysnTaxAdjusted]	= ROUND(ISNULL([ysnTaxAdjusted], @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
WHERE 
	intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
	
	
UPDATE
	tblARInvoiceDetail
SET
	 [dblQtyOrdered]	 = ISNULL([dblQtyOrdered], @ZeroDecimal)
	,[dblQtyShipped]	 = ISNULL([dblQtyShipped], @ZeroDecimal)
	,[dblDiscount]		 = ISNULL([dblDiscount], @ZeroDecimal)
	,[dblPrice]			 = ISNULL([dblPrice], @ZeroDecimal)
	,[dblTotalTax]		 = ISNULL([dblTotalTax], @ZeroDecimal)
	,[dblTotal]			 = ISNULL([dblTotal], @ZeroDecimal)
WHERE
	[intInvoiceId] = @InvoiceId
	
	
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
WHERE
	[intInvoiceId] = @InvoiceId
	
	
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
	AND tblARInvoiceDetail.[intInvoiceId] = @InvoiceId

UPDATE
	tblARInvoiceDetail
SET
	[dblTotal]		= ROUND((([dblPrice] / (CASE WHEN ISNULL([ysnSubCurrency],0) = 1 THEN @SubCurrencyCents ELSE 1 END)) * [dblQtyShipped]) - ((([dblPrice] / (CASE WHEN ISNULL([ysnSubCurrency],0) = 1 THEN @SubCurrencyCents ELSE 1 END)) * [dblQtyShipped]) * (dblDiscount/100.00)), [dbo].[fnARGetDefaultDecimal]())
WHERE
	tblARInvoiceDetail.[intInvoiceId] = @InvoiceId
	
--UPDATE
--	tblARInvoiceDetail
--SET
--	[dblTotal]		= ROUND(([dblPrice] * [dblQtyShipped]) - (([dblPrice] * [dblQtyShipped]) * (dblDiscount/100.00)), [dbo].[fnARGetDefaultDecimal]())
--WHERE
--	tblARInvoiceDetail.[intInvoiceId] = @InvoiceId	
	
	
UPDATE
	tblARInvoice
SET
	 [dblTax]				= T.[dblTotalTax]
	,[dblInvoiceSubtotal]	= T.[dblTotal]
	--,[dblDiscount]			= T.[dblDiscount]
FROM
	(
		SELECT 
			 SUM([dblTotalTax])		AS [dblTotalTax]
			,SUM([dblTotal])		AS [dblTotal]
			--,SUM((([dblPrice] * [dblQtyShipped]) * (dblDiscount/100.00))) AS [dblDiscount]
			,[intInvoiceId]
		FROM
			tblARInvoiceDetail
		WHERE
			[intInvoiceId] = @InvoiceId
		GROUP BY
			[intInvoiceId]
	)
	 T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] = @InvoiceId
	
	
UPDATE
	tblARInvoice
SET
	[dblInvoiceTotal]	= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping])
	,[dblAmountDue]		= ([dblInvoiceSubtotal] + [dblTax] + [dblShipping]) - ([dblPayment] + [dblDiscount])
WHERE
	[intInvoiceId] = @InvoiceId

END