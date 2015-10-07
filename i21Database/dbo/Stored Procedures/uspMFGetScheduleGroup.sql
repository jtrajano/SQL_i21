CREATE PROCEDURE uspMFGetScheduleGroup @intScheduleGroupId INT
AS
SET NOCOUNT ON

DECLARE @strTableName NVARCHAR(50)
	,@strColumnName NVARCHAR(50)
	,@sqlCommand NVARCHAR(MAX)
	,@intScheduleRuleId INT

SELECT *
FROM dbo.tblMFScheduleGroup
WHERE intScheduleGroupId = @intScheduleGroupId

SELECT @intScheduleRuleId = intScheduleRuleId
FROM dbo.tblMFScheduleGroup
WHERE intScheduleGroupId = @intScheduleGroupId

SELECT @strTableName = A.strTableName
	,@strColumnName = A.strColumnName
FROM dbo.tblMFScheduleRule R
JOIN dbo.tblMFScheduleAttribute A ON A.intScheduleAttributeId = R.intScheduleAttributeId
WHERE R.intScheduleRuleId = @intScheduleRuleId

SET @sqlCommand = 'SELECT GD.*,
						(SELECT Top 1 strDescription FROM ' + @strTableName + ' WHERE ' + @strColumnName + ' = GD.strGroupValue) AS strDescription 
						FROM dbo.tblMFScheduleGroupDetail GD WHERE intScheduleGroupId=' + LTRIM(@intScheduleGroupId)

EXECUTE sp_executesql @sqlCommand
