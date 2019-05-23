CREATE FUNCTION [dbo].[fnARParseReportParameter]
(
     @fieldname AS NVARCHAR(50)
	,@condition AS NVARCHAR(20)
    ,@from      AS NVARCHAR(100)
    ,@to        AS NVARCHAR(100)
    ,@join      AS NVARCHAR(10)
    ,@datatype  AS NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @Where AS NVARCHAR(MAX)
      , @LocalFrom  AS NVARCHAR(100)
      , @LocalTo    AS NVARCHAR(100)
SET @Where = NULL


IF(@datatype = 'DateTime')
BEGIN
    SET @LocalFrom = CAST(CAST((CASE WHEN ISNULL(@from,'') <> '' THEN @from ELSE CAST(-53690 AS DATETIME) END) AS DATE) AS NVARCHAR(100))
    SET @LocalTo = CAST(CAST((CASE WHEN ISNULL(@to,'') <> '' THEN @to ELSE GETDATE() END) AS DATE) AS NVARCHAR(100))
	SET @fieldname = 'CAST(' + @fieldname + ' AS DATE)'
END

IF(@datatype = 'Boolean')
BEGIN
    SET @LocalFrom = CAST(CAST((CASE WHEN ISNULL(ISNULL(@from, @to),'') <> '' THEN ISNULL(@from, @to) ELSE 0 END) AS BIT) AS NVARCHAR(100))
    SET @LocalTo = CAST(CAST((CASE WHEN ISNULL(@to,'') <> '' THEN @to ELSE 0 END) AS BIT) AS NVARCHAR(100))
END

IF(@datatype = 'int')
BEGIN
    SET @LocalFrom = CAST(CAST((CASE WHEN ISNULL(ISNULL(@from, @to),'') <> '' THEN ISNULL(@from, @to) ELSE 0 END) AS INT) AS NVARCHAR(100))
    SET @LocalTo = CAST(CAST((CASE WHEN ISNULL(@to,'') <> '' THEN @to ELSE 0 END) AS INT) AS NVARCHAR(100))
END

IF(@datatype = 'String')
BEGIN
    SET @LocalFrom = ISNULL(@from,'')
    SET @LocalTo = ISNULL(@to,'')
END

IF UPPER(@condition) = UPPER('Equal To')
BEGIN
    IF @datatype IN ('DateTime','String')
    BEGIN
        SET @LocalFrom = '''' + @LocalFrom + ''''
        SET @LocalTo = '''' + @LocalTo + ''''
    END

    SET @Where = @fieldname + ' = ' + @LocalFrom
END

IF UPPER(@condition) = UPPER('Not Equal To')
BEGIN
    IF @datatype IN ('DateTime','String')
    BEGIN
        SET @LocalFrom = '''' + @LocalFrom + ''''
        SET @LocalTo = '''' + @LocalTo + ''''
    END

    SET @Where = @fieldname + ' <> ' + @LocalFrom
END

IF UPPER(@condition) = UPPER('Like')
BEGIN
    SET @Where = @fieldname + ' LIKE ''%' + @LocalFrom + '%'''
END

IF UPPER(@condition) = UPPER('Not Like')
BEGIN
    SET @Where = @fieldname + ' NOT LIKE ''%' + @LocalFrom + '%'''
END

IF UPPER(@condition) = UPPER('Starts With')
BEGIN
    SET @Where = @fieldname + ' LIKE ''' + @LocalFrom + '%'''
END

IF UPPER(@condition) = UPPER('Ends With')
BEGIN
    SET @Where = @fieldname + ' LIKE ''%' + @LocalFrom + ''''
END

IF UPPER(@condition) = UPPER('Between')
BEGIN
    IF @datatype IN ('DateTime','String')
    BEGIN
        SET @LocalFrom = '''' + @LocalFrom + ''''
        SET @LocalTo = '''' + @LocalTo + ''''
    END

    SET @Where = @fieldname + ' BETWEEN ' + @LocalFrom + ' AND ' + @LocalTo
END

RETURN @Where + ' ' + ISNULL(@join, '') + ' '
END
