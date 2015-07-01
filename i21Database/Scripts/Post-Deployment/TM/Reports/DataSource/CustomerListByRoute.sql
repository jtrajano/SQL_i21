GO	
print N'BEGIN Update Customer List by Route Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Customer List by Route'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
SELECT DISTINCT
 C.intRouteId, 
 B.vwcus_key, 
 RTRIM(LTRIM(B.vwcus_last_name)) as vwcus_last_name, 
 RTRIM(LTRIM(B.vwcus_first_name)) as vwcus_first_name,
 (
 CASE WHEN B.vwcus_co_per_ind_cp = ''C''   
					 THEN    RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   
					 ELSE    
								CASE WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  
									THEN     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    
								ELSE     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)    
								END   
				     END
 ) as CustomerName, 
 C.intSiteNumber,
 REPLACE( C.strSiteAddress,CHAR(13),'' '') as strSiteAddress, 
 (
  Case When C.strSiteAddress is not null Then
   '', '' + C.strCity
  ELSE
   C.strCity  
  END 
 ) as strCity, 
 (
  Case When C.strCity IS NOT NULL and C.strSiteAddress is not null Then
   '', '' + C.strState
  ELSE
   C.strState  
  END 
 ) as strState, 
 (
  Case When C.strState IS NOT NULL and C.strCity IS NOT NULL and C.strSiteAddress is not null Then
   '' '' + C.strZipCode
  ELSE
   C.strZipCode  
  END 
 ) as strZipCode, 
 F.strFillMethod, 
 C.dtmLastDeliveryDate, 
 C.strLocation, 
 B.vwcus_cred_limit, 
 C.strInstruction,
 (
  CASE WHEN (SELECT TOP 1 ysnUseDeliveryTermOnCS from tblTMPreferenceCompany) = 1 THEN
   Cast(C.intDeliveryTermID as nvarchar(5))+ '' - '' + (Select ISNULL(vwtrm_desc,'''') from vwtrmmst where vwtrm_key_n = C.intDeliveryTermID)
  ELSE
   Cast(B.vwcus_terms_cd as nvarchar(5))+ '' - '' + (Select ISNULL(vwtrm_desc,'''') from vwtrmmst where vwtrm_key_n = B.vwcus_terms_cd)
  END
 ) as Terms,
 (Select r.strRouteId FROM tblTMRoute r WHERE r.intRouteId = C.intRouteId) as strRouteId, 
 (
  CASE B.vwcus_active_yn
  WHEN ''Y'' THEN
   ''Active''
  WHEN ''N'' THEN
   ''Inactive''
  END
 ) as customerStatus, 
 (
  CASE C.ysnActive
  WHEN 1 THEN
   ''Active''
  WHEN 0 THEN
   ''Inactive''
  END
 ) as siteStatus, 
 E.strOwnership, 
 ISNULL(HR.strHoldReason,'''') AS strHoldReason,
 C.ysnOnHold,
 E.strSerialNumber
,E.dblTankCapacity 
FROM tblTMCustomer A 
  INNER JOIN vwcusmst B ON A.intCustomerNumber = B.A4GLIdentity
  INNER JOIN tblTMSite C ON A.intCustomerID = C.intCustomerID
  LEFT JOIN tblTMSiteDevice D ON C.intSiteID =D.intSiteID
  LEFT JOIN tblTMDevice E ON D.intDeviceId = E.intDeviceId
  LEFT JOIN tblTMFillMethod F ON C.intFillMethodId = F.intFillMethodId
  LEFT JOIN tblTMDeviceType G ON E.intDeviceTypeId = G.intDeviceTypeId
  LEFT JOIN tblTMHoldReason HR ON C.intHoldReasonID = HR.intHoldReasonID
 WHERE G.strDeviceType = ''Tank'' OR G.strDeviceType IS NUll

' 
WHERE intReportId = @intReportId

GO
print N'END Update Customer List by Route Report Datasource'
GO