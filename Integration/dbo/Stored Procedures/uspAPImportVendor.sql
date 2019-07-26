﻿PRINT 'Import Vendor Scripts'
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportVendor')
	DROP PROCEDURE uspAPImportVendor
GO


IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
EXEC(
'
CREATE PROCEDURE [dbo].[uspAPImportVendor]
	@VendorId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--VALIDATION
--Do not allow to import if some of the default gl account setup for vendor do not exists in tblGLAccount
--IF EXISTS(SELECT 1 FROM ssvndmst 
--		WHERE NOT EXISTS(
--				(SELECT 1 FROM tblGLCOACrossReference WHERE strExternalId = CONVERT(NVARCHAR(50),ssvnd_gl_pur)))
--			AND ssvnd_gl_pur <> 0 AND ssvnd_gl_pur <> 1)
--BEGIN
--	RAISERROR(''Some of the vendor default expense account do not exists in i21 Accounts.'', 16, 1);
--	RETURN;
--END

DECLARE @defaultCurrencyPref INT = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId > 0);
DECLARE @USDCur INT = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'');

IF(@Update = 1 AND @VendorId IS NOT NULL)
BEGIN

	IF(EXISTS(SELECT 1 FROM ssvndmst WHERE ssvnd_vnd_no = SUBSTRING(@VendorId, 1, 10)))
	BEGIN	

		UPDATE ssvndmst
		SET 
		--ssvnd_vnd_no					=	CAST(B.strVendorId AS VARCHAR(10)),
		ssvnd_co_per_ind				=	CASE WHEN B.intVendorType = 0 THEN ''C'' ELSE ''P'' END,
		ssvnd_name						=	CASE WHEN B.intVendorType = 0 THEN CAST(A.strName AS VARCHAR(50))
											ELSE SUBSTRING(A.strName,0,dbo.fnLastIndex(A.strName,'' '')) + '' '' +
												SUBSTRING(A.strName, dbo.fnLastIndex(A.strName,'' ''), DATALENGTH(A.strName))
											END,
		ssvnd_addr_1					=	CAST(CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 
													THEN SUBSTRING(C.strAddress, 0, CHARINDEX(CHAR(10),C.strAddress)) 
													ELSE C.strAddress END AS VARCHAR(30)),
		ssvnd_addr_2					=	CAST(CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 
													THEN SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress), LEN(C.strAddress)) 
													ELSE NULL END AS VARCHAR(30)),
		ssvnd_city						=	CAST(strCity AS VARCHAR(20)),
		ssvnd_st						=	CAST(C.strState AS VARCHAR(2)),
		ssvnd_zip						=	CAST(C.strZipCode AS VARCHAR(10)),
		ssvnd_phone						=	CAST(ISNULL(I.strPhone,'''') AS VARCHAR(15)),
		ssvnd_phone2					=	CAST(ISNULL(D.strPhone2,'''') AS VARCHAR(15)),
		ssvnd_contact					=	CAST(D.strName AS VARCHAR(15)),
		ssvnd_1099_yn					=	CASE WHEN A.ysnPrint1099 = 0 THEN ''N'' ELSE ''Y'' END,
		ssvnd_wthhld_yn					=	CASE WHEN ysnWithholding = 0 THEN ''N'' ELSE ''Y'' END,
		ssvnd_pay_ctl_ind				=	CASE WHEN ysnPymtCtrlActive = 1 THEN ''A''
												WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN ''D''
												WHEN ysnPymtCtrlEFTActive = 1  THEN ''E''
												WHEN ysnPymtCtrlHold = 1 THEN ''H'' END,
		ssvnd_fed_tax_id				=	CAST(A.strFederalTaxId AS VARCHAR(20)),
		ssvnd_w9_signed_rev_dt			=	CONVERT(VARCHAR(8), GETDATE(), 112),
		ssvnd_pay_to					=	CAST(strVendorPayToId AS VARCHAR(10)),		
		ssvnd_currency					=	E.strCurrency,
		ssvnd_1099_name					=	CAST(A.str1099Name AS VARCHAR(50)),
		ssvnd_gl_pur					=	CAST(F.strExternalId AS DECIMAL(16,8)),
		ssvnd_tax_st					=	CAST(B.strTaxState AS VARCHAR(2)),
		ssvnd_our_cus_no				=	CAST(B.strVendorAccountNum AS VARCHAR(20)),
		
		ssvnd_terms_desc				=	H.strTerm,
		ssvnd_terms_disc_pct			=	H.dblDiscountEP,
		ssvnd_terms_due_day				=	H.intBalanceDue,
		ssvnd_terms_disc_day			=	H.intDiscountDay,
		ssvnd_terms_cutoff_day			=	H.intDayofMonthDue,
		ssvnd_acct_stat					=   (CASE WHEN B.ysnPymtCtrlActive = 1 THEN ''A'' ELSE NULL END),
		ssvnd_terms_type 				=	(CASE WHEN H.strTerm IS NOT NULL THEN ''D'' ELSE NULL END)

		FROM ssvndmst 		
		INNER JOIN tblAPVendor B
			ON ssvndmst.ssvnd_vnd_no COLLATE Latin1_General_CI_AS = SUBSTRING(B.strVendorId, 1, 10) COLLATE Latin1_General_CI_AS
		INNER JOIN tblEMEntity A
			ON A.intEntityId = B.intEntityId
		INNER JOIN tblEMEntityLocation C
			ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
		INNER JOIN tblEMEntityToContact G
			ON A.intEntityId = G.intEntityId and G.ysnDefaultContact = 1
		INNER JOIN tblEMEntity D
			ON  G.intEntityContactId = D.intEntityId
		LEFT JOIN tblSMCurrency E
			ON B.intCurrencyId = E.intCurrencyID
		LEFT JOIN tblGLCOACrossReference F
			ON B.intGLAccountExpenseId = F.inti21Id
		LEFT JOIN tblSMTerm H
			on B.intTermsId = H.intTermID
		LEFT JOIN tblEMEntityPhoneNumber I
			ON D.intEntityId = I.intEntityId
		WHERE ssvndmst.ssvnd_vnd_no =  SUBSTRING(@VendorId, 1, 10)
	END
	ELSE
	BEGIN		
		INSERT INTO ssvndmst(
		ssvnd_vnd_no,
		ssvnd_co_per_ind,
		ssvnd_name,
		ssvnd_addr_1,
		ssvnd_addr_2,
		ssvnd_city,
		ssvnd_st,
		ssvnd_zip,
		ssvnd_phone,
		ssvnd_phone2,
		ssvnd_contact,
		ssvnd_1099_yn,
		ssvnd_wthhld_yn,
		ssvnd_pay_ctl_ind,
		ssvnd_fed_tax_id,
		ssvnd_w9_signed_rev_dt,
		ssvnd_pay_to,
		ssvnd_currency,
		ssvnd_1099_name,
		ssvnd_gl_pur,
		ssvnd_tax_st,
		ssvnd_our_cus_no,
		ssvnd_terms_desc,				
		ssvnd_terms_disc_pct,			
		ssvnd_terms_due_day,			
		ssvnd_terms_disc_day,			
		ssvnd_terms_cutoff_day,
		ssvnd_acct_stat,	
		ssvnd_terms_type			
		)
		SELECT 
			ssvnd_vnd_no					=	CASE WHEN CHARINDEX(CHAR(10), B.strVendorId) > 0 THEN SUBSTRING(B.strVendorId, 0, CHARINDEX(CHAR(10),B.strVendorId)) ELSE B.strVendorId END,
			ssvnd_co_per_ind				=	CASE WHEN B.intVendorType = 0 THEN ''C'' ELSE ''P'' END,
			ssvnd_name						=	A.strName,
			ssvnd_addr_1					=	CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE C.strAddress END,
			ssvnd_addr_2					=	CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress), LEN(C.strAddress)) ELSE NULL END,
			ssvnd_city						=	strCity,
			ssvnd_st						=	CAST(C.strState AS VARCHAR(2)),
			ssvnd_zip						=	CAST(C.strZipCode AS VARCHAR(10)),
			ssvnd_phone						=	CAST(ISNULL(I.strPhone,'''') AS VARCHAR(15)),
			ssvnd_phone2					=	CAST(ISNULL(D.strPhone2,'''') AS VARCHAR(15)),
			ssvnd_contact					=	CAST(D.strName AS VARCHAR(15)),
			ssvnd_1099_yn					=	CASE WHEN A.ysnPrint1099 = 0 THEN ''N'' ELSE ''Y'' END,
			ssvnd_wthhld_yn					=	CASE WHEN ysnWithholding = 0 THEN ''N'' ELSE ''Y'' END,
			ssvnd_pay_ctl_ind				=	CASE WHEN ysnPymtCtrlActive = 1 THEN ''A''
												 WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN ''D''
												 WHEN ysnPymtCtrlEFTActive = 1  THEN ''E''
												 WHEN ysnPymtCtrlHold = 1 THEN ''H'' END,
			ssvnd_fed_tax_id				=	CAST(A.strFederalTaxId AS VARCHAR(20)),
			ssvnd_w9_signed_rev_dt			=	CONVERT(VARCHAR(8), GETDATE(), 112),
			ssvnd_pay_to					=	CAST(strVendorPayToId AS VARCHAR(10)),
			ssvnd_currency					=	E.strCurrency,
			ssvnd_1099_name					=	CAST(A.str1099Name AS VARCHAR(50)),
			ssvnd_gl_pur					=	CAST(F.strExternalId AS DECIMAL(16,8)),
			ssvnd_tax_st					=	CAST(B.strTaxState AS VARCHAR(2)),
			ssvnd_our_cus_no				=	CAST(B.strVendorAccountNum AS VARCHAR(20)),
		
			ssvnd_terms_desc				=	H.strTerm,
			ssvnd_terms_disc_pct			=	H.dblDiscountEP,
			ssvnd_terms_due_day				=	H.intBalanceDue,
			ssvnd_terms_disc_day			=	H.intDiscountDay,
			ssvnd_terms_cutoff_day			=	H.intDayofMonthDue,
			ssvnd_acct_stat					=   (CASE WHEN B.ysnPymtCtrlActive = 1 THEN ''A'' ELSE NULL END),
			ssvnd_terms_type 				=	(CASE WHEN H.strTerm IS NOT NULL THEN ''D'' ELSE NULL END)
		FROM
			tblEMEntity A
		INNER JOIN tblAPVendor B
			ON A.intEntityId = B.intEntityId
		INNER JOIN tblEMEntityLocation C		
			ON  A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
		INNER JOIN tblEMEntityToContact G
			ON A.intEntityId = G.intEntityId and G.ysnDefaultContact = 1
		INNER JOIN tblEMEntity D
			ON  G.intEntityContactId = D.intEntityId
		LEFT JOIN tblSMCurrency E
			ON B.intCurrencyId = E.intCurrencyID
		LEFT JOIN tblGLCOACrossReference F
			ON B.intGLAccountExpenseId = F.inti21Id
		LEFT JOIN tblSMTerm H
			on B.intTermsId = H.intTermID
		LEFT JOIN tblEMEntityPhoneNumber I
			on D.intEntityId = I.intEntityId
		WHERE B.strVendorId = @VendorId

		--Insert new record to tblAPImportedVendors
		INSERT INTO tblAPImportedVendors
		SELECT @VendorId, 0
	END

RETURN;
END

IF(@Update = 0 AND @VendorId IS NULL)
BEGIN	
	--1 Time synchronization here
	PRINT ''1 Time Vendor Synchronization''

	--Make a copy of all imported vendor	
		
	DECLARE @originVendor NVARCHAR(50)

	--Entities
	DECLARE @strName			NVARCHAR (255)
	DECLARE	@strWebsite			NVARCHAR (255)
	DECLARE	@strInternalNotes	NVARCHAR (255)
	DECLARE @str1099Name        NVARCHAR (100) 
	DECLARE @ysnPrint1099       BIT     
	DECLARE @dtmW9Signed		DATETIME
	DECLARE	@str1099Form        NVARCHAR (255) 
	DECLARE @strFederalTaxId    NVARCHAR (255) 

	--Contacts
	DECLARE	@strTitle           NVARCHAR (255) 
	DECLARE	@strContactName     NVARCHAR (255) 
	DECLARE	@strContactNumber   NVARCHAR (255) 
	DECLARE	@strDepartment      NVARCHAR (255) 
	DECLARE	@strMobile          NVARCHAR (255) 
	DECLARE	@strPhone           NVARCHAR (255) 
	DECLARE	@strPhone2          NVARCHAR (255) 
	DECLARE	@strEmail           NVARCHAR (255) 
	DECLARE	@strEmail2          NVARCHAR (255) 
	DECLARE	@strFax             NVARCHAR (255) 
	DECLARE	@strNotes           NVARCHAR (255) 
	DECLARE	@strContactMethod   NVARCHAR (255) 
	DECLARE	@strPassword        NVARCHAR (255) 
	DECLARE	@strUserType        NVARCHAR (255) 
	DECLARE	@strTimezone        NVARCHAR (255) 
	DECLARE @ysnPortalAccess	BIT
	DECLARE @imgContactPhoto	varbinary(MAX)

	--Locations
	DECLARE	@strLocationName     NVARCHAR (50) 
	DECLARE	@strLocationContactName      NVARCHAR (255)
	DECLARE	@strAddress          NVARCHAR (255)
	DECLARE	@strCity             NVARCHAR (255)
	DECLARE	@strCountry          NVARCHAR (255)
	DECLARE	@strState            NVARCHAR (255)
	DECLARE	@strZipCode          NVARCHAR (255)
	DECLARE	@strLocationEmail            NVARCHAR (255)
	DECLARE	@strLocationNotes            NVARCHAR (255)
	DECLARE	@strW9Name           NVARCHAR (255)
	DECLARE	@intLocationShipViaId        INT           
	DECLARE	@intTaxCodeId        INT           
	DECLARE	@intTermsId          INT           
	DECLARE	@intWarehouseId      INT          
	
	--Vendors
	DECLARE @intEntityId               INT            
    DECLARE @intEntityLocationId       INT            
    DECLARE @intEntityContactId        INT            
    DECLARE @intCurrencyId             INT            
    DECLARE @strVendorPayToId          NVARCHAR (MAX) 
    DECLARE @intPaymentMethodId        INT            
    DECLARE @intShipViaId              INT            
    DECLARE @intVendorTaxCodeId			INT            
    DECLARE @intGLAccountExpenseId     INT            
    --DECLARE @intVendorTermsId                NVARCHAR (MAX) 
    DECLARE @intVendorType             INT            
    DECLARE @strVendorId               NVARCHAR (50)  
    DECLARE @strVendorAccountNum       NVARCHAR (15)  
    DECLARE @str1099Type               NVARCHAR (20)  
    DECLARE @str1099Category           NVARCHAR (100) 
    DECLARE @ysnPymtCtrlActive         BIT            
    DECLARE @ysnPymtCtrlAlwaysDiscount BIT            
    DECLARE @ysnPymtCtrlEFTActive      BIT            
    DECLARE @ysnPymtCtrlHold           BIT            
    DECLARE @ysnWithholding            BIT            
    DECLARE @ysnW9Signed               BIT            
    DECLARE @dblCreditLimit            FLOAT (53)     
    DECLARE @intCreatedUserId          INT            
    DECLARE @intLastModifiedUserId     INT            
    DECLARE @dtmLastModified           DATETIME       
    DECLARE @dtmCreated                DATETIME       
    DECLARE @strTaxState				NVARCHAR(50) 

	--Import only those are not yet imported
	/*SELECT ssvnd_vnd_no INTO #tmpssvndmst 
	FROM ssvndmst A
	where ssvnd_vnd_no COLLATE Latin1_General_CI_AS not in (select strVendorId from tblAPImportedVendors )*/

	SELECT ssvnd_vnd_no INTO #tmpssvndmst 
	FROM ssvndmst A
		where ssvnd_vnd_no COLLATE Latin1_General_CI_AS not in (select strVendorId from tblAPImportedVendors )


	INSERT INTO #tmpssvndmst  (ssvnd_vnd_no)	
	SELECT DISTINCT A.apchk_vnd_no
	FROM apchkmst A	
		WHERE A.apchk_vnd_no IN (
			SELECT
			DISTINCT B.apivc_vnd_no
			FROM apivcmst B
			WHERE B.apivc_vnd_no NOT IN (SELECT ssvnd_vnd_no FROM ssvndmst)
		)
		AND apchk_vnd_no COLLATE Latin1_General_CI_AS not in (select strVendorId from tblAPImportedVendors )

	
	declare @compare_table table(
		strId nvarchar(100)
	)
	insert into @compare_table
	select distinct trhst_pur_vnd_no from trhstmst
	union
	select distinct trvpr_vnd_no from trvprmst
	union
	select distinct trprc_vnd_no from trprcmst
	delete from @compare_table where strId is null


	WHILE (EXISTS(SELECT 1 FROM #tmpssvndmst))
	BEGIN
		
		DECLARE @continue BIT = 0;

		SELECT @originVendor = ssvnd_vnd_no FROM #tmpssvndmst

		IF(EXISTS(SELECT 1 FROM ssvndmst WHERE ssvnd_vnd_no = @originVendor))
		BEGIN

			SET @continue = 1;

            SELECT TOP 1
                --Entities
                @strName = ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
                            ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
                                + '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
                            END,''''),
                @strWebsite = '''',
                @strInternalNotes = '''',
                @ysnPrint1099   = CASE WHEN ssvnd_1099_yn = ''Y'' THEN 1 ELSE 0 END,
                @str1099Name    = ssvnd_1099_name,
                @str1099Form	= '''',
                @str1099Type	= '''',
                @strFederalTaxId	= ssvnd_fed_tax_id,
                @dtmW9Signed	= CASE WHEN ssvnd_w9_signed_rev_dt = 0 OR ISDATE(ssvnd_w9_signed_rev_dt) = 0 THEN NULL ELSE CONVERT(DATE, CAST(ssvnd_w9_signed_rev_dt AS CHAR(12)), 112) END,

                --Contacts
                @strTitle = '''',
                @strContactName = dbo.fnTrim(ssvnd_contact),
                @strDepartment = NULL,
                @strMobile     = NULL,
                @strPhone      = ISNULL(ssvnd_phone,'''') + '' '' + ISNULL(ssvnd_phone_ext,''''),
                @strPhone2     = NULL,
                @strEmail      = NULL,
                @strEmail2     = NULL,
                @strFax        = NULL,
                @strNotes      = NULL,
                @strContactMethod = NULL,
                @strPassword = NULL,
                @strUserType = NULL,
                @strTimezone = NULL,
                @ysnPortalAccess = NULL,
                @imgContactPhoto = NULL,

                --Locations
                @strLocationName = @strName,
                @strAddress      = dbo.fnTrim(ISNULL(ssvnd_addr_1,'''')) + CHAR(10) + dbo.fnTrim(ISNULL(ssvnd_addr_2,'''')),
                @strCity         = ssvnd_city,
                    @strCountry      = ''United States'',--(SELECT TOP 1 strCountry FROM tblSMZipCode WHERE strState COLLATE Latin1_General_CI_AS = ssvnd_st COLLATE Latin1_General_CI_AS),
                @strState        = ssvnd_st,
                @strZipCode      = dbo.fnTrim(ssvnd_zip),
                @strLocationEmail        = NULL,
                @strLocationNotes        = NULL,
                @strW9Name       = NULL,
                @intLocationShipViaId    = NULL,
                @intShipViaId = NULL,
                @intTaxCodeId    = NULL,
                @intTermsId      = CASE WHEN ssvnd_terms_disc_pct = 0 AND ssvnd_terms_due_day = 0
                                            AND ssvnd_terms_disc_day = 0 AND ssvnd_terms_cutoff_day = 0 THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'')
                                        WHEN ssvnd_terms_type = ''D'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
                                                        WHERE dblDiscountEP = ssvnd_terms_disc_pct
                                                        AND intBalanceDue = ssvnd_terms_due_day
                                                        AND intDiscountDay = ssvnd_terms_disc_day)
                                        WHEN ssvnd_terms_type = ''P'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
                                                        WHERE intBalanceDue = ssvnd_terms_due_day
                                                        AND intDiscountDay = ssvnd_terms_disc_day
                                                        AND intDayofMonthDue = ssvnd_terms_cutoff_day)
                                        ELSE (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'') END
                                            ,
                @intWarehouseId  = NULL,

                --Vendors
                @intVendorType				= CASE WHEN ssvnd_co_per_ind = ''C'' THEN 0 ELSE 1 END,
                @originVendor				= ssvnd_vnd_no,
                @intCurrencyId				= ISNULL((SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency COLLATE Latin1_General_CI_AS = ssvnd_currency COLLATE Latin1_General_CI_AS)
											  ,ISNULL(@defaultCurrencyPref, @USDCur)),
                @strVendorPayToId         	= ssvnd_pay_to,
                @intPaymentMethodId       	= NULL,
                @intVendorTaxCodeId     	= NULL,
                @intGLAccountExpenseId    	= (SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CONVERT(NVARCHAR(50),ssvnd_gl_pur)),
                @strVendorAccountNum      	= ssvnd_our_cus_no,
                @ysnPymtCtrlActive        	= CASE 	WHEN ssvnd_pay_ctl_ind = ''A'' THEN 1 
													WHEN ssvnd_pay_ctl_ind = ''D'' THEN 1
													WHEN ssvnd_pay_ctl_ind = ''H'' THEN 1
												ELSE 0 END,
                @ysnPymtCtrlAlwaysDiscount	= CASE WHEN ssvnd_pay_ctl_ind = ''D'' THEN 1 ELSE 0 END,
                @ysnPymtCtrlEFTActive     	= CASE WHEN ssvnd_pay_ctl_ind = ''E'' THEN 1 ELSE 0 END,
                @ysnPymtCtrlHold          	= CASE WHEN ssvnd_pay_ctl_ind = ''H'' THEN 1 ELSE 0 END,
                @ysnWithholding           	= CASE WHEN ssvnd_wthhld_yn = ''N'' THEN 0 ELSE 1 END,
                @dblCreditLimit           	= 0,
                @intCreatedUserId         	= NULL,
                @intLastModifiedUserId    	= NULL,
                @dtmLastModified          	= NULL,
                @dtmCreated               	= NULL,
                @strTaxState				= ssvnd_tax_st
            FROM ssvndmst
            WHERE ssvnd_vnd_no = @originVendor
		END
		ELSE IF(EXISTS(SELECT 1 FROM apchkmst WHERE apchk_vnd_no = @originVendor))
		BEGIN

			SET @continue = 1;

			SELECT
				TOP 1
				--Entities
				@strName = A.apchk_vnd_no,
				@strWebsite = '''',
				@strInternalNotes = '''',
				@ysnPrint1099   = 0,
				@str1099Name    = '''',
				@str1099Form	= '''',
				@str1099Type	= '''',
				@strFederalTaxId	= NULL,
				@dtmW9Signed	= NULL,

				--Contacts
				@strTitle = '''',
				@strContactName = A.apchk_vnd_no,
				@strDepartment = NULL,
				@strMobile     = NULL,
				@strPhone      = NULL,
				@strPhone2     = NULL,
				@strEmail      = NULL,
				@strEmail2     = NULL,
				@strFax        = NULL,
				@strNotes      = NULL,
				@strContactMethod = NULL,
				@strPassword = NULL,
				@strUserType = NULL,
				@strTimezone = NULL,
				@ysnPortalAccess = NULL,
				@imgContactPhoto = NULL,

				--Locations
				@strLocationName = @strName,
				@strAddress      = dbo.fnTrim(ISNULL(apchk_addr_1,'''')) + CHAR(10) + dbo.fnTrim(ISNULL(apchk_addr_2,'''')),
				@strCity         = apchk_city,
				@strCountry      = ''United States'',
				@strState        = apchk_st,
				@strZipCode      = dbo.fnTrim(apchk_zip),
				@strLocationEmail        = NULL,
				@strLocationNotes        = NULL,
				@strW9Name       = NULL,
				@intLocationShipViaId    = NULL,
				@intShipViaId = NULL,
				@intTaxCodeId    = NULL,
				@intTermsId      = (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt''),
				@intWarehouseId  = NULL,

				--Vendors
				@intVendorType				= 1,
				@originVendor				= apchk_vnd_no,
				@intCurrencyId				= ISNULL(@defaultCurrencyPref, @USDCur),
				@strVendorPayToId         	= NULL,
				@intPaymentMethodId       	= NULL,
				@intVendorTaxCodeId     	= NULL,
				@intGLAccountExpenseId    	= NULL,
				@strVendorAccountNum      	= NULL,
				@ysnPymtCtrlActive        	= 0,
				@ysnPymtCtrlAlwaysDiscount	= 0,
				@ysnPymtCtrlEFTActive     	= 0,
				@ysnPymtCtrlHold          	= 1,
				@ysnWithholding           	= 0,
				@dblCreditLimit           	= 0,
				@intCreatedUserId         	= NULL,
				@intLastModifiedUserId    	= NULL,
				@dtmLastModified          	= NULL,
				@dtmCreated               	= NULL,
				@strTaxState				= NULL
			FROM apchkmst A
			WHERE A.apchk_vnd_no IN (
				SELECT
				DISTINCT B.apivc_vnd_no
				FROM apivcmst B
				WHERE B.apivc_vnd_no NOT IN (SELECT ssvnd_vnd_no FROM ssvndmst)
			) AND A.apchk_vnd_no = @originVendor

		END

		IF(@continue = 1)
		BEGIN
		PRINT ''INSERT Entity Record''
		
		DECLARE @EntityId INT
		DECLARE @ysnIsDefault BIT
		
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where LTRIM(RTRIM(strEntityNo)) = RTRIM(LTRIM(@originVendor))  )
		BEGIN
				SELECT TOP 1 @EntityId = intEntityId FROM tblEMEntity where LTRIM(RTRIM(strEntityNo)) = RTRIM(LTRIM(@originVendor)) 
				SET @ysnIsDefault = 0
		END
		ELSE
		BEGIN
			--INSERT Entity record for Vendor
			INSERT [dbo].[tblEMEntity]	([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed],[strContactNumber], [strEntityNo])
			VALUES						(@strName, @strEmail, @strWebsite, @strInternalNotes, @ysnPrint1099, @str1099Name, @str1099Form, @str1099Type, @strFederalTaxId, @dtmW9Signed,'''',  @originVendor)

			SET @EntityId = SCOPE_IDENTITY()			
			SET @ysnIsDefault = 1
		END

		PRINT ''INSERT Entity Contact Record''
		--INSERT ENTITY record for Contact
		IF(@strContactName IS NOT NULL)
		BEGIN
			INSERT [dbo].[tblEMEntity] ([strName], [strWebsite], [strInternalNotes],[strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
			VALUES					 (@strContactName, @strWebsite, @strInternalNotes,'''', @strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)
		END
		ELSE
		BEGIN
		--Use the the vendor name as contact name if no contact is provided
			SET @strContactName = @strName			
			INSERT [dbo].[tblEMEntity] ([strName], [strWebsite], [strInternalNotes],[strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
			VALUES					 (@strContactName, @strWebsite, @strInternalNotes, '''', @strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)
		END

		DECLARE @ContactEntityId INT
		--Create contact record only if there is contact for vendor
		SET @ContactEntityId = SCOPE_IDENTITY()		
		
		DECLARE @EntityContactId INT
		SET @EntityContactId = @ContactEntityId


		INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
		select top 1 @ContactEntityId, @strPhone, intDefaultCountryId FROM tblSMCompanyPreference
		/*INSERT INTO tblEMEntityToContact( intEntityId, intEntityContactId, ysnPortalAccess, ysnDefaultContact)
		VALUES (@EntityId, @ContactEntityId, 0, 1)*/

		--set term default values if null
		IF LEN(@intTermsId) < 0 OR @intTermsId IS NULL
		BEGIN
			(SELECT TOP 1 @intTermsId = intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')
		END

		--insert into tblEMEntityType		
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityType WHERE strType = ''Vendor'' AND intEntityId = @EntityId)
		BEGIN
			INSERT INTO tblEMEntityType ( intEntityId, strType, intConcurrencyId)
			VALUES (@EntityId, ''Vendor'', 0)
		END
		
		--insert into tblEMEntityLocation if no duplicate
		BEGIN
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityLocation WHERE intEntityId = @EntityId and strLocationName = @strLocationName)
		BEGIN
			INSERT [dbo].[tblEMEntityLocation]	([intEntityId], [strLocationName], [strCheckPayeeName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strNotes],  [intShipViaId], [intTermsId], [intWarehouseId], [ysnDefaultLocation])
			VALUES								(@EntityId, @strLocationName, @strLocationName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strLocationNotes,  @intLocationShipViaId, @intTermsId, @intWarehouseId, @ysnIsDefault)
		END

		DECLARE @EntityLocationId INT
		SET @EntityLocationId = SCOPE_IDENTITY()

		IF ISNULL(@ysnPymtCtrlEFTActive, 0) = 1
		BEGIN
			SET @ysnPymtCtrlActive = 1
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPVendor WHERE intEntityId = @EntityId)
		BEGIN
			INSERT [dbo].[tblAPVendor]	([intEntityId], [intDefaultLocationId], [intDefaultContactId], [intCurrencyId], [strVendorPayToId], [intPaymentMethodId], [intTaxCodeId], [intGLAccountExpenseId], [intVendorType], [strVendorId], [strVendorAccountNum], [ysnPymtCtrlActive], [ysnPymtCtrlAlwaysDiscount], [ysnPymtCtrlEFTActive], [ysnPymtCtrlHold], [ysnWithholding], [intCreatedUserId], [intLastModifiedUserId], [dtmLastModified], [dblCreditLimit], [dtmCreated], [strTaxState], [intBillToId], [intShipFromId], [intTermsId])
			VALUES						(@EntityId, @EntityLocationId, @EntityContactId, @intCurrencyId, @strVendorPayToId, @intPaymentMethodId, @intVendorTaxCodeId, @intGLAccountExpenseId, @intVendorType, @originVendor, @strVendorAccountNum, @ysnPymtCtrlActive, ISNULL(@ysnPymtCtrlAlwaysDiscount,0), ISNULL(@ysnPymtCtrlEFTActive,0), @ysnPymtCtrlHold, @ysnWithholding, @intCreatedUserId, @intLastModifiedUserId, @dtmLastModified, @dblCreditLimit, @dtmCreated, @strTaxState, @EntityLocationId, @EntityLocationId, @intTermsId)
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPVendorTerm WHERE intEntityVendorId = @EntityId AND intTermId = @intTermsId)
		BEGIN
			INSERT INTO dbo.tblAPVendorTerm(intEntityVendorId, intTermId)
			VALUES(@EntityId, @intTermsId)
		END


		DECLARE @VendorIdentityId INT
		SET @VendorIdentityId = SCOPE_IDENTITY()		
		
		INSERT [dbo].[tblEMEntityToContact] ([intEntityId], [intEntityContactId], [intEntityLocationId],[ysnPortalAccess], ysnDefaultContact)
		VALUES							  (@EntityId, @EntityContactId, @EntityLocationId, 0, @ysnIsDefault)/**/

		INSERT INTO [dbo].[tblAPImportedVendors]
			VALUES(@originVendor, 1)
		


		INSERT [dbo].[tblEMEntityLocation]    
		([intEntityId], 
		 [strLocationName], 
		 [strCheckPayeeName],
		 [strAddress], 
		 [strCity], 
		 [strCountry], 
		 [strState], 
		 [strZipCode], 
		 [strNotes],  
		 [intShipViaId], 
		 [intTermsId], 
		 [intWarehouseId], 
		 [ysnDefaultLocation])
		select 				
					--ssvnd_pay_to,
					@EntityId, 
					RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'''')) + ''_'' + CAST(A4GLIdentity AS NVARCHAR),
					RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'''')) + ''_'' + CAST(A4GLIdentity AS NVARCHAR),
					dbo.fnTrim(ISNULL(ssvnd_addr_1,'''')) + CHAR(10) + dbo.fnTrim(ISNULL(ssvnd_addr_2,'''')),
					ssvnd_city,
					''United States'',
					ssvnd_st,
					dbo.fnTrim(ssvnd_zip),
					NULL,
					NULL,
					CASE WHEN ssvnd_terms_disc_pct = 0 AND ssvnd_terms_due_day = 0
							   AND ssvnd_terms_disc_day = 0 AND ssvnd_terms_cutoff_day = 0 THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'')
							   WHEN ssvnd_terms_type = ''D'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
															WHERE dblDiscountEP = ssvnd_terms_disc_pct
															AND intBalanceDue = ssvnd_terms_due_day
															AND intDiscountDay = ssvnd_terms_disc_day)
											WHEN ssvnd_terms_type = ''P'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
															WHERE intBalanceDue = ssvnd_terms_due_day
															AND intDiscountDay = ssvnd_terms_disc_day
															AND intDayofMonthDue = ssvnd_terms_cutoff_day)
											ELSE (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'') END,
					NULL,
					0
	 from ssvndmst  where ssvnd_pay_to is not null and ssvnd_vnd_no <> ssvnd_pay_to and rtrim(ltrim(ssvnd_pay_to)) = @originVendor
	 	 	 
	 --INSERT Vendor Location to Origin Pay to Vendor		
		INSERT [dbo].[tblEMEntityLocation]    
		([intEntityId], 
		 [strLocationName], 
		 [strCheckPayeeName],
		 [strAddress], 
		 [strCity], 
		 [strCountry], 
		 [strState], 
		 [strZipCode], 
		 [strNotes],  
		 [intShipViaId], 
		 [intTermsId], 
		 [intWarehouseId], 
		 [ysnDefaultLocation])
		select 				
					ENT.intEntityId, 
					SUBSTRING ( 
						RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'''')) + ''_'' + SUBSTRING(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY,CURRENT_TIMESTAMP), 1) ,11,8)
					, 0 , 100),
					SUBSTRING ( 
						RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'''')) + ''_'' + SUBSTRING(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY,CURRENT_TIMESTAMP), 1) ,11,8)
					, 0 , 100),			
								--+ CAST(A4GLIdentity AS NVARCHAR),
					dbo.fnTrim(ISNULL(ssvnd_addr_1,'''')) + CHAR(10) + dbo.fnTrim(ISNULL(ssvnd_addr_2,'''')),
					ssvnd_city,
					''United States'',
					ssvnd_st,
					dbo.fnTrim(ssvnd_zip),
					NULL,
					NULL,
					CASE WHEN ssvnd_terms_disc_pct = 0 AND ssvnd_terms_due_day = 0
							   AND ssvnd_terms_disc_day = 0 AND ssvnd_terms_cutoff_day = 0 THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'')
							   WHEN ssvnd_terms_type = ''D'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
															WHERE dblDiscountEP = ssvnd_terms_disc_pct
															AND intBalanceDue = ssvnd_terms_due_day
															AND intDiscountDay = ssvnd_terms_disc_day)
											WHEN ssvnd_terms_type = ''P'' THEN (SELECT TOP 1 intTermID FROM tblSMTerm
															WHERE intBalanceDue = ssvnd_terms_due_day
															AND intDiscountDay = ssvnd_terms_disc_day
															AND intDayofMonthDue = ssvnd_terms_cutoff_day)
											ELSE (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm= ''Due on Receipt'') END,
					NULL,
					0
	 from ssvndmst  
	 inner join tblEMEntity ENT on ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
	 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
	 where ssvnd_vnd_no = @originVendor and ssvnd_pay_to is not null and ssvnd_vnd_no <> ssvnd_pay_to AND ETYP.strType = ''Vendor''
	 END 
	 -- Enable ysnTransportTerminal for the Vendors with Transport Terminal
	 
	 
	 IF EXISTS(select top 1 strId from @compare_table INNER JOIN ssvndmst on ssvnd_vnd_no = strId where strId = @originVendor)
	 BEGIN
		UPDATE tblAPVendor set ysnTransportTerminal = 1 where strVendorId = @originVendor
	 END

	  --UPDATE  VND SET VND.ysnTransportTerminal = 1 FROM tblAPVendor VND INNER JOIN tblEMEntity ENT ON ENT.intEntityId = VND.intEntityVendorId
   --   WHERE ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT DISTINCT ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS from trhstmst
	  --INNER JOIN ssvndmst on ssvnd_vnd_no = trhst_pur_vnd_no)
	  
	  --UPDATE  VND SET VND.ysnTransportTerminal = 1 FROM tblAPVendor VND INNER JOIN tblEMEntity ENT ON ENT.intEntityId = VND.intEntityVendorId
	  --WHERE ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT DISTINCT ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS from trvprmst
	  --INNER JOIN ssvndmst on ssvnd_vnd_no = trvpr_vnd_no)

	  --UPDATE  VND SET VND.ysnTransportTerminal = 1 FROM tblAPVendor VND INNER JOIN tblEMEntity ENT ON ENT.intEntityId = VND.intEntityVendorId
	  --WHERE ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS IN (SELECT DISTINCT ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS from trprcmst
	  --INNER JOIN ssvndmst on ssvnd_vnd_no = trprc_vnd_no)

		EXEC uspAPImportVendorContact @originVendor

		IF(@@ERROR <> 0) 
		BEGIN
			PRINT @@ERROR;
			RETURN;
		END

		END

		DELETE FROM #tmpssvndmst WHERE ssvnd_vnd_no = @originVendor

	END
	
SET @Total = @@ROWCOUNT

END
')
END
