GO
PRINT N'BEGIN Update Device Lease Detail Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Device Lease Detail'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
	SELECT 
		vwcst.vwcus_key as [strCustomerNumber]
		,(Case WHEN vwcst.vwcus_first_name IS NULL OR vwcst.vwcus_first_name = ''''  THEN
		RTRIM(vwcst.vwcus_last_name)
		ELSE
		RTRIM(vwcst.vwcus_last_name) + '', '' + RTRIM(vwcst.vwcus_first_name)
			END) as CustomerName
		,st.intSiteNumber
		,dvctyp.strDeviceType
		,dvc.dblTankCapacity
		,dvc.strSerialNumber
		,ls.strLeaseStatus
		,ls.dtmStartDate 
		,ls.dtmLastLeaseBillingDate
		,RTRIM(lcd.strLeaseCode) + ''-'' + RTRIM(lcd.strDescription) AS [strLeaseDescription]
		,(CASE vwcst.vwcus_active_yn
			WHEN ''Y'' THEN
				 ''Active''
			WHEN ''N'' THEN
				''Inactive''
		  END) AS [strCustomerStatus]
		,(Case st.ysnActive
			When 1 then
				''Active''
			When 0 then
				''Inactive''
			End) AS [strSiteStatus]
		,st.strLocation AS [strSiteLocation]

	FROM tblTMCustomer cust
	INNER JOIN vwcusmst vwcst ON
				cust.intCustomerNumber = vwcst.A4GLIdentity
	INNER JOIN tblTMSite st ON
				cust.intCustomerID = st.intCustomerID
	INNER JOIN tblTMSiteDevice stdvc ON
				st.intSiteID = stdvc.intSiteID
	INNER JOIN tblTMDevice dvc ON
				stdvc.intDeviceId = dvc.intDeviceId
	INNER JOIN tblTMDeviceType dvctyp ON
				dvc.intDeviceTypeId = dvctyp.intDeviceTypeId
	INNER JOIN tblTMLease ls ON
				ls.intLeaseId = dvc.intLeaseId
	INNER JOIN tblTMLeaseCode lcd ON
				lcd.intLeaseCodeId = ls.intLeaseCodeId

' 
WHERE intReportId = @intReportId

GO
PRINT N'END Update Device Lease Detail Datasource'
GO