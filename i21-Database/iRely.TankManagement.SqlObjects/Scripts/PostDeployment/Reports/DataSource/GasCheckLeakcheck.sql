GO	
print N'BEGIN Update Leak Check / Gas Check Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Leak Check / Gas Check'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
	SELECT 

		  '''' AS strCustomerFirstName
		  ,'''' AS strCustomerLastName
		  ,'''' AS strCustomerStatus
		  ,'''' AS strCustomerNumber
		  ,'''' AS strCustomerName
		  ,getdate() AS dtmDate
		  ,0 AS intSiteID
		  ,0 AS intSiteNumber
		  ,'''' AS strSerialNumber
		  ,0 AS intLocationTotalTanks
		  ,'''' AS strSiteStatus
		  ,'''' AS strLocation
		  ,'''' AS strOwnership
		  ,'''' AS strTankType
		  ,0 AS ysnHasLeakGasCheck
		  ,0 AS intGrandTotalTanks
		  ,0.0 AS dblTankSize
		  ,0 AS intLocationTotalWithCheck
		  ,0 AS intGrandTotalWithCheck
		  ,0.0 AS dblGrandPercentWithCheck 
		  ,0.0 AS dblLocationPercentWithCheck
		  ,0.0 AS dblGrandPercentWithOutCheck
		  ,0.0 AS dblLocationPercentWithOutCheck
' 
WHERE intReportId = @intReportId

GO
print N'END Update Leak Check / Gas Check Route Report Datasource'
GO