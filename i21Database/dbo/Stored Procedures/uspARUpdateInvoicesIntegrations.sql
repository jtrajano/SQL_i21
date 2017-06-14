CREATE PROCEDURE [dbo].[uspARUpdateInvoicesIntegrations]
	 @InvoiceIds			InvoiceId	READONLY
	,@UserId				INT = NULL 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @IIDs AS InvoiceId


IF EXISTS(SELECT NULL FROM @InvoiceIds WHERE [strSourceTransaction] IN ('Card Fueling Transaction','CF Tran','CF Invoice'))
BEGIN
	DELETE FROM @IIDs
	INSERT INTO @IIDs SELECT * FROM @InvoiceIds WHERE [strSourceTransaction] IN ('Card Fueling Transaction','CF Tran','CF Invoice')
	DELETE FROM ARTD
	FROM
		tblARTransactionDetail ARTD WITH (NOLOCK)
	INNER JOIN
		@IIDs II
				ON ARTD.[intTransactionId] = II.[intHeaderId]
	INNER JOIN
		(SELECT [strTransactionType], [intInvoiceId]  FROM tblARInvoice WITH (NOLOCK)) ARI
			ON II.[intHeaderId] = ARI.[intInvoiceId] 
			AND ARTD .[strTransactionType] = ARI.[strTransactionType] 
END

DELETE FROM @IIDs
INSERT INTO @IIDs SELECT * FROM @InvoiceIds WHERE [strSourceTransaction] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')

IF NOT EXISTS(SELECT TOP 1 NULL FROM @IIDs)
	RETURN 1

EXEC dbo.[uspARUpdateTransactionsPricingHistory] 2, @IIDs, @UserId

EXEC dbo.[uspARUpdateSOStatusFromInvoices] @IIDs

EXEC dbo.[uspARUpdateLineItemsComponent] @IIDs

EXEC dbo.[uspARUpdateLineItemsReservedStock] @IIDs

EXEC dbo.[uspARUpdateLineItemsComponent] @IIDs

--AR-4579
--EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateInboundShipmentOnInvoices] @IIDs

EXEC dbo.[uspARUpdateProvisionalOnStandardInvoices] @IIDs

EXEC dbo.[uspARUpdateLineItemsCommitted] @IIDs

DELETE FROM ARTD
FROM
	tblARTransactionDetail ARTD WITH (NOLOCK)
INNER JOIN
	@IIDs II
			ON ARTD.[intTransactionId] = II.[intHeaderId]
INNER JOIN
	(SELECT [strTransactionType], [intInvoiceId]  FROM tblARInvoice WITH (NOLOCK)) ARI
		ON II.[intHeaderId] = ARI.[intInvoiceId] 
		AND ARTD .[strTransactionType] = ARI.[strTransactionType] 


GO