CREATE PROCEDURE [dbo].[uspAPCreatePayment]
	@userId INT,
	@bankAccount INT = NULL,
	@paymentMethod INT = NULL,
	@paymentInfo NVARCHAR(10) = NULL,
	@notes NVARCHAR(500) = NULL,
	@payment DECIMAL(18, 6) = NULL,
	@datePaid DATETIME = NULL,
	@isPost BIT = 0,
	@post BIT = 0,
	@billId NVARCHAR(MAX),
	@createdPaymentId INT = NULL OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @queryPayment NVARCHAR(MAX)
	DECLARE @queryPaymentDetail NVARCHAR(MAX)
	DECLARE @paymentId INT
	DECLARE @vendorId INT
	DECLARE @withHoldAccount INT
	DECLARE @amountPaid NUMERIC(18,6) = @payment;
	DECLARE @withholdAmount NUMERIC(18,6)
	DECLARE @withholdPercent NUMERIC(18,6)
	DECLARE @paymentMethodId INT = @paymentMethod
	DECLARE @intBankAccountId INT = @bankAccount;
	DECLARE @vendorWithhold BIT = 0;
	DECLARE @intGLBankAccountId INT;
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT 
		TOP 1 @vendorId = C.[intEntityVendorId] 
		,@vendorWithhold = C.ysnWithholding
		FROM tblAPBill A
		INNER JOIN  #tmpBillsId B
			ON A.intBillId = B.intID
		INNER JOIN tblAPVendor C
			ON A.[intEntityVendorId] = C.[intEntityVendorId]

	--VALIDATION
	--Make sure there is user to use
	IF @userId IS NULL
	BEGIN
		RAISERROR('User is required.', 16, 1);
		RETURN;
	END

	--Make sure there is bank account to use
	IF @intBankAccountId IS NULL
	BEGIN
		SELECT @intGLBankAccountId = B.intCashAccount FROM tblSMUserSecurity A 
					INNER JOIN tblSMCompanyLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
					WHERE A.intEntityId = @userId
		SELECT TOP 1 @intBankAccountId = intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = @intGLBankAccountId

		IF @intBankAccountId IS NULL
		BEGIN
			RAISERROR('The Cash Account setup is missing.', 16, 1);
			RETURN;
		END
	END

	IF @intGLBankAccountId IS NULL
	BEGIN
		SET @intGLBankAccountId = (SELECT TOP 1 intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId);
	END
		
	--Make sure there is payment method to user
	IF @paymentMethodId IS NULL
	BEGIN
		SELECT TOP 1 @paymentMethodId = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'
		IF @paymentMethodId IS NULL
		BEGIN
			RAISERROR('There is no check payment method setup.', 16, 1);
			RETURN;
		END
	END

	IF @amountPaid IS NULL
	BEGIN
		SET @amountPaid = (SELECT SUM(dblAmountDue) FROM tblAPBill WHERE intBillId IN (SELECT intID FROM #tmpBillsId)) 
	END

	--Compute Discount Here

	--Compute Interest Here

	--Compute Withheld Here
	IF @vendorWithhold = 1
	BEGIN
		--Validate if there is a set up for withheld account.
		SELECT @withHoldAccount = B.intWithholdAccountId
			,@withholdPercent = B.dblWithholdPercent
		 FROM tblSMUserSecurity A 
		INNER JOIN tblSMCompanyLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
				WHERE A.intEntityId = @userId
		IF (@withHoldAccount IS NULL)
		BEGIN
			RAISERROR('This vendor enables withholding but there is no setup of withhold account.',16,1);
			RETURN;
		END

		--SET @withholdAmount = @amountPaid * (@withholdPercent / 100)
		--SET @amountPaid = @amountPaid - @withholdAmount
	END


	SET @queryPayment = '
	INSERT INTO tblAPPayment(
		[intAccountId],
		[intBankAccountId],
		[intPaymentMethodId],
		[intCurrencyId],
		[intEntityVendorId],
		[strPaymentInfo],
		[strNotes],
		[dtmDatePaid],
		[dblAmountPaid],
		[dblUnapplied],
		[ysnPosted],
		[dblWithheld],
		[intEntityId],
		[intConcurrencyId])
	SELECT
		[intAccountId]			= @bankGLAccountId,
		[intBankAccountId]		= @bankAccount,
		[intPaymentMethodId]	= @paymentMethod,
		[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = @bankAccount), (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'')),
		[intEntityVendorId]		= @vendorId,
		[strPaymentInfo]		= @paymentInfo,
		[strNotes]				= @notes,
		[dtmDatePaid]			= ISNULL(@datePaid, GETDATE()),
		[dblAmountPaid]			= @payment,
		[dblUnapplied]			= 0,
		[ysnPosted]				= @isPost,
		[dblWithheld]			= 0,
		[intEntityId]			= @userId,
		[intConcurrencyId]		= 0
	
	SELECT @paymentId = SCOPE_IDENTITY()'

	SET @queryPaymentDetail = '
	INSERT INTO tblAPPaymentDetail(
		[intPaymentId],
		[intBillId],
		[intAccountId],
		[dblDiscount],
		[dblWithheld],
		[dblAmountDue],
		[dblPayment],
		[dblInterest],
		[dblTotal])
	SELECT 
		[intPaymentId]	= @paymentId,
		[intBillId]		= A.intBillId,
		[intAccountId]	= A.intAccountId,
		[dblDiscount]	= A.dblDiscount,
		[dblWithheld]	= CASE WHEN @withholdPercent > 0 THEN CAST(ROUND(A.dblTotal * (@withholdPercent / 100), 6) AS NUMERIC(18,6)) ELSE 0 END,
		[dblAmountDue]	= A.dblAmountDue, -- (A.dblTotal - A.dblDiscount - A.dblPayment),
		[dblPayment]	= A.dblTotal - A.dblDiscount - A.dblPayment,
		[dblInterest]	= 0, --TODO
		[dblTotal]		= A.dblTotal
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT [intID] FROM #tmpBillsId)
	'

	EXEC sp_executesql @queryPayment,
	 N'@billId NVARCHAR(MAX),
	 @userId NVARCHAR(50),
	 @bankGLAccountId INT,
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
	 @bankGLAccountId = @intGLBankAccountId,
	 @bankAccount = @intBankAccountId,
	 @paymentMethod = @paymentMethodId,
	 @paymentInfo = @paymentInfo,
	 @vendorId = @vendorId,
	 @notes = @notes,
	 @payment = @amountPaid,
	 @datePaid = @datePaid,
	 @isPost = @isPost,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@paymentId INT,
	@withholdPercent NUMERIC(18,6)',
	 @paymentId = @paymentId,
	 @withholdPercent = @withholdPercent;

	 UPDATE A
		SET A.dblWithheld = Withheld.dblWithheld
		,A.dblAmountPaid = A.dblAmountPaid - Withheld.dblWithheld
	 FROM tblAPPayment A
	 CROSS APPLY 
	 (
		SELECT SUM(dblWithheld) dblWithheld FROM tblAPPaymentDetail B
		WHERE B.intPaymentId = A.intPaymentId
	 ) Withheld
	WHERE A.intPaymentId = @paymentId
		 
	 SET @createdPaymentId = @paymentId
END