GO
PRINT N'BEGIN Update Device Lease Detail Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Device Actions'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
	SELECT 
		ISNULL(A.dblTankCapacity,0) as dblTankCapacity
		, A.strBulkPlant as strLocation
		, C.intSiteNumber
		, A.strSerialNumber
		, D.dtmDate
		, (Select Top 1 tt.strTankType From tblTMTankType tt Where tt.intTankTypeId = A.intTankTypeId) AS [strTankType]
		, A.strOwnership
		,(Case WHEN F.vwcus_first_name IS NULL OR F.vwcus_first_name = ''''  THEN
			RTRIM(F.vwcus_last_name)
			ELSE
			RTRIM(F.vwcus_last_name) + '', '' + RTRIM(F.vwcus_first_name)
		 END) as CustomerName 
		, (Case C.ysnActive
			When 1 then
			''Active''
			When 0 then
			''Inactive''
			When NUll then
			''Inactive'' 
			End) as SiteStatus
		, (Case F.vwcus_active_yn
			When ''Y'' then
			''Active''
			When ''N'' then
			''Inactive''
		End) as CustomerStatus
		, G.strDescription 
		, F.vwcus_key
		, C.strSiteAddress
		, C.intSiteID
		,C.intCustomerID
		,H.strDeviceType
		,A.ysnAppliance
	FROM tblTMEvent D
	LEFT JOIN tblTMDevice A ON D.intDeviceId = A.intDeviceId
	LEFT JOIN tblTMSite C ON ISNULL(D.intSiteID,0) = C.intSiteID
	LEFT JOIN tblTMEventType G ON D.intEventTypeID = G.intEventTypeID
	LEFT JOIN tblTMCustomer E ON C.intCustomerID = E.intCustomerID
	LEFT JOIN vwcusmst F on E.intCustomerNumber = F.A4GLIdentity
	LEFT JOIN tblTMDeviceType H ON A.intDeviceTypeId = H.intDeviceTypeId
	WHERE ysnAppliance = 0 

' 
WHERE intReportId = @intReportId

GO
PRINT N'END Update Device Lease Detail Datasource'
GO