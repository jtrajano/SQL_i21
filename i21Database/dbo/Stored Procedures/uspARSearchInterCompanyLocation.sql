CREATE PROCEDURE [dbo].[uspARSearchInterCompanyLocation]
	@intInterCompanyId INT = 0
AS
	DECLARE @strDatabaseName NVARCHAR(50) = ''

	SELECT @strDatabaseName = strDatabaseName
	FROM tblSMInterCompany
	WHERE intInterCompanyId = @intInterCompanyId

	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyLocationId] = intCompanyLocationId
		,[strInterCompanyLocationId] = strLocationName
	FROM [' + @strDatabaseName + '].[dbo].[tblSMCompanyLocation]'

	IF ISNULL(@strDatabaseName, '') <> ''
		EXEC sp_executesql @strQuery
RETURN 0