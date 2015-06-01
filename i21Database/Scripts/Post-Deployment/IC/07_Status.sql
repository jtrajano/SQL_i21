print('/*******************  BEGIN Populate Inventory Status *******************/')
GO
-- Use UPSERT to populate the inventory statuses
SET IDENTITY_INSERT tblICStatus ON
MERGE 
INTO	dbo.tblICStatus
WITH	(HOLDLOCK) 
AS		InventoryStatuses
USING	(
		SELECT	id = 1
				,name = 'Open'
		UNION ALL 
		SELECT	id = 2
				,name = 'Partial'
		UNION ALL 
		SELECT	id = 3
				,name = 'Closed'
		UNION ALL 
		SELECT	id = 4
				,name = 'Short Closed'
) AS InventoryStatusHardValues
	ON  InventoryStatuses.intStatusId = InventoryStatusHardValues.id

-- When id is matched but name is not, then update the name. 
WHEN MATCHED AND InventoryStatuses.strStatus <> InventoryStatusHardValues.name THEN 
	UPDATE 
	SET 	strStatus = InventoryStatusHardValues.name

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intStatusId
		,strStatus
	)
	VALUES (
		InventoryStatusHardValues.id
		,InventoryStatusHardValues.name
	)
;
SET IDENTITY_INSERT tblICStatus OFF
GO
print('/*******************  END Populate Inventory Status *******************/')