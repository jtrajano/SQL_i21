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

DECLARE @ysnExcludeFromPayment BIT = 0
DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000	

DECLARE @InvoiceIds AS TABLE(intInvoiceId INT)

SELECT TOP 1 @ysnExcludeFromPayment = ysnExcludePaymentInFinalInvoice
FROM dbo.tblARCompanyPreference WITH(NOLOCK)

INSERT INTO @InvoiceIds(intInvoiceId)
SELECT DISTINCT [intInvoiceId]
FROM tblARInvoice
WHERE [intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARInvoiceDetail WHERE [intInvoiceId] = @InvoiceId))
	
UNION ALL

SELECT [intInvoiceId] 
FROM tblARInvoice 
WHERE [intInvoiceId] IN (SELECT [intInvoiceId] FROM tblARInvoiceDetail WHERE [intInvoiceDetailId] IN (SELECT intOriginalInvoiceDetailId FROM tblARTransactionDetail WHERE [intTransactionId] = @InvoiceId))
  AND @ForDelete = 1
	
UPDATE tblARInvoice
SET [ysnProcessed]	= 1
	, dblAmountDue = CASE WHEN ISNULL(@ysnExcludeFromPayment, 0) = 0 THEN 0 ELSE dblAmountDue END 
	, dblBaseAmountDue = CASE WHEN ISNULL(@ysnExcludeFromPayment, 0) = 0 THEN 0 ELSE dblBaseAmountDue END 
WHERE [intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
  AND strType = 'Provisional'
  AND @ForDelete = 0

UPDATE tblARInvoice
SET [ysnProcessed]	= 0
	, dblAmountDue = CASE WHEN ISNULL(@ysnExcludeFromPayment, 0) = 0 THEN dblInvoiceTotal - dblPayment ELSE dblAmountDue END
	, dblBaseAmountDue = CASE WHEN ISNULL(@ysnExcludeFromPayment, 0) = 0 THEN dblBaseInvoiceTotal - dblBasePayment ELSE dblBaseAmountDue END 
WHERE [intInvoiceId] IN (SELECT [intInvoiceId] FROM @InvoiceIds)
  AND strType = 'Provisional'
  AND (
	NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intOriginalInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId <> tblARInvoice.intInvoiceId))
	OR
	@ForDelete = 1
  )
	
UPDATE ARI	
SET ARI.[dblProvisionalAmount]		= PRO.[dblInvoiceTotal]
  , ARI.[dblBaseProvisionalAmount]	= PRO.[dblBaseInvoiceTotal]
  , ARI.[ysnExcludeFromPayment]		= ISNULL(@ysnExcludeFromPayment, 0)
  , ARI.[ysnProvisionalWithGL]     	= PRO.[ysnProvisionalWithGL]
FROM tblARInvoice ARI
INNER JOIN tblARInvoice PRO ON ARI.[intOriginalInvoiceId] = PRO.[intInvoiceId] AND PRO.[strType] = 'Provisional'
WHERE ARI.[intInvoiceId] = @InvoiceId
	

		
GO