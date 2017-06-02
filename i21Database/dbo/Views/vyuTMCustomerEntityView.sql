CREATE VIEW [dbo].vyuTMCustomerEntityView  
AS 

SELECT
	vwcus_key = ISNULL(Ent.strEntityNo,'')
	,vwcus_last_name = ISNULL((CASE WHEN Cus.strType = 'Company' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( ', ', Ent.strName) != 0 THEN CHARINDEX( ', ', Ent.strName)  -1 ELSE 25 END)) END),'')
	,vwcus_first_name = ISNULL((CASE WHEN Cus.strType = 'Company' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( ', ', Ent.strName) != 0 THEN CHARINDEX( ', ', Ent.strName)  + 2 ELSE 50 END),50) END),'')
	,vwcus_mid_init = ''
	,vwcus_name_suffix = ''
	,vwcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END
	,vwcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END
	,vwcus_city = SUBSTRING(Loc.strCity,1,20)
	,vwcus_state = SUBSTRING(Loc.strState,1,2)
	,vwcus_zip = SUBSTRING(Loc.strZipCode,1,10)  
	,vwcus_phone = E.strPhone
	,vwcus_phone_ext = (CASE WHEN CHARINDEX('x', Con.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Con.strPhone,1,30),CHARINDEX('x',Con.strPhone) + 1, LEN(Con.strPhone))END)
	,vwcus_bill_to = ''  
	,vwcus_contact = SUBSTRING((Con.strName),1,20) 
	,vwcus_comments = SUBSTRING(Con.strInternalNotes,1,30) 
	,vwcus_slsmn_id = (SELECT strSalespersonId FROM tblARSalesperson WHERE intEntitySalespersonId = Cus.intSalespersonId)
	,vwcus_terms_cd = T.intTermsId
	,vwcus_prc_lvl = CAST(0 AS INT)
	,vwcus_stmt_fmt =	CASE WHEN Cus.strStatementFormat = 'Open Item' THEN 'O'
							WHEN Cus.strStatementFormat = 'Balance Forward' THEN 'B' 
							WHEN Cus.strStatementFormat = 'Budget Reminder' THEN 'R' 
							WHEN Cus.strStatementFormat = 'None' THEN 'N' 
							WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '' END
	,vwcus_ytd_pur = 0  
	,vwcus_ytd_sls = ISNULL(CI.dblYTDSales, 0.0)
	,vwcus_ytd_cgs = 0.0  
	,vwcus_budget_amt = Cus.dblBudgetAmountForBudgetBilling
	,vwcus_budget_beg_mm = CAST(ISNULL(SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2),0) AS INT)
	,vwcus_budget_end_mm = CAST(ISNULL(SUBSTRING(Cus.strBudgetBillingEndMonth,1,2),0) AS INT)
	,vwcus_active_yn = CASE WHEN Cus.ysnActive = 1 THEN 'Y' ELSE 'N' END
	,vwcus_ar_future = CAST(ISNULL(CI.dblFuture,0.0) AS NUMERIC(18,6))
	,vwcus_ar_per1 = ISNULL(CI.dbl10Days,0.0) +  ISNULL(CI.dbl0Days,0.0)
	,vwcus_ar_per2 = ISNULL(CI.dbl30Days,0.0)
	,vwcus_ar_per3 = ISNULL(CI.dbl60Days,0.0)
	,vwcus_ar_per4 = ISNULL(CI.dbl90Days,0.0)
	,vwcus_ar_per5 = ISNULL(CI.dbl91Days,0.0)
	,vwcus_pend_ivc = ISNULL(CI.dblInvoiceTotal,0.0)
	,vwcus_cred_reg = ISNULL(CI.dblUnappliedCredits,0.0)
	,vwcus_pend_pymt = ISNULL(CI.dblPendingPayment,0.0)
	,vwcus_cred_ga = 0.0
	,vwcus_co_per_ind_cp = CASE WHEN Cus.strType = 'Company' THEN 'C' ELSE 'P' END
	,vwcus_bus_loc_no = ''
	,vwcus_cred_limit = Cus.dblCreditLimit
	,vwcus_last_stmt_bal = ISNULL(CI.dblLastStatement,0.0)
	,vwcus_budget_amt_due  = ISNULL(CI.dblTotalDue,0.0)
	,vwcus_cred_ppd  = CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
	,vwcus_ytd_srvchr = 0.0 
	,vwcus_last_pymt = ISNULL(CI.dblLastPayment,0.0)
	,vwcus_last_pay_rev_dt = ISNULL(CAST((SELECT CAST(YEAR(CI.dtmLastPaymentDate) AS NVARCHAR(4)) + RIGHT('00' + CAST(MONTH(CI.dtmLastPaymentDate) AS NVARCHAR(2)),2)  + RIGHT('00' + CAST(DAY(CI.dtmLastPaymentDate) AS NVARCHAR(2)),2))  AS INT),0)  
	,vwcus_last_ivc_rev_dt = 0
	,vwcus_high_cred = 0.0  
	,vwcus_high_past_due = ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0)
	,vwcus_avg_days_pay = 0
	,vwcus_avg_days_no_ivcs = 0
	,vwcus_last_stmt_rev_dt = ISNULL(CAST((SELECT CAST(YEAR(CI.dtmLastStatementDate) AS NVARCHAR(4)) + RIGHT('00' + CAST(MONTH(CI.dtmLastStatementDate) AS NVARCHAR(2)),2)  + RIGHT('00' + CAST(DAY(CI.dtmLastStatementDate) AS NVARCHAR(2)),2)) AS INT),0) 
	,vwcus_country = (CASE WHEN LEN(Loc.strCountry) = 3 THEN Loc.strCountry ELSE '' END)  
	,vwcus_termdescription = T.strTerm
	,vwcus_tax_ynp = CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN 'Y' ELSE 'N' END   
	,vwcus_tax_state = ''  
	,A4GLIdentity = Ent.intEntityId
	,vwcus_phone2 =  F.strPhone
	,vwcus_balance = ISNULL(CI.dblTotalDue,0.0)
	,vwcus_ptd_sls = ISNULL(CI.dblYTDSales,0.0)
	,vwcus_lyr_sls = ISNULL(CI.dblLastYearSales,0.0)
	,vwcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId)
	,dblFutureCurrent = ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl0Days,0.0)
	,intConcurrencyId = 0
	,strFullLocation =  ISNULL(Loc.strLocationName ,'')
	,intTaxId = CAST(NULL AS INT)
	,ysnOriginIntegration = CAST(0 AS BIT)
	,strFullCustomerName = Ent.strName
	,intCustomerPricingLevel = Cus.intCompanyLocationPricingLevelId
	,strCustomerContactEmail = Con.strEmail
	,intCustomerDeliveryTermId = Cus.intTermsId
	,dtmLastInvoiceRevisedDate = (SELECT TOP 1 dtmDate FROM tblARInvoice WHERE intEntityId = Ent.intEntityId AND strTransactionType = 'Invoice' ORDER BY dtmDate DESC)
	,dtmLastPaymentRevisedDate = CI.dtmLastPaymentDate
	,dtmLastStatementRevDate = CI.dtmLastStatementDate
	,strCompleteAddress = dbo.[fnConvertToFullAddress](ISNULL(Loc.strAddress,'')
														,ISNULL(Loc.strCity,'')
														,ISNULL(Loc.strState,'')
														,ISNULL(Loc.strZipCode,'')) COLLATE Latin1_General_CI_AS
	,strFormattedAddress =  ISNULL(Loc.strAddress,'') COLLATE Latin1_General_CI_AS
	,strFullName = Ent.strName
	,strFullTermName = (CAST(ISNULL(T.intTermID,'') AS NVARCHAR(10)) + ' - ' + ISNULL(T.strTerm,'')) COLLATE Latin1_General_CI_AS
	,strCreditNote =''
FROM tblEMEntity Ent
INNER JOIN tblARCustomer Cus 
	ON Ent.intEntityId = Cus.intEntityCustomerId
INNER JOIN tblEMEntityToContact CustToCon 
	ON Cus.intEntityCustomerId = CustToCon.intEntityId 
		and CustToCon.ysnDefaultContact = 1
INNER JOIN tblEMEntity Con 
	ON CustToCon.intEntityContactId = Con.intEntityId
INNER JOIN tblEMEntityLocation Loc 
	ON Ent.intEntityId = Loc.intEntityId 
		and Loc.ysnDefaultLocation = 1
LEFT JOIN [vyuARCustomerInquiryReport] CI
	ON Ent.intEntityId = CI.intEntityCustomerId
LEFT JOIN tblEMEntityPhoneNumber E
	ON Con.intEntityId = E.intEntityId   
LEFT JOIN tblEMEntityMobileNumber F
	ON Con.intEntityId = F.intEntityId   
LEFT JOIN tblSMTerm T
	ON Cus.intTermsId = T.intTermID

GO