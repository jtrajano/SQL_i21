IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMultiCompany)
BEGIN

	SET IDENTITY_INSERT [dbo].[tblSMMultiCompany] ON

	DECLARE @companyName nvarchar(150)
	SELECT TOP 1 @companyName = strCompanyName FROM tblSMCompanySetup ORDER BY intCompanySetupID ASC

	DECLARE @environmentType nvarchar(150)
	SELECT TOP 1 @environmentType = strEnvironmentType FROM tblSMCompanyPreference ORDER BY intCompanyPreferenceId ASC

	INSERT INTO [dbo].[tblSMMultiCompany] ([intMultiCompanyId], [strCompanyName], [strDatabaseName], [strServer], [strType])
     VALUES(1, @companyName, db_name(), @@servername, @environmentType)

	SET IDENTITY_INSERT [dbo].[tblSMMultiCompany] OFF

END