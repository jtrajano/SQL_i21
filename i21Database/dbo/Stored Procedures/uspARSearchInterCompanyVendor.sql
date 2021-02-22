CREATE PROCEDURE [dbo].[uspARSearchInterCompanyVendor]
	@DatabaseName NVARCHAR(50)
AS
	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyVendorId] = intEntityId
		,[strInterCompanyVendorId] = strName
	FROM [' + @strDatabaseName + '].[dbo].[vyuAPVendor] V
	ORDER BY strName'

	EXEC sp_executesql @strQuery
RETURN 0
