GO	
print N'BEGIN Update Delivery Fill Report Field Selection'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT


SET @strReportName = 'Device Lease Detail'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


--------------------Update Field Selection (tblRMCriteriaField)--------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---Check and add dblTankSize
IF EXISTS (SELECT TOP 1 1 FROM tblRMCriteriaField WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize')
BEGIN
	DELETE FROM tblRMCriteriaField WHERE intReportId = @intReportId AND strFieldName = 'dblTankSize'
END

GO
print N'END Update Delivery Fill Report Field Selection'
GO