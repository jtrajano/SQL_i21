﻿CREATE PROCEDURE [dbo].[uspARUpdateProvisionalOnStandardInvoices]
	 @InvoiceIds	InvoiceId	READONLY  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


DECLARE @Ids AS TABLE(intInvoiceId INT)


INSERT INTO @Ids(intInvoiceId)
SELECT DISTINCT
	[intInvoiceId]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARInvoiceDetail WHERE [intInvoiceId] IN (SELECT [intHeaderId] FROM @InvoiceIds WHERE ISNULL([ysnForDelete],0) = 0)))
	
UNION ALL

SELECT
	[intInvoiceId] 
FROM
	tblARInvoice 
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARTransactionDetail WHERE [intTransactionId] IN (SELECT [intHeaderId] FROM @InvoiceIds WHERE ISNULL([ysnForDelete],0) = 1)))
	
UPDATE
	tblARInvoice
SET
	[ysnProcessed] = 1
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @Ids)
	AND strType = 'Provisional'	

UPDATE
	tblARInvoice
SET
	[ysnProcessed] = 0
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @Ids)
	AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId <> tblARInvoice.intInvoiceId))
	AND strType = 'Provisional'


UPDATE ARI	
SET
	 ARI.[dblProvisionalAmount]		= CASE WHEN ISNULL(PRO.[ysnExcludeFromPayment],0) = 0 THEN PRO.[dblPayment] ELSE PRO.[dblInvoiceTotal] END
	,ARI.[dblBaseProvisionalAmount]	= CASE WHEN ISNULL(PRO.[ysnExcludeFromPayment],0) = 0 THEN PRO.[dblBasePayment] ELSE PRO.[dblBaseInvoiceTotal] END
	,ARI.[strTransactionType]		= CASE WHEN (CASE WHEN ISNULL(PRO.[ysnExcludeFromPayment],0) = 0 THEN PRO.[dblPayment] ELSE PRO.[dblInvoiceTotal] END) > ARI.[dblInvoiceTotal] THEN 'Credit Memo' ELSE ARI.[strTransactionType] END
	,ARI.[ysnExcludeFromPayment]	= PRO.[ysnExcludeFromPayment]
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoice PRO
		ON ARI.[intOriginalInvoiceId] = PRO.[intInvoiceId]
WHERE
	ARI.[intInvoiceId] IN (SELECT [intHeaderId] FROM @InvoiceIds)
		
GO
