PRINT N'START- IC Add GL Account Ids in Valuation'
GO

IF EXISTS (SELECT * FROM [tblICCompanyPreference] WHERE ISNULL(ysnUpdateInventoryTransactionAccountId, 0) = 0)
BEGIN 
	
	UPDATE t
	SET 
		strAccountIdInventory = glAccountIdInventory.strAccountId
		,strAccountIdInTransit = glAccountIdInTransit.strAccountId
	FROM 
		tblICInventoryTransaction t 
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(
			t.intItemId
			,ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
			,'Inventory'
		) accountIdInventory
		LEFT JOIN tblGLAccount glAccountIdInventory
			ON accountIdInventory.intAccountId = glAccountIdInventory.intAccountId
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(
			t.intItemId
			,ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
			,'Inventory In-Transit'
		) accountIdInTransit
		LEFT JOIN tblGLAccount glAccountIdInTransit
			ON accountIdInTransit.intAccountId = glAccountIdInTransit.intAccountId

	UPDATE [tblICCompanyPreference] SET ysnUpdateInventoryTransactionAccountId = 1 
END
GO


PRINT N'END - Add GL Account Ids in Valuation'