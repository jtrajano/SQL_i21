/****************** Implement Inventory Status on Transactions **************/
BEGIN
	UPDATE InvTransaction
	SET intCostingMethod = dbo.fnGetCostingMethod(intItemId, intItemLocationId)
	FROM dbo.tblICInventoryTransaction InvTransaction
	WHERE intCostingMethod IS NULL 
END
GO
/****************** End Implement Inventory Status on Transactions **************/