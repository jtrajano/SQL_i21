CREATE PROCEDURE uspICGetCurrentImportSetup 
	@intImportSetupId INT 
	,@strName NVARCHAR(50) = NULL OUTPUT 
	,@strFolder NVARCHAR(500) = NULL OUTPUT 
	,@strArchiveFolder NVARCHAR(500) = NULL OUTPUT 	
	,@intEdiMapTemplateId INT = NULL OUTPUT 
	,@strCronExpression NVARCHAR(2000) = NULL OUTPUT 
AS 

SELECT 
	@strName = strName
	, @strFolder = strFolder
	, @strArchiveFolder = strArchiveFolder
	, @intEdiMapTemplateId = intEdiMapTemplateId
	, @strCronExpression = strCronExpression
FROM 
	vyuICGetImportSetup 
WHERE 
	intImportSetupId = @intImportSetupId