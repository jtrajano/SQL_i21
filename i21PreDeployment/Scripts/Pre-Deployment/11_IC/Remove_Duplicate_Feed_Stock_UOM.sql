PRINT N'Removing duplicate feed stock uom...'

-- Remove duplicate feed stock uom
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICRinFeedStockUOM'))
BEGIN	
	EXEC (';WITH cte AS (SELECT ROW_NUMBER() OVER (PARTITION BY intUnitMeasureId ORDER BY (SELECT 0)) RN FROM tblICRinFeedStockUOM) DELETE FROM cte WHERE RN > 1;');
END