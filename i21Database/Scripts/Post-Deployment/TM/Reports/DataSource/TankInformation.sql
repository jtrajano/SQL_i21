GO	
print N'BEGIN Update Delivery Fill Group Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Delivery Fill Group'
SET @strReportGroup = 'Sub Report'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
SELECT a.vwcus_key as agcus_key
	, a.vwcus_first_name as agcus_first_name
	, a.vwcus_last_name as agcus_last_name
	, c.intSiteNumber
	, REPLACE(c.strSiteAddress,Char(13),'' '') as strSiteAddress
	, c.strDescription as strSiteDescription
	, ISNULL(d.strFillGroupCode, '''') as strFillGroupCode
	, d.intFillGroupId 
	, d.strDescription
	, (Case d.ysnActive
		When 1 then
			''Yes''
		When 0 then
			''No''
		End) as ysnActive
FROM vwcusmst a 
INNER JOIN tblTMCustomer b 
	ON a.A4GLIdentity = b.intCustomerNumber 
INNER JOIN tblTMSite c 
	ON b.intCustomerID = c.intCustomerID 
INNER JOIN tblTMFillGroup d 
	ON d.intFillGroupId = c.intFillGroupId
WHERE ISNULL(c.ysnActive,0) = 1 AND  ISNULL(a.vwcus_active_yn,'''') = ''Y'' AND (c.ysnOnHold = 0 OR c.dtmOnHoldEndDate < GetDate()) 
GROUP BY
a.vwcus_key
, a.vwcus_first_name
, a.vwcus_last_name
, c.intSiteNumber
, c.strSiteAddress
, c.strDescription
, d.strFillGroupCode
, d.intFillGroupId 
, d.ysnActive
, d.strDescription

' 
WHERE intReportId = @intReportId

GO
print N'END Update Delivery Fill Group Report Datasource'
GO