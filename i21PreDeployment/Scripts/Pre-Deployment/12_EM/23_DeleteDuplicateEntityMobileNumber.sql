GO
PRINT ('Delete entity mobile number with duplicates')
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityMobileNumber' and [COLUMN_NAME] = 'intEntityId')
BEGIN
	PRINT('Start deleting duplicates')
	EXEC('
		WITH CTE_Data AS(
			SELECT intEntityMobileNumberId, intEntityId,
				RN = ROW_NUMBER() OVER (PARTITION BY intEntityId ORDER BY intEntityMobileNumberId DESC) 
			FROM tblEMEntityMobileNumber
		)
		DELETE FROM CTE_Data WHERE RN > 1
	')
	PRINT('End deleting duplicates')
END