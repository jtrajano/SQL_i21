/****************** Implement Inventory Status on Transactions **************/
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tblICStatus'))
BEGIN
	CREATE TABLE [dbo].[tblICStatus]
	(
		[intStatusId] INT NOT NULL IDENTITY, 
		[strStatus] NVARCHAR(50) NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
	)
END
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

-- Implement on Inventory Transfer
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tblICInventoryTransfer'))
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intStatusId' AND object_id = object_id('tblICInventoryTransfer'))
	BEGIN
		EXEC('
			ALTER TABLE tblICInventoryTransfer
			ADD intStatusId INT NULL
		')
	END	
END
GO

IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tblICInventoryTransfer'))
BEGIN
	EXEC('
		UPDATE tblICInventoryTransfer
		SET intStatusId = 1
		WHERE ISNULL(intStatusId, 0) = 0
	')
END
GO
/****************** End Implement Inventory Status on Transactions **************/