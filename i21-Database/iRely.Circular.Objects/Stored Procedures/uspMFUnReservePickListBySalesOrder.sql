CREATE PROCEDURE [dbo].[uspMFUnReservePickListBySalesOrder]
	@intSalesOrderId int
AS

--Unship SO
If Exists (Select 1 From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)
	Update tblICStockReservation Set ysnPosted=0 
	Where intTransactionId=
	(
		Select pl.intPickListId From tblMFPickList pl Where pl.intSalesOrderId=@intSalesOrderId
	)
	AND intInventoryTransactionType=34
Else --Delete SO
	Update tblICStockReservation Set ysnPosted=1
	Where intTransactionId=
	(
		Select pl.intPickListId From tblMFPickList pl Where pl.intSalesOrderId=@intSalesOrderId
	)
	AND intInventoryTransactionType=34
