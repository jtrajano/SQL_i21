CREATE PROCEDURE [dbo].[uspICInventoryTransferAfterSave]
	@TransferId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

-- Get snapshot of Inventory Transfer Items before Save
SELECT	intInventoryTransferId = intTransactionId
		,intInventoryTransferDetailId = intTransactionDetailId
		,intItemId
		,intItemUOMId
		,dblQuantity
INTO	#tmpLogTransferItems
FROM	tblICTransactionDetailLog
WHERE	intTransactionId = @TransferId
		AND strTransactionType = 'Inventory Transfer'

-- Get the current snapshot of the Inventory Transfer Items. 
SELECT 
	strTransactionType = 'Inventory Transfer'
	,t.intInventoryTransferId
	,td.intInventoryTransferDetailId
	,td.intItemId 
	,td.intItemUOMId
	,td.dblQuantity
INTO	
	#tmpTransferItems
FROM
	tblICInventoryTransfer t INNER JOIN tblICInventoryTransferDetail td
		ON t.intInventoryTransferId = td.intInventoryTransferId
	INNER JOIN tblICItem i 
		ON i.intItemId = td.intItemId
WHERE	
	t.intInventoryTransferId = @TransferId

-- Do the stock reservation 
BEGIN
	DECLARE @tblForReservation TABLE (
		intInventoryTransferId	INT
	)

	INSERT INTO @tblForReservation(
		intInventoryTransferId
	)
	-- Get Previous snapshots
	SELECT	previousSnapshot.intInventoryTransferId
	FROM	#tmpLogTransferItems previousSnapshot

	-- Get latest snapshots
	UNION ALL 
	SELECT	currentSnapshot.intInventoryTransferId
	FROM	#tmpTransferItems currentSnapshot LEFT JOIN #tmpLogTransferItems previousSnapshot
				ON currentSnapshot.intInventoryTransferId = previousSnapshot.intInventoryTransferId
	WHERE	previousSnapshot.intInventoryTransferId IS NULL 
	
	DECLARE @intInventoryTransferId	INT
	DECLARE loopForStockReservation CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	DISTINCT intInventoryTransferId
	FROM	@tblForReservation

	OPEN loopForStockReservation;

	-- Initial fetch attempt
	FETCH NEXT FROM loopForStockReservation INTO 
		@intInventoryTransferId;

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for the integration sp. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 		
		-- Call the stock reservation sp. 
		EXEC uspICReserveStockForInventoryTransfer @intInventoryTransferId
	
		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopForStockReservation INTO 
			@intInventoryTransferId;	
	END;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------

	CLOSE loopForStockReservation;
	DEALLOCATE loopForStockReservation;
END


DELETE	FROM tblICTransactionDetailLog 
WHERE	strTransactionType = 'Inventory Transfer' 
		AND intTransactionId = @TransferId

OnError_Exit: