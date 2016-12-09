CREATE PROCEDURE [dbo].[uspCTGetTableDataInXML]
	@TableName		NVARCHAR(MAX),
	@Condition		NVARCHAR(MAX),
	@XML			NVARCHAR(MAX) OUTPUT,
	@TagName		NVARCHAR(MAX) = NULL,
	@Columns		NVARCHAR(MAX) = NULL
AS
BEGIN
	
	IF ISNULL(@TagName,'') = ''
    BEGIN
		SET @TagName = REPLACE(@TableName,'#','')
    END

    IF ISNULL(@Condition,'') <> ''
    BEGIN
		SET @Condition = ' WHERE ' + @Condition + ' '
    END

	IF ISNULL(@Columns,'') = ''
	BEGIN
		SET	@Columns = '*'
	END

	IF @TableName LIKE '#%'
	BEGIN
	 SELECT @TableName = object_name
						(
							object_id('tempdb..'+@TableName),
							(SELECT database_id from sys.databases WHERE name = 'tempdb')
						)
    END
    
	DECLARE @SQL NVARCHAR(MAX)	
	SET @SQL = ' 
	SELECT @TableData = (												
	SELECT '+@Columns+' ' +'   												
	FROM '+@TableName+' '+@TagName + ISNULL(@Condition,'') +'												
	FOR XML AUTO, ELEMENTS,root('''+@TagName+'s'') 												
	)'	

	EXEC sp_executesql @SQL,N'@TableData NVARCHAR(MAX) OUTPUT',@TableData = @XML OUTPUT
END