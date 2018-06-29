-- ----------------------------------------------------------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction No Counter Account Category
-- ----------------------------------------------------------------------------------------------------

print('/*******************  BEGIN Populate Inventory Transaction No Counter Account Category *******************/')
GO

-- Use UPSERT to populate the inventory transaction No Counter Account Category
MERGE 
INTO	dbo.tblICInventoryTransactionWithNoCounterAccountCategory
WITH	(HOLDLOCK) 
AS		A
USING	(
		SELECT	intTransactionTypeId = intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType 
		WHERE	strName IN (
					'Build Assembly'
					,'Consume'
					,'Produce'
					,'Inventory Transfer'
					-- NOTE: Add in this line any additional transaction types that has no counter account category.
				)
) AS B
	ON  A.intTransactionTypeId = B.intTransactionTypeId

-- When id is matched but name is not, then update the name. 
WHEN MATCHED THEN 
	-- Do nothing (update the same thing)
	UPDATE 
	SET 	intTransactionTypeId = B.intTransactionTypeId

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intTransactionTypeId
	)
	VALUES (
		B.intTransactionTypeId
	)
;
GO
print('/*******************  END Populate Inventory Transaction No Counter Account Category *******************/')