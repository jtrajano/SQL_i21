GO
print 'Check and delete duplicate entity type'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityType' and [COLUMN_NAME] = 'strType')
	 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityType' and [COLUMN_NAME] = 'intEntityId')
	
BEGIN
	PRINT 'START'
	EXEC('

		WITH CTE_Data AS(
		   SELECT intEntityId, strType,
			   RN = ROW_NUMBER()OVER(PARTITION BY strType, intEntityId ORDER BY intEntityId )
		   FROM dbo.tblEMEntityType
	
		)
		DELETE FROM CTE_Data WHERE RN > 1
	
	')	

	
	PRINT 'END'
END

print 'Check and delete duplicate entity type'
