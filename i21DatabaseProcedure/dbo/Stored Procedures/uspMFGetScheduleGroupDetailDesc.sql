CREATE PROCEDURE uspMFGetScheduleGroupDetailDesc @intScheduleRuleId INT
	,@strGroupValue NVARCHAR(50)
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

SET @sqlCommand = 'SELECT Top 1 strDescription FROM ' + @strTableName + ' WHERE ' + @strColumnName + ' = ''' + @strGroupValue + ''''

EXECUTE sp_executesql @sqlCommand
