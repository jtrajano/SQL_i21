CREATE PROCEDURE uspImportVendor
	@VendorId NVARCHAR(50) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

AS

IF(@Update = 1 AND @VendorId IS NOT NULL)
BEGIN

	UPDATE ssvndmst
		SET ssvnd_co_per_ind = CASE WHEN B.intVendorType = 0 THEN 'P' ELSE 'C' END,
		ssvnd_name = A.strName,
		ssvnd_addr_1 = CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE C.strAddress END,
		ssvnd_addr_2 = CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress), LEN(C.strAddress)) ELSE NULL END,
		ssvnd_city = C.strCity,
		ssvnd_st = C.strState,
		ssvnd_zip = C.strZipCode,
		ssvnd_phone = ISNULL(D.strPhone, ''),
		ssvnd_phone2 = D.strPhone2,
		ssvnd_contact = D.strName,
		ssvnd_1099_yn = CASE WHEN B.ysnPrint1099 = 0 THEN 'N' ELSE 'Y' END,
		ssvnd_wthhld_yn = CASE WHEN B.ysnWithholding = 0 THEN 'N' ELSE 'Y' END,
		ssvnd_pay_ctl_ind = (CASE WHEN ysnPymtCtrlActive = 1 THEN 'A'
			 WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN 'D'
			 WHEN ysnPymtCtrlEFTActive = 1  THEN 'E'
			 WHEN ysnPymtCtrlHold = 1 THEN 'H' END),
		ssvnd_fed_tax_id = B.strFederalTaxId,
		--ssvnd_w9_signed_rev_dt = CASE WHEN ysnW9Signed = 0 THEN 'N' ELSE 'Y' END,
		ssvnd_pay_to = strVendorPayToId,
		ssvnd_currency = E.strCurrency,
		ssvnd_1099_name = str1099Name,
		ssvnd_gl_pur = F.strExternalID
	FROM
		tblEntities A
	INNER JOIN tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblEntityLocations C
		ON B.intEntityLocationId = C.intEntityLocationId
	INNER JOIN tblEntityContacts D
		ON B.intEntityContactId = D.intEntityContactId
	LEFT JOIN tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN tblGLCOACrossReference F
		ON B.intGLAccountExpenseId = F.inti21ID
	WHERE ssvndmst.ssvnd_vnd_no = @VendorId

RETURN;
END

IF(@Update = 0 AND @VendorId IS NOT NULL) -- INSERT per vendor id
BEGIN
--ssvnd_addr_2, ssvnd_phone_ext, ssvnd_phone2_ext,ssvnd_gl_pur,ssvnd_pay_ctl_ind,ssvnd_prev_ctl_ind
--ssvnd_acct_stat
--ssvnd_terms_type
--ssvnd_terms_desc
--ssvnd_our_cus_no
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
		ssvnd_gl_pur
	)
	SELECT 
		strVendorId,
		CASE WHEN intVendorType = 0 THEN 'C' ELSE 'P' END,
		A.strName,
		CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, 0, CHARINDEX(CHAR(10),C.strAddress)) ELSE C.strAddress END,
		CASE WHEN CHARINDEX(CHAR(10), C.strAddress) > 0 THEN SUBSTRING(C.strAddress, CHARINDEX(CHAR(10),C.strAddress), LEN(C.strAddress)) ELSE NULL END,
		strCity,
		strState,
		strZipCode,
		ISNULL(strPhone,''),
		strPhone2,
		D.strName,
		CASE WHEN ysnPrint1099 = 0 THEN 'N' ELSE 'Y' END,
		CASE WHEN ysnWithholding = 0 THEN 'N' ELSE 'Y' END,
		CASE WHEN ysnPymtCtrlActive = 1 THEN 'A'
			 WHEN ysnPymtCtrlAlwaysDiscount = 1 THEN 'D'
			 WHEN ysnPymtCtrlEFTActive = 1  THEN 'E'
			 WHEN ysnPymtCtrlHold = 1 THEN 'H' END,
		strFederalTaxId,
		CONVERT(VARCHAR(8), GETDATE(), 112),
		strVendorPayToId,
		E.strCurrency,
		str1099Name,
		F.strExternalID
	FROM
		tblEntities A
	INNER JOIN tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblEntityLocations C		
		ON B.intEntityLocationId = C.intEntityLocationId
	INNER JOIN tblEntityContacts D
		ON B.intEntityContactId = D.intEntityContactId
	LEFT JOIN tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN tblGLCOACrossReference F
		ON B.intGLAccountExpenseId = F.inti21ID
	WHERE strVendorId = @VendorId
	RETURN;
