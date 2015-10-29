﻿CREATE PROCEDURE [dbo].[uspARUpdateInvoiceIntegrations] 
	 @InvoiceId		INT = NULL
	,@ForDelete		BIT = 0    
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


IF @ForDelete = 1
	BEGIN
		EXEC dbo.[uspARUpdateSOStatusFromInvoice] @InvoiceId
	END

EXEC dbo.[uspARUpdateCommitted] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateInboundShipmentOnInvoice] @InvoiceId, @ForDelete, @UserId

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = 'Invoice'

GO