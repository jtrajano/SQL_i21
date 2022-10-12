CREATE PROCEDURE uspMFPartialUpdateBatch
	@strBatchId NVARCHAR(50),
	@column NVARCHAR(MAX),
	@MFBatchTableType MFBatchTableType READONLY
AS
DECLARE @tblColumn TABLE (col nvarchar(40))
DECLARE @col NVARCHAR(40)
DECLARE @Sql NVARCHAR(MAX) = ''

INSERT INTO @tblColumn(col)
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'tblMFBatch'

WHILE EXISTS(SELECT 1 FROM @tblColumn)
BEGIN
	SELECT TOP 1 @col = col FROM @tblColumn
	IF CHARINDEX (@col, @column ) > 0
	begin
		SET @Sql = @Sql + @col +'= T.' + @col + ',' 
	SELECT @Sql
	end
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
END