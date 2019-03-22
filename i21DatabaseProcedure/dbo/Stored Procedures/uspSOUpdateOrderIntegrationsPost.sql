CREATE PROCEDURE [dbo].[uspSOUpdateOrderIntegrationsPost] 
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

DECLARE @Ids AS Id
INSERT INTO @Ids(intId) SELECT @intSalesOrderId


IF @ysnForDelete = 1 OR @ysnForUnship = 1
	BEGIN
		EXEC dbo.[uspMFUnReservePickListBySalesOrder] @intSalesOrderId
	END
ELSE IF @ysnForDelete = 0
	BEGIN
		EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @SalesOrderId, @intUserId = @UserId
	END

--DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intSalesOrderId AND [strTransactionType] IN ('Order', 'Quote')

GO