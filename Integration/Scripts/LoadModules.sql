IF OBJECT_ID('tempdb..##tblOriginMod') IS NOT NULL DROP TABLE ##tblOriginMod
GO

-- Validate if there are more than ONE record on coctlmst. if there are, raise error
IF (SELECT count(*) from coctlmst) >1
BEGIN
	GOTO MULTIPLE_Rec;	
END

IF (SELECT count(*) from coctlmst) = 0
BEGIN
	GOTO NO_Rec;	
END


CREATE TABLE ##tblOriginMod
(
	 intModId INT IDENTITY(1,1)
	, strPrefix NVARCHAR(5)
	, strName NVARCHAR(30)
	, ysnUsed BIT
)


IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ap')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strPrefix, strName, ysnUsed) SELECT TOP 1 N''AP'', N''ACCOUNTS PAYABLE'', CASE ISNULL(coctl_ap, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	--SELECT TOP 1 @AP = ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP'
END







RETURN;
MULTIPLE_Rec:
	RAISERROR(N'There are multiple records on coctlmst. Deployment terminated.', 16,1)
	RETURN;
	
NO_Rec:
	RAISERROR(N'There are no records on coctlmst. Deployment terminated.', 16,1)

GO