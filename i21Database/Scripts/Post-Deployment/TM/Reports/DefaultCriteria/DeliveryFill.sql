GO	
print N'BEGIN Update Delivery Fill Report Default Criteria'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT
DECLARE @intCriteriaFieldSelectionId INT

SET @strReportName = 'Delivery Fill Report'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup



--------------------Update Report Parameter (tblRMDefaultFilter)--------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---Check and add ysnPending
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = 'ysnPending')
BEGIN
	INSERT INTO [tblRMDefaultFilter]
           ([strBeginGroup]
           ,[strEndGroup]
           ,[strJoin]
           ,[intReportId]
           ,[strFieldName]
           ,[strDescription]
           ,[strFrom]
           ,[strTo]
           ,[strCondition]
           ,[strDataType]
           ,[intSortId]
           ,[intFilterConcurrencyId]
           ,[intUserId])
     SELECT
           [strBeginGroup] = 0
           ,[strEndGroup] = 0
           ,[strJoin] = 'And'
           ,[intReportId] = @intReportId
           ,[strFieldName] = 'ysnPending'
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = 'ysnPending' AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Equal To'
           ,[strDataType] = 'Bool'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = 'ysnPending' AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strFrom] = 'False'
	WHERE intReportId = @intReportId AND strFieldName = 'ysnPending'
           
END


GO
print N'END Update Delivery Fill Report Default Criteria'
GO