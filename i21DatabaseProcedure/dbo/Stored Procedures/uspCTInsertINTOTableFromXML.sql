CREATE PROCEDURE [dbo].[uspCTInsertINTOTableFromXML]

	@strTblName			NVARCHAR(MAX),
	@XML				NVARCHAR(MAX),
	@intId				INT = NULL OUTPUT,
	@strTagRelaceXML	NVARCHAR(MAX) = NULL
	
AS

BEGIN TRY

	SET ANSI_WARNINGS ON

	DECLARE @strColumns		NVARCHAR(MAX),
			@strXMLColumns	NVARCHAR(MAX),
			@ErrMsg			NVARCHAR(MAX),
			@idoc			INT,
			@idoc2			INT,
			@strSQL			NVARCHAR(MAX),
			@intUniqueId    INT,
			@toFind			NVARCHAR(MAX),		
			@toReplace		NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..##tblColumns') IS NOT NULL  	
		DROP TABLE ##tblColumns	

	CREATE TABLE ##tblColumns
	(
		DATA_TYPE					NVARCHAR(256),
		CHARACTER_MAXIMUM_LENGTH	INT,
		NUMERIC_PRECISION			TINYINT,
		NUMERIC_SCALE				INT,
		COLUMN_NAME					NVARCHAR(256),
		ORDINAL_POSITION			INT,
		ysnIdentity					BIT,
	)

	EXEC sp_xml_preparedocument @idoc2 OUTPUT, @strTagRelaceXML

	IF OBJECT_ID('tempdb..#TagsTable') IS NOT NULL  	
		DROP TABLE #TagsTable

	SELECT	ROW_NUMBER() OVER (ORDER BY toFind ASC) intUniqueId,*
	INTO	#TagsTable
	FROM	OPENXML(@idoc2, 'root/tags',2)
	WITH
	(
			toFind			NVARCHAR(MAX),
			toReplace		NVARCHAR(MAX)
	)  
	
	SELECT @intUniqueId= MIN(intUniqueId) FROM #TagsTable
	
	WHILE	ISNULL(@intUniqueId,0) > 0
	BEGIN
			SELECT	@toFind = toFind, @toReplace = toReplace FROM #TagsTable WHERE intUniqueId = @intUniqueId
			SELECT	@XML = REPLACE(@XML,@toFind,@toReplace)
			
			SELECT	@intUniqueId= MIN(intUniqueId) FROM #TagsTable WHERE intUniqueId > @intUniqueId
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML ,'<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'
	
	IF @strTblName LIKE '#%'
	BEGIN
		INSERT INTO ##tblColumns
		SELECT	DISTINCT DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION,NUMERIC_SCALE,COLUMN_NAME,ORDINAL_POSITION,
				ISNULL(CAST((COLUMNPROPERTY(OBJECT_ID(COL.TABLE_NAME),COL.COLUMN_NAME,'IsIdentity')) AS BIT),0) ysnIdentity
		FROM	tempdb.INFORMATION_SCHEMA.COLUMNS COL 
		WHERE	COL.TABLE_NAME LIKE @strTblName+'%' AND COL.COLUMN_NAME <> 'intCompanyId'
		ORDER BY ORDINAL_POSITION
	END
	ELSE
	BEGIN
		INSERT INTO ##tblColumns
		SELECT	DISTINCT DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION,NUMERIC_SCALE,COLUMN_NAME,ORDINAL_POSITION,
				ISNULL(CAST((COLUMNPROPERTY(OBJECT_ID(COL.TABLE_NAME),COL.COLUMN_NAME,'IsIdentity')) AS BIT),0) ysnIdentity
		FROM	INFORMATION_SCHEMA.COLUMNS COL 
		WHERE	COL.TABLE_NAME = @strTblName AND COL.COLUMN_NAME <> 'intCompanyId'
		ORDER BY ORDINAL_POSITION
	END
	
	SELECT TOP 1 @strColumns = 
				STUFF(													
				   (SELECT											
						', ' + COLUMN_NAME									
						FROM ##tblColumns	
						WHERE ysnIdentity <> 1							
						ORDER BY ORDINAL_POSITION									
						FOR XML PATH(''), TYPE									
				   ).value('.','varchar(max)')											
				   ,1,2, ''											
			  ) 											
	FROM ##tblColumns CH														
	
	SELECT @strXMLColumns =
				STUFF(													
				   (SELECT											
						', ' + COLUMN_NAME +' ' + DATA_TYPE	+
						CASE WHEN DATA_TYPE	= 'nvarchar' THEN '('+CASE WHEN LTRIM(CHARACTER_MAXIMUM_LENGTH) = '-1' THEN 'MAX' ELSE LTRIM(CHARACTER_MAXIMUM_LENGTH) END+')'
							 WHEN DATA_TYPE	IN('numeric','DECIMAL') THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
							 ELSE ''
						END + ' '+ ''''+COLUMN_NAME+'[not(@xsi:nil = "true")]'''
						FROM ##tblColumns	
						WHERE ysnIdentity <> 1							
						ORDER BY ORDINAL_POSITION									
						FOR XML PATH(''), TYPE									
				   ).value('.','varchar(max)')											
				   ,1,2, ''											
			  ) 											
	FROM ##tblColumns CH
	WHERE ORDINAL_POSITION = 1
	
	SET @strSQL  = ''
	SET @strSQL  = ' INSERT INTO ' + @strTblName + '('+@strColumns+') '
	SET @strSQL += ' SELECT ' + @strColumns + ' FROM OPENXML(@idoc, '''+REPLACE(@strTblName,'#','')+'s/'+REPLACE(@strTblName,'#','')+''',2) WITH('+@strXMLColumns+')'
	SET @strSQL += ' SELECT @intId = CAST(SCOPE_IDENTITY() AS INT)'
	
	EXEC sp_executesql @strSQL,N'@idoc INT,@intId INT OUTPUT',@idoc = @idoc,@intId = @intId OUTPUT

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTInsertINTOTableFromXML - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO

/* For Debug
DECLARE @strColumns		NVARCHAR(MAX),
			@strXMLColumns	NVARCHAR(MAX),
			@ErrMsg			NVARCHAR(MAX),
			@idoc			INT,
			@strSQL			NVARCHAR(MAX),
			@strTblName     NVARCHAR(MAX),
			@XML            NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML ,'<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'

	select
*/