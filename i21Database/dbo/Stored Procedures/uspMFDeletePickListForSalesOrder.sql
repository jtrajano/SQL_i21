CREATE PROCEDURE [dbo].[uspMFDeletePickListForSalesOrder]
	@intSalesOrderId int,
	@intUserId int
AS
Begin Try
Declare @ErrMsg nvarchar(max)
Declare @intPickListId INT

If (Select strOrderStatus From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId) IN ('Closed','Cancelled','Short Closed')
Begin
	RaisError('Pick List cannot be deleted since the Sales Order is closed.',16,1)
End

If Exists (Select 1 From tblICInventoryShipment sh Join tblICInventoryShipmentItem sd on sh.intInventoryShipmentId=sd.intInventoryShipmentId 
	Where sh.intOrderType=2 AND sd.intOrderId=@intSalesOrderId)
	RaisError('Shipment is alredy created for the sales order.',16,1)

Select @intPickListId=intPickListId From tblMFPickList Where intSalesOrderId=@intSalesOrderId

Begin Tran

	Delete From tblMFPickListDetail Where intPickListId=@intPickListId
	Delete From tblMFPickList Where intPickListId=@intPickListId
	
	Exec [uspMFDeleteLotReservationByPickList] @intPickListId

Commit Tran

End Try
	
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH 


