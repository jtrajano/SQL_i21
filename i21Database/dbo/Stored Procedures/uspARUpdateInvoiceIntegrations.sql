CREATE PROCEDURE [dbo].[uspARUpdateInvoiceIntegrations] 
	 @InvoiceId	INT = NULL
	,@ForDelete		BIT = 0    
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


EXEC dbo.[uspARUpdateSOStatusFromInvoice] @InvoiceId
EXEC dbo.[uspARUpdateCommitted] @InvoiceId, @ForDelete, @UserId
EXEC dbo.[uspARUpdateContractOnInvoice] @InvoiceId, @ForDelete, @UserId

GO