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

IF @ForDelete = 1
BEGIN
	DECLARE @ErrorMessage NVARCHAR(250) = NULL
	SELECT TOP 1
		@ErrorMessage = 'Unable to Delete! Line Item - ' + ICI.strItemNo + ' was blended already.'
	FROM
		tblSOSalesOrderDetail SOD
	INNER JOIN
		tblICItem ICI
			ON SOD.intItemId = ICI.intItemId
	WHERE
		ISNULL(SOD.ysnBlended,0) = 1
		
	IF RTRIM(LTRIM(ISNULL(@ErrorMessage,''))) <> ''
		RAISERROR(@ErrorMessage, 16, 1);
END

EXEC dbo.[uspARUpdatePricingHistory] 1, @intSalesOrderId, @intUserId
EXEC dbo.[uspSOUpdateItemComponent] @intSalesOrderId, 0
EXEC dbo.[uspSOUpdateCommitted] @intSalesOrderId, @ysnForDelete
EXEC dbo.[uspSOUpdateItemComponent] @intSalesOrderId, 1
EXEC dbo.[uspSOUpdateContractOnSalesOrder] @intSalesOrderId, @ysnForDelete, @intUserId

DECLARE @Ids AS Id
INSERT INTO @Ids(intId) SELECT @intSalesOrderId
EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @Ids, @TransactionType	= 2

--IF @ysnForDelete = 1 OR @ysnForUnship = 1
--	BEGIN
--		EXEC dbo.[uspMFUnReservePickListBySalesOrder] @intSalesOrderId
--	END
--ELSE IF @ysnForDelete = 0
--	BEGIN
--		EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @SalesOrderId, @intUserId = @UserId
--	END

DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @intSalesOrderId AND [strTransactionType] IN ('Order', 'Quote')

GO