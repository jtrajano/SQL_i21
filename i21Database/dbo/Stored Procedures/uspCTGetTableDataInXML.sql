CREATE PROCEDURE [dbo].[uspCTGetTableDataInXML]
	@TableName		NVARCHAR(MAX),
	@XML			NVARCHAR(MAX) OUTPUT,
	@TagName		NVARCHAR(MAX) = NULL
AS
BEGIN
	
	IF @TagName IS NULL
    BEGIN
		SET @TagName = REPLACE(@TableName,'#','')
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
	SELECT * 												
	FROM '+@TableName+' '+@TagName+'												
	FOR XML AUTO, ELEMENTS,root('''+@TagName+'s'') 												
	)'	

	EXEC sp_executesql @SQL,N'@TableData NVARCHAR(MAX) OUTPUT',@TableData = @XML OUTPUT
END