END

IF(@Update = 0 AND @VendorId IS NULL)
BEGIN
	
	--1 Time synchronization here
	PRINT '1 Time Vendor Synchronization'

	DECLARE @originVendor NVARCHAR(50)

	--Entities
	DECLARE @strName          NVARCHAR (MAX)
	DECLARE	@strWebsite       NVARCHAR (MAX)
	DECLARE	@strInternalNotes NVARCHAR (MAX)

	--Contacts
	DECLARE	@strContactName     NVARCHAR (50)  
	DECLARE	@strTitle           NVARCHAR (MAX) 
	DECLARE	@strContactLocationName    NVARCHAR (MAX) 
	DECLARE	@strDepartment      NVARCHAR (MAX) 
	DECLARE	@strMobile          NVARCHAR (MAX) 
	DECLARE	@strPhone           NVARCHAR (MAX) 
	DECLARE	@strPhone2          NVARCHAR (MAX) 
	DECLARE	@strEmail           NVARCHAR (MAX) 
	DECLARE	@strEmail2          NVARCHAR (MAX) 
	DECLARE	@strFax             NVARCHAR (MAX) 
	DECLARE	@strNotes           NVARCHAR (MAX) 

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
    DECLARE @strFederalTaxId           NVARCHAR (MAX) 
    DECLARE @intVendorTermsId                NVARCHAR (MAX) 
    DECLARE @intVendorType             INT            
    DECLARE @strVendorId               NVARCHAR (50)  
    DECLARE @strVendorAccountNum       NVARCHAR (15)  
    DECLARE @str1099Name               NVARCHAR (100) 
    DECLARE @str1099Type               NVARCHAR (20)  
    DECLARE @str1099Category           NVARCHAR (100) 
    DECLARE @ysnPymtCtrlActive         BIT            
    DECLARE @ysnPymtCtrlAlwaysDiscount BIT            
    DECLARE @ysnPymtCtrlEFTActive      BIT            
    DECLARE @ysnPymtCtrlHold           BIT            
    DECLARE @ysnPrint1099              BIT            
    DECLARE @ysnWithholding            BIT            
    DECLARE @ysnW9Signed               BIT            
    DECLARE @dblCreditLimit            FLOAT (53)     
    DECLARE @intCreatedUserId          INT            
    DECLARE @intLastModifiedUserId     INT            
    DECLARE @dtmLastModified           DATETIME       
    DECLARE @dtmCreated                DATETIME       
    DECLARE @strTaxState				NVARCHAR(50) 

	SELECT ssvnd_vnd_no INTO #tmpssvndmst FROM ssvndmst

	WHILE (EXISTS(SELECT 1 FROM #tmpssvndmst))
	BEGIN
		
		SELECT @originVendor = ssvnd_vnd_no FROM #tmpssvndmst

		SELECT TOP 1
			--Entities
			@strName = ssvnd_name,
			@strWebsite = '',
			@strInternalNotes = '',

			--Contacts
			@strContactName = CASE WHEN ISNULL(NULLIF(ssvnd_contact, ''),'') = '' THEN @strName ELSE ssvnd_contact END, --USE Vendor name when no contact
			@strContactLocationName = @strContactName,
			@strDepartment = NULL,
			@strMobile     = NULL,
			@strPhone      = ISNULL(ssvnd_phone,'') + ' ' + ISNULL(ssvnd_phone_ext,''),
			@strPhone2     = NULL,
			@strEmail      = NULL,
			@strEmail2     = NULL,
			@strFax        = NULL,
			@strNotes      = NULL,

			--Locations
			@strLocationName = @strContactName,
			@strContactName  = @strContactName,
			@strAddress      = ISNULL(ssvnd_addr_1,'') + CHAR(10) + ISNULL(ssvnd_addr_2,''),
			@strCity         = ssvnd_city,
			@strCountry      = (SELECT TOP 1 strCountry FROM tblSMZipCode WHERE strState COLLATE Latin1_General_CI_AS = ssvnd_st COLLATE Latin1_General_CI_AS),
			@strState        = ssvnd_st,
			@strZipCode      = SUBSTRING(ssvnd_zip, 0, 5),
			@strLocationEmail        = NULL,
			@strLocationNotes        = NULL,
			@strW9Name       = NULL,
			@intLocationShipViaId    = NULL,
			@intTaxCodeId    = NULL,
			@intTermsId      = NULL,
			@intWarehouseId  = NULL,
			
			--Vendors
			@intVendorType				= CASE WHEN ssvnd_co_per_ind = 'C' THEN 0 ELSE 1 END,
			@originVendor				= ssvnd_vnd_no,
			@intCurrencyId				= (SELECT TOP 1 intConcurrencyID FROM tblSMCurrency WHERE strCurrency COLLATE Latin1_General_CI_AS = ssvnd_currency COLLATE Latin1_General_CI_AS),
			@strVendorPayToId         	= ssvnd_pay_to,
			@intPaymentMethodId       	= NULL,
			@intShipViaId             	= NULL,
			@intVendorTaxCodeId     	= NULL,
			@intGLAccountExpenseId    	= (SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = CONVERT(NVARCHAR(50),ssvnd_gl_pur)),
			@strFederalTaxId          	= ssvnd_fed_tax_id,
			@intTermsId               	= NULL,
			@strVendorAccountNum      	= NULL,
			@str1099Name              	= ssvnd_1099_name,
			@str1099Type              	= NULL,
			@str1099Category          	= NULL,
			@ysnPymtCtrlActive        	= CASE WHEN ssvnd_pay_ctl_ind = 'A' THEN 1 ELSE 0 END,
			@ysnPymtCtrlAlwaysDiscount	= CASE WHEN ssvnd_pay_ctl_ind = 'D' THEN 1 ELSE 0 END,
			@ysnPymtCtrlEFTActive     	= CASE WHEN ssvnd_pay_ctl_ind = 'E' THEN 1 ELSE 0 END,
			@ysnPymtCtrlHold          	= CASE WHEN ssvnd_pay_ctl_ind = 'H' THEN 1 ELSE 0 END,
			@ysnPrint1099             	= CASE WHEN ssvnd_1099_yn = 'Y' THEN 1 ELSE 0 END,
			@ysnWithholding           	= CASE WHEN ssvnd_wthhld_yn = 'N' THEN 0 ELSE 1 END,
			@ysnW9Signed              	= ssvnd_w9_signed_rev_dt,
			@dblCreditLimit           	= ISNULL(ssvnd_future_bal,0),
			@intCreatedUserId         	= NULL,
			@intLastModifiedUserId    	= NULL,
			@dtmLastModified          	= NULL,
			@dtmCreated               	= NULL,
			@strTaxState				= ssvnd_tax_st
		FROM ssvndmst
		WHERE ssvnd_vnd_no = @originVendor
			--INNER JOIN tblSMZipCode ON #tmpssvndmst.ssvnd_st COLLATE Latin1_General_CI_AS = tblSMZipCode.strState COLLATE Latin1_General_CI_AS
			--INNER JOIN tblSMCurrency ON #tmpssvndmst.ssvnd_currency COLLATE Latin1_General_CI_AS = tblSMCurrency.strCurrency COLLATE Latin1_General_CI_AS
			--INNER JOIN tblGLCOACrossReference ON CONVERT(NVARCHAR(50),#tmpssvndmst.ssvnd_gl_pur) = tblGLCOACrossReference.strExternalID

		
		INSERT [dbo].[tblEntities]	([strName], [strWebsite], [strInternalNotes])
		VALUES						(@strName, @strWebsite, @strInternalNotes)

		DECLARE @EntityId INT
		SET @EntityId = SCOPE_IDENTITY()
		
		INSERT [dbo].[tblEntityContacts] ([intEntityId], [strName], [strTitle], [strLocationName], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail], [strEmail2], [strFax], [strNotes])
		VALUES							 (@EntityId, @strContactName, @strTitle, @strContactLocationName, @strDepartment, @strMobile, @strPhone, @strPhone2, @strEmail, @strEmail2, @strFax, @strNotes)

		DECLARE @EntityContactId INT
		SET @EntityContactId = SCOPE_IDENTITY()

		INSERT [dbo].[tblEntityLocations]	([intEntityId], [strLocationName], [strContactName], [strAddress], [strCity], [strCountry], [strState], [strZipCode], [strEmail], [strNotes], [strW9Name], [intShipViaId], [intTaxCodeId], [intTermsId], [intWarehouseId])
		VALUES								(@EntityId, @strLocationName, @strContactName, @strAddress, @strCity, @strCountry, @strState, @strZipCode, @strEmail, @strLocationNotes, @strW9Name, @intLocationShipViaId, @intTaxCodeId, @intTermsId, @intWarehouseId)

		DECLARE @EntityLocationId INT
		SET @EntityLocationId = SCOPE_IDENTITY()

		INSERT [dbo].[tblAPVendor]	([intEntityId], [intEntityLocationId], [intEntityContactId], [intCurrencyId], [strVendorPayToId], [intPaymentMethodId], [intShipViaId], [intTaxCodeId], [intGLAccountExpenseId], [strFederalTaxId], [intTermsId], [intVendorType], [strVendorId], [strVendorAccountNum], [str1099Name], [str1099Type], [str1099Category], [ysnPymtCtrlActive], [ysnPymtCtrlAlwaysDiscount], [ysnPymtCtrlEFTActive], [ysnPymtCtrlHold], [ysnPrint1099], [ysnWithholding], [ysnW9Signed], [dblCreditLimit], [intCreatedUserId], [intLastModifiedUserId], [dtmLastModified], [dtmCreated], [strTaxState])
		VALUES						(@EntityId, @EntityLocationId, @EntityContactId, @intCurrencyId, @strVendorPayToId, ISNULL(@intPaymentMethodId,0), @intShipViaId, @intVendorTaxCodeId, @intGLAccountExpenseId, @strFederalTaxId, @intVendorTermsId, @intVendorType, @originVendor, @strVendorAccountNum, @str1099Name, @str1099Type, @str1099Category, @ysnPymtCtrlActive, ISNULL(@ysnPymtCtrlAlwaysDiscount,0), ISNULL(@ysnPymtCtrlEFTActive,0), @ysnPymtCtrlHold, @ysnPrint1099, @ysnWithholding, @ysnW9Signed, @dblCreditLimit, @intCreatedUserId, @intLastModifiedUserId, @dtmLastModified, @dtmCreated, @strTaxState)

		IF(@@ERROR <> 0) 
		BEGIN
			PRINT @@ERROR;
			RETURN;
		END

		PRINT @originVendor
		DELETE FROM #tmpssvndmst WHERE ssvnd_vnd_no = @originVendor

	END
	
SET @Total = @@ROWCOUNT

END
