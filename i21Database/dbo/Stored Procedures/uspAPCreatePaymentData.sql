CREATE PROCEDURE [dbo].[uspAPCreatePaymentData]
	@userId INT,
	@bankAccount INT = NULL,
	@paymentMethod INT = NULL,
	@paymentInfo NVARCHAR(10) = NULL,
	@notes NVARCHAR(500) = NULL,
	@payment DECIMAL(18, 6) = 0,
	@datePaid DATETIME = NULL,
	@paymentDetail AS [PaymentDetailStaging] READONLY,
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
	DECLARE @amountPaid DECIMAL(18,2) = @payment;
	DECLARE @detailAmountPaid DECIMAL(18,6);
	DECLARE @withholdAmount DECIMAL(18,6) = 0
	DECLARE @withholdPercent DECIMAL(18,6)
	DECLARE @discountAmount DECIMAL(18,6) = 0;
	DECLARE @paymentMethodId INT = @paymentMethod
	DECLARE @intBankAccountId INT = @bankAccount;
	DECLARE @vendorWithhold BIT = 0;
	DECLARE @intGLBankAccountId INT;
	DECLARE @location INT;
	DECLARE @discount DECIMAL(18,6), @interest DECIMAL(18,6);
	DECLARE @bills AS Id;
	DECLARE @autoPay BIT = 0; --Automatically compute the payment
	DECLARE @paymentRecordNum NVARCHAR(50)
	DECLARE @defaultPaymentInfo NVARCHAR(500)
	DECLARE @payToAddress INT;
	DECLARE @foreignCurrency BIT = 0;
	DECLARE @rate DECIMAL(18,6) = 1;
	DECLARE @rateType INT;
	DECLARE @currency INT, @functionalCurrency INT;
	

	SELECT 
		TOP 1 @vendorId = C.[intEntityId] 
		,@vendorWithhold = C.ysnWithholding
		,@location = A.intCompanyLocationId
		,@paymentMethodId = CASE WHEN @paymentMethodId IS NULL THEN C.intPaymentMethodId ELSE @paymentMethodId END
		,@payToAddress = A.intShipToLocationId
		,@currency = A.intCurrencyId
		FROM tblARInvoice A
		INNER JOIN  @paymentDetail B
			ON A.intInvoiceId = B.intInvoiceId
		INNER JOIN tblAPVendor C
			ON A.[intEntityCustomerId] = C.[intEntityId]

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

	--Make sure there is payment method
	IF @paymentMethodId IS NULL OR @paymentMethodId = 0
	BEGIN
		SELECT TOP 1 @paymentMethodId = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'
		IF @paymentMethodId IS NULL
		BEGIN
			RAISERROR('There is no check payment method setup.', 16, 1);
			RETURN;
		END
	END

	----Compute Discount Here, if there is no value computed or added
	--UPDATE A
	--	SET dblDiscount = CAST(dbo.fnGetDiscountBasedOnTerm(ISNULL(@datePaid, GETDATE()), A.dtmBillDate, A.intTermsId, A.dblTotal) AS DECIMAL(18,2))
	--FROM tblAPBill A
	--WHERE A.intBillId IN (SELECT intID FROM #tmpInvoicesId) AND A.intTransactionType = 1
	--AND A.dblDiscount = 0

	----This is usually discount from origin or discount calculated in voucher side
	--SELECT
	--	@discount = SUM(ISNULL(A.dblDiscount,0))
	--FROM tblAPBill A
	--WHERE A.intBillId IN (SELECT intID FROM #tmpInvoicesId)

	----Compute Interest Here
	--UPDATE A
	--	SET dblInterest = dbo.fnGetInterestBasedOnTerm(A.dblTotal, A.dtmBillDate, ISNULL(@datePaid, GETDATE()), A.intTermsId)
	--FROM tblAPBill A
	--WHERE A.intBillId IN (SELECT intID FROM #tmpInvoicesId) AND A.intTransactionType = 1

	--SELECT
	--	@interest = SUM(ISNULL(A.dblInterest,0))
	--FROM tblAPBill A
	--WHERE A.intBillId IN (SELECT intID FROM #tmpInvoicesId)
	
	--IF ((SELECT COUNT(*) FROM #tmpInvoicesId) = 1) SET @autoPay = 1

	--IF @autoPay = 1 AND @amountPaid IS NULL AND @isPost = 0
	--BEGIN
	--	SET @amountPaid = (SELECT SUM(dblAmountDue) FROM tblAPBill WHERE intBillId IN (SELECT intID FROM #tmpInvoicesId)) 
	--	SET @amountPaid = @amountPaid + @interest - @discount 
	--	SET @detailAmountPaid = @amountPaid; --discount subtracted
	--END
	--ELSE
	--BEGIN
	--	SET @amountPaid = @amountPaid + @interest - @discount;
	--END

	
	--Compute Withheld Here
	--Compute only if the payment that will create is posted
	IF @vendorWithhold = 1
	BEGIN
		--Validate if there is a set up for withheld account.
		SELECT @withHoldAccount = B.intWithholdAccountId
			,@withholdPercent = B.dblWithholdPercent
		 FROM tblSMUserSecurity A 
		INNER JOIN tblSMCompanyLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
				WHERE A.[intEntityId] = @userId
		IF (@withHoldAccount IS NULL)
		BEGIN
			RAISERROR('This vendor enables withholding but there is no setup of withhold account.',16,1);
			RETURN;
		END

		SET @withholdAmount = @amountPaid * (@withholdPercent / 100)
		SET @amountPaid = @amountPaid - @withholdAmount
	END

	EXEC uspSMGetStartingNumber 8, @paymentRecordNum OUT
	IF @paymentMethodId = 6
	BEGIN
		EXEC uspSMGetStartingNumberSubType 8, 1, 6, @defaultPaymentInfo OUT
		SET @paymentInfo = @defaultPaymentInfo
	END

	SET @queryPayment = '
	INSERT INTO tblAPPayment(
		[intAccountId],
		[intBankAccountId],
		[intPaymentMethodId],
		[intPayToAddressId],
		[intCompanyLocationId],
		[intCurrencyId],
		[intEntityVendorId],
		[intCurrencyExchangeRateTypeId],
		[strPaymentInfo],
		[strPaymentRecordNum],
		[strNotes],
		[dtmDatePaid],
		[dblAmountPaid],
		[dblUnapplied],
		[dblExchangeRate],
		[ysnPosted],
		[dblWithheld],
		[intEntityId],
		[intConcurrencyId])
	SELECT
		[intAccountId]			= @bankGLAccountId,
		[intBankAccountId]		= @bankAccount,
		[intPaymentMethodId]	= @paymentMethod,
		[intPayToAddressId]		= @payToAddress,
		[intCompanyLocationId]  = @location,
		[intCurrencyId]			= @currency,
		[intEntityVendorId]		= @vendorId,
		[intCurrencyExchangeRateTypeId] = @rateType,
		[strPaymentInfo]		= @paymentInfo,
		[strPaymentRecordNum]	= @paymentRecordNum,
		[strNotes]				= @notes,
		[dtmDatePaid]			= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(@datePaid, GETDATE())), 0),
		[dblAmountPaid]			= CAST(ISNULL(@payment,0) AS DECIMAL(18,2)),
		[dblUnapplied]			= 0,
		[dblExchangeRate]		= @rate,
		[ysnPosted]				= 0,
		[dblWithheld]			= CAST(ISNULL(@withholdAmount,0) AS DECIMAL(18,2)),
		[intEntityId]			= @userId,
		[intConcurrencyId]		= 0
	
	SELECT @paymentId = SCOPE_IDENTITY()'

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
	 @withholdAmount DECIMAL(18, 6),
	 @datePaid DATETIME,
	 @isPost BIT,
	 @payToAddress INT,
	 @rateType INT,
	 @rate DECIMAL(18,6),
	 @currency INT,
	 @location INT,
	 @paymentId INT OUTPUT',
	 @location = @location,
	 @userId = @userId,
	 --@billId = @billId,
	 @bankGLAccountId = @intGLBankAccountId,
	 @bankAccount = @intBankAccountId,
	 @paymentMethod = @paymentMethodId,
	 @paymentInfo = @paymentInfo,
	 @paymentRecordNum = @paymentRecordNum,
	 @vendorId = @vendorId,
	 @notes = @notes,
	 @payment = @amountPaid,
	 @withholdAmount = @withholdAmount,
	 @datePaid = @datePaid,
	 --@isPost = @isPost,
	 @payToAddress = @payToAddress,
	 @rateType = @rateType,
	 @rate = @rate,
	 @currency = @currency,
	 @paymentId = @paymentId OUTPUT;

	
	INSERT INTO tblAPPaymentDetail(
		[intPaymentId],
		[intBillId],
		[intInvoiceId],
		[intAccountId],
		[dblDiscount],
		[dblAmountDue],
		[dblPayment],
		[dblInterest],
		[dblTotal],
		[dblWithheld]
	)
	SELECT
		@paymentId
		,[intBillId]
		,[intInvoiceId]
		,[intAccountId]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[dblInterest]
		,[dblTotal]
		,[dblWithheld]		
	FROM @paymentDetail

	 SET @createdPaymentId = @paymentId
END