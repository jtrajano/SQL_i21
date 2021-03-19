PRINT N'BEGIN - IC Data Fix for 19.1. Populate the Item Category Change Log'
GO

--IF	EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 19.1)
--	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICItemStockUsagePerPeriod)
IF NOT EXISTS (SELECT TOP 1 1 FROM tblICItemCategoryChangeLog)
BEGIN 
	INSERT INTO tblICItemCategoryChangeLog (
		intItemId
		,intOriginalCategoryId
		,intNewCategoryId
		,dtmDateChanged
		,intCreatedByUserId	
	)
	SELECT 
		intItemId = i.intItemId 
		,intOriginalCategoryId = t.intCategoryId
		,intNewCategoryId = i.intCategoryId 
		,dtmDateChanged = t.dtmDate
		,intCreatedByUserId	= NULL 
	FROM
		tblICItem i 
		OUTER APPLY (
			SELECT TOP 1 
				t.intCategoryId
				,t.dtmDate
				
			FROM 
				tblICInventoryTransaction t
			WHERE
				t.intItemId = i.intItemId
				AND t.intCategoryId <> i.intCategoryId
			ORDER BY
				t.dtmDate DESC
		) t
	WHERE	
		t.intCategoryId IS NOT NULL 
END 
GO

PRINT N'END - IC Data Fix for 19.1. Populate the Item Category Change Log'