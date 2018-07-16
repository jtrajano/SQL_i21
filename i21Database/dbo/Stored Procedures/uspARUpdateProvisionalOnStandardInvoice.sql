CREATE PROCEDURE [dbo].[uspARUpdateProvisionalOnStandardInvoice]  
	 @InvoiceId		INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000	

DECLARE @InvoiceIds AS TABLE(intInvoiceId INT)


INSERT INTO @InvoiceIds(intInvoiceId)
SELECT DISTINCT
	[intInvoiceId]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId))
	
UNION ALL

SELECT
	[intInvoiceId] 
FROM
	tblARInvoice 
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARTransactionDetail WHERE [intTransactionId] = @InvoiceId))
	AND @ForDelete = 1
	
UPDATE
	tblARInvoice
SET
	 [ysnProcessed]	= 1
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
	AND strType = 'Provisional'
	AND @ForDelete = 0

UPDATE
	tblARInvoice
SET
	 [ysnProcessed]	= 0
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
	AND 
		(
		NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId <> tblARInvoice.intInvoiceId))
		OR
		@ForDelete = 1
		)
	
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
		ON ARI.[intOriginalInvoiceId] = PRO.[intInvoiceId] AND PRO.[strType] = 'Provisional'
WHERE
	ARI.[intInvoiceId] = @InvoiceId
	

		
GO