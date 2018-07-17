GO	
print N'BEGIN Update Efficiency Report Report Datasource'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intReportId AS INT

SET @strReportName = 'Efficiency Report'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup


-------------------Update Data Source---------------------------------------------------------------------
-----------------------------------------------------------------------------------------

UPDATE tblRMDatasource
SET strQuery = '
SELECT
	(Case WHEN A.vwcus_first_name IS NULL OR A.vwcus_first_name = ''''  THEN
	RTRIM(A.vwcus_last_name)
	ELSE
	RTRIM(A.vwcus_last_name) + '', '' + RTRIM(A.vwcus_first_name)
        END) as CustomerName
	,A.vwcus_key
	,substring(A.vwcus_key, patindex(''%[^0]%'',A.vwcus_key), 50)  AS trimedVwcus_key
	,A.vwcus_phone as strCustomerPhone
	,A.intSiteNumber AS[intConsumptionSiteNumber]
	,A.intSiteID
	,REPLACE(A.strSiteAddress, Char(10),'' '') as strSiteAddress
	,A.strCity
	,A.strZipCode
	,A.strState
	,B.dblTankCapacity
	,B.strSerialNumber
	,ISNULL(A.dblYTDSales, 0) as dblYTDSales
	,ISNULL(dblYTDSalesLastSeason, 0) as dblYTDSalesLastSeason
	,ISNULL(dblYTDSales2SeasonsAgo,0 ) as dblYTDSales2SeasonsAgo
	,ISNULL(A.dblYTDGalsThisSeason, 0) as dblYTDGalsThisSeason
	,ISNULL(A.dblYTDGalsLastSeason, 0) as dblYTDGalsLastSeason
	,ISNULL(A.dblYTDGals2SeasonsAgo, 0 ) as dblYTDGals2SeasonsAgo
	,A.vwcus_ar_per1 AS [dblCurrentBalance]
	,A.vwcus_ar_per2 AS [dbl30DayBalance]
	,A.vwcus_ar_per3 AS [dbl60DayBalance]
	,A.vwcus_ar_per4 AS [dbl90DayBalance]
	,dblNoOfDeliveryThis= (SELECT COUNT(dvh.intDeliveryHistoryID) 
							FROM tblTMDeliveryHistory dvh
							WHERE dvh.intSiteID = A.intSiteID
								AND YEAR(dvh.dtmInvoiceDate) = YEAR(GETDATE()))
	,dblNoOfDeliveryLast= (SELECT COUNT(dvh.intDeliveryHistoryID) 
							FROM tblTMDeliveryHistory dvh
							WHERE dvh.intSiteID = A.intSiteID
								AND YEAR(dvh.dtmInvoiceDate) = YEAR(GETDATE()) - 1
							)
	,dblNoOfDeliveryLastTwo = (SELECT COUNT(dvh.intDeliveryHistoryID) 
								FROM tblTMDeliveryHistory dvh
								WHERE dvh.intSiteID = A.intSiteID
									AND  (YEAR(dvh.dtmInvoiceDate) = YEAR(GETDATE())-2)
							)
	,ISNULL(B.strDeviceType, '''') as strDeviceType
FROM 
	(
		select 
		vwcus_key    
		,vwcus_last_name
		,vwcus_first_name 
		,vwcus_mid_init
		,vwcus_name_suffix
		,vwcus_addr
		,vwcus_addr2
		,vwcus_city
		,vwcus_state
		,vwcus_zip
		,vwcus_phone
		,vwcus_phone_ext
		,vwcus_bill_to
		,vwcus_contact
		,vwcus_comments
		,vwcus_slsmn_id
		,vwcus_terms_cd
		,vwcus_prc_lvl
		,vwcus_stmt_fmt
		,vwcus_ytd_pur
		,vwcus_ytd_sls
		,vwcus_ytd_cgs
		,vwcus_budget_amt
		,vwcus_budget_beg_mm
		,vwcus_budget_end_mm
		,vwcus_active_yn
		,vwcus_ar_future
		,vwcus_ar_per1
		,vwcus_ar_per2
		,vwcus_ar_per3
		,vwcus_ar_per4
		,vwcus_ar_per5
		,vwcus_pend_ivc  
		,vwcus_cred_reg  
		,vwcus_pend_pymt 
		,vwcus_cred_ga   
		,vwcus_co_per_ind_cp
		,vwcus_bus_loc_no 
		,vwcus_cred_limit 
		,vwcus_last_stmt_bal
		,vwcus_budget_amt_due
		,vwcus_cred_ppd  
		,vwcus_ytd_srvchr
		,vwcus_last_pymt 
		,vwcus_last_pay_rev_dt
		,vwcus_last_ivc_rev_dt
		,vwcus_high_cred   
		,vwcus_high_past_due
		,vwcus_avg_days_pay 
		,vwcus_avg_days_no_ivcs
		,vwcus_last_stmt_rev_dt
		,vwcus_country   
		,vwcus_termdescription
		,vwcus_tax_ynp   
		,vwcus_tax_state 
		,A4GLIdentity
		,vwcus_phone2  
		,vwcus_balance 
		,vwcus_ptd_sls 
		,vwcus_lyr_sls 
		,dblFutureCurrent
		, st.*
		FROM tblTMCustomer cust
		INNER JOIN vwcusmst vwcst ON
					cust.intCustomerNumber = vwcst.A4GLIdentity
		INNER JOIN tblTMSite st ON
					cust.intCustomerID = st.intCustomerID
	) A
LEFT JOIN 
	(
		select 
		dvc.dblTankCapacity
		,dvc.strSerialNumber
		,dvc.intDeviceId as id
		,stdvc.* 
		,DevType.strDeviceType
		from	tblTMSiteDevice stdvc 
		INNER JOIN tblTMDevice dvc ON
					stdvc.intDeviceId = dvc.intDeviceId
		INNER JOIN tblTMDeviceType DevType ON 
					dvc.intDeviceTypeId = DevType.intDeviceTypeId
	) B
ON A.intSiteID = B.intSiteID
where  A.vwcus_active_yn = ''Y'' and A.ysnActive = 1 



' 
WHERE intReportId = @intReportId

GO
print N'END Efficiency Report Report Datasource'
GO