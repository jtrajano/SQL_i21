CREATE PROCEDURE [dbo].[uspAPCreatePayment]
	@userId NVARCHAR(50),
	@bankAccount INT,
	@paymentMethod INT,
	@paymentInfo NVARCHAR(10),
	@notes NVARCHAR(500),
	@payment DECIMAL(18, 6) = NULL,
	@datePaid DATETIME = NULL,
	@isPost BIT = 0,
	@post BIT = 0,
	@billId NVARCHAR(MAX)
AS
BEGIN

	DECLARE @queryPayment NVARCHAR(MAX)
	DECLARE @queryPaymentDetail NVARCHAR(MAX)
	DECLARE @paymentId INT
	DECLARE @vendorId INT

	--Compute Discount Here

	--Compute Interest Here

	--TODO Validations

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT TOP 1 @vendorId = intEntityId 
		FROM tblAPBill A
		INNER JOIN  #tmpBillsId B
			ON A.intBillId = B.intID
		INNER JOIN tblAPVendor C
			ON A.strVendorId = C.strVendorId

	SET @queryPayment = '
	INSERT INTO tblAPPayment(
		[intAccountId],
		[intBankAccountId],
		[intPaymentMethodId],
		[intCurrencyId],
		[strVendorId],
		[strPaymentInfo],
		[strNotes],
		[dtmDatePaid],
		[dblCredit],
		[dblAmountPaid],
		[dblUnappliedAmount],
		[ysnPosted],
		[dblWithheldAmount],
		[intUserId],
		[intConcurrencyId])
	SELECT
		[intAccountId]			= (SELECT TOP 1 intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @bankAccount ),
		[intBankAccountId]		= @bankAccount,
		[intPaymentMethodId]	= @paymentMethod,
		[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = @bankAccount), (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'')),
		[strVendorId]			= (SELECT strVendorId FROM tblAPVendor WHERE intEntityId = @vendorId),
		[strPaymentInfo]		= @paymentInfo,
		[strNotes]				= @notes,
		[dtmDatePaid]			= ISNULL(@datePaid, GETDATE()),
		[dblCredit]				= 0,
		[dblAmountPaid]			= @payment,
		[dblUnappliedAmount]	= 0,
		[ysnPosted]				= @isPost,
		[dblWithheldAmount]		= 0,
		[intUserId]				= @userId,
		[intConcurrencyId]		= 0
	
	SELECT @paymentId = SCOPE_IDENTITY()'

	SET @queryPaymentDetail = '
	INSERT INTO tblAPPaymentDetail(
		[intPaymentId],
		[intBillId],
		[intTermsId],
		[intAccountId],
		[dtmDueDate],
		[dblDiscount],
		[dblWithheld],
		[dblAmountDue],
		[dblPayment],
		[dblInterest],
		[dblTotal])
	SELECT 
		[intPaymentId]	= @paymentId,
		[intBillId]		= A.intBillId,
		[intTermsId]	= A.intTermsId,
		[intAccountId]	= A.intAccountId,
		[dtmDueDate]	= A.dtmDueDate,
		[dblDiscount]	= A.dblDiscount,
		[dblWithheld]	= A.dblWithheld,
		[dblAmountDue]	= A.dblAmountDue,
		[dblPayment]	= A.dblTotal,
		[dblInterest]	= 0, --TODO
		[dblTotal]		= A.dblTotal
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT [intID] FROM #tmpBillsId)
	'

	EXEC sp_executesql @queryPayment,
	 N'@billId NVARCHAR(MAX),
	 @userId NVARCHAR(50),
	 @bankAccount INT,
	 @paymentMethod INT,
	 @vendorId INT,
	 @paymentInfo NVARCHAR(10),
	 @notes NVARCHAR(500),
	 @payment DECIMAL(18, 6),
	 @datePaid DATETIME,
	 @isPost BIT,
	 @paymentId INT OUTPUT',
	 @userId = @userId,
	 @billId = @billId,
	 @bankAccount = @bankAccount,
	 @paymentMethod = @paymentMethod,
	 @paymentInfo = @paymentInfo,
	 @vendorId = @vendorId,
	 @notes = @notes,
	 @payment = @payment,
	 @datePaid = @datePaid,
	 @isPost = @isPost,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@paymentId INT',
	 @paymentId = @paymentId;

END