PRINT N'Removing duplicate storage unit types...'

-- Remove duplicate storage unit types
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICStorageUnitType'))
BEGIN	
	EXEC (';WITH cte AS (SELECT ROW_NUMBER() OVER (PARTITION BY strStorageUnitType ORDER BY (SELECT 0)) RN FROM tblICStorageUnitType) DELETE FROM cte WHERE RN > 1;');
END