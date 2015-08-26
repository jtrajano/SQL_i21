GO	
print N'BEGIN Update Tank Information Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Tank Information'
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
	, E.strSerialNumber
	, E.dblTankCapacity
	, C.intSiteNumber
	, ISNULL(G.strTankType,'''') AS [strTankType]
	, F.strDeviceType
FROM tblTMCustomer A 
INNER JOIN vwcusmst B 
	ON A.intCustomerNumber = B.A4GLIdentity 
INNER JOIN tblTMSite C 
	ON A.intCustomerID = C.intCustomerID
INNER JOIN tblTMSiteDevice D 
	ON C.intSiteID =D.intSiteID 
INNER JOIN tblTMDevice E 
	ON D.intDeviceId = E.intDeviceId AND ysnAppliance = 0  
INNER JOIN tblTMDeviceType F 
	ON E.intDeviceTypeId = F.intDeviceTypeId
LEFT JOIN tblTMTankType G
	ON E.intTankTypeId = G.intTankTypeId
WHERE F.strDeviceType IN (''Tank'',''TANK'')

' 
WHERE intReportId = @intReportId

GO
print N'END Update Tank Information Report Datasource'
GO