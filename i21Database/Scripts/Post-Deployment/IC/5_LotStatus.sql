-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the lot status 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Lot Status *******************/')
GO

SET IDENTITY_INSERT dbo.tblICLotStatus ON

-- Use UPSERT to populate the primary lot status 
MERGE 
INTO	dbo.tblICLotStatus
WITH	(HOLDLOCK) 
AS		LotStatus
USING	(
		SELECT	id = 1
				,PrimaryStatus = 'Active'
		UNION ALL 
		SELECT	id = 2
				,PrimaryStatus = 'On Hold'
		UNION ALL 
		SELECT	id = 3
				,PrimaryStatus = 'Quarantine'
) AS PrimaryLotStatusHardValues
	ON  LotStatus.intLotStatusId = PrimaryLotStatusHardValues.id

-- When id is matched but name is not, then update the name. 
WHEN MATCHED AND LotStatus.strPrimaryStatus <> PrimaryLotStatusHardValues.PrimaryStatus THEN 
	UPDATE 
	SET 	strPrimaryStatus = PrimaryLotStatusHardValues.PrimaryStatus
			,strSecondaryStatus = NULL
			,strDescription = NULL

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intLotStatusId
		,strPrimaryStatus
	)
	VALUES (
		PrimaryLotStatusHardValues.id 
		,PrimaryLotStatusHardValues.PrimaryStatus
	)
;

SET IDENTITY_INSERT dbo.tblICLotStatus OFF

GO
print('/*******************  END Populate Lot Status *******************/')