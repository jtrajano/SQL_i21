PRINT N'BEGIN - Clean Short and Long UPC for tblICItemUOM'
GO

BEGIN
	IF EXISTS(SELECT TOP 1
		1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strUpcCode')
	BEGIN
		EXEC ('
		UPDATE UOM
		SET UOM.strUpcCode = NULL
		FROM
		(
			SELECT
			strUpcCode,
			intModifier,
			ROW_NUMBER() OVER (PARTITION BY strUpcCode, intModifier
								ORDER BY strUpcCode) AS RowNumber 
			FROM tblICItemUOM
		) UOM
		WHERE 
		UOM.RowNumber > 1 
		AND 
		UOM.strUpcCode IS NOT NULL
		AND
		UOM.intModifier IS NULL

		UPDATE UOM
		SET 
			UOM.strUpcCode = NULL,
			UOM.intModifier = NULL
		FROM
		(
			SELECT
			strUpcCode,
			intModifier,
			ROW_NUMBER() OVER (PARTITION BY strUpcCode, intModifier
								ORDER BY strUpcCode) AS RowNumber 
			FROM tblICItemUOM
		) UOM
		WHERE 
		UOM.RowNumber > 1 
		AND 
		UOM.strUpcCode IS NOT NULL
		AND
		UOM.intModifier IS NOT NULL		
		')
	END
	IF EXISTS(SELECT TOP 1
		1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strLongUPCCode')
	BEGIN
		EXEC ('
		UPDATE UOM
		SET UOM.strLongUPCCode = NULL
		FROM
		(
			SELECT
			strLongUPCCode,
			intModifier,
			ROW_NUMBER() OVER (PARTITION BY strLongUPCCode
								ORDER BY strLongUPCCode) AS RowNumber 
			FROM tblICItemUOM
			WHERE intModifier IS NULL
		) UOM
		WHERE 
		UOM.RowNumber > 1 
		AND 
		UOM.strLongUPCCode IS NOT NULL

		UPDATE UOM
		SET 
			UOM.strLongUPCCode = NULL,
			UOM.intModifier = NULL
		FROM
		(
			SELECT
			strLongUPCCode,
			intModifier,
			ROW_NUMBER() OVER (PARTITION BY strLongUPCCode, intModifier
								ORDER BY strLongUPCCode) AS RowNumber 
			FROM tblICItemUOM
		) UOM
		WHERE 
		UOM.RowNumber > 1 
		AND 
		UOM.strLongUPCCode IS NOT NULL
		AND
		UOM.intModifier IS NOT NULL
		')
	END
END
GO

-- Remove the old check constraint. 
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_tblICItemUOM_intUpcCode' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN 
	EXEC ('ALTER TABLE [tblICItemUOM] DROP CONSTRAINT CK_tblICItemUOM_intUpcCode')
END 

GO
PRINT N'END - Clean Short and Long UPC for tblICItemUOM'