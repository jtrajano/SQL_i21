CREATE FUNCTION [dbo].[fnICGetPreviousTransactionDate](
	@intItemId AS INT,
	@intItemLocationId AS INT,
	@intSubLocationId AS INT,
	@intStorageLocationId AS INT,
	@intTransactionTypeId AS INT
)
RETURNS DATETIME 
AS
BEGIN 

	DECLARE @dtmPreviousDate AS DATETIME;

	DECLARE @TransactionType_InventoryReceipt AS INT,
			@TransactionType_Invoice AS INT;
	
	SELECT	TOP 1 @TransactionType_InventoryReceipt = intTransactionTypeId
	FROM	tblICInventoryTransactionType 
	WHERE	strName = 'Inventory Receipt';

	SELECT	TOP 1 @TransactionType_Invoice = intTransactionTypeId
	FROM	tblICInventoryTransactionType 
	WHERE	strName = 'Invoice';

	SELECT TOP 1 @dtmPreviousDate = dtmDate
	FROM tblICInventoryTransaction
	WHERE intItemId = @intItemId
		AND (intSubLocationId = @intSubLocationId OR ISNULL(intSubLocationId, 0) = 0)
		AND (intStorageLocationId = @intStorageLocationId OR ISNULL(intStorageLocationId, 0) = 0)
		AND ysnIsUnposted <> 1
		AND intTransactionTypeId IN(@TransactionType_InventoryReceipt, @TransactionType_Invoice)
		AND intTransactionTypeId = @intTransactionTypeId
	ORDER BY dtmDate DESC

	RETURN @dtmPreviousDate;

END