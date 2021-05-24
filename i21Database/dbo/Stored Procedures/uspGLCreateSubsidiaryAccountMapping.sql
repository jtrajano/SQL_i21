

CREATE PROCEDURE uspGLCreateSubsidiaryAccountMapping
AS

DECLARE @tSQL NVARCHAR(MAX), @dbname nvarchar(40)

DECLARE @tbl TABLE(
    strDatabase NVARCHAR(40)
)
DECLARE @strDatabase NVARCHAR(40)
INSERT INTO @tbl
    SELECT strDatabase FROM tblGLSubsidiaryCompany

WHILE EXISTS(SELECT TOP 1 1 FROM @tbl)
BEGIN

	SELECT TOP 1 @dbname=strDatabase  FROM @tbl
	SET @tSQL
	=	REPLACE(
	'
	MERGE intO tblGLSubsidiaryAccountMapping
	WITH (HOLDLOCK)
	AS MappingTable
	USING(

		SELECT intAccountId, strAccountId + ISNULL(''-'' + S.strCompanySegment,'''') strAccountId, ''[dbname]'' strDatabase  FROM [dbname].dbo.tblGLAccount A
			OUTER APPLY(SELECT strCompanySegment FROM tblGLSubsidiaryCompany WHERE strDatabase = ''[dbname]'' and isnull(hasCompanySegment,0)  = 1 )S

	)As MergedTable
	ON MappingTable.intAccountId = MergedTable.intAccountId
	and MappingTable.strDatabase = MergedTable.strDatabase

	WHEN MATCHED THEN UPDATE
	SET

	MappingTable.strAccountId = MergedTable.strAccountId

	WHEN NOT MATCHED THEN INSERT
	(
		intAccountId,
		strDatabase,
		strAccountId
	)
	VALUES(
		MergedTable.intAccountId,
		MergedTable.strDatabase,
		MergedTable.strAccountId
	);', '[dbname]', @dbname)

	DECLARE  @DBExec NVARCHAR(MAX)
	  
	SET @DBExec =  N'.sys.sp_executesql';

	EXEC @DBExec @tSQL;


    DELETE FROM @tbl WHERE strDatabase = @dbname
END

