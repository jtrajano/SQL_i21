-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the lot status 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Lot Status *******************/')
GO

SET IDENTITY_INSERT dbo.tblICLotStatus ON

DECLARE @Description AS NVARCHAR(100) = 'This is system used lot status. Please do not change.'

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
WHEN	MATCHED 
		AND (
			LotStatus.strPrimaryStatus <> PrimaryLotStatusHardValues.PrimaryStatus
			OR LotStatus.strSecondaryStatus <> PrimaryLotStatusHardValues.PrimaryStatus
			OR LotStatus.strDescription <> @Description
		) 
THEN 
	UPDATE 
	SET 	strPrimaryStatus = PrimaryLotStatusHardValues.PrimaryStatus
			,strSecondaryStatus = PrimaryLotStatusHardValues.PrimaryStatus
			,strDescription = @Description

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intLotStatusId
		,strPrimaryStatus
		,strDescription
	)
	VALUES (
		PrimaryLotStatusHardValues.id 
		,PrimaryLotStatusHardValues.PrimaryStatus
		,@Description
	)
;

SET IDENTITY_INSERT dbo.tblICLotStatus OFF

GO
print('/*******************  END Populate Lot Status *******************/')
