CREATE PROCEDURE uspGLValidateSubsidiarySetting
AS
DECLARE @strDatabase nvarchar(50)
DECLARE @tbl TABLE 
(
	[strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL	
)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure)
	RAISERROR ('Account Structure is missing. ', 16,1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLSubsidiaryCompany)
	RAISERROR ('There are no subsidiary companies to merge. ', 16,1)

IF EXISTS (SELECT TOP 1 1 FROM tblGLSubsidiaryCompany WHERE isnull(strDatabase,'') = '')
	RAISERROR ('There are missing database name. ', 16,1)

IF EXISTS (SELECT TOP 1 1 FROM tblGLSubsidiaryCompany WHERE isnull(strCompanySegment,'') = '' AND ysnCompanySegment = 1)
	RAISERROR ('There are missing company segment name. ', 16,1)

IF EXISTS (SELECT 1  from tblGLSubsidiaryCompany WHERE ISNULL(strDatabase,'') != '' GROUP BY strDatabase HAVING count(*) > 1)
	RAISERROR ('There are duplicate company name. ', 16,1)

IF EXISTS (SELECT 1 from tblGLSubsidiaryCompany WHERE ISNULL(strCompanySegment,'') != '' GROUP BY strCompanySegment HAVING count(*) > 1 )
	RAISERROR ('There are duplicate company segment. ', 16,1)


IF @@ERROR > 0
	RETURN

	

INSERT INTO @tbl SELECT strDatabase FROM tblGLSubsidiaryCompany

DECLARE @companyCount int
DECLARE @tSql NVARCHAR(MAX)
DECLARE @tblStructure TABLE (
    
    [intStructureType]       INT            NOT NULL,
    [strStructureName]       NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strType]                NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intLength]              INT            NULL
)

SELECT @companyCount = count(*) + 1 from @tbl

INSERT INTO @tblStructure
SELECT intStructureType, strStructureName, strType, intLength  from tblGLAccountStructure WHERE intStructureType <> 6
AND strType <> 'Divider'



WHILE EXISTS (SELECT TOP 1 1 FROM @tbl)
BEGIN
	SELECT TOP 1 @strDatabase = strDatabase FROM @tbl
	SET @tSql = REPLACE('select intStructureType, strStructureName, strType, intLength  from [strDatabase].dbo.tblGLAccountStructure WHERE intStructureType <> 6 AND strType <> ''Divider''', '[strDatabase]', @strDatabase)
	INSERT INTO @tblStructure EXEC (@tSql)
	DELETE FROM @tbl where @strDatabase = strDatabase
END


	
IF EXISTS(SELECT  1  FROM @tblStructure GROUP BY intStructureType,strStructureName, intLength HAVING COUNT(*) <> @companyCount)
	RAISERROR('Account structure is not compatible for merging', 16, 1)