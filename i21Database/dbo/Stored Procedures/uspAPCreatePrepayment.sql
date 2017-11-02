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
	DECLARE @currency INT, @functionalCurrency INT;
	DECLARE @paymentRecordNum NVARCHAR(50);
	DECLARE @payToAddress INT;
	DECLARE @foreignCurrency BIT = 0;
	DECLARE @rate DECIMAL(18,6) = 1;
	DECLARE @rateType INT;
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT TOP 1 @vendorId = C.[intEntityId] 
			,@location = A.intShipToId
			,@currency = A.intCurrencyId
			,@payToAddress = A.intPayToAddressId
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

	SELECT TOP 1 
		@functionalCurrency = intDefaultCurrencyId 
		,@foreignCurrency = CASE WHEN intDefaultCurrencyId != @currency THEN 1 ELSE 0 END
	FROM tblSMCompanyPreference

	IF @foreignCurrency = 1
	BEGIN
		SELECT TOP 1
			@rateType = intAccountsPayableRateTypeId
		FROM tblSMMultiCurrency
		 
		SELECT TOP 1
			@rate = exchangeRateDetail.dblRate
		FROM tblSMCurrencyExchangeRate exchangeRate
		INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
		WHERE exchangeRateDetail.intRateTypeId = @rateType
		AND exchangeRate.intFromCurrencyId = @currency AND exchangeRate.intToCurrencyId = @functionalCurrency
		AND exchangeRateDetail.dtmValidFromDate <= GETDATE()
		ORDER BY exchangeRateDetail.dtmValidFromDate DESC

		IF @rateType IS NULL 
		BEGIN
			RAISERROR('No exchange rate type setup found. Please set on Multi Currency screen.', 16, 1);
			RETURN;
		END
		
		IF @rate IS NULL OR @rate < 0
		BEGIN
			RAISERROR('No exchange rate setup found. Please set on Currency screen.', 16, 1);
			RETURN;
		END
	END

	--VALIDATION
	--Make sure there is user to use
	IF @userId IS NULL
	BEGIN
		RAISERROR('User is required.', 16, 1);
		RETURN;
	END

	IF @location IS NULL
	BEGIN
		SET @location = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @userId)
		IF @location IS NULL
		BEGIN
			RAISERROR('Location setup is missing.', 16, 1);
			RETURN;
		END
	END

	--Make sure there is bank account to use
	IF @intBankAccountId IS NULL
	BEGIN
		SELECT TOP 1 @intGLBankAccountId = A.intCashAccount FROM tblSMCompanyLocation A
					WHERE A.intCompanyLocationId = @location

		--Find available bank account available for the same currency
		IF @intGLBankAccountId IS NOT NULL
		BEGIN
			SELECT TOP 1 @intBankAccountId = intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = @intGLBankAccountId AND intCurrencyId = @currency AND ysnActive = 1
		END
	END

	--if no cash account setup on location, just look for the bank account on same currency
	IF @intGLBankAccountId IS NULL OR @intBankAccountId IS NULL
	BEGIN
		SELECT TOP 1 
			@intGLBankAccountId = intGLAccountId
			,@intBankAccountId = intBankAccountId
		FROM tblCMBankAccount WHERE intCurrencyId = @currency AND ysnActive = 1
	END
		
	--if no bank account with same currency on transaction
	IF @intGLBankAccountId IS NULL OR @intBankAccountId IS NULL
	BEGIN
		RAISERROR('No available bank account for this transaction.', 16, 1);
		RETURN;
	END

	--Make sure there is payment method to user
	IF @paymentMethodId IS NULL OR @paymentMethodId = 0
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
		[intPayToAddressId],
		[intCompanyLocationId],
		[intCurrencyId],
		[intCurrencyExchangeRateTypeId],
		[intEntityVendorId],
		[strPaymentInfo],
		[strPaymentRecordNum],
		[strNotes],
		[dtmDatePaid],
		[dblAmountPaid],
		[dblUnapplied],
		[dblExchangeRate],
		[ysnPosted],
		[ysnPrepay],
		[dblWithheld],
		[intEntityId],
		[intConcurrencyId])
	SELECT
		[intAccountId]			= @bankGLAccountId,
		[intBankAccountId]		= @bankAccount,
		[intPaymentMethodId]	= @paymentMethod,
		[intPayToAddressId]		= @payToAddress,
		[intCompanyLocationId]	= @location,
		[intCurrencyId]			= @currency,
		[intCurrencyExchangeRateTypeId] = @rateType,
		[intEntityVendorId]		= @vendorId,
		[strPaymentInfo]		= @paymentInfo,
		[strPaymentRecordNum]	= @paymentRecordNum,
		[strNotes]				= @notes,
		[dtmDatePaid]			= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(@datePaid, GETDATE())), 0),
		[dblAmountPaid]			= CAST(ISNULL(@payment,0) AS DECIMAL(18,2)),
		[dblUnapplied]			= 0,
		[dblExchangeRate]		= @rate,
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
		[intPaymentId],
		[intBillId],
		[intAccountId],
		[dblDiscount],
		[dblWithheld],
		SUM(dblAmountDue),
		SUM(dblPayment) - dblDiscount + dblInterest,
		[dblInterest],
		SUM(dblTotal)
		FROM (
			SELECT 
				[intPaymentId]	= @paymentId,
				[intBillId]		= A.intBillId,
				[intAccountId]	= B.intAccountId,
				[dblDiscount]	= A.dblDiscount,
				[dblWithheld]	= 0,
				[dblAmountDue]	= CAST((B.dblTotal + B.dblTax) - ((ISNULL(A.dblPayment,0) / A.dblTotal) * (B.dblTotal + B.dblTax)) AS DECIMAL(18,2)), --handle transaction with prepaid
				[dblPayment]	= CAST((B.dblTotal + B.dblTax) - ((ISNULL(A.dblPayment,0) / A.dblTotal) * (B.dblTotal + B.dblTax)) AS DECIMAL(18,2)),
				[dblInterest]	= A.dblInterest,
				[dblTotal]		= (B.dblTotal + B.dblTax)
			FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			WHERE A.intBillId IN (SELECT [intID] FROM #tmpBillsId)
		) vouchers
	GROUP BY intPaymentId, intBillId, intAccountId, dblDiscount, dblInterest, dblWithheld
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
	 @rateType INT,
	 @rate DECIMAL(18,6),
	 @payToAddress INT,
	 @currency INT,
	 @location INT,
	 @paymentId INT OUTPUT',
	 @location = @location,
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
	 @rateType = @rateType,
	 @rate = @rate,
	 @payToAddress = @payToAddress,
	 @currency = @currency,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@paymentId INT',
	 @paymentId = @paymentId;
	 
	 SET @createdPaymentId = @paymentId
END