-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the lot status 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Warrant Status *******************/')
GO

SET IDENTITY_INSERT dbo.tblICWarrantStatus ON

-- Use UPSERT to populate the warrant status
MERGE 
INTO	dbo.tblICWarrantStatus
WITH	(HOLDLOCK) 
AS		WarrantStatus
USING	(
		SELECT	id = 1
				,WarrantStatus = 'Pledged'
		UNION ALL 
		SELECT	id = 2
				,WarrantStatus = 'Partially Released'
		UNION ALL 
		SELECT	id = 3
				,WarrantStatus = 'Released'
) AS PrimaryWarrantStatusHardValues
	ON  WarrantStatus.intWarrantStatus = PrimaryWarrantStatusHardValues.id

-- When id is matched but name is not, then update the name. 
WHEN	MATCHED 
		AND (
			WarrantStatus.strWarrantStatus <> PrimaryWarrantStatusHardValues.WarrantStatus
		) 
THEN 
	UPDATE 
	SET 	strWarrantStatus = PrimaryWarrantStatusHardValues.WarrantStatus

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intWarrantStatus
		,strWarrantStatus
	)
	VALUES (
		PrimaryWarrantStatusHardValues.id 
		,PrimaryWarrantStatusHardValues.WarrantStatus
	)
;

SET IDENTITY_INSERT dbo.tblICWarrantStatus OFF

GO
print('/*******************  END Populate Warrant Status *******************/')
