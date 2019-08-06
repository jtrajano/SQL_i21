﻿PRINT N'BEGIN - Clean Short and Long UPC for tblICItemUOM'
GO

IF EXISTS(SELECT TOP 1
	1
FROM INFORMATION_SCHEMA.COLUMNS
WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strLongUPCCode')
BEGIN
	UPDATE u 
	SET u.strLongUPCCode = NULL 
	FROM tblICItemUOM u 
	WHERE (LTRIM(RTRIM(strLongUPCCode)) LIKE '%.%' OR ISNUMERIC(RTRIM(LTRIM(u.strLongUPCCode))) != 1)
		AND NULLIF(LTRIM(RTRIM(strLongUPCCode)), '') IS NOT NULL
END
GO

-- IF EXISTS(SELECT TOP 1
-- 		1
-- 	FROM INFORMATION_SCHEMA.COLUMNS
-- 	WHERE [TABLE_NAME] = 'tblICItemUOM')
-- 	AND NOT EXISTS(SELECT TOP 1
-- 		1
-- 	FROM INFORMATION_SCHEMA.COLUMNS
-- 	WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'intUpcCode')
-- BEGIN
-- 	ALTER TABLE tblICItemUOM ADD intUpcCode AS 
-- 	CASE WHEN ISNUMERIC(RTRIM(LTRIM(strLongUPCCode))) = 1 
-- 		THEN CAST(RTRIM(LTRIM(strLongUPCCode)) AS BIGINT) 
-- 		ELSE NULL 
-- 	END
-- END
-- GO

BEGIN
	IF EXISTS(SELECT TOP 1
		1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strUpcCode')
	BEGIN
		UPDATE tblICItemUOM set strUpcCode = NULL 
		WHERE strUpcCode = '' OR strUpcCode = '0' OR
			strUpcCode IN (SELECT strUpcCode
			FROM tblICItemUOM
			GROUP BY strUpcCode
			HAVING (COUNT(strUpcCode) > 1))
	END
	IF EXISTS(SELECT TOP 1
		1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strLongUPCCode')
	BEGIN
		UPDATE tblICItemUOM set strLongUPCCode = NULL 
		WHERE strLongUPCCode = '' OR strLongUPCCode = '0' OR
			strLongUPCCode IN (SELECT strLongUPCCode
			FROM tblICItemUOM
			GROUP BY strLongUPCCode
			HAVING (COUNT(strLongUPCCode) > 1))
	END

	-- IF EXISTS(SELECT TOP 1
	-- 	1
	-- FROM INFORMATION_SCHEMA.COLUMNS
	-- WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'intUpcCode')
	-- BEGIN
	-- 	;WITH
	-- 		CTE
	-- 		AS
	-- 		(
	-- 			SELECT intUpcCode, strLongUPCCode, ROW_NUMBER() OVER (PARTITION BY intUpcCode ORDER BY intUpcCode) AS rc
	-- 			FROM tblICItemUOM
	-- 			WHERE intUpcCode IS NOT NULL
	-- 		)
	-- 	UPDATE CTE SET strLongUPCCode = NULL WHERE rc > 1;
	-- END
END
GO
PRINT N'END - Clean Short and Long UPC for tblICItemUOM'