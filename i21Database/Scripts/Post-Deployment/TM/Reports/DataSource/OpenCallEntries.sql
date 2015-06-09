GO	
print N'BEGIN Update Open Call Entries Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Open Call Entries'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
	SELECT DISTINCT
	 B.vwcus_key
	, rtrim(ltrim(B.vwcus_last_name)) as agcus_last_name
	, rtrim(ltrim(B.vwcus_first_name)) as agcus_first_name
	,(Case WHEN B.vwcus_first_name IS NULL OR B.vwcus_first_name = ''''  THEN
		RTRIM(B.vwcus_last_name)
		ELSE
		RTRIM(B.vwcus_last_name) + '', '' + RTRIM(B.vwcus_first_name)
	 END) as CustomerName
	, C.intSiteNumber
	, REPLACE(C.strSiteAddress,CHAR(13),'' '') + '', '' + RTRIM(C.strCity) + '', '' + RTRIM(C.strState) + '', '' + RTRIM(C.strZipCode) as strSiteAddress
	,(Case When C.strSiteAddress is not null Then
			'', '' + C.strCity
		ELSE
			C.strCity  
		END ) as strCity	
	, (Case When C.strCity IS NOT NULL and C.strSiteAddress is not null Then
			'', '' + C.strState
		ELSE
			C.strState  
		END ) as strState
	, (Case When C.strState IS NOT NULL and C.strCity IS NOT NULL and C.strSiteAddress is not null Then
			'' '' + C.strZipCode
		ELSE
			C.strZipCode  
		END ) as strZipCode
	, C.strDescription
	, H.vwitm_no as strProductID
	, H.vwitm_desc as strProductDescription
	, I.vwitm_no as strProductIDSubs
	, I.vwitm_desc as strProductDescriptionSubs
	, G.dtmRequestedDate
	, G.dtmCallInDate
	, ISNULL(G.dblMinimumQuantity, 0) as dblMinimumQuantity
	, ISNULL(L.strUserName,'''') AS strUserName
	, J.vwsls_name as strDriverName
	, J.vwsls_slsmn_id as strDriverID
	, strDispatchComments = G.strComments
	FROM tblTMCustomer A 
			INNER JOIN vwcusmst B on A.intCustomerNumber = B.A4GLIdentity
			LEFT JOIN tblTMSite C ON A.intCustomerID = C.intCustomerID
			LEFT JOIN tblTMSiteDevice D ON C.intSiteID =D.intSiteID
			LEFT JOIN tblTMDevice E ON D.intDeviceId = E.intDeviceId
			LEFT JOIN tblTMDeviceType F ON E.intDeviceTypeId = F.intDeviceTypeId
			INNER JOIN tblTMDispatch G ON C.intSiteID = G.intSiteID
			LEFT JOIN tblSMUserSecurity L ON G.intUserID = L.intUserSecurityID
			LEFT JOIN vwitmmst H ON C.intProduct = H.A4GLIdentity
			LEFT JOIN vwitmmst I ON G.intSubstituteProductID = I.A4GLIdentity
			LEFT JOIN vwslsmst J ON G.intDriverID = J.A4GLIdentity
			Left Join tblTMClock K On C.intClockID = K.intClockID
	Where (K.strCurrentSeason Is Not Null) AND vwcus_active_yn = ''Y'' and C.ysnActive = 1

' 
WHERE intReportId = @intReportId

GO
print N'END Update Open Call Entries Report Datasource'
GO