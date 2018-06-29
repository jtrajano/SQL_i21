
/*
	Retrieves the id from tblICInventoryTransaction table using the module's transaction id (string and int id)
*/

CREATE FUNCTION [dbo].[fnGetInventoryTransactionId] (
	@strId AS NVARCHAR(50)
	,@intId AS INT
	,@intItemId AS INT
	,@intItemLocationId AS INT 
)
RETURNS TABLE 
AS 

RETURN

SELECT	InventoryTransaction.intInventoryTransactionId
FROM	dbo.tblICInventoryTransaction InventoryTransaction INNER JOIN dbo.tblICInventoryTransactionType InventoryTransactionType
			ON InventoryTransaction.intTransactionTypeId = InventoryTransactionType.intTransactionTypeId
WHERE	InventoryTransaction.strTransactionId = @strId
		AND InventoryTransaction.intTransactionId = @intId
		AND InventoryTransaction.intItemId = @intItemId
		AND InventoryTransaction.intItemLocationId = @intItemLocationId
		AND ISNULL(InventoryTransaction.ysnIsUnposted, 0) = 0
		AND InventoryTransactionType.strName IN (
			'Inventory Receipt', 'Inventory Shipment', 'Purchase Order', 'Sales Order'
		)