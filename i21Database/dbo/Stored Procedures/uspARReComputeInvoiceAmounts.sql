CREATE PROCEDURE [dbo].[uspARReComputeInvoiceAmounts]
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

UPDATE
	tblARInvoiceDetailTax
SET
	 [numRate]			= ISNULL([numRate], @ZeroDecimal)
	,[dblTax]			= ISNULL([dblTax], @ZeroDecimal)
	,[dblAdjustedTax]	= ISNULL([dblAdjustedTax], @ZeroDecimal)
	,[ysnTaxAdjusted]	= ISNULL([ysnTaxAdjusted], @ZeroDecimal)
WHERE 
	intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
	
	
UPDATE
	tblARInvoiceDetail
SET
	 [dblQtyOrdered]	= ISNULL([dblQtyOrdered], @ZeroDecimal)
	,[dblQtyShipped]	= ISNULL([dblQtyShipped], @ZeroDecimal)
	,[dblDiscount]		= ISNULL([dblDiscount], @ZeroDecimal)
	,[dblPrice]			= ISNULL([dblPrice], @ZeroDecimal)
	,[dblTotalTax]		= ISNULL([dblTotalTax], @ZeroDecimal)
	,[dblTotal]			= ISNULL([dblTotal], @ZeroDecimal)
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
	,[dblTotal]		= ([dblPrice] * [dblQtyShipped]) - (([dblPrice] * [dblQtyShipped]) * (dblDiscount/100.00))
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
	tblARInvoice
SET
	 [dblTax]				= ROUND(T.[dblTotalTax],2)
	,[dblInvoiceSubtotal]	= ROUND(T.[dblTotal],2)
	,[dblDiscount]			= ROUND(T.[dblDiscount],2) 
FROM
	(
		SELECT 
			 SUM([dblTotalTax])		AS [dblTotalTax]
			,SUM([dblTotal])		AS [dblTotal]
			,SUM((([dblPrice] * [dblQtyShipped]) * (dblDiscount/100.00))) AS [dblDiscount]
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
	[dblInvoiceTotal]	= (ROUND([dblInvoiceSubtotal],2) + ROUND([dblTax],2) + ROUND([dblShipping],2)) - (ROUND([dblPayment],2) + ROUND([dblDiscount],2))
	,[dblAmountDue]		= (ROUND([dblInvoiceSubtotal],2) + ROUND([dblTax],2) + ROUND([dblShipping],2)) - (ROUND([dblPayment],2) + ROUND([dblDiscount],2))
WHERE
	[intInvoiceId] = @InvoiceId

END