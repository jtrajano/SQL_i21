CREATE PROCEDURE [dbo].[uspARSearchInterCompanyVendor]
	 @intInterCompanyId INT = 0
	,@strInterCompanyVendorId NVARCHAR(100) = ''
AS
	DECLARE @strDatabaseName NVARCHAR(50) = ''

	SELECT @strDatabaseName = strDatabaseName
	FROM tblSMInterCompany
	WHERE intInterCompanyId = @intInterCompanyId

	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyVendorId] = intEntityId
		,[strInterCompanyVendorId] = strName
	FROM [' + @strDatabaseName + '].[dbo].[vyuAPVendor] V '

	IF (ISNULL(@strInterCompanyVendorId, '') <> '')
		SET @strQuery = @strQuery + ' WHERE strName LIKE ''%' + @strInterCompanyVendorId + '%'''

	SET @strQuery = @strQuery + ' ORDER BY strName'

	IF ISNULL(@strDatabaseName, '') <> ''
		EXEC sp_executesql @strQuery

RETURN 0
