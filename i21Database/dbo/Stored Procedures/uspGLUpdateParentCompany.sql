CREATE PROCEDURE uspGLUpdateParentCompany
@strDatabase NVARCHAR(50),
@strParentCompany NVARCHAR(10),
@ysnDelete BIT 

AS
DECLARE @sql NVARCHAR(MAX)

SET @sql = 
REPLACE(
REPLACE(
    'UPDATE  [strDatabase].dbo.tblGLCompanyPreferenceOption SET strParentCompanyCode = ''[strParentCompany]''',
'strDatabase', @strDatabase),
'[strParentCompany]', @strParentCompany)

EXEC sp_executesql @sql

GO

