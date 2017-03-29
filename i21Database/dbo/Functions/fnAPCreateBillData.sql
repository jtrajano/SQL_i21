CREATE FUNCTION [dbo].[fnAPCreateBillData]
(
	@vendorId INT,
	@userId INT,
	@type INT,
	@termId INT = NULL,
	@currencyId INT = NULL,
	@apAccountId INT = NULL,
	@shipFromId INT = NULL,
	@shipToId INT = NULL
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
	[intPayToAddressId]		INT NULL , 
	[intShipToId]			INT NULL , 
	[intShipViaId]			INT NULL , 
    [intStoreLocationId]	INT NULL , 
    [intContactId]			INT NULL , 
    [intOrderById]			INT NULL , 
    [intCurrencyId]			INT NOT NULL,
	[ysnApproved]			BIT NOT NULL DEFAULT 0,
	[ysnForApproval]		BIT NOT NULL DEFAULT 0,
    [ysnOrigin]				BIT NOT NULL DEFAULT 0,
	[ysnDeleted]			BIT NULL DEFAULT 0 ,
	[dtmDateDeleted]		DATETIME NULL,
    [dtmDateCreated]		DATETIME NULL DEFAULT GETDATE()
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
	DECLARE @shipVia INT;
	
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

	IF ISNULL(@userId, 0) > 0
	SELECT TOP 1 
		@shipTo = (CASE WHEN ISNULL(@shipToId,0) > 0 THEN @shipToId ELSE intCompanyLocationId END)
	FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @userId

	SELECT 
		@term = ISNULL((CASE WHEN ISNULL(@termId,0) > 0 THEN @termId ELSE B.intTermsId END),
						(SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm like '%due on receipt%')),
		@contact = C.intEntityContactId,
		@shipFrom = B.intEntityLocationId,
		@shipVia = B.intShipViaId,
		@shipFromAddress = B.strAddress,
		@shipFromCity = B.strCity,
		@shipFromCountry = B.strCountry,
		@shipFromCity = B.strCity,
		@shipFromPhone = B.strPhone,
		@shipFromState = B.strState,
		@shipFromZipCode = B.strZipCode
	FROM tblAPVendor A
	LEFT JOIN [tblEMEntityLocation] B ON A.[intEntityId] = B.intEntityId
	LEFT JOIN [tblEMEntityToContact] C ON A.[intEntityId] = C.intEntityId 
	WHERE A.[intEntityId]= @vendorId 
	AND 1 = (CASE WHEN @shipFrom IS NOT NULL THEN 
					(CASE WHEN B.intEntityLocationId = @shipFrom THEN 1 ELSE 0 END)
				ELSE (CASE WHEN B.ysnDefaultLocation = 1 THEN 1 ELSE 0 END) END)
	AND C.ysnDefaultContact = 1

	SELECT
		@apAccount = CASE WHEN ISNULL(@apAccountId,0) > 0 THEN @apAccountId ELSE intAPAccount END,
		@shipToAddress = strAddress,
		@shipToCity = strCity,
		@shipToCountry = strCountry,
		@shipToPhone = strPhone,
		@shipToState = strStateProvince,
		@shipToZipCode = strZipPostalCode
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @shipTo

	SELECT
		@currency = CASE WHEN ISNULL(@currencyId,0) > 0 THEN @currencyId ELSE intDefaultCurrencyId END
	FROM tblSMCompanyPreference

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
		[intCurrencyId]			
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
		@shipFrom,
		@shipTo,
		@shipVia,
		@contact,
		@userId,
		@currency

	RETURN;
END
