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
	[ysnProcessed] = 1
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
	AND strType = 'Provisional'	

UPDATE
	tblARInvoice
SET
	[ysnProcessed] = 0
WHERE
	[intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
	AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId <> tblARInvoice.intInvoiceId))
	AND strType = 'Provisional'
		
GO