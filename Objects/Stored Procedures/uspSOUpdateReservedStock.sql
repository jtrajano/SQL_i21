CREATE PROCEDURE [dbo].[uspSOUpdateReservedStock]
	 @intSalesOrderId		INT
	,@ysnNegate				BIT	= 0
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intTransactionTypeId AS INT
DECLARE @intPickListId		  AS INT

SELECT TOP 1 @intTransactionTypeId = intTransactionTypeId 
FROM tblICInventoryTransactionType 
WHERE strName = 'Pick List'

SELECT TOP 1 @intPickListId = intPickListId
FROM tblMFPickList PL
INNER JOIN tblSOSalesOrder SO ON PL.intSalesOrderId = SO.intSalesOrderId 
							 AND PL.strWorkOrderNo = SO.strSalesOrderNumber 
WHERE SO.intSalesOrderId = @intSalesOrderId

IF ISNULL(@intPickListId, 0) <> 0
	BEGIN
		EXEC dbo.uspICPostStockReservation @intTransactionId		= @intPickListId
									     , @intTransactionTypeId	= @intTransactionTypeId
										 , @ysnPosted				= @ysnNegate
	END
END

GO