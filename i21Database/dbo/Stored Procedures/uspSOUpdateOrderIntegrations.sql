﻿CREATE PROCEDURE [dbo].[uspSOUpdateOrderIntegrations] 
	 @SalesOrderId	INT = NULL
	,@ForDelete		BIT = 0    
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


EXEC dbo.[uspSOUpdateCommitted] @SalesOrderId, @ForDelete
EXEC dbo.[uspSOUpdateContractOnSalesOrder] @SalesOrderId, @ForDelete, @UserId

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @SalesOrderId AND [strTransactionType] = 'Order'

GO