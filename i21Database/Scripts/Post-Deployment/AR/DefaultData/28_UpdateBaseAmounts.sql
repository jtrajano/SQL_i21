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
	 [dblBaseTax]					= T.[dblBaseTotalTax]
	,[dblBaseSalesOrderSubtotal]	= T.[dblBaseTotal]
	,[dblBasePayment]				= [dblPayment]
FROM
	(
		SELECT 
			 SUM([dblBaseTotalTax])	AS [dblBaseTotalTax]
			,SUM([dblBaseTotal])	AS [dblBaseTotal]
			,[intSalesOrderId]
		FROM
			tblSOSalesOrderDetail
		GROUP BY
			[intSalesOrderId]
	)
	 T
WHERE
	tblSOSalesOrder.[intSalesOrderId] = T.[intSalesOrderId]
	AND tblSOSalesOrder.[intSalesOrderId] IN (SELECT DISTINCT [intSalesOrderId] FROM @SOIds)
	

UPDATE
	tblSOSalesOrder
SET
	 [dblBaseSalesOrderTotal]	= ([dblBaseSalesOrderSubtotal] + [dblBaseTax] + [dblBaseShipping])
	,[dblBaseAmountDue]			= ([dblBaseSalesOrderSubtotal] + [dblBaseTax] + [dblBaseShipping]) - ([dblBasePayment] + [dblBaseDiscount])
WHERE
	[intSalesOrderId] IN (SELECT DISTINCT [intSalesOrderId] FROM @SOIds)	
	


GO
print('/*******************  END Update Update Base Amounts for Mulit-Currency  *******************/')