print('/*******************  BEGIN Update Base Amounts for Mulit-Currency  *******************/')
GO


DECLARE @Ids AS TABLE(intInvoiceId INT, intInvoiceDetailId INT)
INSERT INTO @Ids(intInvoiceId, intInvoiceDetailId)
SELECT intInvoiceId, intInvoiceDetailId FROM tblARInvoiceDetail WHERE ISNULL(dblCurrencyExchangeRate, 1) = 1 AND dblBaseTotal <> dblTotal

UNION ALL

SELECT ARI.intInvoiceId, ARID.intInvoiceDetailId
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoiceDetail ARID
		ON ARI.intInvoiceId = ARID.intInvoiceId
INNER JOIN
	tblARInvoiceDetailTax ARIDT
		ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId
WHERE
	ISNULL(ARID.dblCurrencyExchangeRate, 1) = 1
	AND ARIDT.dblAdjustedTax <> ARIDT.dblBaseAdjustedTax


UPDATE
	tblARInvoiceDetailTax
SET
	[dblBaseAdjustedTax] = [dblAdjustedTax]
WHERE
	[intInvoiceDetailId] IN (SELECT DISTINCT [intInvoiceDetailId] FROM @Ids)
	
UPDATE
	tblARInvoiceDetail
SET
	[dblBasePrice]		= [dblPrice]
	,[dblBaseTotalTax]	= [dblTotalTax]
	,[dblBaseTotal]		= [dblTotal]
WHERE
	[intInvoiceDetailId] IN (SELECT DISTINCT [intInvoiceDetailId] FROM @Ids)
	
	
UPDATE
	tblARInvoice
SET
	 [dblBaseTax]				= T.[dblBaseTotalTax]
	,[dblBaseInvoiceSubtotal]	= T.[dblBaseTotal]
	,[dblBasePayment]			= [dblPayment]
FROM
	(
		SELECT 
			 SUM([dblBaseTotalTax])	AS [dblBaseTotalTax]
			,SUM([dblBaseTotal])	AS [dblBaseTotal]
			,[intInvoiceId]
		FROM
			tblARInvoiceDetail
		GROUP BY
			[intInvoiceId]
	)
	 T
WHERE
	tblARInvoice.[intInvoiceId] = T.[intInvoiceId]
	AND tblARInvoice.[intInvoiceId] IN (SELECT DISTINCT [intInvoiceId] FROM @Ids)
	

UPDATE
	tblARInvoice
SET
	 [dblBaseInvoiceTotal]	= ([dblBaseInvoiceSubtotal] + [dblBaseTax] + [dblBaseShipping])
	,[dblBaseAmountDue]		= ([dblBaseInvoiceSubtotal] + [dblBaseTax] + [dblBaseShipping]) - ([dblBasePayment] + [dblBaseDiscount])
WHERE
	[intInvoiceId] IN (SELECT DISTINCT [intInvoiceId] FROM @Ids)	
	
	
UPDATE
	ARPD
SET
	ARPD.[dblBaseInvoiceTotal]	= ARI.[dblBaseInvoiceTotal]
	,ARPD.[dblBaseAmountDue]	= CASE WHEN ARP.[ysnPosted] = 1 THEN ARI.[dblBaseAmountDue] ELSE (ARI.[dblBaseInvoiceTotal] + [dbo].fnRoundBanker(ARPD.[dblInterest] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]())) - ([dbo].fnRoundBanker(ARPD.[dblPayment] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]()) + [dbo].fnRoundBanker(ARPD.[dblDiscount] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]())) END
	,ARPD.[dblBaseDiscount]		= [dbo].fnRoundBanker(ARPD.[dblDiscount] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblBaseInterest]		= [dbo].fnRoundBanker(ARPD.[dblInterest] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblBasePayment]		= [dbo].fnRoundBanker(ARPD.[dblPayment] * ISNULL(dblCurrencyExchangeRate,1.000000), [dbo].[fnARGetDefaultDecimal]())
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblARPayment ARP
		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
INNER JOIN
	tblARInvoice ARI
		ON ARPD.intInvoiceId = ARI.intInvoiceId
WHERE
	ARI.intInvoiceId IN (SELECT DISTINCT [intInvoiceId] FROM @Ids)
	


GO
print('/*******************  END Update Update Base Amounts for Mulit-Currency  *******************/')