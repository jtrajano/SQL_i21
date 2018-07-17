CREATE PROCEDURE [dbo].[uspARReComputePaymentAmounts]
	@PaymentIds	PaymentId	READONLY
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE  @ZeroDecimal	DECIMAL(18,6)
SET @ZeroDecimal = 0.000000 

UPDATE ARPD
SET
	ARPD.[dblCurrencyExchangeRate]	= CASE WHEN ISNULL(ARPD.[dblCurrencyExchangeRate], @ZeroDecimal) =  @ZeroDecimal THEN 1.000000 ELSE ARPD.[dblCurrencyExchangeRate] END
FROM
	tblARPaymentDetail ARPD
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARP
SET
	 ARP.[dblExchangeRate]	= [dbo].fnRoundBanker(ISNULL(PD.[dblCurrencyExchangeRate], 1.000000) / ISNULL(PD.[intCount], 1.000000), 6)
FROM tblARPayment ARP
INNER JOIN 
	(SELECT
		 [intPaymentId]			= [intPaymentId]
		,[dblCurrencyExchangeRate]	= SUM([dblCurrencyExchangeRate])
		,[intCount]					= COUNT([intPaymentId])
	FROM
		tblARPaymentDetail GROUP BY intPaymentId
	) PD
		ON ARP.[intPaymentId] = PD.[intPaymentId]
WHERE
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARP.[intPaymentId])
						
UPDATE ARPD
SET
	 ARPD.[dblDiscount]					= ISNULL(ARPD.[dblDiscount], @ZeroDecimal)
	,ARPD.[dblBaseDiscount]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblDiscount], @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblDiscountAvailable]		= ISNULL(ARPD.[dblDiscountAvailable], @ZeroDecimal)
	,ARPD.[dblBaseDiscountAvailable]	= [dbo].fnRoundBanker(ISNULL(ARPD.[dblDiscountAvailable], @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblInterest]					= ISNULL(ARPD.[dblInterest], @ZeroDecimal)
	,ARPD.[dblBaseInterest]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblInterest], @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblAmountDue]				= ISNULL(ARPD.[dblAmountDue], @ZeroDecimal)
	,ARPD.[dblBaseAmountDue]			= [dbo].fnRoundBanker(ISNULL(ARPD.[dblAmountDue], @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblPayment]					= ISNULL(ARPD.[dblPayment], @ZeroDecimal)
	,ARPD.[dblBasePayment]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblPayment], @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblARPayment ARP
		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARPD
SET	
	 ARPD.[dblAmountDue]		= (ISNULL(ARI.[dblAmountDue], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType])) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal))
	,ARPD.[dblBaseAmountDue]	= [dbo].fnRoundBanker(ISNULL((ISNULL(ARI.[dblAmountDue], @ZeroDecimal) * dbo.fnARGetInvoiceAmountMultiplier(ARI.[strTransactionType])) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal)), @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblARPayment ARP
		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
INNER JOIN
	tblARInvoice ARI
		ON ARPD.[intInvoiceId] = ARI.[intInvoiceId] 
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARPD
SET	
	 ARPD.[dblAmountDue]		= (ISNULL(APB.[dblAmountDue], @ZeroDecimal) * (CASE WHEN APB.[strTransactionType] IN ('Voucher', 'Deferred Interest') THEN -1 ELSE 1 END)) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal))
	,ARPD.[dblBaseAmountDue]	= [dbo].fnRoundBanker(ISNULL((ISNULL(APB.[dblAmountDue], @ZeroDecimal) * (CASE WHEN APB.[strTransactionType] IN ('Voucher', 'Deferred Interest') THEN -1 ELSE 1 END)) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal)), @ZeroDecimal) * ARP.[dblExchangeRate], [dbo].[fnARGetDefaultDecimal]())
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblARPayment ARP
		ON ARPD.[intPaymentId] = ARP.[intPaymentId]
INNER JOIN
	(SELECT
		[intBillId]
		,CASE WHEN [intTransactionType] = 1 THEN 'Voucher'
			  WHEN [intTransactionType] = 2 THEN 'Vendor Prepayment'
			  WHEN [intTransactionType] = 3 THEN 'Debit Memo'
			  WHEN [intTransactionType] = 7 THEN 'Invalid Type'
			  WHEN [intTransactionType] = 9 THEN '1099 Adjustment'
			  WHEN [intTransactionType] = 11 THEN 'Claim'
			  WHEN [intTransactionType] = 13 THEN 'Basis Advance'
			  WHEN [intTransactionType] = 14 THEN 'Deferred Interest'
			  ELSE 'Invalid Type' 
		 END AS [strTransactionType]
		,[dblAmountDue]
	FROM tblAPBill) APB
		ON ARPD.[intBillId] = APB.[intBillId] 
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARP
SET
	 ARP.[dblAmountPaid]		= PD.[dblPaymentTotal]
	,ARP.[dblBaseAmountPaid]	= PD.[dblBasePaymentTotal]
	,ARP.[intCurrentStatus] =  2
FROM tblARPayment ARP
INNER JOIN 
	(SELECT
		 [intPaymentId]			= [intPaymentId]
		,[dblPaymentTotal]		= SUM([dblPayment])
		,[dblBasePaymentTotal]	= SUM([dblBasePayment])
	FROM
		tblARPaymentDetail GROUP BY intPaymentId
	) PD
		ON ARP.[intPaymentId] = PD.[intPaymentId]
WHERE
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARP.[intPaymentId])

UPDATE ARP
SET
	 ARP.[dblUnappliedAmount]		= ARP.[dblAmountPaid] - PD.[dblPaymentTotal]
	,ARP.[dblBaseUnappliedAmount]	= ARP.[dblBaseAmountPaid] - PD.[dblBasePaymentTotal]
	,ARP.[dblOverpayment]			= ARP.[dblAmountPaid] - PD.[dblPaymentTotal]
	,ARP.[dblBaseOverpayment]		= ARP.[dblBaseAmountPaid] - PD.[dblBasePaymentTotal]
	,ARP.[intCurrentStatus] =  2
FROM tblARPayment ARP
INNER JOIN 
	(SELECT
		 [intPaymentId]			= [intPaymentId]
		,[dblPaymentTotal]		= SUM([dblPayment])
		,[dblBasePaymentTotal]	= SUM([dblBasePayment])
	FROM
		tblARPaymentDetail GROUP BY intPaymentId
	) PD
		ON ARP.[intPaymentId] = PD.[intPaymentId]
WHERE
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARP.[intPaymentId])

--UPDATE ARP
--SET
--	 ARP.[dblAmountPaid]			= PD.[dblPaymentTotal]
--	,ARP.[dblBaseAmountPaid]		= PD.[dblBasePaymentTotal]
--	,ARP.[dblUnappliedAmount]		= @ZeroDecimal
--	,ARP.[dblBaseUnappliedAmount]	= @ZeroDecimal
--	,ARP.[dblOverpayment]			= @ZeroDecimal
--	,ARP.[dblBaseOverpayment]		= @ZeroDecimal
--FROM tblARPayment ARP
--INNER JOIN 
--	(SELECT
--		 [intPaymentId]			= [intPaymentId]
--		,[dblPaymentTotal]		= SUM([dblPayment])
--		,[dblBasePaymentTotal]	= SUM([dblBasePayment])
--	FROM
--		tblARPaymentDetail GROUP BY intPaymentId
--	) PD
--		ON ARP.[intPaymentId] = PD.[intPaymentId]
--WHERE
--	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARP.[intPaymentId])

END
