GO	
print N'BEGIN Update Customer List by Route Default Criteria'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT
DECLARE @intCriteriaFieldSelectionId INT
DECLARE @strFieldName NVARCHAR(100)

SET @strReportName = 'Customer List by Route'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup



--------------------Update Report Parameter (tblRMDefaultFilter)--------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

---Check and update intRouteId
SET @strFieldName = 'intRouteId'
IF EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET	
		[strFieldName] = 'strRouteId'
		,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = 'strRouteId' AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
END

---Check and add strLocation
SET @strFieldName = 'strLocation'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Between'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add strRouteId
SET @strFieldName = 'strRouteId'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Between'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add CustomerName
SET @strFieldName = 'CustomerName'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Between'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add strFillMethod
SET @strFieldName = 'strFillMethod'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Equal To'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add customerStatus
SET @strFieldName = 'customerStatus'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Equal To'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add siteStatus
SET @strFieldName = 'siteStatus'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Equal To'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

---Check and add strOwnership
SET @strFieldName = 'strOwnership'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = @strFieldName)
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
           ,[strFieldName] = @strFieldName
           ,[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[strFrom] = NULL
           ,[strTo] = NULL
           ,[strCondition] = 'Equal To'
           ,[strDataType] = 'String'
           ,[intSortId] = 0
           ,[intFilterConcurrencyId] = (SELECT TOP 1 intConcurrencyId FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
           ,[intUserId] = 0
END
ELSE
BEGIN
	UPDATE [tblRMDefaultFilter] 
	SET		[strDescription] = (SELECT TOP 1 strDescription FROM tblRMCriteriaField WHERE strFieldName = @strFieldName AND intReportId = @intReportId)
	WHERE intReportId = @intReportId AND strFieldName = @strFieldName
           
END

GO
print N'END Update Delivery Fill Report Default Criteria'
GO