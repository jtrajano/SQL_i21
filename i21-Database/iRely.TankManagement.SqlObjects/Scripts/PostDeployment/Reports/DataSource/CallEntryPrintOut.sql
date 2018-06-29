GO	
print N'BEGIN Update Call Entry Printout Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Call Entry Printout'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
	Select A.intCustomerID, 
		IsNull(F.dblPrice, 0) As dblProductCost, 
		Coalesce(F.dblQuantity, 0.0) As dblQuantity, 
		RTrim(LTrim(B.vwcus_last_name)) As agcus_last_name, 
		RTrim(LTrim(B.vwcus_first_name)) As agcus_first_name,
		(Case WHEN B.vwcus_first_name IS NULL OR B.vwcus_first_name = ''''  THEN
		RTRIM(B.vwcus_last_name)
		ELSE
		RTRIM(B.vwcus_last_name) + '', '' + RTRIM(B.vwcus_first_name)
			END) as CustomerName,
		B.vwcus_phone as agcus_phone ,
		B.vwcus_key as agcus_key, 
		B.vwcus_zip as agcus_zip, 
		ISNULL(K.vwlcl_tax_state,B.vwcus_tax_state) as agcus_tax_state, 
		B.vwcus_cred_limit as agcus_cred_limit, 
		B.vwcus_ar_per1 as agcus_ar_per1, 
		B.vwcus_last_stmt_bal as agcus_last_stmt_bal, 
		B.vwcus_budget_amt_due as agcus_budget_amt_due, 
		B.vwcus_ar_future as agcus_ar_future, 
		B.vwcus_prc_lvl as agcus_prc_lvl,
		(B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) As Credits, 
		(B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) As TotalPast, 
		(B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga) As ARBalance, 
		Cast((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) As money) As dblPastCredit, 
		C.intSiteNumber, 
		ISNULL(C.dblLastDeliveredGal,0) AS dblLastDeliveredGal, 
		C.intRouteId, 
		C.strSequenceID, 
		ISNULL(C.intLastDeliveryDegreeDay,0) AS intLastDeliveryDegreeDay,
		 REPLACE(C.strSiteAddress,CHAR(13),'' '') as strSiteAddress,
	 (Case When C.strSiteAddress is not null Then
			'', '' + C.strCity
		ELSE
			C.strCity  
		END ) as strCity,	
	(Case When C.strCity IS NOT NULL and C.strSiteAddress is not null Then
			'', '' + C.strState
		ELSE
			C.strState  
		END ) as strState,
	 (Case When C.strState IS NOT NULL and C.strCity IS NOT NULL and C.strSiteAddress is not null Then
			'' '' + C.strZipCode
		ELSE
			C.strZipCode  
		END ) as strZipCode,
		C.strComment, 
		C.strInstruction, 
		C.dblDegreeDayBetweenDelivery as dblDDBetweenDlvry, 
		C.dblTotalCapacity, 
		C.dblTotalReserve,
		C.strDescription As strSiteDescription, 
		ISNULL(C.dblLastGalsInTank,0) AS dblLastGalsInTank, 
		C.dtmLastDeliveryDate,
		C.intSiteID, 
		C.intDriverID, 
		(C.dblEstimatedPercentLeft / 100) AS dblEstimatedPercentLeft, 
		C.dtmNextDeliveryDate, 
		ISNULL(C.intNextDeliveryDegreeDay,0) AS intNextDeliveryDegreeDay,
		(Case When C.dtmNextDeliveryDate IS NOT Null Then ''Date'' Else ''DD'' End) As SiteLabel, 
		(Case When C.dtmNextDeliveryDate IS NOT Null Then CONVERT(varchar,C.dtmNextDeliveryDate,101) Else CAST(C.intNextDeliveryDegreeDay as nvarchar(20)) End) As SiteDeliveryDD, 
		(Case When H.strCurrentSeason = ''Summer'' Then 
				C.dblSummerDailyUse
			When H.strCurrentSeason = ''Winter''
			Then  C.dblWinterDailyUse
			ELSE
				Coalesce(C.dblWinterDailyUse,0) End) AS dblDailyUse,
		F.dblPercentLeft, 
		F.dblMinimumQuantity, 
		F.dtmRequestedDate, 
		F.strComments, 
		C.intFillMethodId, 
		J.vwsls_name as strDriverName,
		J.vwsls_slsmn_id as strDriverID,
		(Select tt.strFillMethod From tblTMFillMethod tt Where tt.intFillMethodId = C.intFillMethodId) As strFillMethod, 
		ISNULL(M.vwitm_no,G.vwitm_no) as strProductID,
		ISNULL(M.vwitm_desc,G.vwitm_desc) as strProductDescription,
		(Select r.strRouteId FROM tblTMRoute r WHERE r.intRouteId = C.intRouteId) as strRouteId,
		(CASE WHEN ISNumeric(C.strLocation) = 1 THEN
		C.strLocation
		ELSE
		substring(C.strLocation, patindex(''%[^0]%'',C.strLocation), 50) END) AS strLocation,
		F.dtmCallInDate, 
		strEnteredBy = (SELECT TOP 1 strUserName FROM tblSMUserSecurity WHERE intEntityUserSecurityId = F.intUserID),
		F.intUserID,
		I.vwtrm_desc,
		I.vwtrm_key_n
		From tblTMCustomer A Inner Join vwcusmst B On A.intCustomerNumber = B.A4GLIdentity
		INNER Join tblTMSite C On A.intCustomerID = C.intCustomerID
		LEFT JOIN vwlocmst L
			ON C.intLocationId = L.A4GLIdentity
		Left Join tblTMDispatch F On C.intSiteID = F.intSiteID 
		Left Join vwitmmst G On C.intProduct = G.A4GLIdentity 
			AND G.vwitm_loc_no COLLATE Latin1_General_CI_AS = L.vwloc_loc_no COLLATE Latin1_General_CI_AS
		Left Join vwtrmmst I On F.intDeliveryTermID = I.vwtrm_key_n
		Left Join vwitmmst M On F.intSubstituteProductID = M.A4GLIdentity 
			AND M.vwitm_loc_no COLLATE Latin1_General_CI_AS = L.vwloc_loc_no COLLATE Latin1_General_CI_AS
		Left Join tblTMClock H On H.intClockID = C.intClockID
		LEFT JOIN vwslsmst J ON J.A4GLIdentity = F.intDriverID 
		LEFT JOIN vwlclmst K
			ON C.intTaxStateID = K.A4GLIdentity
		And (H.strCurrentSeason Is Not Null) AND vwcus_active_yn = ''Y'' 
		AND  (ysnOnHold = 0 OR dtmOnHoldEndDate < GetDate()) AND C.ysnActive = 1

' 
WHERE intReportId = @intReportId

GO
print N'END Update Call Entry Printout Report Datasource'
GO