CREATE PROCEDURE [dbo].[uspMFKitItemMove]
	@intPickListDetailId int,
	@intToStorageLocationId int,
	@intUserId int
AS

DECLARE @TransferEntries AS InventoryTransferStagingTable
DECLARE @dtmDate DATETIME=GETDATE()
DECLARE @intLocationId int
DECLARE	@intFromSubLocationId int
DECLARE @intToSubLocationId int
DECLARE @intFromStorageLocationId int
DECLARE @dblQuantity NUMERIC(38,20)
DECLARE @intItemId int
DECLARE @intItemUOMId int
DECLARE @strPickListNo nvarchar(50)

Select @strPickListNo=pl.strPickListNo,@intLocationId=pl.intLocationId,@intFromSubLocationId=pld.intSubLocationId,@intFromStorageLocationId=pld.intStorageLocationId,
@intItemId=pld.intItemId,@intItemUOMId=pld.intItemUOMId,@dblQuantity=pld.dblQuantity 
From tblMFPickListDetail pld Join tblMFPickList pl on pld.intPickListId=pl.intPickListId Where pld.intPickListDetailId=@intPickListDetailId

Select @intToSubLocationId=intSubLocationId 
From tblICStorageLocation Where intStorageLocationId=@intToStorageLocationId

IF NOT EXISTS (
		SELECT 1
		FROM tempdb..sysobjects
		WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult')
		)
BEGIN
	CREATE TABLE #tmpAddInventoryTransferResult (
		intSourceId INT
		,intInventoryTransferId INT
		)
END

-- Insert the data needed to create the inventory transfer.
INSERT INTO @TransferEntries (
	-- Header
	[dtmTransferDate]
	,[strTransferType]
	,[intSourceType]
	,[strDescription]
	,[intFromLocationId]
	,[intToLocationId]
	,[ysnShipmentRequired]
	,[intStatusId]
	,[intShipViaId]
	,[intFreightUOMId]
	-- Detail
	,[intItemId]
	,[intLotId]
	,[intItemUOMId]
	,[dblQuantityToTransfer]
	,[strNewLotId]
	,[intFromSubLocationId]
	,[intToSubLocationId]
	,[intFromStorageLocationId]
	,[intToStorageLocationId]
	-- Integration Field
	,[intInventoryTransferId]
	,[intSourceId]
	,[strSourceId]
	,[strSourceScreenName]
	)
SELECT -- Header
	[dtmTransferDate] = @dtmDate
	,[strTransferType] = 'Storage to Storage'
	,[intSourceType] = 0
	,[strDescription] = NULL
	,[intFromLocationId] = @intLocationId
	,[intToLocationId] = @intLocationId
	,[ysnShipmentRequired] = 0
	,[intStatusId] = 3
	,[intShipViaId] = NULL
	,[intFreightUOMId] = NULL
	-- Detail
	,[intItemId] = @intItemId
	,[intLotId] = NULL
	,[intItemUOMId] = @intItemUOMId
	,[dblQuantityToTransfer] = @dblQuantity
	,[strNewLotId] = NULL
	,[intFromSubLocationId] = @intFromSubLocationId
	,[intToSubLocationId] = @intToSubLocationId
	,[intFromStorageLocationId] = @intFromStorageLocationId
	,[intToStorageLocationId] = @intToStorageLocationId
	-- Integration Field
	,[intInventoryTransferId] = NULL
	,[intSourceId] = @intPickListDetailId
	,[strSourceId] = @strPickListNo
	,[strSourceScreenName] = 'Kit Pick List'

-- Call uspICAddInventoryTransfer stored procedure.
EXEC dbo.uspICAddInventoryTransfer @TransferEntries
	,@intUserId

-- Post the Inventory Transfers                                            
DECLARE @intTransferId INT
	,@strTransactionId NVARCHAR(50);

WHILE EXISTS (
		SELECT TOP 1 1
		FROM #tmpAddInventoryTransferResult
		)
BEGIN
	SELECT @intTransferId = NULL
		,@strTransactionId = NULL

	SELECT TOP 1 @intTransferId = intInventoryTransferId
	FROM #tmpAddInventoryTransferResult

	-- Post the Inventory Transfer that was created
	SELECT @strTransactionId = strTransferNo
	FROM tblICInventoryTransfer
	WHERE intInventoryTransferId = @intTransferId

	EXEC dbo.uspICPostInventoryTransfer 1
		,0
		,@strTransactionId
		,@intUserId;

	DELETE
	FROM #tmpAddInventoryTransferResult
	WHERE intInventoryTransferId = @intTransferId
END
