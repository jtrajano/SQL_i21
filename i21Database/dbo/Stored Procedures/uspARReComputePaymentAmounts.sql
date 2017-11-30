﻿CREATE PROCEDURE [dbo].[uspARReComputePaymentAmounts]
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
						
UPDATE ARPD
SET
	 ARPD.[dblDiscount]					= ISNULL(ARPD.[dblDiscount], @ZeroDecimal)
	,ARPD.[dblBaseDiscount]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblDiscount], @ZeroDecimal) * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblDiscountAvailable]		= ISNULL(ARPD.[dblDiscountAvailable], @ZeroDecimal)
	,ARPD.[dblBaseDiscountAvailable]	= ISNULL(ARPD.[dblBaseDiscountAvailable], @ZeroDecimal)
	,ARPD.[dblInterest]					= ISNULL(ARPD.[dblInterest], @ZeroDecimal)
	,ARPD.[dblBaseInterest]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblInterest], @ZeroDecimal) * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblAmountDue]				= ISNULL(ARPD.[dblAmountDue], @ZeroDecimal)
	,ARPD.[dblBaseAmountDue]			= [dbo].fnRoundBanker(ISNULL(ARPD.[dblAmountDue], @ZeroDecimal) * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
	,ARPD.[dblPayment]					= ISNULL(ARPD.[dblPayment], @ZeroDecimal)
	,ARPD.[dblBasePayment]				= [dbo].fnRoundBanker(ISNULL(ARPD.[dblPayment], @ZeroDecimal) * ARPD.[dblCurrencyExchangeRate], [dbo].[fnARGetDefaultDecimal]())
FROM
	tblARPaymentDetail ARPD
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARPD
SET	
	 ARPD.[dblAmountDue]		= ISNULL(ARI.[dblAmountDue], @ZeroDecimal) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal))
	,ARPD.[dblBaseAmountDue]	= ISNULL(ARI.[dblBaseAmountDue], @ZeroDecimal) + ISNULL(ARPD.[dblBaseInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblBasePayment], @ZeroDecimal) + ISNULL(ARPD.[dblBaseDiscount], @ZeroDecimal))
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblARInvoice ARI
		ON ARPD.[intInvoiceId] = ARI.[intInvoiceId] 
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARPD
SET	
	 ARPD.[dblAmountDue]		= ISNULL(APB.[dblAmountDue], @ZeroDecimal) + ISNULL(ARPD.[dblInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblPayment], @ZeroDecimal) + ISNULL(ARPD.[dblDiscount], @ZeroDecimal))
	,ARPD.[dblBaseAmountDue]	= ISNULL(APB.[dblAmountDue], @ZeroDecimal) + ISNULL(ARPD.[dblBaseInterest], @ZeroDecimal) - (ISNULL(ARPD.[dblBasePayment], @ZeroDecimal) + ISNULL(ARPD.[dblBaseDiscount], @ZeroDecimal))
FROM
	tblARPaymentDetail ARPD
INNER JOIN
	tblAPBill APB
		ON ARPD.[intBillId] = APB.[intBillId] 
WHERE 
	EXISTS(SELECT NULL FROM @PaymentIds WHERE [intHeaderId] = ARPD.[intPaymentId])

UPDATE ARP
SET
	 ARP.[dblAmountPaid]			= PD.[dblPaymentTotal]
	,ARP.[dblBaseAmountPaid]		= PD.[dblBasePaymentTotal]
	,ARP.[dblUnappliedAmount]		= @ZeroDecimal
	,ARP.[dblBaseUnappliedAmount]	= @ZeroDecimal
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

END
