CREATE PROCEDURE [dbo].[uspMFUnReservePickListBySalesOrder]
	@intSalesOrderId int
AS

Update tblICStockReservation Set ysnPosted=0 
Where intTransactionId=
(
	Select pl.intPickListId From tblMFPickList pl Where pl.intSalesOrderId=@intSalesOrderId
)
AND intInventoryTransactionType=34