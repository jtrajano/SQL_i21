﻿GO	
print N'BEGIN Update Delivery Fill Report Field Selection'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT


SET @strReportName = 'Delivery Fill Report'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


--------------------Update Field Selection (tblRMCriteriaField)--------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---Check and add ysnPending
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMCriteriaField WHERE intReportId = @intReportId AND strFieldName = 'ysnPending')
BEGIN
	INSERT INTO [tblRMCriteriaField]
           ([intReportId]
           ,[intCriteriaFieldSelectionId]
           ,[strFieldName]
           ,[strDataType]
           ,[strDescription]
           ,[strConditions]
           ,[ysnIsRequired]
           ,[ysnShow]
           ,[ysnAllowSort]
           ,[ysnEditCondition])
     SELECT
           [intReportId] = @intReportId
           ,[intCriteriaFieldSelectionId] = (SELECT TOP 1 intCriteriaFieldSelectionId FROM [tblRMCriteriaFieldSelection] WHERE strName = 'True/False')
           ,[strFieldName] = 'ysnPending'
           ,[strDataType] = 'Bool'
           ,[strDescription] = 'Pending Orders'
           ,[strConditions] = NULL
           ,[ysnIsRequired] = 0
           ,[ysnShow] = 1
           ,[ysnAllowSort] = 0
           ,[ysnEditCondition] = 1
END
ELSE
BEGIN
	UPDATE [tblRMCriteriaField]
	SET [strDescription] = 'Pending Orders'
	WHERE intReportId = @intReportId AND strFieldName = 'ysnPending'
END

IF EXISTS (SELECT TOP 1 1 FROM tblRMCriteriaField WHERE intReportId = @intReportId AND strFieldName = 'intNextDeliveryDegreeDay')
BEGIN
	UPDATE tblRMCriteriaField
	SET strConditions = 'Less Than Or Equal, Between'
		,ysnEditCondition = 1
	WHERE strFieldName = 'intNextDeliveryDegreeDay'
		AND intReportId = @intReportId
END

GO
print N'END Update Delivery Fill Report Field Selection'
GO