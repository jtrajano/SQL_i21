CREATE PROCEDURE [dbo].[uspARSearchInterCompanyVendor]
	@intInterCompanyId INT = 0
AS
	DECLARE @strDatabaseName NVARCHAR(50) = ''

	SELECT @strDatabaseName = strDatabaseName
	FROM tblSMInterCompany
	WHERE intInterCompanyId = @intInterCompanyId

	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyVendorId] = intEntityId
		,[strInterCompanyVendorId] = strName
	FROM [' + @strDatabaseName + '].[dbo].[vyuAPVendor] V
	ORDER BY strName'

	IF ISNULL(@strDatabaseName, '') <> ''
		EXEC sp_executesql @strQuery
RETURN 0
