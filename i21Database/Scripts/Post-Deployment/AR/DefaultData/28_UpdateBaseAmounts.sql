print('/*******************  BEGIN Update Base Amounts for Mulit-Currency  *******************/')
GO

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

--Invoice

DECLARE @Ids AS TABLE(intInvoiceId INT, intInvoiceDetailId INT)
INSERT INTO @Ids(intInvoiceId, intInvoiceDetailId)
SELECT intInvoiceId, intInvoiceDetailId FROM tblARInvoiceDetail WHERE ISNULL(dblCurrencyExchangeRate, 1) = 1 AND (ISNULL(dblBaseTotal,@ZeroDecimal) <> dblTotal OR ISNULL([dblBaseMaintenanceAmount],@ZeroDecimal) <> [dblMaintenanceAmount] OR ISNULL([dblBaseLicenseAmount],@ZeroDecimal) <> [dblBaseLicenseAmount])

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
	AND ARIDT.dblAdjustedTax <> ISNULL(ARIDT.dblBaseAdjustedTax,0)

UNION ALL

SELECT ARI.intInvoiceId, NULL
FROM
	tblARInvoice ARI
WHERE
	NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID WHERE ARID.intInvoiceId = ARI.intInvoiceId AND ISNULL(ARID.dblCurrencyExchangeRate, 1) <> 1)
	AND (
			ISNULL(ARI.dblAmountDue, @ZeroDecimal) <> ISNULL(ARI.dblBaseAmountDue, @ZeroDecimal)
		OR
			ISNULL(ARI.dblDiscount, @ZeroDecimal) <> ISNULL(ARI.dblBaseDiscount, @ZeroDecimal)
		OR
			ISNULL(ARI.dblInterest, @ZeroDecimal) <> ISNULL(ARI.dblBaseInterest, @ZeroDecimal)
		OR
			ISNULL(ARI.dblInvoiceSubtotal, @ZeroDecimal) <> ISNULL(ARI.dblBaseInvoiceSubtotal, @ZeroDecimal)
		OR
			ISNULL(ARI.dblPayment, @ZeroDecimal) <> ISNULL(ARI.dblBasePayment, @ZeroDecimal)
		OR
			ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) <> ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal)
		OR
			ISNULL(ARI.dblShipping, @ZeroDecimal) <> ISNULL(ARI.dblBaseShipping, @ZeroDecimal)
		OR
			ISNULL(ARI.dblTax, @ZeroDecimal) <> ISNULL(ARI.dblBaseTax, @ZeroDecimal)
		)
	


UPDATE
	tblARInvoiceDetailTax
SET
	[dblBaseAdjustedTax] = [dblAdjustedTax]
WHERE
	[intInvoiceDetailId] IN (SELECT DISTINCT [intInvoiceDetailId] FROM @Ids)
	
UPDATE
	tblARInvoiceDetail
SET
	 [dblBasePrice]				= [dblPrice]
	,[dblBaseTotalTax]			= [dblTotalTax]
	,[dblBaseTotal]				= [dblTotal]
	,[dblBaseMaintenanceAmount]	= [dblMaintenanceAmount]
	,[dblBaseLicenseAmount]		= [dblBaseLicenseAmount]
WHERE
	[intInvoiceDetailId] IN (SELECT DISTINCT [intInvoiceDetailId] FROM @Ids)
	
	
UPDATE
	tblARInvoice
SET
	 [dblBaseDiscount]			= [dblDiscount]
	,[dblInterest]				= [dblInterest]
	,[dblPayment]				= [dblBasePayment]
	,[dblShipping]				= [dblBaseShipping]
	,[dblBaseTax]				= [dblTax]
	,[dblBaseInvoiceSubtotal]	= [dblInvoiceSubtotal]
	,[dblBasePayment]			= [dblPayment]
	,[dblBaseAmountDue]			= [dblAmountDue]
	,[dblBaseInvoiceTotal]		= [dblInvoiceTotal]
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


--Sales Order

