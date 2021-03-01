

CREATE PROCEDURE uspGLValidateSubsidiarySetting
AS
DECLARE @strDatabase nvarchar(50)
DECLARE @tbl TABLE 
(
	[intSubsidiaryCompanyId] [int],
	[strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL	
)

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



INSERT INTO @tbl SELECT intSubsidiaryCompanyId, strDatabase FROM tblGLSubsidiaryCompany

DECLARE @i int
DECLARE @x INT = 1
DECLARE @tblMessage TABLE(msg nvarchar(max))
DECLARE @tSql NVARCHAR(MAX)
DECLARE  @DBExec NVARCHAR(40)
SET @DBExec =  N'.sys.sp_executesql';
declare @s NVARCHAR(MAX)

WHILE EXISTS (SELECT TOP 1 1 FROM @tbl)
BEGIN
	SELECT TOP 1 @i = [intSubsidiaryCompanyId],@strDatabase = [strDatabase]
	from @tbl
	
	SET @tSql =
	REPLACE(
	'DECLARE @strError NVARCHAR(MAX) = NULL

	IF NOT EXISTS (select top 1 1  from [strDatabase].dbo.tblGLAccountStructure where intStructureType = 6 )
	BEGIN
		SELECT @strError =''Company '' + strDatabase + '' needs an company segment setting. ''  FROM tblGLSubsidiaryCompany where strDatabase =''[strDatabase]'' AND isnull(strCompanySegment,'''') = ''''
		IF @strError IS NOT NULL
			SELECT @strError
	END','[strDatabase]', @strDatabase)

	INSERT INTO  @tblMessage  EXEC @DBExec @tSql;
	IF EXISTS(SELECT TOP 1 1 FROM @tblMessage )
	BEGIN
		SELECT TOP 1 @s = msg from @tblMessage
		RAISERROR (@s, 16, 1)
		RETURN
	END
	

	DELETE FROM @tbl where [intSubsidiaryCompanyId] = @i
END



