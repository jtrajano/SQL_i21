GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportCustomer')
	DROP PROCEDURE uspARImportCustomer
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

EXEC('CREATE PROCEDURE [dbo].[uspARImportCustomer]
	@CustomerId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS 

	--Make first a copy of agcusmst. This will use to track all customer already imported
	IF(OBJECT_ID(''dbo.tblARTempCustomer'') IS NULL)
		SELECT * INTO tblARTempCustomer FROM agcusmst

	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @CustomerId IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM agcusmst WHERE agcus_key = @CustomerId))
		BEGIN
			UPDATE agcusmst
			SET 
			--Entity
			agcus_last_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),''''),
			agcus_first_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),''''),
			agcus_comments = SUBSTRING(Ent.strInternalNotes,1,30),
			agcus_1099_name = SUBSTRING(Ent.str1099Name,1,50),
			--Location
			agcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END,
			agcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END,
			agcus_city = SUBSTRING(Loc.strCity,1,20),
			agcus_state = SUBSTRING(Loc.strState,1,2),
			agcus_zip = SUBSTRING(Loc.strZipCode,1,10),
			agcus_country = (CASE WHEN LEN(Loc.strCountry) = 3 THEN Loc.strCountry ELSE '''' END),
			--Contact
			agcus_contact = SUBSTRING((SELECT strName FROM tblEntity WHERE intEntityId = Con.intEntityId),1,20),
			agcus_phone = SUBSTRING(Con.strPhone,1,15),
			agcus_phone2 = SUBSTRING(Con.strPhone2,1,15),
			--Customer
			agcus_key = SUBSTRING(Cus.strCustomerNumber,1,10),
			agcus_co_per_ind_cp = CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END,
			agcus_cred_limit = Cus.dblCreditLimit,
			agcus_tax_exempt = SUBSTRING(Cus.strTaxNumber,1,15),
			agcus_dflt_currency = SUBSTRING(Cus.strCurrency,1,3),
			agcus_active_yn = CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END,
			agcus_req_po_yn = CASE WHEN Cus.ysnPORequired = 1 THEN ''Y'' ELSE ''N'' END,
			agcus_stmt_dtl_yn = CASE WHEN Cus.ysnStatementDetail = 1 THEN ''Y'' ELSE ''N'' END,
			agcus_stmt_fmt = CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O'' WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' WHEN Cus.strStatementFormat = ''None'' THEN ''N'' WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END,
			agcus_cred_stop_days = Cus.intCreditStopDays,
			agcus_tax_auth_id1 = SUBSTRING(Cus.strTaxAuthority1,1,3),
			agcus_tax_auth_id2 = SUBSTRING(Cus.strTaxAuthority2,1,3),
			agcus_pic_prc_yn = CASE WHEN Cus.ysnPrintPriceOnPrintTicket = 1 THEN ''Y'' ELSE ''N'' END,
			agcus_tax_ynp = CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''Y'' ELSE ''N'' END,
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
			agcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId),
			agcus_slsmn_id		= (SELECT strSalespersonId FROM tblARSalesperson WHERE intSalespersonId = Cus.intSalespersonId),
			agcus_srvchr_cd		= (SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId),
			agcus_dflt_mkt_zone = (SELECT strMarketZoneCode FROM tblARMarketZone WHERE intMarketZoneId = Cus.intMarketZoneId)	
		FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblARCustomerToContact CustToCon ON Cus.intDefaultContactId = CustToCon.intARCustomerToContactId
			INNER JOIN tblEntityContact Con ON CustToCon.intContactId = Con.intContactId
			INNER JOIN tblEntityLocation Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
			WHERE strCustomerNumber = @CustomerId AND agcus_key = @CustomerId
		END
		--INSERT IF NOT EXIST IN THE ORIGIN	
		ELSE
			INSERT INTO agcusmst(
			--Entity
			agcus_last_name,
			agcus_first_name,
			agcus_comments,
			agcus_1099_name,
			--Contact,
			agcus_contact,
			agcus_phone,
			agcus_phone2,
			--Location
			agcus_addr,
			agcus_addr2,
			agcus_city,
			agcus_state,
			agcus_zip,
			agcus_country,
			--Customer
			agcus_key,
			agcus_co_per_ind_cp,
			agcus_cred_limit,
			agcus_tax_exempt,
			agcus_dflt_currency,
			agcus_active_yn,
			agcus_req_po_yn,
			agcus_stmt_dtl_yn,
			agcus_stmt_fmt,
			agcus_cred_stop_days,
			agcus_tax_auth_id1,
			agcus_tax_auth_id2,
			agcus_pic_prc_yn,
			agcus_tax_ynp,
			agcus_budget_amt,
			agcus_budget_beg_mm,
			agcus_budget_end_mm,
			agcus_dpa_cnt,
			agcus_dpa_rev_dt,
			agcus_gb_rcpt_no,
			agcus_ckoff_exempt_yn,
			agcus_ckoff_vol_yn,
			agcus_ga_origin_st,
			agcus_mkt_sign_yn,
			agcus_ga_hold_pay_yn ,
			agcus_ga_wthhld_yn,
			agcus_acct_stat_x_1,
			agcus_slsmn_id,		
			agcus_srvchr_cd,		
			agcus_dflt_mkt_zone	
		
		)
	
		SELECT 
			--Entity
			ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),'''') AS strLastName,
			ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),'''') AS strFirsName,
			SUBSTRING(Ent.strInternalNotes,1,30) as strInternalNotes ,
			SUBSTRING(Ent.str1099Name,1,50) as str1099Name,
			--Contact
			SUBSTRING((SELECT strName FROM tblEntity WHERE intEntityId = Con.intEntityId),1,20) AS strContactName,
			SUBSTRING(Con.strPhone,1,15) as strPhone,
			SUBSTRING(Con.strPhone2,1,15) as strPhone2,
			--Location
			(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END) AS strAddress1,
			(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END) AS strAddress2,
			SUBSTRING(Loc.strCity,1,20) as strCity,
			SUBSTRING(Loc.strState,1,2) as strState,
			SUBSTRING(Loc.strZipCode,1,10) as strZipCode,
			(CASE WHEN LEN(Loc.strCountry) = 3 THEN Loc.strCountry ELSE '''' END)as strCountry,
			--Customer
			SUBSTRING(Cus.strCustomerNumber,1,10) as strCustomerNumber,
			(CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END) AS strType,
			Cus.dblCreditLimit,
			SUBSTRING(Cus.strTaxNumber,1,15) as strTaxNumber,
			SUBSTRING(Cus.strCurrency,1,3) as strCurrency,
			(CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END) AS ysnActive,
			(CASE WHEN Cus.ysnPORequired = 1 THEN ''Y'' ELSE ''N'' END) AS ysnPORequired,
			(CASE WHEN Cus.ysnStatementDetail = 1 THEN ''Y'' ELSE ''N'' END) AS ysnStatementDetail,
			(CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O'' WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' WHEN Cus.strStatementFormat = ''None'' THEN ''N'' WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END) as strStatementFormat ,
			Cus.intCreditStopDays,
			SUBSTRING(Cus.strTaxAuthority1,1,3) as strTaxAuthority1,
			SUBSTRING(Cus.strTaxAuthority2,1,3) as strTaxAuthority2,
			(CASE WHEN Cus.ysnPrintPriceOnPrintTicket = 1 THEN ''Y'' ELSE ''N'' END) AS ysnPrintPriceOnPrintTicket,
			(CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''Y'' ELSE ''N'' END) AS ysnApplyPrepaidTax,
			Cus.dblBudgetAmountForBudgetBilling,
			SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2) as strBudgetBillingBeginMonth,
			SUBSTRING(Cus.strBudgetBillingEndMonth,1,2) as strBudgetBillingEndMonth,
			SUBSTRING(Cus.strDPAContract,1,6) as strDPAContract,				
			CONVERT(int,''20'' + CONVERT(nvarchar,Cus.dtmDPADate,12)),					
			SUBSTRING(Cus.strGBReceiptNumber,1,6) as strGBReceiptNumber,			
			(CASE WHEN Cus.ysnCheckoffExempt = 1 THEN ''Y'' ELSE ''N'' END) as ysnCheckoffExempt,			
			(CASE WHEN Cus.ysnVoluntaryCheckoff = 1 THEN ''Y'' ELSE ''N'' END) as ysnVoluntaryCheckoff,		
			SUBSTRING(Cus.strCheckoffState,1,2) as strCheckoffState,			
			(CASE WHEN Cus.ysnMarketAgreementSigned = 1 THEN ''Y'' ELSE ''N'' END) as ysnMarketAgreementSigned,			
			(CASE WHEN Cus.ysnHoldBatchGrainPayment = 1 THEN ''Y'' ELSE ''N'' END) as ysnHoldBatchGrainPayment,	
			(CASE WHEN Cus.ysnFederalWithholding = 1 THEN ''Y'' ELSE ''N'' END) as ysnFederalWithholding,
			(SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId),
			(SELECT strSalespersonId FROM tblARSalesperson WHERE intSalespersonId = Cus.intSalespersonId),
			(SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId),
			(SELECT strMarketZoneCode FROM tblARMarketZone WHERE intMarketZoneId = Cus.intMarketZoneId)
			FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblARCustomerToContact CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
			INNER JOIN tblEntityContact Con ON CusToCon.intContactId = Con.intContactId
			INNER JOIN tblEntityLocation Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
			WHERE strCustomerNumber = @CustomerId

			-- INSERT Contact to ssonmst
			DECLARE @ContactNumber nvarchar(20)
			
			select top 1 @ContactNumber = substring(isnull((SELECT top 1 strName FROM tblEntity WHERE intEntityId = Con.intEntityId), ''''), 1,20)
			FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblARCustomerToContact CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
			INNER JOIN tblEntityContact Con ON CusToCon.intContactId = Con.intContactId
			INNER JOIN tblEntityLocation Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
			WHERE strCustomerNumber = @CustomerId

			EXEC uspARContactOriginSync @ContactNumber
		

	RETURN;
	END

	--================================================
	--     ONE TIME CUSTOMER SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @CustomerId IS NULL) 
	BEGIN
	
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
		DECLARE @intCustomerId				INT
		DECLARE @strCustomerNumber			NVARCHAR(15)    
		DECLARE @strType					NVARCHAR(MAX)
		DECLARE @dblCreditLimit				NUMERIC(18,6)
		DECLARE @strTaxNumber				NVARCHAR(MAX)
		DECLARE @strCurrency				NVARCHAR(3)
		DECLARE @intAccountStatusId			INT
		DECLARE @intSalespersonId			INT
		DECLARE	@strPricing					NVARCHAR(MAX)
		DECLARE @ysnActive					BIT
		DECLARE @ysnPORequired				BIT
		DECLARE @ysnStatementDetail			BIT
		DECLARE @strStatementFormat			NVARCHAR(50)
		DECLARE @intCreditStopDays			INT
		DECLARE @strTaxAuthority1			NVARCHAR(MAX)
		DECLARE @strTaxAuthority2			NVARCHAR(MAX)
		DECLARE @ysnPrintPriceOnPrintTicket	BIT
		DECLARE @intServiceChargeId			INT
		DECLARE @ysnApplySalesTax			BIT
		DECLARE @dblBudgetAmountForBudgetBilling NUMERIC(18,6)
		DECLARE @strBudgetBillingBeginMonth	NVARCHAR(50)
		DECLARE @strBudgetBillingEndMonth	NVARCHAR(50)
		
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
    
		--Import only those are not yet imported
		SELECT agcus_key INTO #tmpagcusmst 
			FROM agcusmst
		LEFT JOIN tblARCustomer
			ON agcusmst.agcus_key COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
		WHERE tblARCustomer.strCustomerNumber IS NULL
		ORDER BY agcusmst.agcus_key

		WHILE (EXISTS(SELECT 1 FROM #tmpagcusmst))
		BEGIN
		
			SELECT @originCustomer = agcus_key FROM #tmpagcusmst

			SELECT TOP 1
				--Entity
				@strName = CASE WHEN agcus_co_per_ind_cp = ''C'' THEN agcus_last_name + agcus_first_name WHEN agcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(agcus_last_name)) + '', '' + RTRIM(LTRIM(agcus_first_name))END,
				@strEmail   = '''',
				@strWebsite = '''',
				@strInternalNotes = agcus_comments,
				@ysnPrint1099   = 0,--To Map
				@str1099Name    = agcus_1099_name,
				@str1099Form	= '''',
				@str1099Type	= '''',
				@strFederalTaxId	= NULL, --To Map
				@dtmW9Signed	= NULL, --To Map,
				@imgPhoto = NULL,

				--Contacts
				@strTitle = '''',
				@strContactName = agcus_contact,
				@strDepartment = NULL,
				@strMobile     = NULL,
				@strPhone      = agcus_phone,
				@strPhone2     = agcus_phone2,
				@strEmail2     = NULL,
				@strFax        = NULL,
				@strNotes      = NULL,
				@strContactMethod = NULL,
				@strTimezone = NULL,
				
				@strUserType = NULL,
				@ysnPortalAccess = NULL,
				

				--Locations
				@strLocationName = @strName,
				@strAddress      = ISNULL(agcus_addr,'''') + CHAR(10) + ISNULL(agcus_addr2,''''),
				@strCity         = agcus_city,
				@strCountry      = agcus_country,
				@strState        = agcus_state,
				@strZipCode      = agcus_zip,
				@strLocationNotes        = NULL,
				@intShipViaId = NULL,
				@intTaxCodeId    = NULL,
				@intTermsId      = NULL,
				@intWarehouseId  = NULL,
			
				--Customer
				@strCustomerNumber		= agcus_key,			
				@strType				= CASE WHEN agcus_co_per_ind_cp = ''C'' THEN ''Company'' ELSE ''Person'' END,					
				@dblCreditLimit			= agcus_cred_limit,					
				@strTaxNumber			= agcus_tax_exempt,
				@strCurrency			= agcus_dflt_currency, 				
				@intAccountStatusId		= (SELECT intAccountStatusId FROM tblARAccountStatus WHERE strAccountStatusCode COLLATE Latin1_General_CI_AS = agcus_acct_stat_x_1 COLLATE Latin1_General_CI_AS),			
				@intSalespersonId		= (SELECT intSalespersonId FROM tblARSalesperson WHERE strSalespersonId COLLATE Latin1_General_CI_AS = agcus_slsmn_id COLLATE Latin1_General_CI_AS),			
    			@strPricing				= NULL, --agcus_prc_lvl					
				@ysnActive				= CASE WHEN agcus_active_yn = ''Y'' THEN 1 ELSE 0 END,					
				@ysnPORequired			= CASE WHEN agcus_req_po_yn = ''Y'' THEN 1 ELSE 0 END,									
				@ysnStatementDetail		= CASE WHEN agcus_stmt_dtl_yn = ''Y'' THEN 1 ELSE 0 END,			
				@strStatementFormat		= CASE WHEN agcus_stmt_fmt = ''O'' THEN ''Open Item'' WHEN agcus_stmt_fmt = ''B'' THEN ''Balance Forward'' WHEN agcus_stmt_fmt = ''R'' THEN ''Budget Reminder'' WHEN agcus_stmt_fmt = ''N'' THEN ''None'' WHEN agcus_stmt_fmt IS NULL THEN Null Else '''' END ,			
				@intCreditStopDays		= agcus_cred_stop_days,			
				@strTaxAuthority1		= agcus_tax_auth_id1,			
				@strTaxAuthority2		= agcus_tax_auth_id2,			
				@ysnPrintPriceOnPrintTicket = CASE WHEN agcus_pic_prc_yn = ''Y'' THEN 1 ELSE 0 END,	
				@intServiceChargeId		= (SELECT intServiceChargeId FROM tblARServiceCharge WHERE strServiceChargeCode = agcus_srvchr_cd),			
				@ysnApplySalesTax		= CASE WHEN agcus_tax_ynp = ''Y'' THEN 1 ELSE 0 END,			
				@dblBudgetAmountForBudgetBilling = agcus_budget_amt,
				@strBudgetBillingBeginMonth	= agcus_budget_beg_mm,	
				@strBudgetBillingEndMonth	= agcus_budget_end_mm,
				--Grain Tab
				@strDPAContract = agcus_dpa_cnt,				
				@dtmDPADate = (CASE WHEN agcus_dpa_rev_dt = 0 THEN NULL ELSE CONVERT(datetime,SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),0,5) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),5,2) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),7,2)) END),					
				@strGBReceiptNumber = agcus_gb_rcpt_no,			
				@ysnCheckoffExempt = CASE WHEN agcus_ckoff_exempt_yn = ''Y'' THEN 1 ELSE 0 END,			
				@ysnVoluntaryCheckoff = CASE WHEN agcus_ckoff_vol_yn = ''Y'' THEN 1 ELSE 0 END ,		
				@strCheckoffState = agcus_ga_origin_st,			
				@ysnMarketAgreementSigned = CASE WHEN agcus_mkt_sign_yn = ''Y'' THEN 1 ELSE 0 END ,	
				@intMarketZoneId = (SELECT intMarketZoneId FROM tblARMarketZone WHERE strMarketZoneCode COLLATE Latin1_General_CI_AS = agcus_dflt_mkt_zone COLLATE Latin1_General_CI_AS),			
				@ysnHoldBatchGrainPayment = CASE WHEN agcus_ga_hold_pay_yn = ''Y'' THEN 1 ELSE 0 END ,	
				@ysnFederalWithholding = CASE WHEN agcus_ga_wthhld_yn = ''Y'' THEN 1 ELSE 0 END	
			
			FROM agcusmst
			WHERE agcus_key = @originCustomer
			
			--INSERT Entity record for Customer
			INSERT [dbo].[tblEntity]	([strName],[strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed],[imgPhoto])
			VALUES						(@strName, @strEmail, @strWebsite, @strInternalNotes, @ysnPrint1099, @str1099Name, @str1099Form, @str1099Type, @strFederalTaxId, @dtmW9Signed, @imgPhoto)

			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()
			
			--INSERT into Customer
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
			[dblBudgetAmountForBudgetBilling],
			[strBudgetBillingBeginMonth],
			[strBudgetBillingEndMonth],
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
			[ysnFederalWithholding])
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
			 @intSalespersonId,		
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
			 @dblBudgetAmountForBudgetBilling,
			 @strBudgetBillingBeginMonth,
			 @strBudgetBillingEndMonth,
			 @strDPAContract,				
			 @dtmDPADate,					
			 @strGBReceiptNumber,			
			 @ysnCheckoffExempt,			
			 @ysnVoluntaryCheckoff,		
			 @strCheckoffState,			
			 @ysnMarketAgreementSigned,	
			 @intMarketZoneId,			
			 @ysnHoldBatchGrainPayment,	
			 @ysnFederalWithholding)
			 
			 --Get intCustomerId
			 SELECT @intCustomerId = intCustomerId FROM tblARCustomer WHERE intEntityId = @EntityId
	

			--INSERT ENTITY record for Contact
			IF(@strContactName IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes])
				VALUES					 (@strContactName, @strEmail, @strWebsite, @strInternalNotes)
			END
			ELSE
				INSERT [dbo].[tblEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes])
				VALUES					 (@strName, @strEmail, @strWebsite, @strInternalNotes)
			
				

			DECLARE @ContactEntityId INT
		
			SET @ContactEntityId = SCOPE_IDENTITY()
	
			-- RULE: when creating a default contact from agcusmst.agcus_contact, trim tblEntityContact.strContactNumber to 20 characters
			INSERT [dbo].[tblEntityContact] ([intEntityId], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
			SELECT							 @ContactEntityId, 
											UPPER(CASE WHEN @strContactName IS NOT NULL THEN SUBSTRING(@strContactName, 1, 20) ELSE SUBSTRING(@strName, 1, 20) END)
											,@strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes
						
			--Get intContactId
			SELECT @intContactId = intContactId FROM tblEntityContact WHERE intEntityId = @ContactEntityId
		
		
			--INSERT into Location
			INSERT [dbo].[tblEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strNotes],  [intShipViaId], [intTaxCodeId], [intTermsId], [intWarehouseId])
			VALUES								(@EntityId, @strLocationName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strLocationNotes,  @intShipViaId, @intTaxCodeId, @intTermsId, @intWarehouseId)

			DECLARE @EntityLocationId INT
			SET @EntityLocationId = SCOPE_IDENTITY()
		
			 
			 --INSERT into tblARCustomerToContact
			DECLARE @CustomerToContactId INT
			
			INSERT [dbo].[tblARCustomerToContact] ([intCustomerId],[intContactId],[intEntityLocationId],[strUserType],[ysnPortalAccess])
			VALUES							  (@intCustomerId, @intContactId, @EntityLocationId, ''User'', 0)
		
			SET @CustomerToContactId = SCOPE_IDENTITY()
				
			UPDATE tblARCustomer 
			SET intDefaultContactId = @CustomerToContactId, 
				intDefaultLocationId = @EntityLocationId,
				intBillToId = @EntityLocationId,
				intShipToId = @EntityLocationId
			WHERE intEntityId = @EntityId 
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			PRINT @originCustomer
			DELETE FROM #tmpagcusmst WHERE agcus_key = @originCustomer
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempCustomer

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @CustomerId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(agcus_key) from tblARTempCustomer
	END
	')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
EXEC('CREATE PROCEDURE [dbo].[uspARImportCustomer]
	@CustomerId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of ptcusmst. This will use to track all customer already imported
	IF(OBJECT_ID(''dbo.tblARTempCustomer'') IS NULL)
		SELECT * INTO tblARTempCustomer FROM ptcusmst

	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @CustomerId IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM ptcusmst WHERE ptcus_cus_no = @CustomerId))
		BEGIN
			UPDATE ptcusmst
			SET 
			--Entity
			ptcus_last_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),''''),
			ptcus_first_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),''''),
			ptcus_comment = SUBSTRING(Ent.strInternalNotes,1,30),
			--ptcus_1099_name = SUBSTRING(Ent.str1099Name,1,50),
			--Location
			ptcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END,
			ptcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END,
			ptcus_city = SUBSTRING(Loc.strCity,1,20),
			ptcus_state = SUBSTRING(Loc.strState,1,2),
			ptcus_zip = SUBSTRING(Loc.strZipCode,1,10),
			ptcus_country = (CASE WHEN LEN(Loc.strCountry) = 10 THEN Loc.strCountry ELSE '''' END),
			--Contact
			ptcus_contact = SUBSTRING((SELECT strName FROM tblEntity WHERE intEntityId = Con.intEntityId),1,20),
			ptcus_phone = SUBSTRING(Con.strPhone,1,15),
			ptcus_phone2 = SUBSTRING(Con.strPhone2,1,15),
			--Customer
			ptcus_cus_no = SUBSTRING(Cus.strCustomerNumber,1,10),
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
			ptcus_sales_tax_yn = CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''Y'' ELSE ''N'' END,
			ptcus_budget_amt = Cus.dblBudgetAmountForBudgetBilling,
			ptcus_budget_beg_mm = SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2),
			ptcus_budget_end_mm = SUBSTRING(Cus.strBudgetBillingEndMonth,1,2),
			ptcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId),
			ptcus_slsmn_id		= (SELECT strSalespersonId FROM tblARSalesperson WHERE intSalespersonId = Cus.intSalespersonId),
			ptcus_srv_cd		= (SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId)
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
		FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblARCustomerToContact CustToCon ON Cus.intDefaultContactId = CustToCon.intARCustomerToContactId
			INNER JOIN tblEntityContact Con ON CustToCon.intContactId = Con.intContactId
			INNER JOIN tblEntityLocation Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
			WHERE strCustomerNumber = @CustomerId AND ptcus_cus_no = @CustomerId
		END
		--INSERT IF NOT EXIST IN THE ORIGIN	
		ELSE
			INSERT INTO ptcusmst(
			--Entity
			ptcus_last_name,
			ptcus_first_name,
			ptcus_comment,
			--Contact,
			ptcus_contact,
			ptcus_phone,
			ptcus_phone2,
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
			ptcus_srv_cd
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
			SUBSTRING(Ent.strInternalNotes,1,30) as strInternalNotes,
			--Ent.str1099Name,
			--Contact
			SUBSTRING((SELECT strName FROM tblEntity WHERE intEntityId = Con.intEntityId),1,20) AS strContactName,
			SUBSTRING(Con.strPhone,1,15) as strPhone,
			SUBSTRING(Con.strPhone2,1,15) as strPhone2,
			--Location
			(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END) AS strAddress1,
			(CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END) AS strAddress2,
			SUBSTRING(Loc.strCity,1,20) as strCity,
			SUBSTRING(Loc.strState,1,2) as strState,
			SUBSTRING(Loc.strZipCode,1,10) as strZipCode,
			(CASE WHEN LEN(Loc.strCountry) = 10 THEN Loc.strCountry ELSE '''' END)as strCountry,
			--Customer
			SUBSTRING(Cus.strCustomerNumber,1,10) as strCustomerNumber,
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
			(CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''Y'' ELSE ''N'' END) AS ysnApplyPrepaidTax,
			Cus.dblBudgetAmountForBudgetBilling,
			SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2) as strBudgetBillingBeginMonth,
			SUBSTRING(Cus.strBudgetBillingEndMonth,1,2) as strBudgetBillingEndMonth,
			(SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId),
			(SELECT strSalespersonId FROM tblARSalesperson WHERE intSalespersonId = Cus.intSalespersonId),
			(SELECT strServiceChargeCode FROM tblARServiceCharge WHERE intServiceChargeId = Cus.intServiceChargeId)
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
			FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblARCustomerToContact CustToCon ON Cus.intDefaultContactId = CustToCon.intARCustomerToContactId
			INNER JOIN tblEntityContact Con ON CustToCon.intContactId = Con.intContactId
			INNER JOIN tblEntityLocation Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
			WHERE strCustomerNumber = @CustomerId
		

	RETURN;
	END

	--================================================
	--     ONE TIME CUSTOMER SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @CustomerId IS NULL) 
	BEGIN
	
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
		DECLARE @intCustomerId				INT            
		DECLARE @strCustomerNumber			NVARCHAR(15)    
		DECLARE @strType					NVARCHAR(MAX)
		DECLARE @dblCreditLimit				NUMERIC(18,6)
		DECLARE @strTaxNumber				NVARCHAR(MAX)
		DECLARE @strCurrency				NVARCHAR(3)
		DECLARE @intAccountStatusId			INT
		DECLARE @intSalespersonId			INT
		DECLARE	@strPricing					NVARCHAR(MAX)
		DECLARE @ysnActive					BIT
		DECLARE @ysnPORequired				BIT
		DECLARE @ysnStatementDetail			BIT
		DECLARE @strStatementFormat			NVARCHAR(50)
		DECLARE @intCreditStopDays			INT
		DECLARE @strTaxAuthority1			NVARCHAR(MAX)
		DECLARE @strTaxAuthority2			NVARCHAR(MAX)
		DECLARE @ysnPrintPriceOnPrintTicket	BIT
		DECLARE @intServiceChargeId			INT
		DECLARE @ysnApplySalesTax			BIT
		DECLARE @dblBudgetAmountForBudgetBilling NUMERIC(18,6)
		DECLARE @strBudgetBillingBeginMonth	NVARCHAR(50)
		DECLARE @strBudgetBillingEndMonth	NVARCHAR(50)
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
    
		--Import only those are not yet imported
		SELECT ptcus_cus_no INTO #tmpptcusmst 
			FROM ptcusmst
		LEFT JOIN tblARCustomer
			ON ptcusmst.ptcus_cus_no COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
		WHERE tblARCustomer.strCustomerNumber IS NULL
		ORDER BY ptcusmst.ptcus_cus_no

		WHILE (EXISTS(SELECT 1 FROM #tmpptcusmst))
		BEGIN
		
			SELECT @originCustomer = ptcus_cus_no FROM #tmpptcusmst

			SELECT TOP 1
				--Entity
				@strName = CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ptcus_last_name + ptcus_first_name WHEN ptcus_co_per_ind_cp = ''P'' THEN RTRIM(LTRIM(ptcus_last_name)) + '', '' + RTRIM(LTRIM(ptcus_first_name))END,
				@strWebsite = '''',
				@strInternalNotes = ptcus_comment,
				@ysnPrint1099   = 0,--To Map
				--@str1099Name    = agcus_1099_name,
				@str1099Form	= '''',
				@str1099Type	= '''',
				@strFederalTaxId	= NULL, --To Map
				@dtmW9Signed	= NULL, --To Map,
				@imgPhoto = NULL,

				--Contacts
				@strTitle = '''',
				@strContactName = ptcus_contact,
				@strDepartment = NULL,
				@strMobile     = NULL,
				@strPhone      = ptcus_phone,
				@strPhone2     = ptcus_phone2,
				@strEmail      = NULL,
				@strEmail2     = NULL,
				@strFax        = NULL,
				@strNotes      = NULL,
				@strContactMethod = NULL,
				@strTimezone = NULL,
				
				@strUserType = NULL,
				@ysnPortalAccess = NULL,

				--Locations
				@strLocationName = @strName,
				@strAddress      = ISNULL(ptcus_addr,'''') + CHAR(10) + ISNULL(ptcus_addr2,''''),
				@strCity         = ptcus_city,
				@strCountry      = ptcus_country,
				@strState        = ptcus_state,
				@strZipCode      = ptcus_zip,
				@strLocationNotes        = NULL,
				@intShipViaId = NULL,
				@intTaxCodeId    = NULL,
				@intTermsId      = NULL,
				@intWarehouseId  = NULL,
			
				--Customer
				@strCustomerNumber		= ptcus_cus_no,			
				@strType				= CASE WHEN ptcus_co_per_ind_cp = ''C'' THEN ''Company'' ELSE ''Person'' END,					
				@dblCreditLimit			= ptcus_credit_limit,					
				@strTaxNumber			= ptcus_sales_tax_id,
				--@strCurrency			= agcus_dflt_currency, 				
				@intAccountStatusId		= (SELECT intAccountStatusId FROM tblARAccountStatus WHERE strAccountStatusCode COLLATE Latin1_General_CI_AS = ptcus_acct_stat_x_1 COLLATE Latin1_General_CI_AS),			
				@intSalespersonId		= (SELECT intSalespersonId FROM tblARSalesperson WHERE strSalespersonId COLLATE Latin1_General_CI_AS = ptcus_slsmn_id COLLATE Latin1_General_CI_AS),		
    			@strPricing				= NULL, --agcus_prc_lvl					
				@ysnActive				= CASE WHEN ptcus_active_yn = ''Y'' THEN 1 ELSE 0 END,					
				@ysnPORequired			= 0, --there is no source field for PT  --CASE WHEN ptcus_req_po_yn = ''Y'' THEN 1 ELSE 0 END,									
				@ysnStatementDetail		= CASE WHEN ptcus_prt_stmnt_dtl_yn = ''Y'' THEN 1 ELSE 0 END,			
				@strStatementFormat		= CASE WHEN ptcus_stmt_fmt = ''O'' THEN ''Open Item'' WHEN ptcus_stmt_fmt = ''B'' THEN ''Balance Forward'' WHEN ptcus_stmt_fmt = ''R'' THEN ''Budget Reminder'' WHEN ptcus_stmt_fmt = ''N'' THEN ''None'' WHEN ptcus_stmt_fmt IS NULL THEN Null Else '''' END ,			
				@intCreditStopDays		= ptcus_crd_stop_days,			
				@strTaxAuthority1		= ptcus_local1,			
				@strTaxAuthority2		= ptcus_local2,			
				@ysnPrintPriceOnPrintTicket = CASE WHEN ptcus_pic_prc_yn = ''Y'' THEN 1 ELSE 0 END,	
				@intServiceChargeId		= (SELECT intServiceChargeId FROM tblARServiceCharge WHERE strServiceChargeCode COLLATE Latin1_General_CI_AS = ptcus_srv_cd COLLATE Latin1_General_CI_AS),			
				@ysnApplySalesTax		= CASE WHEN ptcus_sales_tax_yn = ''Y'' THEN 1 ELSE 0 END,			
				@dblBudgetAmountForBudgetBilling = ptcus_budget_amt,
				@strBudgetBillingBeginMonth	= ptcus_budget_beg_mm,	
				@strBudgetBillingEndMonth	= ptcus_budget_end_mm
				--Grain Tab
				--@strDPAContract = agcus_dpa_cnt,				
				--@dtmDPADate = (CASE WHEN agcus_dpa_rev_dt = 0 THEN NULL ELSE CONVERT(datetime,SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),0,5) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),5,2) + ''-'' + SUBSTRING(CONVERT(nvarchar,agcus_dpa_rev_dt),7,2)) END),					
				--@strGBReceiptNumber = agcus_gb_rcpt_no,			
				--@ysnCheckoffExempt = CASE WHEN agcus_ckoff_exempt_yn = ''Y'' THEN 1 ELSE 0 END,			
				--@ysnVoluntaryCheckoff = CASE WHEN agcus_ckoff_vol_yn = ''Y'' THEN 1 ELSE 0 END ,		
				--@strCheckoffState = agcus_ga_origin_st,			
				--@ysnMarketAgreementSigned = CASE WHEN agcus_mkt_sign_yn = ''Y'' THEN 1 ELSE 0 END ,	
				--@intMarketZoneId = NULL, --agcus_dflt_mkt_zone this should be query to tblARMarketzone,			
				--@ysnHoldBatchGrainPayment = CASE WHEN agcus_ga_hold_pay_yn = ''Y'' THEN 1 ELSE 0 END ,	
				--@ysnFederalWithholding = CASE WHEN agcus_ga_wthhld_yn = ''Y'' THEN 1 ELSE 0 END	
			
			FROM ptcusmst
			WHERE ptcus_cus_no = @originCustomer
			
			--INSERT Entity record for Customer
			INSERT [dbo].[tblEntity]	([strName],[strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed],[imgPhoto])
			VALUES						(@strName, @strEmail, @strWebsite, @strInternalNotes, @ysnPrint1099, @str1099Name, @str1099Form, @str1099Type, @strFederalTaxId, @dtmW9Signed, @imgPhoto)

			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()
			
			--INSERT into Customer
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
			[dblBudgetAmountForBudgetBilling],
			[strBudgetBillingBeginMonth],
			[strBudgetBillingEndMonth]
			--Grain Tab
			--[strDPAContract],				
			--[dtmDPADate],				
			--[strGBReceiptNumber],			
			--[ysnCheckoffExempt],			
			--[ysnVoluntaryCheckoff],		
			--[strCheckoffState],			
			--[ysnMarketAgreementSigned],	
			--[intMarketZoneId],			
			--[ysnHoldBatchGrainPayment],	
			--[ysnFederalWithholding]
			)
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
			 @intSalespersonId,		
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
			 @dblBudgetAmountForBudgetBilling,
			 @strBudgetBillingBeginMonth,
			 @strBudgetBillingEndMonth
			 --@strDPAContract,				
			 --@dtmDPADate,					
			 --@strGBReceiptNumber,			
			 --@ysnCheckoffExempt,			
			 --@ysnVoluntaryCheckoff,		
			 --@strCheckoffState,			
			 --@ysnMarketAgreementSigned,	
			 --@intMarketZoneId,			
			 --@ysnHoldBatchGrainPayment,	
			 --@ysnFederalWithholding
			 )
			 
			 --Get intCustomerId
			 SELECT @intCustomerId = intCustomerId FROM tblARCustomer WHERE intEntityId = @EntityId
	

			--INSERT ENTITY record for Contact
			IF(@strContactName IS NOT NULL)
			BEGIN
				INSERT [dbo].[tblEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes])
				VALUES					 (@strContactName, @strEmail, @strWebsite, @strInternalNotes)
			END
			ELSE
				INSERT [dbo].[tblEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes])
				VALUES					 (@strName, @strEmail, @strWebsite, @strInternalNotes)

			DECLARE @ContactEntityId INT
			
			SET @ContactEntityId = SCOPE_IDENTITY()
		
			-- RULE: when creating a default contact from agcusmst.agcus_contact, trim tblEntityContact.strContactNumber to 20 characters
			INSERT [dbo].[tblEntityContact] ([intEntityId], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
			SELECT							 @ContactEntityId, 
											CASE WHEN @strContactName IS NOT NULL THEN SUBSTRING(@strContactName, 1, 20) ELSE SUBSTRING(@strName, 1, 20) END
											,@strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes
				
			--Get intContactId
			SELECT @intContactId = intContactId FROM tblEntityContact WHERE intEntityId = @ContactEntityId
			
		
			--INSERT into Location
			INSERT [dbo].[tblEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strNotes],  [intShipViaId], [intTaxCodeId], [intTermsId], [intWarehouseId])
			VALUES								(@EntityId, @strLocationName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strLocationNotes,  @intShipViaId, @intTaxCodeId, @intTermsId, @intWarehouseId)

			DECLARE @EntityLocationId INT
			SET @EntityLocationId = SCOPE_IDENTITY()
		
			 
			--INSERT into tblARCustomerToContact
			DECLARE @CustomerToContactId INT
			
			INSERT [dbo].[tblARCustomerToContact] ([intCustomerId],[intContactId],[intEntityLocationId],[strUserType],[ysnPortalAccess])
			VALUES							  (@intCustomerId, @intContactId, @EntityLocationId, ''User'', 0)
			
			SET @CustomerToContactId = SCOPE_IDENTITY()
			
			UPDATE tblARCustomer 
			SET intDefaultContactId = @CustomerToContactId, 
				intDefaultLocationId = @EntityLocationId,
				intBillToId = @EntityLocationId,
				intShipToId = @EntityLocationId
			WHERE intEntityId = @EntityId 
	
		

			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			PRINT @originCustomer
			DELETE FROM #tmpptcusmst WHERE ptcus_cus_no = @originCustomer
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempCustomer

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @CustomerId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(ptcus_cus_no) from tblARTempCustomer
	END'
)
END