-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert the name of the M2M computations used in Inventory costing. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate M2M Computations *******************/')
GO

SET IDENTITY_INSERT dbo.tblICM2MComputation ON;

-- Use UPSERT to populate the inventory M2M Computations
MERGE 
INTO	dbo.[tblICM2MComputation]
WITH	(HOLDLOCK) 
AS		M2MComputations
USING	(
		SELECT 
			[intM2MComputationId] = 1,
			[strM2MComputation] = 'No'
		UNION ALL
		SELECT 
			[intM2MComputationId] = 2,
			[strM2MComputation] = 'Add'
		UNION ALL
		SELECT 
			[intM2MComputationId] = 3,
			[strM2MComputation] = 'Reduce'

) AS HardCodedM2MComputations
	ON  M2MComputations.intM2MComputationId = HardCodedM2MComputations.intM2MComputationId

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strM2MComputation = HardCodedM2MComputations.strM2MComputation

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intM2MComputationId
		,strM2MComputation
	)
	VALUES (
		HardCodedM2MComputations.intM2MComputationId
		,HardCodedM2MComputations.strM2MComputation
	)
;

SET IDENTITY_INSERT dbo.tblICM2MComputation OFF;

GO
print('/*******************  END Populate M2M Computations *******************/')