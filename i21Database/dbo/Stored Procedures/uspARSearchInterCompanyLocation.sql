CREATE PROCEDURE [dbo].[uspARSearchInterCompanyLocation]
	@DatabaseName NVARCHAR(50)
AS
	DECLARE @strQuery NVARCHAR(MAX) = 
	'SELECT 
		 [intInterCompanyLocationId] = intCompanyLocationId
		,[strInterCompanyLocationId] = strLocationName
	FROM [' + @DatabaseName + '].[dbo].[tblSMCompanyLocation]'

	EXEC sp_executesql @strQuery
RETURN 0