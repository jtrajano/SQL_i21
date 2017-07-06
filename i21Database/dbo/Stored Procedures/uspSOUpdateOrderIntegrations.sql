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

DECLARE @intSalesOrderId INT
	  , @intUserId		 INT
	  , @ysnForDelete    BIT
	  , @ysnForUnship    BIT	  

SET @intSalesOrderId = @SalesOrderId
SET @intUserId = @UserId
SET @ysnForDelete = @ForDelete
SET @ysnForUnship = @ForUnship

EXEC dbo.[uspARUpdatePricingHistory] 1, @intSalesOrderId, @intUserId
EXEC dbo.[uspSOUpdateItemComponent] @intSalesOrderId, 0
EXEC dbo.[uspSOUpdateCommitted] @intSalesOrderId, @ysnForDelete
EXEC dbo.[uspSOUpdateItemComponent] @intSalesOrderId, 1

DECLARE @Ids AS Id
INSERT INTO @Ids(intId) SELECT @intSalesOrderId
EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @Ids, @TransactionType	= 2

IF @ysnForDelete = 1 OR @ysnForUnship = 1
	BEGIN
		EXEC dbo.[uspMFUnReservePickListBySalesOrder] @intSalesOrderId
	END

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intSalesOrderId AND [strTransactionType] IN ('Order', 'Quote')

GO