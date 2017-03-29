CREATE PROCEDURE [dbo].[uspAPCreatePrepayment]
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
	DECLARE @amountPaid NUMERIC(18,6) = @payment;
	DECLARE @paymentMethodId INT = @paymentMethod
	DECLARE @intBankAccountId INT = @bankAccount;
	DECLARE @intGLBankAccountId INT;
	DECLARE @location INT;
	DECLARE @paymentRecordNum NVARCHAR(50);
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT TOP 1 @vendorId = C.[intEntityId] 
			,@location = A.intShipToId
		FROM tblAPBill A
		INNER JOIN  #tmpBillsId B
			ON A.intBillId = B.intID
		INNER JOIN tblAPVendor C
			ON A.[intEntityVendorId] = C.[intEntityId]

	IF EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
				INNER JOIN tblCMBankTransaction D ON A.strPaymentRecordNum = D.strTransactionId
					WHERE C.intBillId IN (SELECT [intID] FROM #tmpBillsId) AND A.ysnPosted = 1 AND D.ysnCheckVoid = 0 AND A.ysnPrepay = 1)
	BEGIN
		RAISERROR('Prepay already have payment.', 16, 1);
		RETURN;
	END

	--VALIDATION
	--Make sure there is user to use
	IF @userId IS NULL
	BEGIN
		RAISERROR('User is required.', 16, 1);
		RETURN;
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

	--Make sure there is bank account to use
	IF @intBankAccountId IS NULL
	BEGIN

		IF @location IS NULL
		BEGIN
			SET @location = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @userId) --USER USER LOCATION
		END

		SELECT @intGLBankAccountId = A.intCashAccount 
			FROM tblSMCompanyLocation A
		WHERE A.intCompanyLocationId = @location
		
		SELECT TOP 1 @intBankAccountId = intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = @intGLBankAccountId

	END

	IF @intBankAccountId IS NULL
	BEGIN
		RAISERROR('Cash account setup is missing.', 16, 1);
		RETURN;
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

	EXEC uspSMGetStartingNumber 8, @paymentRecordNum OUT

	SET @queryPayment = '
	INSERT INTO tblAPPayment(
		[intAccountId],
		[intBankAccountId],
		[intPaymentMethodId],
		[intCurrencyId],
		[intEntityVendorId],
		[strPaymentInfo],
		[strPaymentRecordNum],
		[strNotes],
		[dtmDatePaid],
		[dblAmountPaid],
		[dblUnapplied],
		[ysnPosted],
		[ysnPrepay],
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
		[strPaymentRecordNum]	= @paymentRecordNum,
		[strNotes]				= @notes,
		[dtmDatePaid]			= ISNULL(@datePaid, GETDATE()),
		[dblAmountPaid]			= @payment,
		[dblUnapplied]			= 0,
		[ysnPosted]				= @isPost,
		[ysnPrepay]				= 1,
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
		[dblDiscount]	= 0,
		[dblWithheld]	= 0,
		[dblAmountDue]	= CASE WHEN (A.dblAmountDue < 0) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END,
		[dblPayment]	= CASE WHEN (A.dblTotal < 0) THEN A.dblTotal * -1 ELSE A.dblTotal END,
		[dblInterest]	= 0, --TODO
		[dblTotal]		= CASE WHEN (A.dblTotal < 0) THEN A.dblTotal * -1 ELSE A.dblTotal END 
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
	 @paymentRecordNum NVARCHAR(50),
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
	 @paymentRecordNum = @paymentRecordNum,
	 @vendorId = @vendorId,
	 @notes = @notes,
	 @payment = @amountPaid,
	 @datePaid = @datePaid,
	 @isPost = @isPost,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@paymentId INT',
	 @paymentId = @paymentId;
	 
	 SET @createdPaymentId = @paymentId
END