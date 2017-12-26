IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMultiCompany)
BEGIN

	SET IDENTITY_INSERT [dbo].[tblSMMultiCompany] ON

	DECLARE @companyName nvarchar(150)
	SELECT TOP 1 @companyName = strCompanyName FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC

	
	DECLARE @serverName NVARCHAR(MAX) = N''
	SELECT TOP 1 @serverName +=convert(nvarchar(max), SERVERPROPERTY('ServerName'));

	DECLARE @environmentType nvarchar(150)
	SELECT TOP 1 @environmentType = strEnvironmentType FROM tblSMCompanyPreference ORDER BY intCompanyPreferenceId ASC

	INSERT INTO [dbo].[tblSMMultiCompany] ([intMultiCompanyId], [strCompanyName], [strDatabaseName], [strServer], [strUserName], [strPassword], [strType])
     VALUES(1, @companyName, db_name(), @serverName, 'irelyinstaller', 'RPWc3BK5', @environmentType)

	SET IDENTITY_INSERT [dbo].[tblSMMultiCompany] OFF

END


GO
UPDATE tblSMCompanySetup SET intMultiCompanyId = 1 where intMultiCompanyId  is null
GO
