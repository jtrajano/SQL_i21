CREATE PROCEDURE uspMFPartialUpdateBatch
	@strBatchId NVARCHAR(50),
	@column NVARCHAR(MAX), --this should be comma separated and end with ','
	@MFBatchTableType MFBatchTableType READONLY
AS
DECLARE @tblColumn TABLE (col nvarchar(40))
DECLARE @col NVARCHAR(40)
DECLARE @Sql NVARCHAR(MAX) = ''

DECLARE @return INT = -1
--remove spaces
SET @column = LTRIM(RTRIM( REPLACE(@column,' ','')))
IF LEN(RTRIM(LTRIM(@column))) = 0
BEGIN
	RAISERROR('Column name parameter is empty', 16,1)
	RETURN @return
END

IF NOT EXISTS(SELECT 1 FROM @MFBatchTableType)
BEGIN
	RAISERROR('Table data parameter is empty', 16,1)
	RETURN @return
END

IF LEN(LTRIM(RTRIM(@strBatchId)))=0
BEGIN
	RAISERROR('Batch Id parameter is empty', 16,1)
	RETURN @return
END


-- sets column to lowercase
SET @column = LOWER(@column)
--ensures there is comma at the end of the column parameter
IF SUBSTRING(@column,LEN(@column), 1) <> ','
	SET @column = @column + ','



INSERT INTO @tblColumn(col)
SELECT A.COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS A 
WHERE A.COLUMN_NAME NOT IN(
	SELECT C.COLUMN_NAME
	FROM
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
	JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C
	ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME
	WHERE
	C.TABLE_NAME= A.TABLE_NAME
	AND C.COLUMN_NAME = A.COLUMN_NAME
	and T.CONSTRAINT_TYPE='PRIMARY KEY'
	UNION SELECT 'intBatchId' UNION SELECT 'strBatchId'
)
AND A.TABLE_NAME = N'tblMFBatch'



WHILE EXISTS(SELECT 1 FROM @tblColumn)
BEGIN
	SELECT TOP 1 @col = col FROM @tblColumn
	IF CHARINDEX (LOWER(@col)+',', @column ) > 0 -- checks colum with comma to be sure the whole column is compared
	BEGIN
		SET @Sql = @Sql + @col +'= T.' + @col + ',' 
	END
	DELETE FROM @tblColumn WHERE @col = col
END
IF LEN(@Sql) > 0
BEGIN
	SET @Sql = SUBSTRING(@Sql,1 ,LEN(@Sql)-1)
	SET @Sql =
	'UPDATE A SET ' + @Sql + 
	' FROM tblMFBatch A OUTER APPLY(SELECT * FROM @_MFBatchTableType)T WHERE @_strBatchId = strBatchId'
	EXECUTE sp_executesql @Sql,
	N'@_strBatchId NVARCHAR(50), @_column NVARCHAR(MAX),@_MFBatchTableType MFBatchTableType',
	@_strBatchId=@strBatchId,@_column=@column, @_MFBatchTableType=@MFBatchTableType

	SET @return = 1
END

RETURN @return