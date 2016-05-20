CREATE PROCEDURE [dbo].[uspMFCreateShipmentFromSalesOrderPickList]
	@intSalesOrderId int,
	@intUserId int,
	@intInventoryShipmentId int=0 OUT
AS
	
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ErrMsg nvarchar(max)
Declare @intMinPickListDetail INT
Declare @intPickListId INT
Declare @intLotId INT
Declare @dblShipQty NUMERIC(38,20)
Declare @intInventoryShipmentItemId INT
Declare @intItemId INT

	Select TOP 1 @intPickListId=intPickListId From tblMFPickList Where intSalesOrderId=@intSalesOrderId
	
	If ISNULL(@intPickListId,0)=0
		RaisError('Please save the pick list before shipping.',16,1)

	If Exists (Select 1 From tblICInventoryShipment sh Join tblICInventoryShipmentItem sd on sh.intInventoryShipmentId=sd.intInventoryShipmentId 
		Where sh.intOrderType=2 AND sd.intOrderId=@intSalesOrderId)
		RaisError('Shipmnet is alredy created for the sales order.',16,1)

Begin Tran
	--Create Shipment Header and Line	
	Exec uspICAddSalesOrderToInventoryShipment @intSalesOrderId,@intUserId,@intInventoryShipmentId OUT

	Select @intMinPickListDetail=MIN(intPickListDetailId) From tblMFPickListDetail Where intPickListId=@intPickListId AND ISNULL(intLotId,0)>0

	--Add Shipment Lot
	While @intMinPickListDetail is not null
	Begin
		Select @intLotId=intLotId,@dblShipQty=dblPickQuantity,@intItemId=intItemId From tblMFPickListDetail Where intPickListDetailId=@intMinPickListDetail

		Select TOP 1 @intInventoryShipmentItemId=intInventoryShipmentItemId From tblICInventoryShipmentItem Where intItemId=@intItemId

		INSERT INTO tblICInventoryShipmentItemLot(intInventoryShipmentItemId, intLotId, dblQuantityShipped, dblGrossWeight, dblTareWeight)
		VALUES (@intInventoryShipmentItemId, @intLotId, @dblShipQty, 0, 0)

		Select @intMinPickListDetail=MIN(intPickListDetailId) From tblMFPickListDetail Where intPickListId=@intPickListId AND ISNULL(intLotId,0)>0 
		AND intPickListDetailId>@intMinPickListDetail
	End

	--Remove reservation against pick list
	UPDATE	tblICStockReservation SET ysnPosted = 1 WHERE intTransactionId = @intPickListId AND intInventoryTransactionType = 34

	--Reserve against shipment
	EXEC uspICReserveStockForInventoryShipment @intInventoryShipmentId
Commit Tran

End Try
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
