GO	
print N'BEGIN Update Regulator Information Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Regulator Information'
SET @strReportGroup = 'Sub Report'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
SELECT E.intDeviceId
	, B.vwcus_key as agcus_key
	, E.strManufacturerID
	, E.strManufacturerName
	, E.dtmManufacturedDate
	, E.strDescription
	, C.intSiteNumber
FROM 	tblTMCustomer A inner join vwcusmst B on A.intCustomerNumber = B.A4GLIdentity 
INNER JOIN tblTMSite C 
	ON A.intCustomerID = C.intCustomerID
INNER JOIN tblTMSiteDevice D 
	ON C.intSiteID =D.intSiteID 
INNER JOIN tblTMDevice E 
	ON D.intDeviceId = E.intDeviceId AND ysnAppliance = 0
INNER JOIN tblTMDeviceType F 
	ON E.intDeviceTypeId = F.intDeviceTypeId
WHERE F.strDeviceType IN (''Regulator'',''REGULATOR'')

' 
WHERE intReportId = @intReportId

GO
print N'END Update Regulator Information Report Datasource'
GO