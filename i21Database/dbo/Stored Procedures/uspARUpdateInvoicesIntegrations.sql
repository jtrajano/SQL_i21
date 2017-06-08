CREATE PROCEDURE [dbo].[uspARUpdateInvoicesIntegrations]
	@InvoiceIds		InvoiceId	READONLY
	,@UserId		INT = NULL 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--DECLARE @Ids AS Id -- a call in uspARPostInvoice will suffice
--INSERT INTO @Ids(intId) SELECT @InvoiceId
--EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @Ids, @TransactionType	= 1

DECLARE @Ids InvoiceId
DELETE FROM @Ids
INSERT INTO @Ids
SELECT * FROM @InvoiceIds

EXEC dbo.[uspARUpdateTransactionsPricingHistory] 2, @Ids, @UserId

EXEC dbo.[uspARUpdateSOStatusFromInvoices] @Ids

UPDATE @Ids SET [ysnForDelete] = 0 

EXEC dbo.[uspARUpdateLineItemsComponent] @Ids

DELETE FROM @Ids
INSERT INTO @Ids
SELECT * FROM @InvoiceIds

--- commented Temporarily --- for testing
--UPDATE @Ids SET [ysnPost] = 0
--EXEC dbo.[uspARUpdateLineItemsReservedStock] @Ids

UPDATE @Ids SET [ysnForDelete] = 1
EXEC dbo.[uspARUpdateLineItemsComponent] @Ids

--AR-4579
--EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId
DELETE FROM @Ids
INSERT INTO @Ids
SELECT * FROM @InvoiceIds

EXEC dbo.[uspARUpdateInboundShipmentOnInvoices] @Ids

EXEC dbo.[uspARUpdateProvisionalOnStandardInvoices] @Ids

--- commented Temporarily --- for testing
--UPDATE @Ids SET [ysnFromPosting] = 0
--EXEC dbo.[uspARUpdateLineItemsCommitted] @Ids

DELETE FROM ARTD
FROM
	tblARTransactionDetail ARTD WITH (NOLOCK)
INNER JOIN
	@InvoiceIds II
		 ON ARTD.[intTransactionId] = II.[intHeaderId]
INNER JOIN
	(SELECT [strTransactionType], [intInvoiceId]  FROM tblARInvoice WITH (NOLOCK)) ARI
		ON II.[intHeaderId] = ARI.[intInvoiceId] 
		AND ARTD .[strTransactionType] = ARI.[strTransactionType] 


GO