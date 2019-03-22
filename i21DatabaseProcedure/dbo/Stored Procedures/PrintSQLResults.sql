CREATE PROCEDURE [dbo].[PrintSQLResults] 
    @query NVARCHAR(MAX)
	, @Results NVARCHAR(MAX) OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @cols NVARCHAR(MAX)
	, @displayCols NVARCHAR(MAX)
	, @sql NVARCHAR(MAX)
	, @printableResults NVARCHAR(MAX)
	, @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
	, @Tab AS CHAR(9) = CHAR(9)

IF EXISTS (SELECT * FROM tempdb.sys.tables WHERE name = '##PrintSQLResultsTempTable')
	DROP TABLE ##PrintSQLResultsTempTable

SET @query = REPLACE(@query, 'from', ' into ##PrintSQLResultsTempTable from')

EXEC(@query);

SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID12345XYZ
	, *
INTO #PrintSQLResultsTempTable
FROM ##PrintSQLResultsTempTable

DROP TABLE ##PrintSQLResultsTempTable

SELECT name
INTO #PrintSQLResultsTempTableColumns
FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..#PrintSQLResultsTempTable')

SELECT @cols = STUFF(((SELECT ' , space(1) + ' + name as [text()]
					FROM #PrintSQLResultsTempTableColumns
					WHERE name != 'ID12345XYZ'
					FOR XML PATH(''), ROOT('str'), TYPE).value('/str[1]','NVARCHAR(MAX)')),1,0,'''''')

SELECT @displayCols = STUFF(((SELECT space(1) + name as [text()]
							FROM #PrintSQLResultsTempTableColumns
							WHERE name != 'ID12345XYZ'
							FOR XML PATH(''), ROOT('str'), TYPE).value('/str[1]','NVARCHAR(MAX)')),1,0,'');

DECLARE @tableCount INT = (SELECT COUNT(*) FROM #PrintSQLResultsTempTable)
DECLARE @i int = 1

WHILE @i <= @tableCount
BEGIN
    SET @sql = N'select @printableResults = concat(@printableResults, ' + @cols + ', @NewLineChar) from #PrintSQLResultsTempTable where ID12345XYZ = ' + CAST(@i as varchar(10))
    
    EXECUTE sp_executesql @sql, N'@NewLineChar char(2), @printableResults nvarchar(max) output', @NewLineChar = @NewLineChar, @printableResults = @printableResults output

	IF (@i = 1)
	BEGIN
		IF (SUBSTRING(@printableResults, 0, 11) = ' UNION ALL')
		BEGIN
			SET @printableResults = SUBSTRING(@printableResults, 11, LEN(@printableResults) - 10)
		END
	END

    PRINT @printableResults
    SET @printableResults = NULL;
    SET @i += 1;
END