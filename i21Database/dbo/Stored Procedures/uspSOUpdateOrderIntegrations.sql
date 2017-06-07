CREATE PROCEDURE [dbo].[uspSOUpdateOrderIntegrations] 
	 @SalesOrderId	INT = NULL
	,@ForDelete		BIT = 0
	,@ForUnship		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF 

EXEC dbo.[uspARUpdatePricingHistory] 1, @SalesOrderId, @UserId
EXEC dbo.[uspSOUpdateItemComponent] @SalesOrderId, 0
EXEC dbo.[uspSOUpdateCommitted] @SalesOrderId, @ForDelete
EXEC dbo.[uspSOUpdateItemComponent] @SalesOrderId, 1
--AR-4579
--EXEC dbo.[uspSOUpdateContractOnSalesOrder] @SalesOrderId, @ForDelete, @UserId

DECLARE @Ids AS Id
INSERT INTO @Ids(intId) SELECT @SalesOrderId
EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @Ids, @TransactionType	= 2

IF @ForDelete = 1 OR @ForUnship = 1
	BEGIN
		EXEC dbo.[uspMFUnReservePickListBySalesOrder] @SalesOrderId
	END

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @SalesOrderId AND [strTransactionType] IN ('Order', 'Quote')

GO