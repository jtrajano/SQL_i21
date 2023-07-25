﻿PRINT 'Import Customer Scripts'
GO

IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AG') = 1
BEGIN

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportCustomer')
BEGIN
	PRINT 'DROP PROCEDURE uspARImportCustomer'
	DROP PROCEDURE uspARImportCustomer
END

	PRINT 'CREATE PROCEDURE uspARImportCustomer'
EXEC(
'
CREATE PROCEDURE [dbo].[uspARImportCustomer]
		@CustomerId NVARCHAR(50) = NULL,
		@Update BIT = 0,
		@Total INT = 0 OUTPUT

		AS 
	BEGIN
		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF
		--================================================
		--     UPDATE/INSERT IN ORIGIN	
		--================================================
		IF(@Update = 1 AND @CustomerId IS NOT NULL) 
		BEGIN
			--UPDATE IF EXIST IN THE ORIGIN
			IF(EXISTS(SELECT 1 FROM agcusmst WHERE agcus_key = SUBSTRING(@CustomerId,1,10)))
			BEGIN
							
				UPDATE agcusmst
				SET 
				--Entity
				agcus_last_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),''''),
				agcus_first_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),''''),
				agcus_comments = SUBSTRING(Con.strInternalNotes,1,30),
				agcus_1099_name = SUBSTRING(Ent.str1099Name,1,50),
				--Location
				agcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END,
				agcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END,
				agcus_city = SUBSTRING(Loc.strCity,1,20),
				agcus_state = SUBSTRING(Loc.strState,1,2),
				agcus_zip = SUBSTRING(Loc.strZipCode,1,10),
				agcus_country = (CASE WHEN LEN(Loc.strCountry) = 3 THEN Loc.strCountry ELSE '''' END),
				agcus_terms_cd = (SELECT case when ISNUMERIC(strTermCode) = 0 then null else strTermCode end  FROM tblSMTerm WHERE intTermID = Cus.intTermsId and cast( (case when isnumeric(strTermCode) = 1 then  strTermCode else 266 end ) as bigint) <= 255),
				--Contact
				agcus_contact = SUBSTRING((Con.strName),1,20),
				agcus_phone = ISNULL( (CASE WHEN CHARINDEX(''x'', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,15), 0, CHARINDEX(''x'',P.strPhone)) ELSE SUBSTRING(P.strPhone,1,15)END), '''' ),
				agcus_phone_ext = (CASE WHEN CHARINDEX(''x'', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,30),CHARINDEX(''x'',P.strPhone) + 1, LEN(P.strPhone))END),
				agcus_phone2 = (CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,15), 0, CHARINDEX(''x'',M.strPhone)) ELSE SUBSTRING(M.strPhone,1,15)END),
				agcus_phone2_ext = (CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,30),CHARINDEX(''x'',M.strPhone) + 1, LEN(M.strPhone))END),
				--Customer
				agcus_key = SUBSTRING(Cus.strCustomerNumber,1,10),
				agcus_co_per_ind_cp = CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END,
				agcus_cred_limit = Cus.dblCreditLimit,
				agcus_tax_exempt = SUBSTRING(Cus.strTaxNumber,1,15),
				agcus_dflt_currency = SUBSTRING(Cus.strCurrency,1,3),
				agcus_active_yn = CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_req_po_yn = CASE WHEN Cus.ysnPORequired = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_stmt_dtl_yn = CASE WHEN Cus.ysnStatementDetail = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_stmt_fmt = CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O''
									 WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' 
									 WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' 
									 WHEN Cus.strStatementFormat = ''None'' THEN ''N'' 
									 WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END,
				agcus_cred_stop_days = Cus.intCreditStopDays,
				agcus_tax_auth_id1 = SUBSTRING(Cus.strTaxAuthority1,1,3),
				agcus_tax_auth_id2 = SUBSTRING(Cus.strTaxAuthority2,1,3),
				agcus_pic_prc_yn = CASE WHEN Cus.ysnPrintPriceOnPrintTicket = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_tax_ynp = (CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''P'' ELSE  CASE WHEN Cus.ysnApplySalesTax = 1 THEN ''Y'' ELSE ''N'' END END),
				agcus_budget_amt = Cus.dblBudgetAmountForBudgetBilling,
				agcus_budget_beg_mm = SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2),
				agcus_budget_end_mm = SUBSTRING(Cus.strBudgetBillingEndMonth,1,2),
				agcus_dpa_cnt = SUBSTRING(Cus.strDPAContract,1,6),
				agcus_dpa_rev_dt = CONVERT(int,''20'' + CONVERT(nvarchar,Cus.dtmDPADate,12)),
				agcus_gb_rcpt_no = SUBSTRING(Cus.strGBReceiptNumber,1,6),
				agcus_ckoff_exempt_yn = CASE WHEN Cus.ysnCheckoffExempt = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_ckoff_vol_yn = CASE WHEN Cus.ysnVoluntaryCheckoff = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_ga_origin_st = SUBSTRING(Cus.strCheckoffState,1,2),
				agcus_mkt_sign_yn = CASE WHEN Cus.ysnMarketAgreementSigned = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_ga_hold_pay_yn = CASE WHEN Cus.ysnHoldBatchGrainPayment = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_ga_wthhld_yn = CASE WHEN Cus.ysnFederalWithholding = 1 THEN ''Y'' ELSE ''N'' END,
				agcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = (SELECT TOP 1 intAccountStatusId FROM tblARCustomerAccountStatus WHERE intEntityCustomerId = Cus.intEntityId)),
				agcus_slsmn_id		= (SELECT strSalespersonId FROM tblARSalesperson WHERE intEntityId = Cus.intSalespersonId),
				agcus_srvchr_cd		= (SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId),
				agcus_dflt_mkt_zone = (SELECT strMarketZoneCode FROM tblARMarketZone WHERE intMarketZoneId = Cus.intMarketZoneId)	
			FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus 
					ON Ent.intEntityId = Cus.intEntityId
				INNER JOIN tblEMEntityToContact CustToCon 
					ON Cus.intEntityId = CustToCon.intEntityId 
						and CustToCon.ysnDefaultContact = 1
				INNER JOIN tblEMEntity Con 
					ON CustToCon.intEntityContactId = Con.intEntityId
				INNER JOIN tblEMEntityLocation Loc 
					ON Ent.intEntityId = Loc.intEntityId 
						and Loc.ysnDefaultLocation = 1
				LEFT JOIN tblEMEntityPhoneNumber P
					ON P.intEntityId = Con.intEntityId
				LEFT JOIN tblEMEntityMobileNumber M
					ON M.intEntityId = Con.intEntityId				
				WHERE Cus.strCustomerNumber = @CustomerId AND agcus_key = SUBSTRING(@CustomerId,1,10)
			END
			


				
				-- INSERT Contact to ssonmst
				DECLARE @ContactNumber nvarchar(20)
				DECLARE @ContactID	INT
				select top 1 @ContactNumber = substring(Con.strContactNumber,1,20),
				@ContactID = Con.intEntityId
				FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus 
					ON Ent.intEntityId = Cus.intEntityId
				INNER JOIN tblEMEntityToContact CusToCon 
					ON Cus.intEntityId = CusToCon.intEntityId 
						and CusToCon.ysnDefaultContact = 1
				INNER JOIN tblEMEntity Con 
					ON CusToCon.intEntityContactId = Con.intEntityId
				WHERE Cus.strCustomerNumber = @CustomerId
								
				EXEC uspARContactOriginSync @ContactNumber, @ContactID
				
				

		RETURN;
		END

		--================================================
		--     ONE TIME CUSTOMER SYNCHRONIZATION	
		--================================================
		IF(@Update = 0 AND @CustomerId IS NULL) 
		BEGIN
			TRUNCATE TABLE tblARCustomerFailedImport
			--1 Time synchronization here
			PRINT ''1 Time Customer Synchronization''

			DECLARE @originCustomer NVARCHAR(50)

			--Entity
			DECLARE @strName			NVARCHAR (MAX)
			DECLARE	@strEmail           NVARCHAR (MAX) 
			DECLARE	@strWebsite			NVARCHAR (MAX)
			DECLARE	@strInternalNotes	NVARCHAR (MAX)
			DECLARE @str1099Name        NVARCHAR (100) 
			DECLARE @ysnPrint1099       BIT     
			DECLARE @str1099Type		NVARCHAR (100) 
			DECLARE @dtmW9Signed		DATETIME
			DECLARE	@str1099Form        NVARCHAR (MAX) 
			DECLARE @strFederalTaxId    NVARCHAR (MAX) 
			DECLARE @imgPhoto			varbinary(MAX)


			--Contacts
			DECLARE @intContactId		INT
			DECLARE	@strTitle           NVARCHAR (MAX) 
			DECLARE	@strContactName     NVARCHAR (MAX) 
			DECLARE	@strDepartment      NVARCHAR (MAX) 
			DECLARE	@strMobile          NVARCHAR (MAX) 
			DECLARE	@strPhone           NVARCHAR (MAX) 
			DECLARE	@strPhone2          NVARCHAR (MAX) 
			DECLARE	@strEmail2          NVARCHAR (MAX) 
			DECLARE	@strFax             NVARCHAR (MAX) 
			DECLARE	@strNotes           NVARCHAR (MAX) 
			DECLARE	@strContactMethod   NVARCHAR (MAX)
			DECLARE	@strTimezone        NVARCHAR (MAX) 
		
		
			--Customer To Contact
			DECLARE	@strUserType        NVARCHAR (MAX) 
			DECLARE @ysnPortalAccess	BIT
		
			--Locations
			DECLARE	@strLocationName     NVARCHAR (50) 
			DECLARE	@strLocationContactName      NVARCHAR (MAX)
			DECLARE	@strAddress          NVARCHAR (MAX)
			DECLARE	@strCity             NVARCHAR (MAX)
			DECLARE	@strCountry          NVARCHAR (MAX)
			DECLARE	@strState            NVARCHAR (MAX)
			DECLARE	@strZipCode          NVARCHAR (MAX)
			DECLARE	@strLocationNotes            NVARCHAR (MAX)
			DECLARE	@intShipViaId        INT           
			DECLARE	@intTaxCodeId        INT           
			DECLARE	@intTermsId          INT           
			DECLARE	@intWarehouseId      INT          
	
			--Customer
			DECLARE @intEntityId				INT
			--DECLARE @intEntityCustomerId				INT --MSA not in used
			DECLARE @strCustomerNumber			NVARCHAR(15)    
			DECLARE @strType					NVARCHAR(MAX)
			DECLARE @dblCreditLimit				NUMERIC(18,6)
			DECLARE @strTaxNumber				NVARCHAR(MAX)
			DECLARE @strCurrency				NVARCHAR(3)
			DECLARE @intAccountStatusId			INT
			DECLARE @intEntitySalespersonId			INT
			DECLARE	@strPricing					NVARCHAR(MAX)
			DECLARE @ysnActive					BIT
			DECLARE @dtmOriginationDate			DATETIME			
			DECLARE @ysnPORequired				BIT
			DECLARE @ysnStatementDetail			BIT
			DECLARE @strStatementFormat			NVARCHAR(50)
			DECLARE @intCreditStopDays			INT
			DECLARE @strTaxAuthority1			NVARCHAR(MAX)
			DECLARE @strTaxAuthority2			NVARCHAR(MAX)
			DECLARE @ysnPrintPriceOnPrintTicket	BIT
			DECLARE @intServiceChargeId			INT
			DECLARE @ysnApplySalesTax			BIT
			DECLARE @ysnApplyPrepaidTax			BIT
			DECLARE @dblBudgetAmountForBudgetBilling NUMERIC(18,6)
			DECLARE @dblMonthlyBudget			NUMERIC(18,6)
			DECLARE @intNoOfPeriods				INT
			DECLARE @dtmBudgetBeginDate			DATETIME
			DECLARE @strBudgetBillingBeginMonth	NVARCHAR(50)
			DECLARE @strBudgetBillingEndMonth	NVARCHAR(50)
			DECLARE @OriginCurrency				NVARCHAR(50)
			DECLARE @intCurrencyId				INT
			--Grain Tab
			DECLARE @strDPAContract				NVARCHAR(50)
			DECLARE @dtmDPADate					DATETIME
			DECLARE @strGBReceiptNumber			NVARCHAR(100)
			DECLARE @ysnCheckoffExempt			BIT
			DECLARE @ysnVoluntaryCheckoff		BIT
			DECLARE @strCheckoffState			NVARCHAR(100)
			DECLARE @ysnMarketAgreementSigned	BIT
			DECLARE @intMarketZoneId			INT
			DECLARE @ysnHoldBatchGrainPayment	BIT
			DECLARE @ysnFederalWithholding		BIT
    
			DECLARE @Counter INT = 0
			
			DECLARE @EntityId INT = NULL 

    
			--Import only those are not yet imported
			--SELECT agcus_key INTO #tmpagcusmst 
			--	FROM agcusmst
			--		where agcus_key COLLATE Latin1_General_CI_AS not in ( select strCustomerNumber from tblARCustomer) 
			--ORDER BY agcusmst.agcus_key 

			DECLARE tmpagcusmst CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT     
				        agcus_key = RTRIM(LTRIM(agcus_key)), 
						strName = CASE WHEN agcus_co_per_ind_cp = ''C'' OR agcus_co_per_ind_cp IS NULL THEN agcus_last_name + agcus_first_name WHEN agcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(agcus_last_name)) + '', '' + RTRIM(LTRIM(agcus_first_name))END,
						strEmail   = '''',
						strWebsite = '''',
						strInternalNotes = agcus_comments,
						ysnPrint1099   = 0,--To Map
						str1099Name    = agcus_1099_name,
						str1099Form	= '''',
						str1099Type	= '''',
						strFederalTaxId	= NULL, --To Map	
						dtmW9Signed	= NULL, --To Map,
						imgPhoto = NULL,

						--Contacts
						strTitle = '''',
						strContactName = agcus_contact,
						strDepartment = NULL,
						strMobile     = NULL,
						strPhone      = (CASE	
											WHEN agcus_phone_ext IS NULL OR agcus_phone_ext = '''' THEN
												RTRIM(LTRIM(agcus_phone))
											WHEN agcus_phone IS NULL OR agcus_phone = '''' AND agcus_phone_ext IS NOT NULL AND agcus_phone_ext <> '''' THEN
												''x'' + RTRIM(LTRIM(agcus_phone_ext))
											ELSE
												RTRIM(LTRIM(agcus_phone)) + '' x'' + RTRIM(LTRIM(agcus_phone_ext))
										 END),
						strPhone2     = (CASE	
											WHEN agcus_phone2_ext IS NULL OR agcus_phone2_ext = '''' THEN
												RTRIM(LTRIM(agcus_phone2))
											WHEN agcus_phone2 IS NULL OR agcus_phone2 = '''' AND agcus_phone2_ext IS NOT NULL AND agcus_phone2_ext <> '''' THEN
												''x'' + RTRIM(LTRIM(agcus_phone2_ext))
											ELSE
												RTRIM(LTRIM(agcus_phone2)) + '' x'' + RTRIM(LTRIM(agcus_phone2_ext))
										 END),
						strEmail2     = NULL,
						strFax        = NULL,
						strNotes      = NULL,
						strContactMethod = NULL,
						strTimezone = NULL,
					
						strUserType = NULL,
						ysnPortalAccess = NULL,
					
						--Locations
						strLocationName = CASE WHEN agcus_co_per_ind_cp = ''C'' OR agcus_co_per_ind_cp IS NULL THEN agcus_last_name + agcus_first_name WHEN agcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(agcus_last_name)) + '', '' + RTRIM(LTRIM(agcus_first_name))END,
						strAddress      = ISNULL(agcus_addr,'''') + CHAR(10) + ISNULL(agcus_addr2,''''),
						strCity         = LTRIM(RTRIM(agcus_city)),
						strCountry      = LTRIM(RTRIM(agcus_country)),
						strState        = LTRIM(RTRIM(agcus_state)),
						strZipCode      = LTRIM(RTRIM(agcus_zip)),
						strLocationNotes  = NULL,
						intShipViaId = NULL,
						intTaxCodeId    = NULL,
						intTermsId      = (SELECT  intTermID FROM tblSMTerm WHERE strTermCode = CAST(agcus_terms_cd AS CHAR(10))),
						intWarehouseId  = (SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = agcus_bus_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS),
				
						--Customer
						strCustomerNumber		= agcus_key,			
						strType				= CASE WHEN agcus_co_per_ind_cp = ''C'' OR agcus_co_per_ind_cp IS NULL THEN ''Company'' ELSE ''Person'' END,					
						dblCreditLimit			= agcus_cred_limit,					
						strTaxNumber			= agcus_tax_exempt,
						strCurrency			= agcus_dflt_currency, 				
						intAccountStatusId		= (SELECT intAccountStatusId FROM tblARAccountStatus WHERE strAccountStatusCode COLLATE Latin1_General_CI_AS = agcus_acct_stat_x_1 COLLATE Latin1_General_CI_AS),			
						intEntitySalespersonId		= (SELECT intEntityId FROM tblARSalesperson WHERE strSalespersonId COLLATE Latin1_General_CI_AS = agcus_slsmn_id COLLATE Latin1_General_CI_AS),			
    					strPricing				= agcus_prc_lvl,					
						ysnActive				= CASE WHEN agcus_active_yn = ''Y'' THEN 1 ELSE 0 END,	
						dtmOriginationDate		= (CASE WHEN agcus_orig_rev_dt = 0 THEN NULL ELSE CONVERT(datetime,SUBSTRING(CONVERT(nvarchar,agcus_orig_rev_dt),0,5) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_orig_rev_dt),5,2) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_orig_rev_dt),7,2)) END),
						ysnPORequired			= CASE WHEN agcus_req_po_yn = ''Y'' THEN 1 ELSE 0 END,									
						ysnStatementDetail		= CASE WHEN agcus_stmt_dtl_yn = ''Y'' THEN 1 ELSE 0 END,			
						strStatementFormat		= CASE WHEN agcus_stmt_fmt = ''O'' THEN ''Open Item'' WHEN agcus_stmt_fmt = ''B'' THEN ''Balance Forward'' WHEN agcus_stmt_fmt = ''R'' THEN ''Budget Reminder'' WHEN agcus_stmt_fmt = ''N'' THEN ''None'' WHEN agcus_stmt_fmt IS NULL THEN Null Else '''' END ,			
						intCreditStopDays		= agcus_cred_stop_days,			
						strTaxAuthority1		= agcus_tax_auth_id1,			
						strTaxAuthority2		= agcus_tax_auth_id2,			
						ysnPrintPriceOnPrintTicket = CASE WHEN agcus_pic_prc_yn = ''Y'' THEN 1 ELSE 0 END,	
						intServiceChargeId		= (SELECT intServiceChargeId FROM tblARServiceCharge WHERE strServiceChargeCode = agcus_srvchr_cd),			
						ysnApplySalesTax		= CASE WHEN agcus_tax_ynp = ''Y'' THEN 1 ELSE 0 END,			
						ysnApplyPrepaidTax		= CASE WHEN agcus_tax_ynp = ''P'' THEN 1 ELSE 0 END,			
						dblBudgetAmountForBudgetBilling = agcus_budget_amt,
						strBudgetBillingBeginMonth	= agcus_budget_beg_mm,	
						strBudgetBillingEndMonth	= agcus_budget_end_mm,
						dblMonthlyBudget	= ISNULL(agcus_budget_amt,0),
						intNoOfPeriods		= CASE WHEN (agcus_budget_beg_mm < agcus_budget_end_mm) THEN (agcus_budget_end_mm -agcus_budget_beg_mm) + 1
												   WHEN (agcus_budget_beg_mm > agcus_budget_end_mm) THEN ((13 - agcus_budget_beg_mm) + agcus_budget_end_mm)
												   ELSE 0 END, 
						dtmBudgetBeginDate =  CASE WHEN agcus_budget_beg_mm <> 0 THEN CONVERT(DATE, CAST(YEAR(getdate()) AS CHAR(4))+RIGHT(''00''+RTRIM(CAST(agcus_budget_beg_mm AS CHAR(2))),2)+''01'' , 112) ELSE NULL END,
						OriginCurrency 			= agcus_dflt_currency,
						--Grain Tab
						strDPAContract = agcus_dpa_cnt,				
						dtmDPADate = (CASE WHEN agcus_dpa_rev_dt = 0 THEN NULL ELSE CONVERT(datetime,SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),0,5) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),5,2) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),7,2)) END),					
						strGBReceiptNumber = agcus_gb_rcpt_no,			
						ysnCheckoffExempt = CASE WHEN agcus_ckoff_exempt_yn = ''Y'' THEN 1 ELSE 0 END,			
						ysnVoluntaryCheckoff = CASE WHEN agcus_ckoff_vol_yn = ''Y'' THEN 1 ELSE 0 END ,		
						strCheckoffState = agcus_ga_origin_st,			
						ysnMarketAgreementSigned = CASE WHEN agcus_mkt_sign_yn = ''Y'' THEN 1 ELSE 0 END ,	
						intMarketZoneId = (SELECT intMarketZoneId FROM tblARMarketZone WHERE strMarketZoneCode COLLATE Latin1_General_CI_AS = agcus_dflt_mkt_zone COLLATE Latin1_General_CI_AS),			
						ysnHoldBatchGrainPayment = CASE WHEN agcus_ga_hold_pay_yn = ''Y'' THEN 1 ELSE 0 END ,	
						ysnFederalWithholding = CASE WHEN agcus_ga_wthhld_yn = ''Y'' THEN 1 ELSE 0 END,
						intCurrencyId  = (select TOP 1 intCurrencyID from tblSMCurrency where strCurrency COLLATE Latin1_General_CI_AS = agcus_dflt_currency COLLATE Latin1_General_CI_AS),
						intEntityId = tblEMEntity.intEntityId  
					FROM agcusmst
						LEFT JOIN tblEMEntity ON rtrim(ltrim(agcus_key)) COLLATE Latin1_General_CI_AS =  strEntityNo COLLATE Latin1_General_CI_AS
					WHERE agcus_key COLLATE Latin1_General_CI_AS not in ( select strCustomerNumber from tblARCustomer) --Import only those are not yet imported
					ORDER BY agcusmst.agcus_key 
			
			OPEN tmpagcusmst;

				FETCH NEXT FROM tmpagcusmst INTO 
						@originCustomer 
						,@strName 
						,@strEmail   
						,@strWebsite 
						,@strInternalNotes 
						,@ysnPrint1099   
						,@str1099Name    
						,@str1099Form	
						,@str1099Type	
						,@strFederalTaxId	
						,@dtmW9Signed	
						,@imgPhoto 
						,@strTitle 
						,@strContactName 
						,@strDepartment 
						,@strMobile     
						,@strPhone      
						,@strPhone2     
						,@strEmail2     
						,@strFax        
						,@strNotes      
						,@strContactMethod 
						,@strTimezone 
						,@strUserType 
						,@ysnPortalAccess 
					    ,@strLocationName 
						,@strAddress      
						,@strCity         
						,@strCountry      
						,@strState        
						,@strZipCode      
						,@strLocationNotes 
						,@intShipViaId 
						,@intTaxCodeId 
						,@intTermsId   
						,@intWarehouseId  
						,@strCustomerNumber		
						,@strType				
						,@dblCreditLimit			
						,@strTaxNumber			
						,@strCurrency			
						,@intAccountStatusId		
						,@intEntitySalespersonId	
    					,@strPricing				
						,@ysnActive				
						,@dtmOriginationDate		
						,@ysnPORequired
						,@ysnStatementDetail
						,@strStatementFormat
						,@intCreditStopDays
						,@strTaxAuthority1
						,@strTaxAuthority2
						,@ysnPrintPriceOnPrintTicket 
						,@intServiceChargeId		
						,@ysnApplySalesTax		
						,@ysnApplyPrepaidTax		
						,@dblBudgetAmountForBudgetBilling 
						,@strBudgetBillingBeginMonth	
						,@strBudgetBillingEndMonth	
						,@dblMonthlyBudget	
						,@intNoOfPeriods		
						,@dtmBudgetBeginDate 
						,@OriginCurrency 			
						,@strDPAContract 
		                ,@dtmDPADate 
						,@strGBReceiptNumber 
						,@ysnCheckoffExempt 
						,@ysnVoluntaryCheckoff 
						,@strCheckoffState 
						,@ysnMarketAgreementSigned 
						,@intMarketZoneId 
						,@ysnHoldBatchGrainPayment 
						,@ysnFederalWithholding 
				        ,@intCurrencyId  
						,@EntityId 


			--------------------------------------------------------------------------------------------------------------------------------------------
			SELECT 
				 (RTRIM (CASE WHEN agcus_co_per_ind_cp = ''C'' OR agcus_co_per_ind_cp IS NULL THEN 
										agcus_last_name + agcus_first_name 
									WHEN agcus_co_per_ind_cp =''P'' THEN 
										RTRIM(LTRIM(agcus_last_name)) + '', '' + RTRIM(LTRIM(agcus_first_name))
									END)) + '' '' + cast(cast(newid() as nvarchar(40)) as nvarchar(2))+ ''_'' + CAST(A4GLIdentity AS NVARCHAR) AS strLocationName,
				 ISNULL(agcus_addr,'''') + CHAR(10) + ISNULL(agcus_addr2,'''') AS strAddress ,
				 LTRIM(RTRIM(agcus_city)) AS strCity ,
				 LTRIM(RTRIM(agcus_country)) AS strCountry ,
				 LTRIM(RTRIM(agcus_state)) AS strState ,
				 LTRIM(RTRIM(agcus_zip)) AS strZipCode ,
				 NULL AS strNotes ,
				 NULL intShipViaId ,
				 (SELECT intTermID FROM tblSMTerm WHERE strTermCode = CAST(agcus_terms_cd AS CHAR(10))) AS intTermsId ,
				 NULL AS intWarehouseId ,
				 0 AS ysnDefaultLocation ,
					LTRIM(RTRIM(agcus_key)) AS strOriginLinkCustomer  
			INTO #tmpagcusOtherLocation		
			FROM agcusmst  
			WHERE agcus_key <> agcus_bill_to 
			--------------------------------------------------------------------------------------------------------------------------------------------	
			
			/**Account Status**/
			----------------------------------------------------------------------------------------------------------
			----------------INSERT INTO tblARCustomerAccountStatus(intEntityCustomerId, intAccountStatusId, intConcurrencyId)
			SELECT s.intAccountStatusId AS intAccountStatusId
			, 1 AS intConcurrencyId
			,P.agcus_key AS agcus_key
			INTO #tmpCustomerAccountStatus
			FROM (SELECT agcus_key, x, y	FROM agcusmst
			UNPIVOT
			(x FOR y IN (agcus_acct_stat_x_1, agcus_acct_stat_x_2, agcus_acct_stat_x_3, agcus_acct_stat_x_4
			, agcus_acct_stat_x_5, agcus_acct_stat_x_6, agcus_acct_stat_x_7, agcus_acct_stat_x_8, agcus_acct_stat_x_9
			, agcus_acct_stat_x_10)
			) unpiv) AS P
			--JOIN tblARCustomer c ON P.agcus_key COLLATE Latin1_General_CI_AS = c.strCustomerNumber
			JOIN tblARAccountStatus s ON P.x COLLATE Latin1_General_CI_AS = s.strAccountStatusCode
			--WHERE agcus_key = @originCustomer
			----------------------------------------------------------------------------------------------------------
				 
			DECLARE @TransName NVARCHAR(100)
			SET @TransName = ''CustomerImport''

			--WHILE (EXISTS(SELECT 1 FROM #tmpagcusmst)) --original code
			--WHILE (1=1)--test performance msa
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				--SELECT @originCustomer = agcus_key FROM #tmpagcusmst
				
				--SET @OriginCurrency = ''''

				BEGIN TRY
				
					BEGIN TRANSACTION @TransName
				
				 	DECLARE @ysnIsDefault BIT
					
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					IF (@EntityId IS NOT NULL)
					BEGIN
							--SELECT TOP 1 @EntityId = intEntityId FROM tblEMEntity where LTRIM(RTRIM(strEntityNo)) = RTRIM(LTRIM(@originCustomer))  --msa --remove duplicate select.
							SET @ysnIsDefault = 0	
					END
					ELSE
					BEGIN
						INSERT [dbo].[tblEMEntity]	([strName],[strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed],[imgPhoto],[strContactNumber], [strEntityNo],[dtmOriginationDate])
						VALUES (@strName, @strEmail, @strWebsite, @strInternalNotes, @ysnPrint1099, @str1099Name, @str1099Form, @str1099Type, @strFederalTaxId, @dtmW9Signed, @imgPhoto,'''', @originCustomer,@dtmOriginationDate)

						SET @EntityId = SCOPE_IDENTITY()
						SET @ysnIsDefault = 1
					END	
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
					/**Entity Type**/
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					IF NOT EXISTS (SELECT TOP 1 1 From tblEMEntityType where strType = ''Customer'' and intEntityId = @EntityId)
					BEGIN
						INSERT INTO [dbo].[tblEMEntityType]([intEntityId],[strType],[intConcurrencyId]) values( @EntityId, ''Customer'', 0 )
					END
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

					/**Insert into Customer Table**/
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					INSERT [dbo].[tblARCustomer](
					[intEntityId], 
					[intDefaultLocationId], 
					[intDefaultContactId], 
					[strCustomerNumber],		
					[strType],			
					[dblCreditLimit],
					[dblARBalance],				
					[strTaxNumber],
					[strCurrency],			
					[intAccountStatusId],			
					[intSalespersonId],		
					[strPricing],	
					[ysnActive],				
					[ysnPORequired],									
					[ysnStatementDetail],		
					[strStatementFormat],		
					[intCreditStopDays],		
					[strTaxAuthority1],		
					[strTaxAuthority2],			
					[ysnPrintPriceOnPrintTicket],	
					[intServiceChargeId],		
					[ysnApplySalesTax],		
					[ysnApplyPrepaidTax],		
					[dblBudgetAmountForBudgetBilling],
					[strBudgetBillingBeginMonth],
					[strBudgetBillingEndMonth],
					[dblMonthlyBudget],			
					[intNoOfPeriods],				
					[dtmBudgetBeginDate],			
					--Grain Tab
					[strDPAContract],				
					[dtmDPADate],				
					[strGBReceiptNumber],			
					[ysnCheckoffExempt],			
					[ysnVoluntaryCheckoff],		
					[strCheckoffState],			
					[ysnMarketAgreementSigned],	
					[intMarketZoneId],			
					[ysnHoldBatchGrainPayment],	
					[ysnFederalWithholding], 
					[intTermsId],
					[intCurrencyId])
					VALUES						
					(@EntityId,
					 NULL, 
					 NULL, 
					 @strCustomerNumber,		
					 @strType,			
					 @dblCreditLimit,
					 0,				
					 @strTaxNumber,
					 @strCurrency,			
					 @intAccountStatusId,			
					 @intEntitySalespersonId,		
					 @strPricing,	
					 @ysnActive,				
					 @ysnPORequired,									
					 @ysnStatementDetail,		
					 @strStatementFormat,		
					 @intCreditStopDays,		
					 @strTaxAuthority1,		
					 @strTaxAuthority2,			
					 @ysnPrintPriceOnPrintTicket,	
					 @intServiceChargeId,		
					 @ysnApplySalesTax,		
					 @ysnApplyPrepaidTax,		
					 @dblBudgetAmountForBudgetBilling,
					 @strBudgetBillingBeginMonth,
					 @strBudgetBillingEndMonth,
					 @dblMonthlyBudget,			
					 @intNoOfPeriods,				
					 @dtmBudgetBeginDate,			
					 @strDPAContract,				
					 @dtmDPADate,					
					 @strGBReceiptNumber,			
					 @ysnCheckoffExempt,			
					 @ysnVoluntaryCheckoff,		
					 @strCheckoffState,			
					 @ysnMarketAgreementSigned,	
					 @intMarketZoneId,			
					 @ysnHoldBatchGrainPayment,	
					 @ysnFederalWithholding, 
					 @intTermsId,
					 @intCurrencyId)
				 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				--Get intEntityCustomerId
				--SELECT @intEntityCustomerId = intEntityId FROM tblARCustomer WHERE intEntityId = @EntityId -- not in used 
		
				if(@strName is null)
				set @strName = ''''
				
				/**INSERT ENTITY record for Contact**/
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				IF(@strContactName IS NOT NULL)
				BEGIN
					INSERT [dbo].[tblEMEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes],[strContactNumber],[strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
					VALUES					 (@strContactName, @strEmail, @strWebsite, @strInternalNotes, 
												UPPER(CASE WHEN @strContactName IS NOT NULL THEN SUBSTRING(@strContactName, 1, 20) ELSE SUBSTRING(@strName, 1, 20) END), 
												@strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)
				END
				ELSE
					IF NOT EXISTS(SELECT TOP 1 1 FROM ssconmst WHERE sscon_cus_no COLLATE Latin1_General_CI_AS = @originCustomer)
					BEGIN
						INSERT [dbo].[tblEMEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes],[strContactNumber],[strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
						VALUES					 (@strName, @strEmail, @strWebsite, @strInternalNotes, 
													UPPER(CASE WHEN @strContactName IS NOT NULL THEN SUBSTRING(@strContactName, 1, 20) ELSE SUBSTRING(@strName, 1, 20) END), 
													@strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)
					END
					ELSE
					BEGIN
						SELECT 
							@strContactName = isnull(sscon_contact_id, '''')								
							, @strTitle = isnull(sscon_contact_title, '''')
							, @strEmail = RTRIM(LTRIM(isnull(sscon_email, '''')))
							, @strName = RTRIM(LTRIM(sscon_last_name)) + '', '' + RTRIM(LTRIM(sscon_first_name)) 
							, @strPhone = (CASE	
										WHEN sscon_work_ext IS NULL OR sscon_work_ext = '''' THEN
											RTRIM(LTRIM(sscon_work_no))
										WHEN sscon_work_no IS NULL OR sscon_work_no = '''' AND sscon_work_ext IS NOT NULL AND sscon_work_ext <> '''' THEN
											''x'' + RTRIM(LTRIM(sscon_work_ext))
										ELSE
											RTRIM(LTRIM(sscon_work_no)) + '' x'' + RTRIM(LTRIM(sscon_work_ext))
										END)
						FROM ssconmst sscon WHERE sscon_cus_no COLLATE Latin1_General_CI_AS = @originCustomer

						INSERT [dbo].[tblEMEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes],[strContactNumber],[strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
						VALUES					 (@strName, @strEmail, @strWebsite, @strInternalNotes, 
													UPPER(CASE WHEN @strContactName IS NOT NULL THEN SUBSTRING(@strContactName, 1, 20) ELSE SUBSTRING(@strName, 1, 20) END), 
													@strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)
					END
				
				  DECLARE @ContactEntityId INT
				  SET @ContactEntityId = SCOPE_IDENTITY()
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				/**INSERT Phone Number**/
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				if @strPhone <> ''''
				INSERT INTO tblEMEntityPhoneNumber(intEntityId,intCountryId, strPhone) VALUES (@ContactEntityId,NULL, @strPhone)
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
				-- RULE: when creating a default contact from agcusmst.agcus_contact, trim tblEMEntityContact.strContactNumber to 20 characters				
							
				--Get intContactId				
				DECLARE @LocCount INT
				SET @LocCount = 1 
				WHILE EXISTS(SELECT TOP 1 1 FROM tblEMEntityLocation where intEntityId = @EntityId and strLocationName = @strLocationName)
				BEGIN
					SET @LocCount = @LocCount + 1 
					SET @strLocationName =  LTRIM(RTRIM(@strLocationName)) + '' '' + CAST(@LocCount as Nvarchar(2))
				END
			
				--INSERT into Location
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				DECLARE @EntityLocationId INT
				IF(@strLocationName IS NOT NULL )
				BEGIN
					INSERT [dbo].[tblEMEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strNotes],  [intShipViaId], [intTermsId], [intWarehouseId], [ysnDefaultLocation])
					VALUES (@EntityId, @strLocationName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strLocationNotes,  @intShipViaId, @intTermsId, @intWarehouseId, @ysnIsDefault)
					SET @EntityLocationId = SCOPE_IDENTITY()
				END
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
				/**INSERT MULTIPLE Location based on the Bill to**/
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				INSERT [dbo].[tblEMEntityLocation]    
						([intEntityId], 
						 [strLocationName], 
						 [strAddress], 
						 [strCity], 
						 [strCountry], 
						 [strState], 
						 [strZipCode], 
						 [strNotes],  
						 [intShipViaId], 
						 [intTermsId], 
						 [intWarehouseId], 
						 [ysnDefaultLocation],
						 [strOriginLinkCustomer])
				SELECT @EntityId,
						[strLocationName], 
						 [strAddress], 
						 [strCity], 
						 [strCountry], 
						 [strState], 
						 [strZipCode], 
						 [strNotes],  
						 [intShipViaId], 
						 [intTermsId], 
						 [intWarehouseId], 
						 [ysnDefaultLocation],
						 [strOriginLinkCustomer]
				FROM #tmpagcusOtherLocation
				WHERE strOriginLinkCustomer = @originCustomer 		
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						 				 
				--INSERT into tblEMEntityToContact
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				DECLARE @CustomerToContactId INT
				
				INSERT INTO [dbo].[tblEMEntityToContact]([intEntityId],[intEntityContactId],[intEntityLocationId],[ysnDefaultContact],[ysnPortalAccess],[strUserType])
				VALUES( @EntityId, @ContactEntityId, @EntityLocationId, @ysnIsDefault ,0 , ''User'')
			
				SET @CustomerToContactId = SCOPE_IDENTITY()
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				UPDATE tblARCustomer 
				SET intDefaultContactId = @CustomerToContactId, 
					intDefaultLocationId = @EntityLocationId,
					intBillToId = @EntityLocationId,
					intShipToId = @EntityLocationId
				WHERE intEntityId = @EntityId 
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

				/**INSERT into tblARCustomerBudget**/
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				DECLARE @cnt int = 0
				DECLARE @cntNumberOfPeriods INT  = 0 --msa
				SET @cntNumberOfPeriods = @intNoOfPeriods --(SELECT intNoOfPeriods FROM tblARCustomer where strCustomerNumber = @originCustomer) -- to do use entityId to filter. MSA -->> use the value get from iteration.

				IF (ISNULL(@cntNumberOfPeriods ,0) > 0) --msa
				BEGIN
					WHILE @cnt < @cntNumberOfPeriods --msa
					BEGIN
						IF @cnt = 0
						BEGIN
								INSERT INTO tblARCustomerBudget
										([intEntityCustomerId]	
										,[dblBudgetAmount]		
										,[dtmBudgetDate]			
										,[intConcurrencyId])	
								SELECT  @EntityId -- msa
										,@dblMonthlyBudget -- dblMonthlyBudget--dblBudgetAmount --msa >> @dblMonthlyBudget
										,@dtmBudgetBeginDate -- dtmBudgetBeginDate -- msa >> @dtmBudgetBeginDate
										,0
								-- FROM tblARCustomer --msa comment out.
								--WHERE strCustomerNumber = @originCustomer --msa --msa comment out.
						END 
						ELSE 
						BEGIN
								INSERT INTO tblARCustomerBudget
										([intEntityCustomerId]	
										,[dblBudgetAmount]		
										,[dtmBudgetDate]			
										,[intConcurrencyId])	
								SELECT @EntityId --msa
										,@dblMonthlyBudget -- dblMonthlyBudget--dblBudgetAmount --msa >> @dblMonthlyBudget
										,DATEADD(MONTH, @cnt, @dtmBudgetBeginDate) --msa >> @dtmBudgetBeginDate
										,0
								-- FROM tblARCustomer --msa comment out.
								--WHERE strCustomerNumber = @originCustomer -- --msa comment out.
						END

						SET @cnt = @cnt + 1;
					END
				END
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				/**INSERT Customer Account Status**/
				----------------------------------------------------------------------------------------------------------
				INSERT INTO tblARCustomerAccountStatus(intEntityCustomerId, intAccountStatusId, intConcurrencyId)
				SELECT @EntityId, intAccountStatusId, intConcurrencyId
				FROM #tmpCustomerAccountStatus A
				--JOIN tblARCustomer c ON P.agcus_key COLLATE Latin1_General_CI_AS = c.strCustomerNumber
				WHERE agcus_key = @originCustomer
				----------------------------------------------------------------------------------------------------------

				COMMIT TRANSACTION @TransName
				END TRY

				BEGIN CATCH
				      PRINT ''Failed to imports'' + @originCustomer + ERROR_MESSAGE() 		
					IF (XACT_STATE()) <> 0
				    ROLLBACK TRANSACTION @TransName
					
					--INSERT INTO tblARCustomerFailedImport( strCustomerNumber, strReason)					
					--VALUES(@originCustomer,ERROR_MESSAGE())					
					
					GOTO CONTINUELOOP;
				END CATCH
				
				IF(@@ERROR <> 0) 
				BEGIN
					PRINT @@ERROR;
					RETURN;
				END
								
				CONTINUELOOP:
				
				--DELETE FROM #tmpagcusmst WHERE agcus_key = @originCustomer
		
				SET @Counter += 1;
				--PRINT @originCustomer
				--PRINT @Counter 

				FETCH NEXT FROM tmpagcusmst INTO 
						@originCustomer 
						,@strName 
						,@strEmail   
						,@strWebsite 
						,@strInternalNotes 
						,@ysnPrint1099   
						,@str1099Name    
						,@str1099Form	
						,@str1099Type	
						,@strFederalTaxId	
						,@dtmW9Signed	
						,@imgPhoto 
						,@strTitle 
						,@strContactName 
						,@strDepartment 
						,@strMobile     
						,@strPhone      
						,@strPhone2     
						,@strEmail2     
						,@strFax        
						,@strNotes      
						,@strContactMethod 
						,@strTimezone 
						,@strUserType 
						,@ysnPortalAccess 
					    ,@strLocationName 
						,@strAddress      
						,@strCity         
						,@strCountry      
						,@strState        
						,@strZipCode      
						,@strLocationNotes 
						,@intShipViaId 
						,@intTaxCodeId 
						,@intTermsId   
						,@intWarehouseId  
						,@strCustomerNumber		
						,@strType				
						,@dblCreditLimit			
						,@strTaxNumber			
						,@strCurrency			
						,@intAccountStatusId		
						,@intEntitySalespersonId	
    					,@strPricing				
						,@ysnActive				
						,@dtmOriginationDate		
						,@ysnPORequired
						,@ysnStatementDetail
						,@strStatementFormat
						,@intCreditStopDays
						,@strTaxAuthority1
						,@strTaxAuthority2
						,@ysnPrintPriceOnPrintTicket 
						,@intServiceChargeId		
						,@ysnApplySalesTax		
						,@ysnApplyPrepaidTax		
						,@dblBudgetAmountForBudgetBilling 
						,@strBudgetBillingBeginMonth	
						,@strBudgetBillingEndMonth	
						,@dblMonthlyBudget	
						,@intNoOfPeriods		
						,@dtmBudgetBeginDate 
						,@OriginCurrency 			
						,@strDPAContract 
		                ,@dtmDPADate 
						,@strGBReceiptNumber 
						,@ysnCheckoffExempt 
						,@ysnVoluntaryCheckoff 
						,@strCheckoffState 
						,@ysnMarketAgreementSigned 
						,@intMarketZoneId 
						,@ysnHoldBatchGrainPayment 
						,@ysnFederalWithholding 
				        ,@intCurrencyId  
						,@EntityId 
			END
	
			SET @Total = @Counter
		
			/**IMPORT CUSTOMER COMMENTS**/
			-----------------------------------
			EXEC uspARImportCustomerComments
			-----------------------------------

		END

		--================================================
		--     GET TO BE IMPORTED RECORDS	
		--================================================
		IF(@Update = 1 AND @CustomerId IS NULL) 
		BEGIN
			SELECT @Total = COUNT(agcus_key)  
				FROM agcusmst
			LEFT JOIN tblARCustomer
				ON agcusmst.agcus_key COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE tblARCustomer.strCustomerNumber IS NULL
		END
		
	END'
	)
END

IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PT') = 1
BEGIN

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportCustomer')
BEGIN
	PRINT 'DROP PROCEDURE uspARImportCustomer'
	DROP PROCEDURE uspARImportCustomer
END

	PRINT 'CREATE PROCEDURE uspARImportCustomer'
EXEC(
'
CREATE PROCEDURE [dbo].[uspARImportCustomer]
		@CustomerId NVARCHAR(50) = NULL,
		@Update BIT = 0,
		@Total INT = 0 OUTPUT

		AS
	BEGIN
		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF
		--================================================
		--     UPDATE/INSERT IN ORIGIN
		--================================================
		IF(@Update = 1 AND @CustomerId IS NOT NULL)
		BEGIN
			UPDATE Loc 
				SET strOriginLinkCustomer = SUBSTRING(Ent.strEntityNo,1,10)
				FROM tblEMEntity Ent
					INNER JOIN tblEMEntityLocation Loc 
						ON Ent.intEntityId = Loc.intEntityId 
			WHERE Ent.strEntityNo =  @CustomerId

			--UPDATE IF EXIST IN THE ORIGIN
			IF(EXISTS(SELECT 1 FROM ptcusmst WHERE ptcus_cus_no = SUBSTRING(@CustomerId,1,10)))
			BEGIN
				UPDATE ptcusmst
				SET
				--Entity
				ptcus_last_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),''''),
				ptcus_first_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),''''),
				ptcus_comment = SUBSTRING(Con.strInternalNotes,1,30),
				--ptcus_1099_name = SUBSTRING(Ent.str1099Name,1,50),
				--Location
				ptcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END,
				ptcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END,
				ptcus_city = SUBSTRING(Loc.strCity,1,20),
				ptcus_state = SUBSTRING(Loc.strState,1,2),
				ptcus_zip = ISNULL(SUBSTRING(Loc.strZipCode,1,10), ''''),
				ptcus_country = (CASE WHEN LEN(Loc.strCountry) = 10 THEN Loc.strCountry ELSE '''' END),
				--Contact
				ptcus_contact = SUBSTRING((Con.strName),1,20),
				ptcus_phone = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL ((CASE WHEN CHARINDEX('x', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,15), 0, CHARINDEX('x',P.strPhone)) ELSE SUBSTRING(P.strPhone,1,15)END), '') , '(', ''), ')', ''), ' ', ''),'-', ''),
				ptcus_phone_ext = (CASE WHEN CHARINDEX(''x'', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,30),CHARINDEX(''x'',P.strPhone) + 1, LEN(P.strPhone))END),
				ptcus_phone2 = (CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,15), 0, CHARINDEX(''x'',M.strPhone)) ELSE SUBSTRING(M.strPhone,1,15)END),
				ptcus_phone_ext2 = (CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,30),CHARINDEX(''x'',M.strPhone) + 1, LEN(M.strPhone))END),
				--Customer
				ptcus_cus_no = SUBSTRING(Ent.strEntityNo,1,10),
				ptcus_co_per_ind_cp = CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END,
				ptcus_credit_limit = Cus.dblCreditLimit,
				ptcus_sales_tax_id = SUBSTRING(Cus.strTaxNumber,1,15),
				--ptcus_dflt_currency = Cus.strCurrency,
				ptcus_active_yn = CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END,
				--ptcus_req_po_yn = CASE WHEN Cus.ysnPORequired = 1 THEN ''Y'' ELSE ''N'' END,
				ptcus_prt_stmnt_dtl_yn = CASE WHEN Cus.ysnStatementDetail = 1 THEN ''Y'' ELSE ''N'' END,
				ptcus_stmt_fmt = CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O'' WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' WHEN Cus.strStatementFormat = ''None'' THEN ''N'' WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END,
				ptcus_crd_stop_days = Cus.intCreditStopDays,
				ptcus_local1 = SUBSTRING(Cus.strTaxAuthority1,1,3),
				ptcus_local2 = SUBSTRING(Cus.strTaxAuthority2,1,3),
				ptcus_pic_prc_yn = CASE WHEN Cus.ysnPrintPriceOnPrintTicket = 1 THEN ''Y'' ELSE ''N'' END,
				ptcus_sales_tax_yn = (CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''P'' ELSE  CASE WHEN Cus.ysnApplySalesTax = 1 THEN ''Y'' ELSE ''N'' END END),
				ptcus_budget_amt = Cus.dblBudgetAmountForBudgetBilling,
				ptcus_budget_beg_mm = SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2),
				ptcus_budget_end_mm = SUBSTRING(Cus.strBudgetBillingEndMonth,1,2),
				ptcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = (SELECT TOP 1 intAccountStatusId FROM tblARCustomerAccountStatus WHERE intEntityCustomerId = Cus.intEntityId ORDER BY intCustomerAccountStatusId)),
				ptcus_acct_stat_x_2 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = (SELECT  intAccountStatusId FROM tblARCustomerAccountStatus WHERE intEntityCustomerId = Cus.intEntityId ORDER BY intCustomerAccountStatusId OFFSET (2) ROW FETCH NEXT (2) ROW ONLY)),
				ptcus_slsmn_id		= (SELECT strSalespersonId FROM tblARSalesperson WHERE intEntityId = Cus.intSalespersonId),
				ptcus_srv_cd		= (SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId),
				ptcus_terms_code = (SELECT case when ISNUMERIC(strTermCode) = 0 then null else strTermCode end  FROM tblSMTerm WHERE intTermID = Cus.intTermsId and cast( (case when isnumeric(strTermCode) = 1 then  strTermCode else 266 end ) as bigint) <= 255 ),
				ptcus_bill_to = SUBSTRING(Ent.strEntityNo,1,10)
				--ptcus_dpa_cnt = Cus.strDPAContract,
				--ptcus_dpa_rev_dt = CONVERT(int,''20'' + CONVERT(nvarchar,Cus.dtmDPADate,12)),
				--ptcus_gb_rcpt_no = Cus.strGBReceiptNumber,
				--agcus_ckoff_exempt_yn = CASE WHEN Cus.ysnCheckoffExempt = 1 THEN ''Y'' ELSE ''N'' END,
				--agcus_ckoff_vol_yn = CASE WHEN Cus.ysnVoluntaryCheckoff = 1 THEN ''Y'' ELSE ''N'' END,
				--agcus_ga_origin_st = Cus.strCheckoffState,
				--agcus_mkt_sign_yn = CASE WHEN Cus.ysnMarketAgreementSigned = 1 THEN ''Y'' ELSE ''N'' END,
				--agcus_dflt_mkt_zone = Cus.intMarketZoneId,
				--agcus_ga_hold_pay_yn = CASE WHEN Cus.ysnHoldBatchGrainPayment = 1 THEN ''Y'' ELSE ''N'' END,
				--agcus_ga_wthhld_yn = CASE WHEN Cus.ysnFederalWithholding = 1 THEN ''Y'' ELSE ''N'' END
			FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
				INNER JOIN tblEMEntityToContact CustToCon 
					ON Cus.intEntityId = CustToCon.intEntityId 
						and CustToCon.ysnDefaultContact = 1
				INNER JOIN tblEMEntity Con 
					ON CustToCon.intEntityContactId = Con.intEntityId
				INNER JOIN tblEMEntityLocation Loc 
					ON Ent.intEntityId = Loc.intEntityId 
						and Loc.ysnDefaultLocation = 1
				LEFT JOIN tblEMEntityLocation BillToLocation
					ON Cus.intBillToId = BillToLocation.intEntityLocationId
						AND BillToLocation.intEntityId = Cus.intEntityId
				LEFT JOIN tblEMEntityPhoneNumber P
					ON P.intEntityId = Con.intEntityId
				LEFT JOIN tblEMEntityMobileNumber M
					ON M.intEntityId = Con.intEntityId	
				--WHERE Ent.strEntityNo = @CustomerId AND ptcus_cus_no = SUBSTRING(@CustomerId,1,10)
				WHERE Cus.strCustomerNumber = @CustomerId AND ptcus_cus_no = SUBSTRING(@CustomerId,1,10)
			END
			--INSERT IF NOT EXIST IN THE ORIGIN
			ELSE
				INSERT INTO ptcusmst(
				--Entity
				ptcus_last_name,
				ptcus_first_name,
				ptcus_mid_init,
				ptcus_name_suffx,
				ptcus_comment,
				--Contact,
				ptcus_contact,
				ptcus_phone,
				ptcus_phone_ext,
				ptcus_phone2,
				ptcus_phone_ext2,
				--Location
				ptcus_addr,
				ptcus_addr2,
				ptcus_city,
				ptcus_state,
				ptcus_zip,
				ptcus_country,
				--Customer
				ptcus_cus_no,
				ptcus_co_per_ind_cp,
				ptcus_credit_limit,
				ptcus_sales_tax_id,
				ptcus_active_yn,
				ptcus_prt_stmnt_dtl_yn,
				ptcus_stmt_fmt,
				ptcus_crd_stop_days,
				ptcus_local1,
				ptcus_local2,
				ptcus_pic_prc_yn,
				ptcus_sales_tax_yn,
				ptcus_budget_amt,
				ptcus_budget_beg_mm,
				ptcus_budget_end_mm,
				ptcus_acct_stat_x_1,
				ptcus_slsmn_id,
				ptcus_srv_cd,
				ptcus_terms_code,
				ptcus_bill_to				
				--agcus_dpa_cnt
				--agcus_dpa_rev_dt,
				--agcus_gb_rcpt_no,
				--agcus_ckoff_exempt_yn,
				--agcus_ckoff_vol_yn,
				--agcus_ga_origin_st,
				--agcus_mkt_sign_yn,
				--agcus_dflt_mkt_zone,
				--agcus_ga_hold_pay_yn ,
				--agcus_ga_wthhld_yn

			)

			SELECT
				--Entity
				ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),'''') AS strLastName,
				ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),'''') AS strFirsName,
				'''' as strMiddleInitial,
				'''' as strNameSuffix,
				SUBSTRING(Ent.strInternalNotes,1,30) as strInternalNotes,
				--Ent.str1099Name,
				--Contact
				SUBSTRING((Con.strName),1,20) AS strContactName,
				ISNULL( (CASE WHEN CHARINDEX(''x'', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,15), 0, CHARINDEX(''x'',P.strPhone)) ELSE SUBSTRING(P.strPhone,1,15)END) , '''') as strPhone,
				(CASE WHEN CHARINDEX(''x'', P.strPhone) > 0 THEN SUBSTRING(SUBSTRING(P.strPhone,1,30),CHARINDEX(''x'',P.strPhone) + 1, LEN(P.strPhone))END) as strPhoneExt,
				(CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,15), 0, CHARINDEX(''x'',M.strPhone)) ELSE SUBSTRING(M.strPhone,1,15)END) as strPhone2,
				(CASE WHEN CHARINDEX(''x'', M.strPhone) > 0 THEN SUBSTRING(SUBSTRING(M.strPhone,1,30),CHARINDEX(''x'',M.strPhone) + 1, LEN(M.strPhone))END) as strPhone2Ext,
				--Location
				(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END) AS strAddress1,
				(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END) AS strAddress2,
				SUBSTRING(Loc.strCity,1,20) as strCity,
				SUBSTRING(Loc.strState,1,2) as strState,
				ISNULL(SUBSTRING(Loc.strZipCode,1,10), '''') as strZipCode,
				(CASE WHEN LEN(Loc.strCountry) = 10 THEN Loc.strCountry ELSE '''' END)as strCountry,
				--Customer
				SUBSTRING(Ent.strEntityNo,1,10) as strCustomerNumber,
				(CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END) AS strType,
				Cus.dblCreditLimit,
				SUBSTRING(Cus.strTaxNumber,1,15) as strTaxNumber,
				(CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END) AS ysnActive,
				(CASE WHEN Cus.ysnStatementDetail = 1 THEN ''Y'' ELSE ''N'' END) AS ysnStatementDetail,
				(CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O'' WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' WHEN Cus.strStatementFormat = ''None'' THEN ''N'' WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END) as strStatementFormat ,
				Cus.intCreditStopDays,
				SUBSTRING(Cus.strTaxAuthority1,1,3) as strTaxAuthority1,
				SUBSTRING(Cus.strTaxAuthority2,1,3) as strTaxAuthority2,
				(CASE WHEN Cus.ysnPrintPriceOnPrintTicket = 1 THEN ''Y'' ELSE ''N'' END) AS ysnPrintPriceOnPrintTicket,
				(CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''P'' ELSE  CASE WHEN Cus.ysnApplySalesTax = 1 THEN ''Y'' ELSE ''N'' END END) AS ysnApplyPrepaidTax,
				Cus.dblBudgetAmountForBudgetBilling,
				SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2) as strBudgetBillingBeginMonth,
				SUBSTRING(Cus.strBudgetBillingEndMonth,1,2) as strBudgetBillingEndMonth,
				(SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId),
				(SELECT strSalespersonId FROM tblARSalesperson WHERE intEntityId = Cus.intSalespersonId),
				(SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId),
				(SELECT case when ISNUMERIC(strTermCode) = 0 then null else strTermCode end  FROM tblSMTerm WHERE intTermID = Cus.intTermsId and cast( (case when isnumeric(strTermCode) = 1 then  strTermCode else 266 end ) as bigint) <= 255),
				SUBSTRING(Ent.strEntityNo,1,10)
				--Cus.strDPAContract,
				--CONVERT(int,''20'' + CONVERT(nvarchar,Cus.dtmDPADate,12)),
				--Cus.strGBReceiptNumber,
				--(CASE WHEN Cus.ysnCheckoffExempt = 1 THEN ''Y'' ELSE ''N'' END) as ysnCheckoffExempt,
				--(CASE WHEN Cus.ysnVoluntaryCheckoff = 1 THEN ''Y'' ELSE ''N'' END) as ysnVoluntaryCheckoff,
				--Cus.strCheckoffState,
				--(CASE WHEN Cus.ysnMarketAgreementSigned = 1 THEN ''Y'' ELSE ''N'' END) as ysnMarketAgreementSigned,
				--Cus.intMarketZoneId,
				--(CASE WHEN Cus.ysnHoldBatchGrainPayment = 1 THEN ''Y'' ELSE ''N'' END) as ysnHoldBatchGrainPayment,
				--(CASE WHEN Cus.ysnFederalWithholding = 1 THEN ''Y'' ELSE ''N'' END) as ysnFederalWithholding
				FROM tblEMEntity Ent
				INNER JOIN tblARCustomer Cus 
					ON Ent.intEntityId = Cus.intEntityId
				INNER JOIN tblEMEntityToContact CusToCon 
					ON Cus.intEntityId = CusToCon.intEntityId 
						and CusToCon.ysnDefaultContact = 1
				INNER JOIN tblEMEntity Con 
					ON CusToCon.intEntityContactId = Con.intEntityId
				INNER JOIN tblEMEntityLocation Loc 
					ON Ent.intEntityId = Loc.intEntityId 
						and Loc.ysnDefaultLocation = 1
				LEFT JOIN tblEMEntityLocation BillToLocation
					ON Cus.intBillToId = BillToLocation.intEntityLocationId
						AND BillToLocation.intEntityId = Cus.intEntityId
				LEFT JOIN tblEMEntityPhoneNumber P
					ON P.intEntityId = Con.intEntityId
				LEFT JOIN tblEMEntityMobileNumber M
					ON M.intEntityId = Con.intEntityId	
				WHERE Ent.strEntityNo =  @CustomerId

		RETURN;
		END

		--================================================
		--     ONE TIME CUSTOMER SYNCHRONIZATION
		--================================================
		IF(@Update = 0 AND @CustomerId IS NULL)
		BEGIN
			
			TRUNCATE TABLE tblARCustomerFailedImport
			--1 Time synchronization here
			PRINT ''1 Time Customer Synchronization''

			DECLARE @intCurrencyId	INT = NULL
			
			SELECT TOP 1 @intCurrencyId = intDefaultCurrencyId 
			FROM tblSMCompanyPreference
			ORDER BY intCompanyPreferenceId

			IF(OBJECT_ID(''tempdb..#CUSTOMERS'') IS NOT NULL) DROP TABLE #CUSTOMERS
			CREATE TABLE #CUSTOMERS (
					intId								INT	IDENTITY (1, 1) NOT NULL PRIMARY KEY
				  , intEntityId							INT NULL
				  , intEntityLocationId					INT NULL
				  , strName								NVARCHAR(200) COLLATE Latin1_General_CI_AS	  
				  , strInternalNotes					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
				  , ysnPrint1099						BIT NULL DEFAULT 0
				  , strFederalTaxId						NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
				  , ysnDefault							BIT NULL DEFAULT 0
				  --CONTACT
				  , strContactName						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
				  , strPhone							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				  , strPhone2							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				  --LOCATION
				  , strLocationName						NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
				  , strAddress							NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
				  , strCity								NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				  , strCountry							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				  , strState							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				  , strZipCode							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				  , intTermsId							INT NULL
				  , intWarehouseId						INT NULL
				  --CUSTOMER
				  , strCustomerNumber					NVARCHAR(200) COLLATE Latin1_General_CI_AS
				  , strType								NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
				  , dblCreditLimit						NUMERIC(18,6) NULL DEFAULT 0
				  , strTaxNumber						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
				  , intAccountStatusId					INT NULL
				  , intEntitySalespersonId				INT NULL
				  , strPricing							NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				  , ysnActive							BIT NULL DEFAULT 0
				  , dtmOriginationDate					DATETIME NULL
				  , ysnPORequired						BIT NULL DEFAULT 0
				  , ysnStatementDetail					BIT NULL DEFAULT 0
				  , strStatementFormat					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				  , intCreditStopDays					INT NULL
				  , strTaxAuthority1					NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				  , strTaxAuthority2					NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				  , ysnPrintPriceOnPrintTicket			BIT NULL DEFAULT 0
				  , intServiceChargeId					INT NULL
				  , ysnApplySalesTax					BIT NULL DEFAULT 0
				  , ysnApplyPrepaidTax					BIT NULL DEFAULT 0
				  , dblBudgetAmountForBudgetBilling		NUMERIC(18,6) NULL DEFAULT 0
				  , strBudgetBillingBeginMonth			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				  , strBudgetBillingEndMonth			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				  , dblMonthlyBudget					NUMERIC(18,6) NULL DEFAULT 0
				  , intNoOfPeriods						INT NULL
				  , dtmBudgetBeginDate					DATETIME NULL
				  , strLevel							NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				  , intCompanyLocationPricingLevelId	INT NULL
			)

			INSERT INTO #CUSTOMERS WITH (TABLOCK) (
					strName
				  , strInternalNotes
				  , ysnPrint1099
				  , strFederalTaxId
				  , ysnDefault
				  --CONTACT
				  , strContactName
				  , strPhone
				  , strPhone2
				  --LOCATION
				  , strLocationName
				  , strAddress
				  , strCity
				  , strCountry
				  , strState
				  , strZipCode
				  , intTermsId
				  , intWarehouseId
				  --CUSTOMER
				  , strCustomerNumber
				  , strType
				  , dblCreditLimit
				  , strTaxNumber
				  , intAccountStatusId
				  , intEntitySalespersonId
				  , strPricing
				  , ysnActive
				  , dtmOriginationDate
				  , ysnPORequired
				  , ysnStatementDetail
				  , strStatementFormat
				  , intCreditStopDays
				  , strTaxAuthority1
				  , strTaxAuthority2
				  , ysnPrintPriceOnPrintTicket
				  , intServiceChargeId
				  , ysnApplySalesTax
				  , ysnApplyPrepaidTax
				  , dblBudgetAmountForBudgetBilling
				  , strBudgetBillingBeginMonth
				  , strBudgetBillingEndMonth
				  , dblMonthlyBudget
				  , intNoOfPeriods
				  , dtmBudgetBeginDate
			)
			SELECT strName								 = CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name)) END
				  , strInternalNotes					 = ptcus_comment
				  , ysnPrint1099						 = 0
				  , strFederalTaxId						 = ptcus_sales_tax_id
				  , ysnDefault							 = 1	
				  --CONTACT								 
				  , strContactName						 = ptcus_contact
				  , strPhone							 = (CASE WHEN ptcus_phone_ext IS NULL OR ptcus_phone_ext = '''' THEN RTRIM(LTRIM(ptcus_phone))
																 WHEN ptcus_phone IS NULL OR ptcus_phone = '''' AND ptcus_phone_ext IS NOT NULL AND ptcus_phone_ext <> '''' THEN ''x'' + RTRIM(LTRIM(ptcus_phone_ext))
																 ELSE RTRIM(LTRIM(ptcus_phone)) + '' x'' + RTRIM(LTRIM(ptcus_phone_ext))
															END)
				  , strPhone2							 = (CASE WHEN ptcus_phone_ext2 IS NULL OR ptcus_phone_ext2 = '''' THEN RTRIM(LTRIM(ptcus_phone2))
																 WHEN ptcus_phone2 IS NULL OR ptcus_phone2 = '''' AND ptcus_phone_ext2 IS NOT NULL AND ptcus_phone_ext2 <> '''' THEN ''x'' + RTRIM(LTRIM(ptcus_phone_ext2))
																 ELSE RTRIM(LTRIM(ptcus_phone2)) + '' x'' + RTRIM(LTRIM(ptcus_phone_ext2))
															END)
				  --LOCATION							  
				  , strLocationName						 = CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name)) END
				  , strAddress							 = ISNULL(ptcus_addr, '''') + CHAR(10) + ISNULL(ptcus_addr2, '''')
				  , strCity								 = LTRIM(RTRIM(ptcus_city))
				  , strCountry							 = LTRIM(RTRIM(ptcus_country))
				  , strState							 = LTRIM(RTRIM(ptcus_state))
				  , strZipCode							 = ISNULL(LTRIM(RTRIM(ptcus_zip)), '''')
				  , intTermsId							 = TERMS.intTermID
				  , intWarehouseId						 = LOC.intCompanyLocationId
				  --CUSTOMER							 
				  , strCustomerNumber					 = ptcus_cus_no
				  , strType								 = CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ''Company'' ELSE ''Person'' END
				  , dblCreditLimit						 = ptcus_credit_limit
				  , strTaxNumber						 = ptcus_sales_tax_id
				  , intAccountStatusId					 = ACCS.intAccountStatusId
				  , intEntitySalespersonId				 = SP.intEntityId
				  , strPricing							 = NULL --agcus_prc_lvl
				  , ysnActive							 = CASE WHEN ptcus_active_yn = ''Y'' THEN 1 ELSE 0 END
				  , dtmOriginationDate					 = CASE WHEN ptcus_origin_rev_dt = 0 THEN NULL ELSE CONVERT(datetime,SUBSTRING(CONVERT(nvarchar,ptcus_origin_rev_dt),0,5) + ''-'' + SUBSTRING(CONVERT(nvarchar,ptcus_origin_rev_dt),5,2) + ''-'' + SUBSTRING(CONVERT(nvarchar,ptcus_origin_rev_dt),7,2)) END
				  , ysnPORequired						 = 0
				  , ysnStatementDetail					 = CASE WHEN ptcus_prt_stmnt_dtl_yn = ''Y'' THEN 1 ELSE 0 END
				  , strStatementFormat					 = CASE WHEN ptcus_stmt_fmt = ''O'' THEN ''Open Item'' WHEN ptcus_stmt_fmt = ''B'' THEN ''Balance Forward'' WHEN ptcus_stmt_fmt = ''R'' THEN ''Budget Reminder'' WHEN ptcus_stmt_fmt = ''N'' THEN ''None'' WHEN ptcus_stmt_fmt IS NULL THEN NULL Else '''' END
				  , intCreditStopDays					 = ptcus_crd_stop_days
				  , strTaxAuthority1					 = ptcus_local1
				  , strTaxAuthority2					 = ptcus_local2
				  , ysnPrintPriceOnPrintTicket			 = CASE WHEN ptcus_pic_prc_yn = ''Y'' THEN 1 ELSE 0 END
				  , intServiceChargeId					 = SC.intServiceChargeId
				  , ysnApplySalesTax					 = CASE WHEN ptcus_sales_tax_yn = ''Y'' THEN 1 ELSE 0 END
				  , ysnApplyPrepaidTax					 = CASE WHEN ptcus_sales_tax_yn = ''P'' THEN 1 ELSE 0 END
				  , dblBudgetAmountForBudgetBilling		 = ptcus_budget_amt
				  , strBudgetBillingBeginMonth			 = ptcus_budget_beg_mm
				  , strBudgetBillingEndMonth			 = ptcus_budget_end_mm
				  , dblMonthlyBudget					 = ISNULL(ptcus_budget_amt,0)
				  , intNoOfPeriods						 = CASE WHEN (ptcus_budget_beg_mm < ptcus_budget_end_mm) THEN (ptcus_budget_end_mm -ptcus_budget_beg_mm) + 1
																WHEN (ptcus_budget_beg_mm > ptcus_budget_end_mm) THEN ((13 - ptcus_budget_beg_mm) + ptcus_budget_end_mm)
														   ELSE 0 END
				  , dtmBudgetBeginDate					 = CASE WHEN ptcus_budget_beg_mm <> 0 THEN CONVERT(DATE, CAST(YEAR(getdate()) AS CHAR(4))+RIGHT(''00''+RTRIM(CAST(ptcus_budget_beg_mm AS CHAR(2))),2)+''01'' , 112) ELSE NULL END
			FROM ptcusmst O
			LEFT JOIN tblARCustomer C ON O.ptcus_cus_no COLLATE Latin1_General_CI_AS = C.strCustomerNumber COLLATE Latin1_General_CI_AS
			OUTER APPLY (
				SELECT TOP 1 intTermID
				FROM tblSMTerm 
				WHERE strTermCode = CAST(ptcus_terms_code AS CHAR(10))
			) TERMS
			OUTER APPLY (
				SELECT TOP 1 intCompanyLocationId 
				FROM tblSMCompanyLocation 
				WHERE strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = ptcus_bus_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS
			) LOC
			OUTER APPLY (
				SELECT TOP 1 intAccountStatusId 
				FROM tblARAccountStatus 
				WHERE strAccountStatusCode COLLATE Latin1_General_CI_AS = ptcus_acct_stat_x_1 COLLATE Latin1_General_CI_AS
				OR strAccountStatusCode COLLATE Latin1_General_CI_AS = ptcus_acct_stat_x_2 COLLATE Latin1_General_CI_AS
			) ACCS
			OUTER APPLY (
				SELECT TOP 1 intEntityId 
				FROM tblARSalesperson 
				WHERE strSalespersonId COLLATE Latin1_General_CI_AS = ptcus_slsmn_id COLLATE Latin1_General_CI_AS
			) SP
			OUTER APPLY (
				SELECT TOP 1 intServiceChargeId 
				FROM tblARServiceCharge 
				WHERE strServiceChargeCode COLLATE Latin1_General_CI_AS = ptcus_srv_cd COLLATE Latin1_General_CI_AS
			) SC
			WHERE C.strCustomerNumber IS NULL 
			  AND O.ptcus_co_per_ind_cp IS NOT NULL
			  AND O.ptcus_cus_no = O.ptcus_bill_to

			--COUNT 
			SELECT @Total = COUNT(1) FROM #CUSTOMERS

			--PRICE LEVEL
			UPDATE C
			SET strLevel							= PL.strPriceLevelName
			  , intCompanyLocationPricingLevelId	= PL.intCompanyLocationPricingLevelId
			FROM #CUSTOMERS C
			CROSS APPLY (
				SELECT TOP 1 XREF.strPriceLevelName
						   , XREF.intCompanyLocationPricingLevelId
				FROM (
					SELECT O.strPriceLevelName
						 , O.ptcus_cus_no
						 , intCompanyLocationPricingLevelId
					FROM (
						SELECT strPriceLevelName = (CASE A.ptcus_prc_level 
															WHEN 1 THEN ptctlmst.pt3cf_prc1 
															WHEN 2 THEN ptctlmst.pt3cf_prc2 
															WHEN 3THEN ptctlmst.pt3cf_prc3 
													END)
							 , ptcus_bus_loc_no
							  ,ptcus_cus_no
						FROM ptcusmst A
						INNER JOIN ptctlmst ON ptctl_key = 3 AND ptcus_prc_level IS NOT NULL AND ptcus_bus_loc_no IS NOT NULL
					) O
					INNER JOIN tblSMCompanyLocation CompL ON O.ptcus_bus_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = CompL.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
					INNER JOIN tblSMCompanyLocationPricingLevel i21CompLocPrcLvl ON CompL.intCompanyLocationId = i21CompLocPrcLvl.intCompanyLocationId AND O.strPriceLevelName COLLATE Latin1_General_CI_AS = i21CompLocPrcLvl.strPricingLevelName COLLATE Latin1_General_CI_AS
				) XREF
				WHERE C.strCustomerNumber COLLATE Latin1_General_CI_AS = XREF.ptcus_cus_no COLLATE Latin1_General_CI_AS
			) PL

			--DEFAULT FLAG
			UPDATE C
			SET ysnDefault = 0
			FROM #CUSTOMERS C
			INNER JOIN tblEMEntity E ON LTRIM(RTRIM(E.strEntityNo)) = RTRIM(LTRIM(C.strCustomerNumber))
			WHERE E.intEntityId IS NOT NULL

			--ENTITY
			INSERT INTO tblEMEntity (
				   strName
				 , strInternalNotes
				 , strFederalTaxId
				 , strContactNumber
				 , strEntityNo
				 , dtmOriginationDate
			)
			SELECT strName				= C.strName
				 , strInternalNotes		= C.strInternalNotes
				 , strFederalTaxId		= C.strFederalTaxId
				 , strContactNumber		= ''''
				 , strEntityNo			= C.strCustomerNumber
				 , dtmOriginationDate	= C.dtmOriginationDate
			FROM #CUSTOMERS C
			LEFT JOIN tblEMEntity E ON LTRIM(RTRIM(E.strEntityNo)) = RTRIM(LTRIM(C.strCustomerNumber))
			WHERE E.intEntityId IS NULL

			--CUSTOMER
			INSERT INTO tblARCustomer WITH (TABLOCK) (
				  intEntityId
				, intDefaultLocationId
				, intDefaultContactId
				, strCustomerNumber
				, strType
				, dblCreditLimit
				, dblARBalance
				, strTaxNumber
				, strCurrency
				, intAccountStatusId
				, intSalespersonId
				, strPricing
				, ysnActive
				, ysnPORequired
				, ysnStatementDetail
				, strStatementFormat
				, intCreditStopDays
				, strTaxAuthority1
				, strTaxAuthority2
				, ysnPrintPriceOnPrintTicket
				, intServiceChargeId
				, ysnApplySalesTax
				, ysnApplyPrepaidTax
				, dblBudgetAmountForBudgetBilling
				, strBudgetBillingBeginMonth
				, strBudgetBillingEndMonth
				, dblMonthlyBudget
				, intNoOfPeriods
				, dtmBudgetBeginDate
				, intTermsId
				, intCurrencyId
				, strLevel
				, intCompanyLocationPricingLevelId
			)
			SELECT intEntityId							= E.intEntityId
				, intDefaultLocationId					= NULL
				, intDefaultContactId					= NULL
				, strCustomerNumber						= C.strCustomerNumber
				, strType								= C.strType
				, dblCreditLimit						= C.dblCreditLimit
				, dblARBalance							= 0
				, strTaxNumber							= strTaxNumber
				, strCurrency							= NULL
				, intAccountStatusId					= intAccountStatusId
				, intSalespersonId						= C.intEntitySalespersonId
				, strPricing							= C.strPricing
				, ysnActive								= C.ysnActive
				, ysnPORequired							= C.ysnPORequired
				, ysnStatementDetail					= C.ysnStatementDetail
				, strStatementFormat					= C.strStatementFormat
				, intCreditStopDays						= C.intCreditStopDays
				, strTaxAuthority1						= C.strTaxAuthority1
				, strTaxAuthority2						= C.strTaxAuthority2
				, ysnPrintPriceOnPrintTicket			= C.ysnPrintPriceOnPrintTicket
				, intServiceChargeId					= C.intServiceChargeId
				, ysnApplySalesTax						= C.ysnApplySalesTax
				, ysnApplyPrepaidTax					= C.ysnApplyPrepaidTax
				, dblBudgetAmountForBudgetBilling		= C.dblBudgetAmountForBudgetBilling
				, strBudgetBillingBeginMonth			= C.strBudgetBillingBeginMonth
				, strBudgetBillingEndMonth				= C.strBudgetBillingEndMonth
				, dblMonthlyBudget						= C.dblMonthlyBudget
				, intNoOfPeriods						= C.intNoOfPeriods
				, dtmBudgetBeginDate					= C.dtmBudgetBeginDate
				, intTermsId							= C.intTermsId
				, intCurrencyId							= @intCurrencyId
				, strLevel								= C.strLevel
				, intCompanyLocationPricingLevelId		= C.intCompanyLocationPricingLevelId
			FROM #CUSTOMERS C
			INNER JOIN tblEMEntity E ON C.strCustomerNumber = E.strEntityNo
			LEFT JOIN tblEMEntityType ET ON E.intEntityId  = ET.intEntityId AND ET.strType = ''Customer''
            WHERE ET.intEntityTypeId IS NULL

			--UPDATE TEMP TABLE ENTITY ID
			UPDATE CC
			SET intEntityId = C.intEntityId
			FROM #CUSTOMERS CC
			INNER JOIN tblARCustomer C ON CC.strCustomerNumber = C.strCustomerNumber

			--CUSTOMER ENTITY TYPE
			INSERT INTO tblEMEntityType (
				  intEntityId
				, strType
				, intConcurrencyId
			) 
			SELECT intEntityId		= CC.intEntityId
				, strType			= ''Customer''
				, intConcurrencyId	= 0
			FROM #CUSTOMERS CC
			LEFT JOIN tblEMEntityType ET ON CC.intEntityId = ET.intEntityId AND ET.strType = ''Customer''
			WHERE ET.intEntityTypeId IS NULL

			--CONTACT
			INSERT INTO tblEMEntity WITH (TABLOCK) (
				  strName
				, strEmail
				, strWebsite
				, strInternalNotes
				, strContactNumber
				, strTitle
				, strDepartment
				, strMobile
				, strPhone
				, strPhone2
				, strEmail2
				, strFax
				, strNotes
			)
			SELECT strName			= C.strContactName
				, strEmail			= NULL
				, strWebsite		= NULL
				, strInternalNotes	= C.strInternalNotes
				, strContactNumber	= UPPER(CASE WHEN C.strContactName IS NOT NULL THEN SUBSTRING(C.strContactName, 1, 20) ELSE SUBSTRING(C.strName, 1, 20) END)
				, strTitle			= NULL
				, strDepartment		= NULL
				, strMobile			= NULL
				, strPhone			= C.strPhone
				, strPhone2			= C.strPhone2
				, strEmail2			= NULL
				, strFax			= NULL
				, strNotes			= NULL
			FROM #CUSTOMERS C
			WHERE (C.strContactName IS NOT NULL AND C.strContactName <> '''')

			UNION ALL

			SELECT strName			= ISNULL(RTRIM(LTRIM(sscon_last_name)), '''') + '', '' + ISNULL(RTRIM(LTRIM(sscon_first_name)), '''')
				, strEmail			= RTRIM(LTRIM(isnull(sscon_email, '''')))
				, strWebsite		= NULL
				, strInternalNotes	= C.strInternalNotes
				, strContactNumber	= UPPER(CASE WHEN ISNULL(sscon_contact_id, '''') IS NOT NULL THEN SUBSTRING(ISNULL(sscon_contact_id, ''''), 1, 20) ELSE SUBSTRING(RTRIM(LTRIM(sscon_last_name)) + '', '' + RTRIM(LTRIM(sscon_first_name)), 1, 20) END)
				, strTitle			= ISNULL(sscon_contact_title, '''')
				, strDepartment		= NULL
				, strMobile			= NULL
				, strPhone			= (CASE	WHEN sscon_work_ext IS NULL OR sscon_work_ext = '''' THEN RTRIM(LTRIM(sscon_work_no))
											WHEN sscon_work_no IS NULL OR sscon_work_no = '''' AND sscon_work_ext IS NOT NULL AND sscon_work_ext <> '''' THEN ''x'' + RTRIM(LTRIM(sscon_work_ext))
											ELSE RTRIM(LTRIM(sscon_work_no)) + '' x'' + RTRIM(LTRIM(sscon_work_ext))
									  END)
				, strPhone2			= C.strPhone2
				, strEmail2			= NULL
				, strFax			= NULL
				, strNotes			= NULL
			FROM #CUSTOMERS C
			INNER JOIN ssconmst O ON O.sscon_cus_no COLLATE Latin1_General_CI_AS = C.strCustomerNumber
			WHERE C.strContactName IS NULL OR C.strContactName = ''''

			--ACCOUNT STATUS
			INSERT INTO tblARCustomerAccountStatus (
				  intEntityCustomerId
				, intAccountStatusId
				, intConcurrencyId
			)
			SELECT intEntityCustomerId	= C.intEntityId
				, intAccountStatusId	= s.intAccountStatusId
				, intConcurrencyId		= 1
			FROM (
				SELECT ptcus_cus_no, x, y	
				FROM ptcusmst
	
				UNPIVOT
				(x FOR y IN (ptcus_acct_stat_x_1, ptcus_acct_stat_x_2, ptcus_acct_stat_x_3, ptcus_acct_stat_x_4
				, ptcus_acct_stat_x_5, ptcus_acct_stat_x_6, ptcus_acct_stat_x_7, ptcus_acct_stat_x_8, ptcus_acct_stat_x_9
				, ptcus_acct_stat_x_10)
				) unpiv
			) AS P
			INNER JOIN tblARCustomer C ON P.ptcus_cus_no COLLATE Latin1_General_CI_AS = C.strCustomerNumber
			INNER JOIN tblARAccountStatus s ON P.x COLLATE Latin1_General_CI_AS = s.strAccountStatusCode
			INNER JOIN #CUSTOMERS CC ON C.intEntityId = CC.intEntityId

			--ENTITY PHONE NUMBER
			INSERT INTO tblEMEntityPhoneNumber(
				  intEntityId
				, strPhone
			) 
			SELECT E.intEntityId
				 , E.strPhone
			FROM tblEMEntity E
			LEFT JOIN tblEMEntityPhoneNumber EPN ON E.intEntityId = EPN.intEntityId AND E.strPhone = EPN.strPhone
			WHERE E.strContactNumber IS NOT NULL
			  AND E.strPhone IS NOT NULL
			  AND EPN.intEntityPhoneNumberId IS NULL

			--UPDATE CUSTOMER''S DEFAULT LOCATION USING EXISTING LOCATION
			UPDATE CC
			SET intEntityLocationId = LOC.intEntityLocationId
			FROM #CUSTOMERS CC
			CROSS APPLY (
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = CC.intEntityId
				  AND EL.ysnDefaultLocation = 1
			) LOC

			--CUSTOMERS NEW MAIN LOCATION
			INSERT tblEMEntityLocation	(
				  intEntityId
				, strCheckPayeeName
				, strLocationName
				, strAddress
				, strCity
				, strCountry
				, strState
				, strZipCode
				, strNotes
				, intShipViaId
				, intTermsId
				, intWarehouseId
				, ysnDefaultLocation
				, strOriginLinkCustomer
			)
			SELECT intEntityId				= CC.intEntityId
				, strCheckPayeeName			= CC.strName
				, strLocationName			= CC.strLocationName
				, strAddress				= CC.strAddress
				, strCity					= CC.strCity
				, strCountry				= CC.strCountry
				, strState					= CC.strState
				, strZipCode				= CC.strZipCode
				, strNotes					= NULL
				, intShipViaId				= NULL
				, intTermsId				= CC.intTermsId
				, intWarehouseId			= CC.intWarehouseId
				, ysnDefaultLocation		= 1
				, strOriginLinkCustomer		= CC.strCustomerNumber
			FROM #CUSTOMERS CC
			WHERE CC.intEntityLocationId IS NULL

			--UPDATE CUSTOMER''S DEFAULT LOCATION USING NEWLY ADDED LOCATION
			UPDATE CC
			SET intEntityLocationId = LOC.intEntityLocationId
			FROM #CUSTOMERS CC
			CROSS APPLY (
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = CC.intEntityId
				  AND EL.ysnDefaultLocation = 1
			) LOC
			WHERE CC.intEntityLocationId IS NULL

			--ENTITY LOCATION BILL TO
			INSERT tblEMEntityLocation (   
				  intEntityId
				, strCheckPayeeName
				, strLocationName
				, strAddress
				, strCity
				, strCountry
				, strState
				, strZipCode
				, strNotes
				, intShipViaId
				, intTermsId
				, intWarehouseId
				, ysnDefaultLocation
				, strOriginLinkCustomer
			)
			SELECT intEntityId			= C.intEntityId
				, strCheckPayeeName		= CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name))  END
				, strLocationName		= (RTRIM (CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name 
													   WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name))
												   END)) + '' '' + cast(cast(newid() as nvarchar(40)) as nvarchar(2))+ ''_'' + CAST(A4GLIdentity AS NVARCHAR)
				, strAddress			= ISNULL(ptcus_addr, '''') + CHAR(10) + ISNULL(ptcus_addr2, '''')
				, strCity				= LTRIM(RTRIM(ptcus_city))
				, strCountry			= LTRIM(RTRIM(ptcus_country))
				, strState				= LTRIM(RTRIM(ptcus_state))
				, strZipCode			= LTRIM(RTRIM(ptcus_zip))
				, strNotes				= NULL
				, intShipViaId			= NULL
				, intTermsId			= NULL
				, intWarehouseId		= NULL
				, ysnDefaultLocation	= 0
				, strOriginLinkCustomer	= LTRIM(RTRIM(ptcus_cus_no))								
			FROM ptcusmst O
			INNER JOIN #CUSTOMERS C ON O.ptcus_bill_to COLLATE Latin1_General_CI_AS = C.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE ptcus_cus_no <> ptcus_bill_to 

			--INSERT BILL TO ADDRESS LOCATIONS (ptadrmst)
			INSERT tblEMEntityLocation ( 
				  intEntityId
				, strCheckPayeeName
				, strLocationName
				, strAddress
				, strCity
				, strCountry
				, strState
				, strZipCode
				, strNotes
				, intShipViaId
				, intTermsId
				, intWarehouseId
				, ysnDefaultLocation
			)
			SELECT intEntityId			= CUS.intEntityId
				, strCheckPayeeName		= CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name)) END
				, strLocationName		= ISNULL(LTRIM(RTRIM( ptcus_cus_no)), '''')+ '' BILL TO''
				, strAddress			= ISNULL(LTRIM(RTRIM(ptadr_addr)), '''') + CHAR(10) + ISNULL(LTRIM(RTRIM(ptadr_addr2)), '''')
				, strCity				= LTRIM(RTRIM(ptadr_city))
				, strCountry			= LTRIM(RTRIM(ptcus_country))
				, strState				= LTRIM(RTRIM(ptadr_state))
				, strZipCode			= LTRIM(RTRIM(ptadr_zip))
				, strNotes				= NULL
				, intShipViaId			= NULL
				, intTermsId			= (SELECT intTermID FROM tblSMTerm WHERE strTermCode = CAST(ptcus_terms_code  AS CHAR(10)))
				, intWarehouseId		= (SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = ptcus_bus_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS)
				, ysnDefaultLocation	= 0
			FROM ptadrmst ADR 
			INNER JOIN ptcusmst ON ptcus_cus_no = ptadr_key
			INNER JOIN #CUSTOMERS CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = ADR.ptadr_key COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntity EM ON EM.intEntityId = CUS.intEntityId
			LEFT JOIN tblEMEntityLocation LOC ON LOC.intEntityId = EM.intEntityId AND LOC.strLocationName = ISNULL(LTRIM(RTRIM(EM.strEntityNo)), '''')+ '' BILL TO''
			WHERE LOC.intEntityLocationId IS NULL

			--CREATE ORIGIN CUSTOMER FROM ENTITY LOCATION
			DECLARE @EntityLocationIdTable TABLE(id INT)
			DECLARE @intCurrentLocationId INT

			INSERT INTO @EntityLocationIdTable(id)
			SELECT EL.intEntityLocationId 
			FROM tblEMEntityLocation EL
			INNER JOIN #CUSTOMERS CC ON EL.intEntityId = CC.intEntityId
			WHERE strOriginLinkCustomer IS NULL OR strOriginLinkCustomer = ''''

			WHILE EXISTS (SELECT TOP 1 1 FROM @EntityLocationIdTable)
			BEGIN
				SELECT TOP 1 @intCurrentLocationId = id FROM @EntityLocationIdTable

				EXEC uspEMCreateOriginCustomer @EntityLocationId = @intCurrentLocationId

				DELETE FROM @EntityLocationIdTable WHERE id = @intCurrentLocationId	
			END

			--ENTITY TO CONTACT
			INSERT INTO tblEMEntityToContact (
				  intEntityId
				, intEntityContactId
				, intEntityLocationId
				, ysnDefaultContact
				, ysnPortalAccess
				, strUserType
			)
			SELECT intEntityId			= E.intEntityId
				, intEntityContactId	= CONTACT.intEntityId
				, intEntityLocationId	= LOC.intEntityLocationId
				, ysnDefaultContact		= C.ysnDefault
				, ysnPortalAccess		= 0
				, strUserType			= ''User''
			FROM #CUSTOMERS C
			INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
			CROSS APPLY (
				SELECT TOP 1 intEntityId
				FROM tblEMEntity CONTACT 
				WHERE C.strContactName = CONTACT.strName 
				  AND C.strPhone = CONTACT.strPhone 
				  AND C.strPhone2 = CONTACT.strPhone2
			) CONTACT
			LEFT JOIN tblEMEntityToContact ETC ON E.intEntityId = ETC.intEntityId AND CONTACT.intEntityId = ETC.intEntityContactId
			CROSS APPLY (
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = E.intEntityId
			) LOC
			WHERE ETC.intEntityToContactId IS NULL

			UPDATE ETC
			SET ysnDefaultContact = 0
			FROM tblEMEntityToContact ETC
			INNER JOIN (
				SELECT intEntityId
				FROM tblEMEntityToContact
				WHERE ysnDefaultContact = 1
				GROUP BY intEntityId
				HAVING COUNT(1) > 1
			) DUP ON ETC.intEntityId = DUP.intEntityId

			UPDATE ETC
			SET ysnDefaultContact = 1
			FROM tblEMEntityToContact ETC
			INNER JOIN (
				SELECT intEntityId
				FROM tblEMEntityToContact
				WHERE ysnDefaultContact = 1
				GROUP BY intEntityId
				HAVING COUNT(1) > 1
			) DUP ON ETC.intEntityId = DUP.intEntityId
			CROSS APPLY (
				SELECT TOP 1 intEntityToContactId
				FROM tblEMEntityToContact
				WHERE intEntityId = ETC.intEntityId	
			) DEF
			WHERE ETC.intEntityToContactId = DEF.intEntityToContactId

			--DEFAULT CONTACT FOR ENTITY
			UPDATE C
			SET intDefaultContactId = CONTACT.intEntityToContactId
			FROM tblARCustomer C
			CROSS APPLY (
				SELECT ETC.intEntityToContactId
				FROM tblEMEntityToContact ETC
				WHERE ETC.intEntityId = C.intEntityId
				  AND ETC.ysnDefaultContact = 1
			) CONTACT

			--DEFAULT LOCATION, SHIP TO FOR ENTITY
			UPDATE C
			SET intDefaultLocationId	= LOC.intEntityLocationId
			  , intShipToId				= LOC.intEntityLocationId
			  , intBillToId				= LOC.intEntityLocationId
			FROM tblARCustomer C
			CROSS APPLY (
				SELECT EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = C.intEntityId
				  AND EL.ysnDefaultLocation = 1
			) LOC

			--DEFAULT BILL TO FOR ENTITY
			UPDATE C
			SET intBillToId				= BILLTO.intEntityLocationId
			FROM tblARCustomer C
			INNER JOIN tblEMEntity EM ON C.intEntityId = EM.intEntityId
			CROSS APPLY (
				SELECT EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = C.intEntityId 
				  AND EL.strLocationName = ISNULL(LTRIM(RTRIM(EM.strEntityNo)), '''')+ '' BILL TO''
			) BILLTO

			--BUDGET
			IF OBJECT_ID(''tempdb..#CUSTOMERBUDGET'') IS NOT NULL DROP TABLE #CUSTOMERBUDGET
			CREATE TABLE #CUSTOMERBUDGET (intId INT PRIMARY KEY, intEntityCustomerId INT, dtmBudgetBeginDate	DATETIME)

			;WITH BUDGETDATE AS (
				SELECT dtmBudgetBeginDate	= C.dtmBudgetBeginDate
					 , intEntityCustomerId	= C.intEntityId
				FROM #CUSTOMERS CC
				INNER JOIN tblARCustomer C ON CC.intEntityId = C.intEntityId
				WHERE C.intNoOfPeriods > 0

				UNION ALL

				SELECT dtmBudgetBeginDate	= DATEADD(MONTH, 1, BD.dtmBudgetBeginDate)
					 , intEntityCustomerId	= C.intEntityId
				FROM BUDGETDATE BD
				INNER JOIN tblARCustomer C ON BD.intEntityCustomerId = C.intEntityId
				WHERE DATEADD(MONTH, 1, BD.dtmBudgetBeginDate) <= DATEADD(MONTH, C.intNoOfPeriods - 1, C.dtmBudgetBeginDate)
			)
			INSERT INTO #CUSTOMERBUDGET
			SELECT intId				= ROW_NUMBER() OVER (ORDER BY dtmBudgetBeginDate ASC)
				 , intEntityCustomerId	= intEntityCustomerId
				 , dtmBudgetBeginDate	= dtmBudgetBeginDate
			FROM BUDGETDATE
			OPTION (MAXRECURSION 0)

			INSERT INTO tblARCustomerBudget WITH (TABLOCK) (
				  intEntityCustomerId
				, dblBudgetAmount		
				, dtmBudgetDate
				, intConcurrencyId
			)
			SELECT intEntityCustomerId		= CC.intEntityCustomerId
				, dblBudgetAmount			= C.dblMonthlyBudget
				, dtmBudgetDate				= CC.dtmBudgetBeginDate
				, intConcurrencyId			= 0
			FROM tblARCustomer C
			INNER JOIN #CUSTOMERBUDGET CC ON C.intEntityId = CC.intEntityCustomerId		

			--IMPORT CUSTOMER COMMENTS
			-----------------------------------
			EXEC uspARImportCustomerComments	
			-----------------------------------

		END

		--================================================
		--     GET TO BE IMPORTED RECORDS
		--================================================
		IF(@Update = 1 AND @CustomerId IS NULL)
		BEGIN
			SELECT @Total = COUNT(ptcus_cus_no)
			FROM ptcusmst
			LEFT JOIN tblARCustomer
			ON ptcusmst.ptcus_cus_no COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE tblARCustomer.strCustomerNumber IS NULL 
			  AND ptcus_co_per_ind_cp IS NOT NULL
			  AND ptcus_cus_no = ptcus_bill_to
		END
	END
	'

)

END