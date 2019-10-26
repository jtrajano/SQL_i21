
IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICItemBundle'))
BEGIN	
EXEC ('
	WITH CTE 
    AS (
        SELECT	RN = ROW_NUMBER() OVER (PARTITION BY intItemId, intBundleItemId, intItemUnitMeasureId ORDER BY intItemId)
        FROM	tblICItemBundle 
    )
    DELETE FROM CTE WHERE RN > 1
')

END 