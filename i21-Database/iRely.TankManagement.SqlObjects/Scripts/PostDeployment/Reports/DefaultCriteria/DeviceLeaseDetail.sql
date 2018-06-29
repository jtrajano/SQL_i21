GO	
print N'BEGIN Update Delivery Fill Report Default Criteria'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT
DECLARE @intCriteriaFieldSelectionId INT

SET @strReportName = 'Device Lease Detail'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup



--------------------Update Report Parameter (tblRMDefaultFilter)--------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--Remove dblTankSize
IF EXISTS (SELECT TOP 1 1 FROM tblRMDefaultFilter WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize')
BEGIN
	DELETE FROM tblRMDefaultFilter  WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize'
END

IF EXISTS (SELECT TOP 1 1 FROM tblRMFilter WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize')
BEGIN
	DELETE FROM tblRMFilter  WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize'
END

GO
print N'END Update Delivery Fill Report Default Criteria'
GO