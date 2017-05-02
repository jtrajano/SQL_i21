CREATE PROCEDURE [dbo].[uspLGUpdateLoadShipmentOnInvoicePost]
	@InvoiceId		INT
	,@Post			BIT = 0  
	,@LoadId		INT = NULL   
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF


--IF @LoadId IS NOT NULL
--	BEGIN
--	END
