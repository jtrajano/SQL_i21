CREATE PROCEDURE uspGLUpdateFiscalAccountOverride
AS
BEGIN

declare @columns NVARCHAR(500)
declare @columnnumber NVARCHAR(30)

DECLARE @strOverrideREArray NVARCHAR(10)
SELECT TOP 1 @strOverrideREArray = strOverrideREArray FROM tblGLCompanyPreferenceOption
DECLARE @tbl TABLE (Item INT)
INSERT INTO @tbl(Item)
select cast( Item as int) Item from  dbo.fnSplitString(@strOverrideREArray,',');

DECLARE @ysnOverrideFirstColumn bit = 0
DECLARE @ysnOverrideSecondColumn bit = 0
DECLARE @ysnOverrideThirdColumn bit = 0


IF EXISTS(SELECT 1 FROM @tbl WHERE Item = 1)
	select @ysnOverrideFirstColumn = 1
IF EXISTS(SELECT 1 FROM @tbl WHERE Item = 2)
	select @ysnOverrideSecondColumn = 1
IF EXISTS(SELECT 1 FROM @tbl WHERE Item = 3)
	select @ysnOverrideThirdColumn = 1

DECLARE @maxColId INT 

SELECT @maxColId = max(ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'tblGLTempCOASegment'


IF @maxColId = 6
	GOTO _max6
IF @maxColId = 5
	GOTO _max5
IF @maxColId = 4
	GOTO _max4



_max7:
;WITH QUERY as(

SELECT 'Column' as col,[3],[4],[5],[6],[7] FROM (
	SELECT ORDINAL_POSITION, COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = N'tblGLTempCOASegment'
	AND COLUMN_NAME NOT IN('intAccountId', 'strAccountId')
) AS tempTable

PIVOT(
	min (COLUMN_NAME)
	for ORDINAL_POSITION in([3],[4],[5],[6],[7])

) DAS
)
SELECT @columns ='[' + [3] + '] + ''-''' +
case when @ysnOverrideFirstColumn = 1 then '+ replicate(''X'', LEN([' + [4] + '])) + ''-'''  else  '+ [' + [4] + '] + ''-''' end  + 
case when @ysnOverrideSecondColumn = 1 then '+ replicate(''X'', LEN([' +[5] + '])) + ''-'''  else  '+ [' + [5] + '] + ''-''' end  + 
case when @ysnOverrideThirdColumn = 1 then '+ replicate(''X'', LEN([' + [6] + '])) + ''-'''  else  '+ [' + [6] + '] + ''-''' end  + 
 '+ [' + [7] + ']'   
FROM QUERY
GOTO _execute
_max6:
	;WITH QUERY as(

SELECT 'Column' as col,[3],[4],[5],[6] FROM (
	SELECT ORDINAL_POSITION, COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = N'tblGLTempCOASegment'
	AND COLUMN_NAME NOT IN('intAccountId', 'strAccountId')
	--order by ORDINAL_POSITION
) AS tempTable

PIVOT(
	min (COLUMN_NAME)
	for ORDINAL_POSITION in([3],[4],[5],[6])

) DAS
)
SELECT @columns ='[' + [3] + '] + ''-''' +
case when @ysnOverrideFirstColumn = 1 then '+ replicate(''X'', LEN([' + [4] + '])) + ''-'''  else  '+ [' + [4] + '] + ''-''' end  + 
case when @ysnOverrideSecondColumn = 1 then '+ replicate(''X'', LEN([' +[5] + '])) + ''-'''  else  '+ [' + [5] + '] + ''-''' end  + 
case when @ysnOverrideThirdColumn = 1 then '+ replicate(''X'', LEN([' + [6] + ']))'  else  '+ [' + [6] + ']' end  
FROM QUERY
GOTO _execute
_max5:
;WITH QUERY as(

SELECT 'Column' as col,[3],[4],[5] FROM (
	SELECT ORDINAL_POSITION, COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = N'tblGLTempCOASegment'
	AND COLUMN_NAME NOT IN('intAccountId', 'strAccountId')
	--order by ORDINAL_POSITION
) AS tempTable

PIVOT(
	min (COLUMN_NAME)
	for ORDINAL_POSITION in([3],[4],[5])

) DAS
)
SELECT @columns ='[' + [3] + '] + ''-''' +
case when @ysnOverrideFirstColumn = 1 then '+ replicate(''X'', LEN([' + [4] + '])) + ''-'''  else  '+ [' + [4] + '] + ''-''' end  + 
case when @ysnOverrideSecondColumn = 1 then '+ replicate(''X'', LEN([' +[5] + ']))'  else  '+ [' + [5] + ']' end
FROM QUERY
GOTO _execute
_max4:
;WITH QUERY as(

SELECT 'Column' as col,[3],[4] FROM (
	SELECT ORDINAL_POSITION, COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = N'tblGLTempCOASegment'
	AND COLUMN_NAME NOT IN('intAccountId', 'strAccountId')
	--order by ORDINAL_POSITION
) AS tempTable

PIVOT(
	min (COLUMN_NAME)
	for ORDINAL_POSITION in([3],[4])

) DAS
)
SELECT @columns ='[' + [3] + '] + ''-''' +
case when @ysnOverrideFirstColumn = 1 then '+ replicate(''X'', LEN([' + [4] + ']))'  else  '+ [' + [4] + ']' end 
FROM QUERY

_execute:
declare @sql nvarchar(max) =
 'TRUNCATE TABLE tblGLREMaskAccount insert into tblGLREMaskAccount(intAccountId, strAccountId, intConcurrencyId, dtmModified) select intAccountId,' + @columns +', 1, getdate()  from tblGLTempCOASegment'
EXEC (@sql)

END
