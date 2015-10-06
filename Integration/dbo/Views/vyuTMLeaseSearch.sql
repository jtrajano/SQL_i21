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
		FROM tblTMLease A
		LEFT JOIN tblTMLeaseCode B
			ON A.intLeaseCodeId = B.intLeaseCodeId
		LEFT JOIN vwcusmst D
			ON A.intBillToCustomerId = D.A4GLIdentity
		')
GO

