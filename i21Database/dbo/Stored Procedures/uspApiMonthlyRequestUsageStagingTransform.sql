CREATE PROCEDURE [dbo].[uspApiMonthlyRequestUsageStagingTransform] (@guiStagingIdentifier UNIQUEIDENTIFIER)
AS

MERGE tblApiMonthlyRequestUsage WITH (HOLDLOCK) AS TARGET
USING (
	SELECT * 
	FROM tblApiMonthlyRequestUsageStaging 
	WHERE guiStagingIdentifier = @guiStagingIdentifier
) AS SOURCE 
ON (TARGET.strName = SOURCE.strName
	AND TARGET.strMethod = SOURCE.strMethod
	AND TARGET.strPath = SOURCE.strPath
	AND TARGET.intMonth = SOURCE.intMonth
	AND TARGET.intYear = SOURCE.intYear
	AND TARGET.guiSubscriptionId = SOURCE.guiSubscriptionId) 
WHEN MATCHED
THEN UPDATE SET TARGET.intCount = SOURCE.intCount
WHEN NOT MATCHED BY TARGET 
THEN INSERT (guiApiMonthlyRequestUsageId, guiSubscriptionId, strName, strMethod, strPath, intCount, intMonth, strMonth, intYear, strLastStatus, dtmDateLastUpdated) 
	VALUES (NEWID(), SOURCE.guiSubscriptionId, SOURCE.strName, SOURCE.strMethod, SOURCE.strPath, 
		SOURCE.intCount, SOURCE.intMonth, SOURCE.strMonth, SOURCE.intYear, SOURCE.strLastStatus, SOURCE.dtmDateLastUpdated)
;
DELETE FROM tblApiMonthlyRequestUsageStaging
WHERE guiStagingIdentifier = @guiStagingIdentifier