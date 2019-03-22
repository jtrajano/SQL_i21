CREATE PROCEDURE [dbo].[uspAPDuplicateRecord]
    @tableName VARCHAR(MAX),
    @keyName VARCHAR(MAX),
    @oldKeyId INT,
    @newTableId INT OUTPUT
AS
    DECLARE @sqlCommand NVARCHAR(MAX),
            @columnList VARCHAR(MAX);

    SELECT  @columnList = COALESCE(@columnList + ',','') + sys.columns.name
    FROM    sys.columns
    WHERE   OBJECT_NAME(sys.columns.object_id) = @tableName
        and sys.columns.name not in ( @keyName )
        and is_computed = 0;

    SET @sqlCommand = 'insert into ' + @tableName + ' ( ' + @columnList + ') (' +
        'select ' + @columnList + ' from ' + @tableName + ' where ' + @keyName + ' = @oldKeyId )'
    EXEC sp_executesql @sqlCommand, N'@oldKeyId int', @oldKeyId = @oldKeyId
    SELECT @newTableId = @@IDENTITY