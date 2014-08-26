GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportVendor')
	DROP PROCEDURE uspAPImportVendor
GO


IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
CREATE PROCEDURE [dbo].[uspAPImportVendor]
	@VendorId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

AS

IF(@Update = 1 AND @VendorId IS NOT NULL)
BEGIN

	IF(EXISTS(SELECT 1 FROM ssvndmst WHERE ssvnd_vnd_no = @VendorId))
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
		ssvnd_st						=	CAST(strState AS VARCHAR(2)),
		ssvnd_zip						=	CAST(strZipCode AS VARCHAR(10)),
		ssvnd_phone						=	CAST(ISNULL(D.strPhone,'''') AS VARCHAR(15)),
		ssvnd_phone2					=	CAST(ISNULL(A.strName,'''') AS VARCHAR(15)),
		ssvnd_contact					=	CAST(A.strName AS VARCHAR(15)),
		ssvnd_1099_yn					=	CASE WHEN ysnPrint1099 = 0 THEN ''N'' ELSE ''Y'' END,
		ssvnd_wthhld_yn					=	CASE WHEN ysnWithholding = 0 THEN ''N'' ELSE ''Y'' END,
		ssvnd_pay_ctl_ind				=	CASE WHEN ysnPymtCtrlActive = 1 THEN ''A''
												WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN ''D''
												WHEN ysnPymtCtrlEFTActive = 1  THEN ''E''
												WHEN ysnPymtCtrlHold = 1 THEN ''H'' END,
		ssvnd_fed_tax_id				=	CAST(strFederalTaxId AS VARCHAR(20)),
		ssvnd_w9_signed_rev_dt			=	CONVERT(VARCHAR(8), GETDATE(), 112),
		ssvnd_pay_to					=	CAST(strVendorPayToId AS VARCHAR(10)),

		ssvnd_1099_name					=	CAST(str1099Name AS VARCHAR(50)),
		ssvnd_gl_pur					=	CAST(F.strExternalId AS DECIMAL(16,8)),
		ssvnd_tax_st					=	CAST(B.strTaxState AS VARCHAR(2))
		FROM ssvndmst 
		INNER JOIN tblAPVendor B
			ON ssvndmst.ssvnd_vnd_no COLLATE Latin1_General_CI_AS = B.strVendorId COLLATE Latin1_General_CI_AS
		INNER JOIN tblEntity A
			ON A.intEntityId = B.intEntityId
		INNER JOIN tblEntityLocation C
			ON B.intDefaultLocationId = C.intEntityLocationId
		INNER JOIN tblEntityContact D
			ON B.intDefaultContactId = D.intContactId
		LEFT JOIN tblSMCurrency E
			ON B.intCurrencyId = E.intCurrencyID
		LEFT JOIN tblGLCOACrossReference F
			ON B.intGLAccountExpenseId = F.inti21Id
		WHERE ssvndmst.ssvnd_vnd_no = @VendorId
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
		ssvnd_tax_st
		)
		SELECT 
			ssvnd_vnd_no					=	B.strVendorId,
			ssvnd_co_per_ind				=	CASE WHEN B.intVendorType = 0 THEN ''C'' ELSE ''P'' END,
			ssvnd_name						=	A.strName,
			ssvnd_addr_1					=	CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE C.strAddress END,
			ssvnd_addr_2					=	CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress), LEN(C.strAddress)) ELSE NULL END,
			ssvnd_city						=	strCity,
			ssvnd_st						=	strState,
			ssvnd_zip						=	strZipCode,
			ssvnd_phone						=	ISNULL(D.strPhone,''''),
			ssvnd_phone2					=	D.strPhone2,
			ssvnd_contact					=	A.strName,
			ssvnd_1099_yn					=	CASE WHEN ysnPrint1099 = 0 THEN ''N'' ELSE ''Y'' END,
			ssvnd_wthhld_yn					=	CASE WHEN ysnWithholding = 0 THEN ''N'' ELSE ''Y'' END,
			ssvnd_pay_ctl_ind				=	CASE WHEN ysnPymtCtrlActive = 1 THEN ''A''
												 WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN ''D''
												 WHEN ysnPymtCtrlEFTActive = 1  THEN ''E''
												 WHEN ysnPymtCtrlHold = 1 THEN ''H'' END,
			ssvnd_fed_tax_id				=	strFederalTaxId,
			ssvnd_w9_signed_rev_dt			=	CONVERT(VARCHAR(8), GETDATE(), 112),
			ssvnd_pay_to					=	strVendorPayToId,
			ssvnd_currency					=	E.strCurrency,
			ssvnd_1099_name					=	str1099Name,
			ssvnd_gl_pur					=	F.strExternalId,
			ssvnd_tax_st					=	B.strTaxState
		FROM
			tblEntity A
		INNER JOIN tblAPVendor B
			ON A.intEntityId = B.intEntityId
		INNER JOIN tblEntityLocation C		
			ON B.intDefaultLocationId = C.intEntityLocationId
		INNER JOIN tblEntityContact D
			ON B.intDefaultContactId = D.intContactId
		LEFT JOIN tblSMCurrency E
			ON B.intCurrencyId = E.intCurrencyID
		LEFT JOIN tblGLCOACrossReference F
			ON B.intGLAccountExpenseId = F.inti21Id
		WHERE strVendorId = @VendorId

		--Insert new record to tblAPImportedVendors
		INSERT INTO tblAPImportedVendors
		SELECT @VendorId
	END

RETURN;
END

IF(@Update = 0 AND @VendorId IS NULL)
BEGIN
	
	--1 Time synchronization here
	PRINT ''1 Time Vendor Synchronization''

	--Make a copy of all imported vendor
	
	EXEC(''
	INSERT INTO tblAPImportedVendors
	SELECT ssvnd_vnd_no FROM ssvndmst A
	LEFT JOIN tblAPImportedVendors B
	ON A.ssvnd_vnd_no COLLATE Latin1_General_CI_AS = B.strVendorId COLLATE Latin1_General_CI_AS AND B.strVendorId IS NULL

	INSERT INTO tblAPImportedVendors
	SELECT DISTINCT A.apchk_vnd_no
	FROM apchkmst A
	LEFT JOIN tblAPImportedVendors B
	ON A.apchk_vnd_no COLLATE Latin1_General_CI_AS = B.strVendorId COLLATE Latin1_General_CI_AS AND B.strVendorId IS NULL
		WHERE A.apchk_vnd_no IN (
		SELECT
		DISTINCT B.apivc_vnd_no
		FROM apivcmst B
		WHERE B.apivc_vnd_no NOT IN (SELECT ssvnd_vnd_no FROM ssvndmst)
	)
	'')

	DECLARE @originVendor NVARCHAR(50)

	--Entities
	DECLARE @strName			NVARCHAR (MAX)
	DECLARE	@strWebsite			NVARCHAR (MAX)
	DECLARE	@strInternalNotes	NVARCHAR (MAX)
	DECLARE @str1099Name        NVARCHAR (100) 
	DECLARE @ysnPrint1099       BIT     
	DECLARE @dtmW9Signed		DATETIME
	DECLARE	@str1099Form        NVARCHAR (MAX) 
	DECLARE @strFederalTaxId    NVARCHAR (MAX) 

	--Contacts
	DECLARE	@strTitle           NVARCHAR (MAX) 
	DECLARE	@strContactName     NVARCHAR (MAX) 
	DECLARE	@strDepartment      NVARCHAR (MAX) 
	DECLARE	@strMobile          NVARCHAR (MAX) 
	DECLARE	@strPhone           NVARCHAR (MAX) 
	DECLARE	@strPhone2          NVARCHAR (MAX) 
	DECLARE	@strEmail           NVARCHAR (MAX) 
	DECLARE	@strEmail2          NVARCHAR (MAX) 
	DECLARE	@strFax             NVARCHAR (MAX) 
	DECLARE	@strNotes           NVARCHAR (MAX) 
	DECLARE	@strContactMethod   NVARCHAR (MAX) 
	DECLARE	@strPassword        NVARCHAR (MAX) 
	DECLARE	@strUserType        NVARCHAR (MAX) 
	DECLARE	@strTimezone        NVARCHAR (MAX) 
	DECLARE @ysnPortalAccess	BIT
	DECLARE @imgContactPhoto	varbinary(MAX)

	--Locations
	DECLARE	@strLocationName     NVARCHAR (50) 
	DECLARE	@strLocationContactName      NVARCHAR (MAX)
	DECLARE	@strAddress          NVARCHAR (MAX)
	DECLARE	@strCity             NVARCHAR (MAX)
	DECLARE	@strCountry          NVARCHAR (MAX)
	DECLARE	@strState            NVARCHAR (MAX)
	DECLARE	@strZipCode          NVARCHAR (MAX)
	DECLARE	@strLocationEmail            NVARCHAR (MAX)
	DECLARE	@strLocationNotes            NVARCHAR (MAX)
	DECLARE	@strW9Name           NVARCHAR (MAX)
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
    DECLARE @intVendorTermsId                NVARCHAR (MAX) 
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
	SELECT ssvnd_vnd_no INTO #tmpssvndmst 
	FROM ssvndmst A
	LEFT JOIN tblAPImportedVendors B
	ON A.ssvnd_vnd_no COLLATE Latin1_General_CI_AS = B.strVendorId COLLATE Latin1_General_CI_AS AND B.strVendorId IS NULL
		

	WHILE (EXISTS(SELECT 1 FROM #tmpssvndmst))
	BEGIN
		
		DECLARE @continue BIT = 0;

		SELECT @originVendor = ssvnd_vnd_no FROM #tmpssvndmst

		IF(EXISTS(SELECT 1 FROM ssvndmst WHERE ssvnd_vnd_no = @originVendor))
		BEGIN

			SET @continue = 1;

            SELECT TOP 1
                --Entities
                @strName = CASE WHEN ssvnd_co_per_ind = ''C'' THEN ssvnd_name
                            ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
                                + '' '' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
                            END,
                @strWebsite = '''',
                @strInternalNotes = '''',
                @ysnPrint1099   = CASE WHEN ssvnd_1099_yn = ''Y'' THEN 1 ELSE 0 END,
                @str1099Name    = ssvnd_1099_name,
                @str1099Form	= '''',
                @str1099Type	= '''',
                @strFederalTaxId	= ssvnd_fed_tax_id,
                @dtmW9Signed	= CASE WHEN ssvnd_w9_signed_rev_dt = 0 THEN NULL ELSE CONVERT(DATE, CAST(ssvnd_w9_signed_rev_dt AS CHAR(12)), 112) END,

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
                @strZipCode      = ssvnd_zip,
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
                @intCurrencyId				= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency COLLATE Latin1_General_CI_AS = ssvnd_currency COLLATE Latin1_General_CI_AS),
                @strVendorPayToId         	= ssvnd_pay_to,
                @intPaymentMethodId       	= NULL,
                @intVendorTaxCodeId     	= NULL,
                @intGLAccountExpenseId    	= (SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CONVERT(NVARCHAR(50),ssvnd_gl_pur)),
                @strVendorAccountNum      	= NULL,
                @ysnPymtCtrlActive        	= CASE WHEN ssvnd_pay_ctl_ind = ''A'' THEN 1 ELSE 0 END,
                @ysnPymtCtrlAlwaysDiscount	= CASE WHEN ssvnd_pay_ctl_ind = ''D'' THEN 1 ELSE 0 END,
                @ysnPymtCtrlEFTActive     	= CASE WHEN ssvnd_pay_ctl_ind = ''E'' THEN 1 ELSE 0 END,
                @ysnPymtCtrlHold          	= CASE WHEN ssvnd_pay_ctl_ind = ''H'' THEN 1 ELSE 0 END,
                @ysnWithholding           	= CASE WHEN ssvnd_wthhld_yn = ''N'' THEN 0 ELSE 1 END,
                @dblCreditLimit           	= ISNULL(ssvnd_future_bal,0),
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
				@strZipCode      = apchk_zip,
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
				@intCurrencyId				= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD''),
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

		--INSERT Entity record for Vendor
		INSERT [dbo].[tblEntity]	([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed])
		VALUES						(@strName, @strEmail, @strWebsite, @strInternalNotes, @ysnPrint1099, @str1099Name, @str1099Form, @str1099Type, @strFederalTaxId, @dtmW9Signed)

		DECLARE @EntityId INT
		SET @EntityId = SCOPE_IDENTITY()

		--INSERT ENTITY record for Contact
		IF(@strContactName IS NOT NULL)
		BEGIN
			INSERT [dbo].[tblEntity] ([strName], [strWebsite], [strInternalNotes])
			VALUES					 (@strContactName, @strWebsite, @strInternalNotes)
		END
		ELSE
		BEGIN
		--Use the the vendor name as contact name if no contact is provided
			SET @strContactName = @strName
			INSERT [dbo].[tblEntity] ([strName], [strWebsite], [strInternalNotes])
			VALUES					 (@strContactName, @strWebsite, @strInternalNotes)
		END

		DECLARE @ContactEntityId INT
		--Create contact record only if there is contact for vendor
		IF(@strContactName IS NOT NULL)
		BEGIN
			SET @ContactEntityId = SCOPE_IDENTITY()
		
			INSERT [dbo].[tblEntityContact] ([intEntityId], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes])
			VALUES							 (@ContactEntityId, @strTitle, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail2, @strFax, @strNotes)

		END
		
		DECLARE @EntityContactId INT
		SET @EntityContactId = SCOPE_IDENTITY()

		INSERT [dbo].[tblEntityLocation]	([intEntityId], [strLocationName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strNotes],  [intShipViaId], [intTaxCodeId], [intTermsId], [intWarehouseId])
		VALUES								(@EntityId, @strLocationName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strLocationNotes,  @intLocationShipViaId, @intTaxCodeId, @intTermsId, @intWarehouseId)

		DECLARE @EntityLocationId INT
		SET @EntityLocationId = SCOPE_IDENTITY()

		INSERT [dbo].[tblAPVendor]	([intEntityId], [intDefaultLocationId], [intDefaultContactId], [intCurrencyId], [strVendorPayToId], [intPaymentMethodId], [intTaxCodeId], [intGLAccountExpenseId], [intVendorType], [strVendorId], [strVendorAccountNum], [ysnPymtCtrlActive], [ysnPymtCtrlAlwaysDiscount], [ysnPymtCtrlEFTActive], [ysnPymtCtrlHold], [ysnWithholding], [dblCreditLimit], [intCreatedUserId], [intLastModifiedUserId], [dtmLastModified], [dtmCreated], [strTaxState])
		VALUES						(@EntityId, @EntityLocationId, @EntityContactId, @intCurrencyId, @strVendorPayToId, ISNULL(@intPaymentMethodId,0), @intVendorTaxCodeId, ISNULL(@intGLAccountExpenseId,0), @intVendorType, @originVendor, @strVendorAccountNum, @ysnPymtCtrlActive, ISNULL(@ysnPymtCtrlAlwaysDiscount,0), ISNULL(@ysnPymtCtrlEFTActive,0), @ysnPymtCtrlHold, @ysnWithholding, @dblCreditLimit, @intCreatedUserId, @intLastModifiedUserId, @dtmLastModified, @dtmCreated, @strTaxState)

		DECLARE @VendorIdentityId INT
		SET @VendorIdentityId = SCOPE_IDENTITY()
		INSERT [dbo].[tblAPVendorToContact] ([intVendorId], [intContactId], [intEntityLocationId])
		VALUES							  (@VendorIdentityId, @EntityContactId, @EntityLocationId)

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
