CREATE FUNCTION [dbo].[fnAPGetBillDefaultData]
(
	@userId INT,
	@vendorId INT
)
RETURNS @returntable TABLE
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
	[dblBillTax]			DECIMAL(18, 6) NOT NULL DEFAULT 0, 
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
AS
BEGIN

	--TODO: RETURN SCHEMA OF THIS SHOULD ALWAYS THE SAME tblAPBill TABLE	
	DECLARE @userLocation INT;
	DECLARE @defaultTerm INT;
	
	SET @userLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityId = @userId);
	SET @defaultTerm = (SELECT intTermsId FROM tblEntityLocation WHERE intEntityId = @vendorId AND ysnDefaultLocation = 1);

	INSERT @returntable
	SELECT @param1, @param2
	RETURN
END
