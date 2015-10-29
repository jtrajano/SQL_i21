CREATE PROCEDURE [dbo].[uspARUpdateInboundShipmentOnInvoice]  
	 @InvoiceId		INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  



GO
