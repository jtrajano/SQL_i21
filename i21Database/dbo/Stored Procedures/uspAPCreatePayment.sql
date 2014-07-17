CREATE PROCEDURE [dbo].[uspAPCreatePayment]
	@userId NVARCHAR(50),
	@bankAccount INT,
	@paymentMethod INT,
	@intVendorId INT,
	@paymentInfo NVARCHAR(10),
	@notes NVARCHAR(500),
	@payment DECIMAL(18, 6) = NULL,
	@datePaid DATETIME = NULL,
	@isPost BIT = 0,
	@post BIT = 0,
	@discount DECIMAL(18,6) = 0,
	@interest DECIMAL(18,6) = 0,
	@withHeld DECIMAL(18,6) = 0,
	@billId int
AS
BEGIN

	DECLARE @queryPayment NVARCHAR(MAX)
	DECLARE @queryPaymentDetail NVARCHAR(MAX)
	DECLARE @paymentId INT

	--Compute Discount Here

	--Compute Interest Here

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
		[strVendorId]			= (SELECT strVendorId FROM tblAPVendor WHERE intEntityId = @intVendorId),
		[strPaymentInfo]		= @paymentInfo,
		[strNotes]				= @notes,
		[dtmDatePaid]			= ISNULL(@datePaid, GETDATE()),
		[dblCredit]				= 0,
		[dblAmountPaid]			= ISNULL(@payment, A.dblAmountDue),
		[dblUnappliedAmount]	= 0,
		[ysnPosted]				= @isPost,
		[dblWithheldAmount]		= @withHeld,
		[intUserId]				= @userId,
		[intConcurrencyId]		= 0
	FROM tblAPBill A
	WHERE A.intBillId = @billId
	
	SELECT @paymentId = SCOPE_IDENTITY()'

	SET @queryPaymentDetail = '
	INSERT INTO tblAPPaymentDetail(
		[intPaymentId],
		[intBillId],
		[intTermsId],
		[intAccountId],
		[dtmDueDate],
		[dblDiscount],
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
		[dblDiscount]	=  @discount,
		[dblAmountDue]	= A.dblAmountDue,
		[dblPayment]	= @payment,
		[dblInterest]	= @interest,
		[dblTotal]		= A.dblTotal
	FROM tblAPBill A
	WHERE A.intBillId = @billId
	'

	EXEC sp_executesql @queryPayment,
	 N'@billId INT,
	 @userId NVARCHAR(50),
	 @bankAccount INT,
	 @paymentMethod INT,
	 @intVendorId INT,
	 @paymentInfo NVARCHAR(10),
	 @notes NVARCHAR(500),
	 @payment DECIMAL(18, 6),
	 @datePaid DATETIME,
	 @withHeld DECIMAL(18,6),
	 @isPost BIT,
	 @paymentId INT OUTPUT',
	 @userId = @userId,
	 @billId = @billId,
	 @bankAccount = @bankAccount,
	 @paymentMethod = @paymentMethod,
	 @paymentInfo = @paymentInfo,
	 @intVendorId = @intVendorId,
	 @notes = @notes,
	 @payment = @payment,
	 @withHeld = @withHeld,
	 @datePaid = @datePaid,
	 @isPost = @isPost,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@billId INT,
	 @payment DECIMAL(18, 6),
	 @discount DECIMAL(18,6),
	 @interest DECIMAL(18,6),
	 @paymentId INT',
	 @paymentId = @paymentId,
	 @billId = @billId,
	 @payment = @payment,
	 @discount = @discount,
	 @interest = @interest;

END