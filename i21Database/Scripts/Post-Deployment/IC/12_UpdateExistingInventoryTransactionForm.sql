print('/*******************  BEGIN Fix existing data for transaction form *******************/')
GO

UPDATE	dbo.tblICInventoryTransaction 
SET		strTransactionForm = 'Inventory Adjustment'
WHERE	strTransactionId LIKE 'ADJ%'
		AND ISNULL(strTransactionForm, '') <> 'Inventory Adjustment'

UPDATE	dbo.tblICInventoryLotTransaction 
SET		strTransactionForm = 'Inventory Adjustment'
WHERE	strTransactionId LIKE 'ADJ%'
		AND ISNULL(strTransactionForm, '') <> 'Inventory Adjustment'

UPDATE	dbo.tblGLDetail 
SET		strTransactionForm = 'Inventory Adjustment'
WHERE	strTransactionId LIKE 'ADJ%'
		AND ISNULL(strTransactionForm, '') <> 'Inventory Adjustment'


print('/*******************  END Fix existing data for transaction form *******************/')
GO
