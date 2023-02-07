CREATE FUNCTION [dbo].[fnAPCreateBillData]
(
	@vendorId INT,
	@userId INT,
	@type INT,
	@termId INT = NULL,
	@currencyId INT = NULL,
	@apAccountId INT = NULL,
	@shipFromId INT = NULL,
	@shipToId INT = NULL,
	@shipFromEntityId INT = NULL
)
RETURNS @returntable TABLE
(
	[intTermsId]			INT             NOT NULL,
    [dtmDate]				DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDueDate]			DATETIME        NOT NULL DEFAULT GETDATE(),
    [intAccountId]			INT             NOT NULL,
    [strReference]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strApprovalNotes]		NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]				DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal]			DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [ysnPosted]				BIT             NOT NULL DEFAULT 0,
    [ysnPaid]				BIT             NOT NULL DEFAULT 0,
    [dblAmountDue]			DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dtmDatePaid]			DATETIME        NULL ,
	[dtmApprovalDate]       DATETIME        NULL ,
    [dtmDiscountDate]		DATETIME        NULL,
    [intUserId]				INT             NULL,
    [intConcurrencyId]		INT NOT NULL DEFAULT 0, 
    [dtmBillDate]			DATETIME NOT NULL DEFAULT GETDATE(), 
    [intEntityId]			INT NOT NULL , 
    [intEntityVendorId]		INT NOT NULL  , 
    [dblWithheld]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTax]				DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPayment]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblInterest]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intTransactionType]	INT NOT NULL DEFAULT 0, 
    [intPurchaseOrderId]	INT NULL, 
	[strPONumber]			NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAttention]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAddress]		NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCity]			NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToState]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToZipCode]		NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCountry]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToPhone]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAttention]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAddress]	NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCity]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromState]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromZipCode]	NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCountry]	NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromPhone]		NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
    [intShipFromId]			INT NULL , 
	[intShipFromEntityId]	INT NOT NULL,
	[intPayToAddressId]		INT NULL , 
	[intShipToId]			INT NULL , 
	[intShipViaId]			INT NULL , 
    [intStoreLocationId]	INT NULL , 
    [intContactId]			INT NULL , 
    [intOrderById]			INT NULL , 
    [intCurrencyId]			INT NOT NULL,
	[intSubCurrencyCents]	INT NOT NULL DEFAULT 1,
	[ysnApproved]			BIT NOT NULL DEFAULT 0,
	[ysnForApproval]		BIT NOT NULL DEFAULT 0,
    [ysnOrigin]				BIT NOT NULL DEFAULT 0,
	[ysnDeleted]			BIT NULL DEFAULT 0 ,
	[dtmDateDeleted]		DATETIME NULL,
    [dtmDateCreated]		DATETIME NULL DEFAULT GETDATE(),
	[intPayFromBankAccountId]		INT NULL,
	[strFinancingSourcedFrom] 		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intPayToBankAccountId]			INT NULL
)
AS
BEGIN

	DECLARE @currentDate DATETIME = GETDATE()
	DECLARE @userLocation INT;
	DECLARE @term INT;
	DECLARE @shipFrom INT;
	DECLARE @shipTo INT;
	DECLARE @apAccount INT;
	DECLARE @billRecordNumber NVARCHAR(50);
	DECLARE @contact INT;
	DECLARE @currency INT;
	DECLARE @vendorCurrency INT;
	DECLARE @shipVia INT;
	DECLARE @subCurrencyCents INT;
	DECLARE @payto INT;
	
	DECLARE @shipFromAddress NVARCHAR(200)
	DECLARE @shipFromCity NVARCHAR(50)
	DECLARE @shipFromState NVARCHAR(50)
	DECLARE @shipFromZipCode NVARCHAR(12)
	DECLARE @shipFromCountry NVARCHAR(25)
	DECLARE @shipFromPhone NVARCHAR(25)
	DECLARE @shipFromAttention NVARCHAR(200)

	DECLARE @shipToAddress NVARCHAR(200)
	DECLARE @shipToCity NVARCHAR(50)
	DECLARE @shipToState NVARCHAR(50)
	DECLARE @shipToZipCode NVARCHAR(12)
	DECLARE @shipToCountry NVARCHAR(25)
	DECLARE @shipToPhone NVARCHAR(25)
	DECLARE @shipToAttention NVARCHAR(200)

	DECLARE @payFromBankAccount INT;
	DECLARE @financingSourcedFrom NVARCHAR(50);
	DECLARE @payToBankAccountId INT;

	IF ISNULL(@userId, 0) > 0
	SELECT TOP 1 
		@shipTo = (CASE WHEN ISNULL(@shipToId,0) > 0 THEN @shipToId ELSE intCompanyLocationId END)
	FROM tblSMUserSecurity WHERE [intEntityId] = @userId

	IF ISNULL(@shipFromEntityId, 0) > 0
	SELECT TOP 1
		@shipFromId = (CASE WHEN ISNULL(@shipFromEntityId,0) != @vendorId AND @shipFromId IS NULL THEN A.intEntityLocationId ELSE @shipFromId END)
	FROM [tblEMEntityLocation] A
	WHERE A.ysnDefaultLocation = 1 AND A.intEntityId = @shipFromEntityId

	SELECT TOP 1
		@term = ISNULL((CASE WHEN ISNULL(@termId,0) > 0 THEN @termId ELSE ISNULL(CASE WHEN ISNULL(@shipFromId,0) > 0 THEN B2.intTermsId ELSE ISNULL(B.intTermsId,A.intTermsId) END, ISNULL(B.intTermsId,A.intTermsId)) END),
						(SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm like '%due on receipt%')),
		@contact = C.intEntityContactId,
		@shipFrom =  ISNULL(@shipFromId, B.intEntityLocationId),
		@payto = CASE WHEN A.intBillToId > 0 THEN A.intBillToId ELSE B.intEntityLocationId END,
		@shipVia = B.intShipViaId,
		@shipFromAddress = B.strAddress,
		@shipFromCity = B.strCity,
		@shipFromCountry = B.strCountry,
		@shipFromCity = B.strCity,
		@shipFromPhone = B.strPhone,
		@shipFromState = B.strState,
		@shipFromZipCode = B.strZipCode,
		@vendorCurrency	= A.intCurrencyId
	FROM tblAPVendor A
	LEFT JOIN [tblEMEntityLocation] B ON A.[intEntityId] = B.intEntityId AND B.ysnDefaultLocation = 1
	LEFT JOIN [tblEMEntityLocation] B2 ON B2.intEntityLocationId = @shipFromId AND B2.ysnDefaultLocation = 1
	LEFT JOIN [tblEMEntityToContact] C ON A.[intEntityId] = C.intEntityId 
	WHERE A.[intEntityId]= @vendorId 
	--  AND 1 = (CASE WHEN @shipFromId IS NOT NULL THEN 
    --  				(CASE WHEN @shipFromId = ISNULL(B2.intEntityLocationId,B.intEntityLocationId)
    -- 			THEN 1 ELSE 0 END)
    --ELSE (CASE WHEN B.ysnDefaultLocation = 1 THEN 1 ELSE 0 END) END)
 	AND C.ysnDefaultContact = 1

	SELECT
		@apAccount = CASE WHEN ISNULL(@apAccountId,0) > 0 THEN @apAccountId 
						ELSE (CASE WHEN @type IN (2, 13) THEN intPurchaseAdvAccount
							 	ELSE intAPAccount  END)
						END,
		@shipToAddress = strAddress,
		@shipToCity = strCity,
		@shipToCountry = strCountry,
		@shipToPhone = strPhone,
		@shipToState = strStateProvince,
		@shipToZipCode = strZipPostalCode
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @shipTo

	SELECT
		@currency = CASE WHEN ISNULL(@currencyId,0) > 0 THEN @currencyId 
						 WHEN @vendorCurrency > 0 THEN @vendorCurrency
					ELSE intDefaultCurrencyId END
	FROM tblSMCompanyPreference

	SELECT
		@subCurrencyCents = ISNULL(NULLIF(intCent, 0), 1)
	FROM tblSMCurrency
	WHERE intMainCurrencyId = @currency AND ysnSubCurrency = 1

	SELECT @payToBankAccountId = VD.intEntityEFTInfoId
	FROM vyuAPVendorDefault VD
	WHERE VD.intEntityId = @vendorId

	INSERT @returntable
	(
		[intTermsId]			,
		[dtmDate]				,
		[dtmDueDate]			,
		[intAccountId]			,
		[intEntityId]			,
		[intEntityVendorId]		,
		[intTransactionType]	,
		[strShipToAttention]	,
		[strShipToAddress]		,
		[strShipToCity]			,
		[strShipToState]		,
		[strShipToZipCode]		,
		[strShipToCountry]		,
		[strShipToPhone]		,
		[strShipFromAttention]	,
		[strShipFromAddress]	,
		[strShipFromCity]		,
		[strShipFromState]		,
		[strShipFromZipCode]	,
		[strShipFromCountry]	,
		[strShipFromPhone]		,
		[intShipFromId]			,
		[intPayToAddressId]		, 
		[intShipToId]			,
		[intShipViaId]			,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]	,
		[intShipFromEntityId]	,
		[intPayFromBankAccountId]	,
		[strFinancingSourcedFrom]	,
		[intPayToBankAccountId]		
	)
	SELECT 
		@term, 
		@currentDate,
		dbo.fnGetDueDateBasedOnTerm(@currentDate, @term),
		@apAccount,
		@userId,
		@vendorId,
		@type,
		NULL,
		@shipToAddress,
		@shipToCity,
		@shipToState,
		@shipToZipCode,
		@shipToCountry,
		@shipToPhone,
		NULL,
		@shipFromAddress,
		@shipFromCity,
		@shipFromState,
		@shipFromZipCode,
		@shipFromCountry,
		@shipFromPhone,
		@shipFrom,
		@payto,
		@shipTo,
		@shipVia,
		@contact,
		@userId,
		@currency,		
		ISNULL(@subCurrencyCents,1),
		@vendorId,
		@payFromBankAccount,
		@financingSourcedFrom,
		@payToBankAccountId

	--UPDATE PAY FROM BANK ACCOUNT
	UPDATE A
	SET A.intPayFromBankAccountId = ISNULL(B.intPayFromBankAccountId, ISNULL(C.intPayFromBankAccountId, ISNULL(D.intPayFromBankAccountId, NULL))),
		A.strFinancingSourcedFrom = CASE WHEN B.strSourcedFrom IS NULL 
										THEN CASE WHEN C.strSourcedFrom IS NULL
											 THEN CASE WHEN D.strSourcedFrom IS NULL
											 	  THEN 'None'
												  ELSE D.strSourcedFrom END
											 ELSE C.strSourcedFrom END
										ELSE B.strSourcedFrom END
	FROM @returntable A
	OUTER APPLY (
		SELECT VANL.intPayFromBankAccountId intPayFromBankAccountId, 'Vendor Default' strSourcedFrom
		FROM tblAPVendor V
		INNER JOIN tblAPVendorAccountNumLocation VANL ON VANL.intEntityVendorId = V.intEntityId
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = VANL.intPayFromBankAccountId
		WHERE V.intEntityId = A.intEntityVendorId AND VANL.intCompanyLocationId = A.intShipToId AND BA.intCurrencyId = A.intCurrencyId
	) B
	OUTER APPLY (
		SELECT V.intPayFromBankAccountId intPayFromBankAccountId, 'Vendor Default' strSourcedFrom
		FROM tblAPVendor V
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = V.intPayFromBankAccountId
		WHERE V.intEntityId = A.intEntityVendorId AND BA.intCurrencyId = A.intCurrencyId
	) C
	OUTER APPLY (
		SELECT DPFBA.intBankAccountId intPayFromBankAccountId, 'Company Default' strSourcedFrom
		FROM tblAPDefaultPayFromBankAccount DPFBA
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = DPFBA.intBankAccountId
		WHERE DPFBA.intCurrencyId = A.intCurrencyId
	) D	
	
	RETURN;
END
