PRINT N'BEGIN - IC Data Fix for 18.1. #1'
GO
--------------------------------------------------------------------------------------------------------------------------------------
-- Update NULL status value of item contracts. Set to Discontinued if the item status is Discontinued.
-- ----------------------------------------------------------------------------------------------------------------------------------- 
IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	UPDATE c
	SET c.strStatus = CASE i.strStatus WHEN 'Discontinued' THEN 'Discontinued' ELSE CASE WHEN c.strStatus IS NULL THEN 'Active' ELSE c.strStatus END END
	FROM tblICItemContract c
		INNER JOIN tblICItem i ON i.intItemId = c.intItemId
END

GO
PRINT N'END - IC Data Fix for 18.1. #1'
GO