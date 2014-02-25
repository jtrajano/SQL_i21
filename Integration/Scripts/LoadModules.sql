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
	, strDBName nvarchar(50) NOT NULL 
	, strPrefix NVARCHAR(5) NOT NULL UNIQUE
	, strName NVARCHAR(30) NOT NULL UNIQUE
	, ysnUsed BIT NOT NULL 
)


-- AG ACCOUNTING
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- AG SPECIAL PRICES
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_sp_yn')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''ASP'', N''AG Special Price'', CASE ISNULL(coctl_sp_yn, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END


-- PETRO ACCOUNTING
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- PT SPECIAL PRICES
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ps_yn')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PSP'', N''PT Special Price'', CASE ISNULL(coctl_ps_yn, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END


-- ACCOUNTS PAYABLE
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ap')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AP'', N''ACCOUNTS PAYABLE'', CASE ISNULL(coctl_ap, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- CONTRACTS
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_cn_yn')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''CN'', N''CONTRACTS'', CASE ISNULL(coctl_cn_yn, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- GRAINS
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ga')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''GR'', N''GRAINS'', CASE ISNULL(coctl_ga, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- TAX FORMS
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_px_yn')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''TF'', N''TAX FORMS'', CASE ISNULL(coctl_px_yn, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END

-- E-COMMERCE
IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ec')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''EC'', N''E-COMMERCE'', CASE ISNULL(coctl_ec, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
END



RETURN;
MULTIPLE_Rec:
	RAISERROR(N'There are multiple records on coctlmst. Deployment terminated.', 16,1)
	RETURN;
	
NO_Rec:
	RAISERROR(N'There are no records on coctlmst. Deployment terminated.', 16,1)

GO