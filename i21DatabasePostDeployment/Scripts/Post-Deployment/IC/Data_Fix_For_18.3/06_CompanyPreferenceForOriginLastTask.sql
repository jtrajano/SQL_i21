PRINT N'BEGIN - IC Data Fix for 18.3. #6'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.3)
BEGIN 
	-- AdditionalGLAccts was removed, so update the current origin task
	UPDATE tblICCompanyPreference
	SET strOriginLastTask = 'Items'
	WHERE strOriginLastTask = 'AdditionalGLAccts'

END 

GO 
PRINT N'END - IC Data Fix for 18.3. #6'
GO
