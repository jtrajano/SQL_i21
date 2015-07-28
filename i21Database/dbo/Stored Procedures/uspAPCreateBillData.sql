CREATE PROCEDURE [dbo].[uspAPCreateBillData]
	@userId INT,
	@vendorId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @bill TABLE
(
	[intTermsId]			INT             NOT NULL DEFAULT 0,
    [intTaxId]				INT             NULL ,
    [dtmDate]				DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDueDate]			DATETIME        NOT NULL DEFAULT GETDATE(),
    [intAccountId]			INT             NOT NULL DEFAULT 0,
    [strReference]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strApprovalNotes]		NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]				DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal]			DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [ysnPosted]				BIT             NOT NULL DEFAULT 0,
    [ysnPaid]				BIT             NOT NULL DEFAULT 0,
    [strBillId]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
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
	[intShipToId]			INT NULL , 
	[intShipViaId]			INT NULL , 
    [intStoreLocationId]	INT NULL , 
    [intContactId]			INT NULL , 
    [intOrderById]			INT NULL , 
    [intCurrencyId]			INT NOT NULL DEFAULT 0,
	[ysnApproved]			BIT NOT NULL DEFAULT 0,
	[ysnForApproval]		BIT NOT NULL DEFAULT 0,
    [ysnOrigin]				BIT NOT NULL DEFAULT 0,
	[ysnDeleted]			BIT NULL DEFAULT 0 ,
	[dtmDateDeleted]		DATETIME NULL,
    [dtmDateCreated]		DATETIME NULL DEFAULT GETDATE()
)

	--TODO: RETURN SCHEMA OF THIS SHOULD ALWAYS THE SAME tblAPBill TABLE	
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
	
	SELECT TOP 1 
		@userLocation = intCompanyLocationId ,
		@shipTo = intCompanyLocationId
	FROM tblSMUserSecurity WHERE intEntityId = @userId

	SELECT 
		@term = B.intTermsId,
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
	LEFT JOIN tblEntityLocation B ON A.intEntityVendorId = B.intEntityId
	LEFT JOIN tblEntityToContact C ON A.intEntityVendorId = C.intEntityId 
	WHERE A.intEntityVendorId= @vendorId 
	AND B.ysnDefaultLocation = 1
	AND C.ysnDefaultContact = 1

	SELECT
		@apAccount = intAPAccount,
		@shipToAddress = strAddress,
		@shipToCity = strCity,
		@shipToCountry = strCountry,
		@shipToPhone = strPhone,
		@shipToState = strStateProvince,
		@shipToZipCode = strZipPostalCode
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @userLocation

	SELECT
		@currency = intDefaultCurrencyId
	FROM tblSMCompanyPreference
	
	EXEC uspSMGetStartingNumber 9, @billRecordNumber OUTPUT

	INSERT INTO @bill
	(
		[intTermsId]			,
		[dtmDueDate]			,
		[intAccountId]			,
		[strBillId]				,
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
		[intShipToId]			,
		[intShipViaId]			,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			
	)
	SELECT 
		@term, 
		ISNULL(dbo.fnGetDueDateBasedOnTerm(GETDATE(), @term), GETDATE()),
		@apAccount,
		@billRecordNumber,
		@userId,
		@vendorId,
		1,
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
		@shipTo,
		@shipVia,
		@contact,
		@userId,
		@currency

	SELECT * FROM @bill
END
