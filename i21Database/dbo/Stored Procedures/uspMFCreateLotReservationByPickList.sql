CREATE PROCEDURE [dbo].[uspMFCreateLotReservationByPickList]
	@intPickListId int,
	@strBulkItemXml nvarchar(max)=''
AS

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=34
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 
DECLARE @intMinWO int
DECLARE @intWorkOrderId int
DECLARE @idoc int 
DECLARE @intLocationId int
DECLARE @strPickListNo NVARCHAR(50)

DECLARE @tblBulkItem AS TABLE
(
	intItemId INT,
	dblQuantity NUMERIC(38,20),
	intItemUOMId INT
)

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

Select @intLocationId=intLocationId,@strPickListNo=strPickListNo From tblMFPickList Where intPickListId=@intPickListId

	--Delete all Reservation against all WorkOrders for the Pick List
	Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder Where intPickListId=@intPickListId

	While(@intMinWO is not null)
	Begin
		Select @intWorkOrderId=intWorkOrderId from tblMFWorkOrder Where intWorkOrderId=@intMinWO

		EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intWorkOrderId
		,8

		Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder where intPickListId=@intPickListId And intWorkOrderId>@intWorkOrderId
	End

	--Delete Reservation against Pick List
	EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intPickListId
		,@intInventoryTransactionType

	--Create Reservation against Pick List
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
	SELECT	intItemId = pld.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = pld.intItemUOMId
			,intLotId = pld.intStageLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = pld.dblQuantity
			,intTransactionId = pld.intPickListId
			,strTransactionId = pl.strPickListNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFPickListDetail pld 
			Join tblMFPickList pl on pld.intPickListId=pl.intPickListId
			JOIN tblICLot l ON l.intLotId = pld.intStageLotId
	WHERE	pld.intPickListId = @intPickListId

	--Non Lot Tracked
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
	SELECT	intItemId = pld.intItemId
			,intItemLocationId = il.intItemLocationId
			,intItemUOMId = pld.intItemUOMId
			,intLotId = NULL
			,intSubLocationId = pld.intSubLocationId
			,intStorageLocationId = pld.intStorageLocationId
			,dblQty = pld.dblQuantity
			,intTransactionId = pld.intPickListId
			,strTransactionId = pl.strPickListNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFPickListDetail pld 
			Join tblMFPickList pl on pld.intPickListId=pl.intPickListId
			JOIN tblICItem i on pld.intItemId=i.intItemId
			JOIN tblICItemLocation il on i.intItemId=il.intItemId AND pld.intLocationId=il.intLocationId
	WHERE	pld.intPickListId = @intPickListId AND ISNULL(pld.intLotId,0)=0

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
			,intLotId = NULL--l.intLotId
			,intSubLocationId = NULL
			,intStorageLocationId = NULL
			,dblQty = bi.dblQuantity
			,intTransactionId = @intPickListId
			,strTransactionId = @strPickListNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM @tblBulkItem bi Join tblICItemLocation il on bi.intItemId=il.intItemId
	Where il.intLocationId=@intLocationId

	-- Validate the reservation 
	--EXEC dbo.uspICValidateStockReserves 
	--	@ItemsToReserve
	--	,@strInvalidItemNo OUTPUT 
	--	,@intInvalidItemId OUTPUT 

	-- If there are enough stocks, let the system create the reservations
	IF (@intInvalidItemId IS NULL)	
	BEGIN 
		EXEC dbo.uspICCreateStockReservation
			@ItemsToReserve
			,@intPickListId
			,@intInventoryTransactionType	
	END 	