DECLARE @SOIds AS TABLE(intSalesOrderId INT, intSalesOrderDetailId INT)
INSERT INTO @SOIds(intSalesOrderId, intSalesOrderDetailId)
SELECT intSalesOrderId, intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE ISNULL(dblCurrencyExchangeRate, 1) = 1 AND (ISNULL(dblBaseTotal,@ZeroDecimal) <> dblTotal OR ISNULL([dblBaseMaintenanceAmount],@ZeroDecimal) <> [dblMaintenanceAmount] OR ISNULL([dblBaseLicenseAmount],@ZeroDecimal) <> [dblBaseLicenseAmount])

UNION ALL

SELECT SO.intSalesOrderId, SOD.intSalesOrderDetailId
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.intSalesOrderId = SOD.intSalesOrderId
INNER JOIN
	tblSOSalesOrderDetailTax SODT
		ON SOD.intSalesOrderDetailId = SODT.intSalesOrderDetailId
WHERE
	ISNULL(SOD.dblCurrencyExchangeRate, 1) = 1
	AND SODT.dblAdjustedTax <> ISNULL(SODT.dblBaseAdjustedTax, @ZeroDecimal)


UNION ALL

SELECT SO.intSalesOrderId, NULL
FROM
	tblSOSalesOrder SO
WHERE
	NOT EXISTS(SELECT NULL FROM tblSOSalesOrderDetail SOD WHERE SOD.intSalesOrderId = SO.intSalesOrderId AND ISNULL(SOD.dblCurrencyExchangeRate, 1) <> 1)
	AND (
			ISNULL(SO.dblAmountDue, @ZeroDecimal) <> ISNULL(SO.dblBaseAmountDue, @ZeroDecimal)
		OR
			ISNULL(SO.dblDiscount, @ZeroDecimal) <> ISNULL(SO.dblBaseDiscount, @ZeroDecimal)
		OR
			ISNULL(SO.dblSalesOrderSubtotal, @ZeroDecimal) <> ISNULL(SO.dblBaseSalesOrderSubtotal, @ZeroDecimal)
		OR
			ISNULL(SO.dblPayment, @ZeroDecimal) <> ISNULL(SO.dblBasePayment, @ZeroDecimal)
		OR
			ISNULL(SO.dblSalesOrderTotal, @ZeroDecimal) <> ISNULL(SO.dblBaseSalesOrderTotal, @ZeroDecimal)
		OR
			ISNULL(SO.dblShipping, @ZeroDecimal) <> ISNULL(SO.dblBaseShipping, @ZeroDecimal)
		OR
			ISNULL(SO.dblTax, @ZeroDecimal) <> ISNULL(SO.dblBaseTax, @ZeroDecimal)
		)


UPDATE
	tblSOSalesOrderDetailTax
SET
	[dblBaseAdjustedTax] = [dblAdjustedTax]
WHERE
	[intSalesOrderDetailId] IN (SELECT DISTINCT [intSalesOrderDetailId] FROM @SOIds)
	
UPDATE
	tblSOSalesOrderDetail
SET
	 [dblBasePrice]				= [dblPrice]
	,[dblBaseTotalTax]			= [dblTotalTax]
	,[dblBaseTotal]				= [dblTotal]
	,[dblBaseMaintenanceAmount]	= [dblMaintenanceAmount]
	,[dblBaseLicenseAmount]		= [dblBaseLicenseAmount]
WHERE
	[intSalesOrderDetailId] IN (SELECT DISTINCT [intSalesOrderDetailId] FROM @SOIds)


UPDATE
	tblSOSalesOrder
SET
	 [dblBaseDiscount]				= [dblDiscount]
	,[dblPayment]					= [dblBasePayment]
	,[dblShipping]					= [dblBaseShipping]
	,[dblBaseTax]					= [dblTax]
	,[dblBaseSalesOrderSubtotal]	= [dblSalesOrderSubtotal]
	,[dblBasePayment]				= [dblPayment]
	,[dblBaseAmountDue]				= [dblAmountDue]
	,[dblBaseSalesOrderTotal]		= [dblSalesOrderTotal]
WHERE
	[intSalesOrderId] IN (SELECT DISTINCT [intSalesOrderId] FROM @SOIds)
			
GO
print('/*******************  END Update Update Base Amounts for Mulit-Currency  *******************/')