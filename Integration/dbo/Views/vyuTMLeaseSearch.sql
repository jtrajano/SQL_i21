GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMLeaseSearch') 
	DROP VIEW vyuTMLeaseSearch
GO
IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
	EXEC('
		CREATE VIEW [dbo].[vyuTMLeaseSearch]
		AS
		SELECT
			A.intLeaseId
			,A.strLeaseNumber
			,A.dtmStartDate
			,strLeaseCode = B.strLeaseCode
			,strBillToCustomerNumber = D.vwcus_key COLLATE Latin1_General_CI_AS 	
			,strBillToCustomerName = (CASE WHEN D.vwcus_co_per_ind_cp = ''D''   
											THEN  ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')   
											ELSE    
												CASE WHEN D.vwcus_first_name IS NULL OR RTRIM(D.vwcus_first_name) = ''''  
													THEN     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')    
													ELSE     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''')    
												END   
										END) COLLATE Latin1_General_CI_AS 
			,A.strRentalStatus
			,A.strLeaseStatus
			,A.strBillingFrequency
			,A.intBillingMonth
			,A.strBillingType
			,ysnLeaseToOwn = CAST(ISNULL(A.ysnLeaseToOwn,0) AS BIT)
			,A.dtmDontBillAfter
			,A.intConcurrencyId 
			,strSiteCustomerNumber = H.vwcus_key COLLATE Latin1_General_CI_AS 	
			,strSiteCustomerName = (CASE WHEN H.vwcus_co_per_ind_cp = ''D''   
											THEN  ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_first_name),'''') + ISNULL(RTRIM(H.vwcus_mid_init),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''')   
											ELSE    
												CASE WHEN H.vwcus_first_name IS NULL OR RTRIM(H.vwcus_first_name) = ''''  
													THEN     ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''')    
													ELSE     ISNULL(RTRIM(H.vwcus_last_name),'''') + ISNULL(RTRIM(H.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(H.vwcus_first_name),'''') + ISNULL(RTRIM(H.vwcus_mid_init),'''')    
												END   
										END) COLLATE Latin1_General_CI_AS 
			,intSiteNumber = F.intSiteNumber
			,strSiteDescription = F.strDescription
			,F.strSiteAddress 
			,I.strDeviceType
			,C.strSerialNumber
			,dblLeaseAmount = J.dblAmount
			,ysnLeaseTaxable = J.ysnTaxable
			,dblTotalUsage = F.dblYTDGalsThisSeason
			,dblLeaseBillingMinimum = (SELECT TOP 1 dblMinimumUsage 
												FROM tblTMLeaseMinimumUse 
												WHERE dblSiteCapacity >= ISNULL(F.dblTotalCapacity,0) 
												ORDER BY tblTMLeaseMinimumUse.dblSiteCapacity ASC)
			,dtmLastLeaseBillingDate = A.dtmLastLeaseBillingDate
		FROM tblTMLease A
		INNER JOIN tblTMDevice C
			ON A.intLeaseId = C.intLeaseId
		INNER JOIN tblTMSiteDevice E
			ON C.intDeviceId = E.intDeviceId
		INNER JOIN tblTMSite F
			ON F.intSiteID = E.intSiteID
		INNER JOIN tblTMCustomer G
			ON F.intCustomerID = G.intCustomerID
		INNER JOIN vwcusmst H
			ON G.intCustomerNumber = H.A4GLIdentity
		LEFT JOIN tblTMDeviceType I
			ON C.intDeviceTypeId = I.intDeviceTypeId
		LEFT JOIN tblTMLeaseCode B
			ON A.intLeaseCodeId = B.intLeaseCodeId
		LEFT JOIN vwcusmst D
			ON A.intBillToCustomerId = D.A4GLIdentity
		LEFT JOIN tblTMLeaseCode J
			ON A.intLeaseCodeId = J.intLeaseCodeId
		')
GO

