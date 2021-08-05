CREATE PROCEDURE [dbo].[uspARSearchInterCompanyLocation]
	 @intInterCompanyId INT = 0
	,@strInterCompanyLocationId NVARCHAR(100) = ''
AS
	DECLARE @strDatabaseName NVARCHAR(50) = ''

	SELECT @strDatabaseName = strDatabaseName
	FROM tblSMInterCompany
	WHERE intInterCompanyId = @intInterCompanyId

	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyLocationId] = intCompanyLocationId
		,[strInterCompanyLocationId] = strLocationName
	FROM [' + @strDatabaseName + '].[dbo].[tblSMCompanyLocation] '

	IF (ISNULL(@strInterCompanyLocationId, '') <> '')
		SET @strQuery = @strQuery + ' WHERE strLocationName LIKE ''%' + @strInterCompanyLocationId + '%'''

	IF ISNULL(@strDatabaseName, '') <> ''
		EXEC sp_executesql @strQuery

RETURN 0