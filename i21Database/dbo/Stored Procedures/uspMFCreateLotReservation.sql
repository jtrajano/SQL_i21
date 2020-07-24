CREATE PROCEDURE [dbo].[uspMFCreateLotReservation]
	@intWorkOrderId int,
	@ysnReservationByParentLot bit=0,
	@strBulkItemXml nvarchar(max)=''
AS

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=8
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 
DECLARE @intLocationId INT
DECLARE @idoc int 
DECLARE @strWorkOrderNo NVARCHAR(50)

DECLARE @tblBulkItem AS TABLE
(
	intItemId INT,
	dblQuantity NUMERIC(38,20),
	intItemUOMId INT
)

Select @intLocationId=intLocationId,@strWorkOrderNo=strWorkOrderNo From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

If ISNULL(@strBulkItemXml,'')<>''
Begin
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strBulkItemXml 

	INSERT INTO @tblBulkItem (
	intItemId
	,dblQuantity
	,intItemUOMId
	)
	Select intItemId,dblQuantity,intItemUOMId
	FROM OPENXML(@idoc, 'root/lot', 2)  
	WITH ( 
	intItemId int, 
	dblQuantity numeric(38,20),
	intItemUOMId int
	) 

	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
End

If @ysnReservationByParentLot=0
Begin
If (Select COUNT(1) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)>0
Begin
	INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	intItemId = wcl.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFWorkOrderConsumedLot wcl
			JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
			JOIN tblICLot l ON l.intLotId = wcl.intLotId
	WHERE	wcl.intWorkOrderId = @intWorkOrderId

	--Non Lot Tracked Item
	INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	intItemId = wcl.intItemId
			,intItemLocationId = (Select TOP 1 intItemLocationId From tblICItemLocation Where intItemId=wcl.intItemId AND intLocationId=@intLocationId)
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = wcl.intSubLocationId
			,intStorageLocationId = wcl.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFWorkOrderConsumedLot wcl
			JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
	WHERE	wcl.intWorkOrderId = @intWorkOrderId AND ISNULL(wcl.intLotId,0)=0
End
Else
	INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	intItemId = wcl.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFWorkOrderInputLot wcl
			JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
			JOIN tblICLot l ON l.intLotId = wcl.intLotId
	WHERE	wcl.intWorkOrderId = @intWorkOrderId
End
Else
Begin
	INSERT INTO tblICStockReservation(intItemId,intLocationId,intItemLocationId,intItemUOMId,intParentLotId,intStorageLocationId,
				dblQty,intTransactionId,strTransactionId,intInventoryTransactionType)
	SELECT	intItemId = wcl.intItemId
			,@intLocationId AS intLocationId
			,intItemLocationId = il.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intParentLotId = wcl.intParentLotId
			,intStorageLocationId = wcl.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFWorkOrderInputParentLot wcl
			JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
			JOIN tblICItemLocation il on wcl.intItemId=il.intItemId And il.intLocationId=@intLocationId
	WHERE	wcl.intWorkOrderId = @intWorkOrderId
End

--Insert Bulk Items if any
	INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	intItemId = bi.intItemId
			,intItemLocationId = il.intItemLocationId
			,intItemUOMId = bi.intItemUOMId
			,intLotId = NULL
			,intSubLocationId = NULL
			,intStorageLocationId = NULL
			,dblQty = bi.dblQuantity
			,intTransactionId = @intWorkOrderId
			,strTransactionId = @strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM @tblBulkItem bi Join tblICItemLocation il on bi.intItemId=il.intItemId
	Where il.intLocationId=@intLocationId

	-- Validate the reservation 
	--EXEC dbo.uspICValidateStockReserves 
	--	@ItemsToReserve
	--	,@strInvalidItemNo OUTPUT 
	--	,@intInvalidItemId OUTPUT 

	-- If there are enough stocks, let the system create the reservations
	IF Exists(Select *from @ItemsToReserve)
	BEGIN 
		EXEC dbo.uspICCreateStockReservation
			@ItemsToReserve
			,@intWorkOrderId
			,@intInventoryTransactionType	
	END 

	
