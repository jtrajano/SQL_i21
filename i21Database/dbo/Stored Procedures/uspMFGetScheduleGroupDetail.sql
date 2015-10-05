CREATE PROCEDURE [uspMFGetScheduleGroupDetail] @intScheduleRuleId INT
	,@intStart INT = 1
	,@intLimit INT = 1
	,@strFilterCriteria NVARCHAR(MAX) = ''
AS
SET NOCOUNT ON

DECLARE @strTableName NVARCHAR(50)
	,@strColumnName NVARCHAR(50)
	,@sqlCommand NVARCHAR(MAX)

SELECT @strTableName = A.strTableName
	,@strColumnName = A.strColumnName
FROM dbo.tblMFScheduleRule R
JOIN dbo.tblMFScheduleAttribute A ON A.intScheduleAttributeId = R.intScheduleAttributeId
WHERE R.intScheduleRuleId = @intScheduleRuleId

SET @sqlCommand = 'SELECT TOP '+LTRIM(@intLimit)+' * FROM (SELECT ' + @strColumnName + ' AS strName, ROW_NUMBER() OVER (ORDER BY ' + @strColumnName + ') AS intRowNumber
						FROM ' + @strTableName + '
						WHERE ' + @strColumnName + ' NOT IN (SELECT strGroupValue FROM dbo.tblMFScheduleGroupDetail) AND ' + @strColumnName + ' NOT IN (''' + @strFilterCriteria + ''')) AS DT WHERE intRowNumber > ' + LTRIM(@intStart) 

EXECUTE sp_executesql @sqlCommand
