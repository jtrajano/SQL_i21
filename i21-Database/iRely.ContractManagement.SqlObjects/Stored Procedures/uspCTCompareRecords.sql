CREATE PROCEDURE [dbo].[uspCTCompareRecords]
	@strTblName	NVARCHAR(50),
	@intCompareWith INT,
	@intCompareTo INT,
	@strColumnsToIgnore NVARCHAR(MAX),
	@strModifiedColumns NVARCHAR(MAX) OUTPUT
AS

BEGIN TRY

	DECLARE @ErrMsg				NVARCHAR(MAX),
			@ORDINAL_POSITION	INT,
			@strSQL				NVARCHAR(MAX),
			@COLUMN_NAME		NVARCHAR(50),
			@ID_COLUMN			NVARCHAR(50),
			@ysnUnEqual			BIT

	SELECT @strModifiedColumns = ''

	DECLARE @tblColumns TABLE
	(
		DATA_TYPE					NVARCHAR(256),
		CHARACTER_MAXIMUM_LENGTH	INT,
		NUMERIC_PRECISION			TINYINT,
		NUMERIC_SCALE				INT,
		COLUMN_NAME					NVARCHAR(256),
		ORDINAL_POSITION			INT,
		ysnIdentity					BIT
	)

	INSERT INTO @tblColumns
	SELECT	DISTINCT DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION,NUMERIC_SCALE,COLUMN_NAME,ORDINAL_POSITION,
			ISNULL(CAST((COLUMNPROPERTY(OBJECT_ID(COL.TABLE_NAME),COL.COLUMN_NAME,'IsIdentity')) AS BIT),0) ysnIdentity
	FROM	INFORMATION_SCHEMA.COLUMNS COL 
	WHERE	COL.TABLE_NAME = @strTblName AND COLUMN_NAME NOT IN (SELECT * FROM dbo.fnSplitString(@strColumnsToIgnore,','))
	ORDER BY ORDINAL_POSITION

	SELECT @ID_COLUMN = COLUMN_NAME FROM @tblColumns WHERE ysnIdentity = 1

	SELECT @ORDINAL_POSITION = MIN(ORDINAL_POSITION) FROM @tblColumns WHERE ysnIdentity <> 1
	
	WHILE ISNULL(@ORDINAL_POSITION,0 ) > 0 
	BEGIN
		SELECT @COLUMN_NAME = COLUMN_NAME,@ysnUnEqual = NULL FROM @tblColumns WHERE ORDINAL_POSITION = @ORDINAL_POSITION

		SET @strSQL =	'IF	(SELECT ISNULL(LTRIM('+@COLUMN_NAME+'),'''') FROM '+@strTblName+' WHERE '+@ID_COLUMN+' = @intCompareWith) = 
							(SELECT ISNULL(LTRIM('+@COLUMN_NAME+'),'''') FROM '+@strTblName+' WHERE '+@ID_COLUMN+' = @intCompareTo)
							SELECT  @ysnUnEqual = 0
						ELSE
							SELECT  @ysnUnEqual = 1'

		EXEC sp_executesql @strSQL,N'@intCompareWith INT, @intCompareTo INT, @ysnUnEqual INT OUTPUT',@intCompareWith = @intCompareWith ,@intCompareTo = @intCompareTo ,@ysnUnEqual = @ysnUnEqual OUTPUT

		IF @ysnUnEqual = 1
		BEGIN
			SELECT @strModifiedColumns  = @strModifiedColumns + @COLUMN_NAME + ','
		END

		SELECT @ORDINAL_POSITION = MIN(ORDINAL_POSITION) FROM @tblColumns WHERE ysnIdentity <> 1 AND ORDINAL_POSITION > @ORDINAL_POSITION
	END

	IF LEN(@strModifiedColumns) > 1
		SET @strModifiedColumns = SUBSTRING(@strModifiedColumns,1, LEN(@strModifiedColumns) - 1)
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH