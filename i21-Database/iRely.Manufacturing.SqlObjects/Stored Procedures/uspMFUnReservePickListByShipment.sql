CREATE PROCEDURE [dbo].[uspMFUnReservePickListByShipment]
	@intInventoryShipmentId int
AS

Update tblICStockReservation Set ysnPosted=0 
Where intTransactionId IN
(
	Select pl.intPickListId From tblMFPickList pl Join tblSOSalesOrder so on pl.intSalesOrderId=so.intSalesOrderId 
	Join tblICInventoryShipmentItem si on si.intOrderId=so.intSalesOrderId 
	Join tblICInventoryShipment sh on si.intInventoryShipmentId=sh.intInventoryShipmentId
	Where si.intInventoryShipmentId=@intInventoryShipmentId AND sh.intOrderType=2
)
AND intInventoryTransactionType=34