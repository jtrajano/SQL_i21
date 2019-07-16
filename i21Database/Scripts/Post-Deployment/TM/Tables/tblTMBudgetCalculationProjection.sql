
GO 
PRINT 'START ALTERING tblTMBudgetCalculationProjection'
GO

IF (0 = (SELECT COUNT(1) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME='tblTMBudgetCalculationProjection_Unique_intClockId'  
))
BEGIN
	PRINT 'STARTED ALTERING tblTMBudgetCalculationProjection'

	--VERIFY DUPLICATES > 
	SELECT intClockId AS DUPLICATE_CLOCK_ID FROM tblTMBudgetCalculationProjection GROUP BY intClockId HAVING COUNT(1) > 1 


	--PREVIEW ITEM TO BE DELETED--
	SELECT 'ITEMS TO BE DELETED' AS QUERY_DESCRIPTION , * FROM (
		SELECT intBudgetCalculationProjectionId,intClockId, ROW_NUMBER() OVER 
		(
			PARTITION BY intClockId ORDER BY intBudgetCalculationProjectionId
		) as RowNumber
		FROM  tblTMBudgetCalculationProjection
	)  as tblPartition WHERE RowNumber > 1 


	--DELETE DUPLICATE RECORD--
	SELECT 'START DELETE DUPLICATE RECORD' AS PROCESS
	DELETE FROM tblTMBudgetCalculationProjection WHERE intBudgetCalculationProjectionId IN (
		SELECT intBudgetCalculationProjectionId FROM (
			SELECT intBudgetCalculationProjectionId,intClockId, ROW_NUMBER() OVER 
			(
				PARTITION BY intClockId ORDER BY intBudgetCalculationProjectionId
			) as RowNumber
			FROM  tblTMBudgetCalculationProjection
		)  as tblPartition WHERE RowNumber > 1 
	)
	SELECT 'END DELETE DUPLICATE RECORD' AS PROCESS


	--ADD UNIQUE CONTRAINTS--
	SELECT 'START ADD UNIQUE CONTRAINTS' AS PROCESS
	ALTER TABLE tblTMBudgetCalculationProjection
	ADD CONSTRAINT tblTMBudgetCalculationProjection_Unique_intClockId UNIQUE (intClockId);
	SELECT 'END ADD UNIQUE CONTRAINTS' AS PROCESS

	PRINT 'ENDED ALTERING tblTMBudgetCalculationProjection'
END


GO 
PRINT 'END ALTERING tblTMBudgetCalculationProjection'
GO