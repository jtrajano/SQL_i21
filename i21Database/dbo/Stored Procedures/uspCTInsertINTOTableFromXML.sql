CREATE PROCEDURE [dbo].[uspCTInsertINTOTableFromXML]

	@strTblName NVARCHAR(MAX),
	@XML		NVARCHAR(MAX)
	
AS

BEGIN TRY

	DECLARE @strColumns		NVARCHAR(MAX),
			@strXMLColumns	NVARCHAR(MAX),
			@ErrMsg			NVARCHAR(MAX),
			@idoc			INT,
			@strSQL			NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..##tblColumns') IS NOT NULL  	
		DROP TABLE ##tblColumns	

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML ,'<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'

	SELECT	DISTINCT COL.*, 
			CAST((COLUMNPROPERTY(OBJECT_ID(COL.TABLE_NAME),COL.COLUMN_NAME,'IsIdentity')) AS BIT) ysnIdentity
	INTO	##tblColumns
	FROM	INFORMATION_SCHEMA.COLUMNS COL 
	WHERE	COL.TABLE_NAME = @strTblName
	ORDER BY ORDINAL_POSITION

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
							 WHEN DATA_TYPE	= 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
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
	SET @strSQL += ' SELECT ' + @strColumns + ' FROM OPENXML(@idoc, '''+@strTblName+'s/'+@strTblName+''',2) WITH('+@strXMLColumns+')'
	SET @strSQL += ' SELECT CAST(SCOPE_IDENTITY() AS INT)'
	
	EXEC sp_executesql @strSQL,N'@idoc INT',@idoc = @idoc

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