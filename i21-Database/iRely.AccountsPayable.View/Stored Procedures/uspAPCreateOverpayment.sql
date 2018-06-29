CREATE PROCEDURE [dbo].[uspAPCreateOverpayment]
	@paymentId INT,
	@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @overpay NUMERIC(18,6);
DECLARE @vendorId INT;
DECLARE @billId INT;
DECLARE @paymentRecord NVARCHAR(50);
DECLARE @generatedBillRecordId NVARCHAR(50);

SELECT 
	@overpay = dblUnapplied,
	@vendorId = intEntityVendorId,
	@paymentRecord = strPaymentRecordNum
FROM tblAPPayment WHERE intPaymentId = @paymentId;

IF (@overpay > 0)
BEGIN
	INSERT INTO tblAPBill
	(
		[intTermsId]			,
		[dtmDate]				,
		[dtmDueDate]			,
		[intAccountId]			,
		[strReference]			,
		[strApprovalNotes]		,
		[strComment]			,
		[dblTotal]				,
		[dblSubtotal]			,
		[ysnPosted]				,
		[ysnPaid]				,
		[dblAmountDue]			,
		[dtmDatePaid]			,
		[dtmApprovalDate]       ,
		[dtmDiscountDate]		,
		[intUserId]				,
		[intConcurrencyId]		,
		[dtmBillDate]			,
		[intEntityId]			,
		[intEntityVendorId]		,
		[dblWithheld]			,
		[dblDiscount]			,
		[dblTax]				,
		[dblPayment]			,
		[dblInterest]			,
		[intTransactionType]	,
		[intPurchaseOrderId]	,
		[strPONumber]			,
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
		[intShipFromEntityId]	,
		[intPayToAddressId]		,
		[intShipToId]			,
		[intShipViaId]			,
		[intStoreLocationId]	,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]	,
		[ysnApproved]			,
		[ysnForApproval]		,
		[ysnOrigin]				,
		[ysnDeleted]			,
		[dtmDateDeleted]		,
		[dtmDateCreated]		
	)
	SELECT * FROM dbo.fnAPCreateBillData(@vendorId, @userId, 8, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)

	SET @billId = SCOPE_IDENTITY();

	EXEC uspSMGetStartingNumber 66, @generatedBillRecordId OUT

	UPDATE A
	SET dblTotal = @overpay,
		dblAmountDue = @overpay,
		intTransactionType = 8,
		strReference = @paymentRecord,
		strBillId = @generatedBillRecordId
	FROM tblAPBill A
	WHERE A.intBillId = @billId
END