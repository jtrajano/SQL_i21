CREATE PROCEDURE [uspMFGetScheduleGroupDetail] @intScheduleRuleId INT
	,@intStart INT = 1
	,@intLimit INT = 1
	,@strFilterCriteria NVARCHAR(MAX) = ''
AS
SET NOCOUNT ON

DECLARE @strTableName NVARCHAR(50)
	,@strColumnName NVARCHAR(50)
	,@sqlCommand NVARCHAR(MAX)

SELECT @strTableName = strTableName
	,@strColumnName = A.strColumnName
FROM dbo.tblMFScheduleRule R
JOIN dbo.tblMFScheduleAttribute A ON A.intScheduleAttributeId = R.intScheduleAttributeId
WHERE R.intScheduleRuleId = @intScheduleRuleId

SET @sqlCommand = 'Select *from (SELECT ' + @strColumnName + ' As strName,Row_Number()Over(Order By ' + @strColumnName + ') As Row_Number
						FROM ' + @strTableName + '
						WHERE ' + @strColumnName + ' not in (Select strGroupValue from tblMFScheduleGroupDetail) and ' + @strColumnName + ' not in (''' + @strFilterCriteria + ''')) As DT Where Row_Number Between ' + ltrim(@intStart) + ' and ' + ltrim(@intStart + @intLimit)

EXECUTE sp_executesql @sqlCommand
