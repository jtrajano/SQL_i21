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
Declare @intMinSalesOrderItem INT
Declare @dblReqQty NUMERIC(38,20)
Declare @strItemNo nvarchar(50)
Declare @dblSelQty NUMERIC(38,20)
Declare @strUOM nvarchar(50)
Declare @intItemUOMId int

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId int
	,strLotTracking nvarchar(50)
	)

	Select TOP 1 @intPickListId=intPickListId From tblMFPickList Where intSalesOrderId=@intSalesOrderId
	
	If ISNULL(@intPickListId,0)=0
		RaisError('Please save the pick list before shipping.',16,1)

	If Exists (Select 1 From tblICInventoryShipment sh Join tblICInventoryShipmentItem sd on sh.intInventoryShipmentId=sd.intInventoryShipmentId 
		Where sh.intOrderType=2 AND sd.intOrderId=@intSalesOrderId)
		RaisError('Shipment is alredy created for the sales order.',16,1)

	If (Select ISNULL(strBOLNumber,'') From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)=''
		RaisError('Please enter BOL number in Sales Order before shipping.',16,1)

	If (Select ISNULL(intFreightTermId,0) From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)=0
		RaisError('Please enter freight term in Sales Order before shipping.',16,1)

Insert Into @tblInputItem(intItemId,dblQty,intItemUOMId)
Select sd.intItemId,SUM(sd.dblQtyOrdered),sd.intItemUOMId From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId 
Where intSalesOrderId=@intSalesOrderId Group By sd.intItemId,sd.intItemUOMId

Select @intMinSalesOrderItem=MIN(intRowNo) From @tblInputItem

While @intMinSalesOrderItem is not null
Begin
	Select @intItemId=intItemId,@dblReqQty=dblQty,@intItemUOMId=intItemUOMId From @tblInputItem Where intRowNo=@intMinSalesOrderItem
	Select @strItemNo=strItemNo From tblICItem Where intItemId=@intItemId

	If NOT Exists(Select 1 From tblMFPickListDetail Where intPickListId=@intPickListId AND intItemId=@intItemId)
	Begin
		Set @ErrMsg='Item ' + @strItemNo + ' is not selected in the pick list.'
		RaisError(@ErrMsg,16,1)
	End

	Select @dblSelQty=SUM(dblQuantity) From tblMFPickListDetail Where intPickListId=@intPickListId AND intItemId=@intItemId
	Select @strUOM=um.strUnitMeasure From tblICUnitMeasure um Join tblICItemUOM iu on um.intUnitMeasureId=iu.intUnitMeasureId 
	Where iu.intItemUOMId = @intItemUOMId

	If @dblSelQty < @dblReqQty
	Begin
		Set @ErrMsg='Item ' + @strItemNo + ' is required ' + dbo.fnRemoveTrailingZeroes(@dblReqQty) + ' ' + @strUOM + ' but selected ' + dbo.fnRemoveTrailingZeroes(@dblSelQty) + ' ' + @strUOM + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select @intMinSalesOrderItem=MIN(intRowNo) From @tblInputItem Where intRowNo>@intMinSalesOrderItem
End

Begin Tran
	--Create Shipment Header and Line	
	Exec uspSOProcessToItemShipment @intSalesOrderId,@intUserId,0,@intInventoryShipmentId OUT

	Select @intMinPickListDetail=MIN(intPickListDetailId) From tblMFPickListDetail Where intPickListId=@intPickListId AND ISNULL(intLotId,0)>0

	--Add Shipment Lot
	While @intMinPickListDetail is not null
	Begin
		Select @intLotId=intLotId,@dblShipQty=dblPickQuantity,@intItemId=intItemId From tblMFPickListDetail Where intPickListDetailId=@intMinPickListDetail

		Select TOP 1 @intInventoryShipmentItemId=intInventoryShipmentItemId From tblICInventoryShipmentItem Where intInventoryShipmentId=@intInventoryShipmentId AND intItemId=@intItemId

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
