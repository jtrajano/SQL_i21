CREATE PROCEDURE uspMFItemMove (
	@intItemId INT
	,@intFromSubLocationId int
	,@intToSubLocationId int
	,@intFromStorageLocationId int
	,@intToStorageLocationId int
	,@dblMoveQty numeric(18,6)
	,@intItemUOMId int
	,@intFromLocationId INT
	,@intToLocationId INT
	,@intUserId int
	)
AS
BEGIN
	DECLARE @dtmPlannedDate DATETIME

	SELECT @dtmPlannedDate = CONVERT(DATETIME, CONVERT(CHAR, Getdate(), 101))

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

	DECLARE @TransferEntries AS InventoryTransferStagingTable

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
		[dtmTransferDate] = @dtmPlannedDate
		,[strTransferType] = 'Storage to Storage'
		,[intSourceType] = 0
		,[strDescription] = NULL
		,[intFromLocationId] = @intFromLocationId
		,[intToLocationId] = @intToLocationId
		,[ysnShipmentRequired] = 0
		,[intStatusId] = 3
		,[intShipViaId] = NULL
		,[intFreightUOMId] = NULL
		-- Detail
		,[intItemId] = @intItemId
		,[intLotId] = NULL
		,[intItemUOMId] = @intItemUOMId 
		,[dblQuantityToTransfer] =@dblMoveQty 
		,[strNewLotId] = NULL
		,[intFromSubLocationId] = @intFromSubLocationId
		,[intToSubLocationId] = @intToSubLocationId
		,[intFromStorageLocationId] = @intFromStorageLocationId
		,[intToStorageLocationId] = @intToStorageLocationId
		-- Integration Field
		,[intInventoryTransferId] = NULL
		,[intSourceId] = 0
		,[strSourceId] = NULL
		,[strSourceScreenName] = 'Process Production Consume'

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
	END;
END