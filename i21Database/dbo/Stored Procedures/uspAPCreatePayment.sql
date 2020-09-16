/*
Usage:
1. Creating payment from Bill screen.
2. Creating payment from Importing of bills.

@userId - User that creates the payment
@bankAccount - Bank Account to use on creating payment
@paymentMethod
	1 - Check
	2 - eCheck
	3 - Debit Memos and Payments
	4 - ACH
	5 - Write Off
@paymentInfo - Usually use for echeck
@isPost - Set the payment that will create as posted (usually use for importing)
@post - Will post the payment
*/
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
	@billId AS NVARCHAR(MAX),
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
	DECLARE @lienExists BIT = 0;
	DECLARE @payee NVARCHAR(300);
	DECLARE @lien NVARCHAR(300);
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT 
		TOP 1 @vendorId = C.[intEntityId] 
		,@vendorWithhold = C.ysnWithholding
		,@location = A.intShipToId
		,@paymentMethodId = CASE WHEN @paymentMethodId IS NULL THEN C.intPaymentMethodId ELSE @paymentMethodId END
		,@payToAddress = A.intPayToAddressId
		,@currency = A.intCurrencyId
		,@payee = loc.strCheckPayeeName
		FROM tblAPBill A
		INNER JOIN  #tmpBillsId B
			ON A.intBillId = B.intID
		INNER JOIN tblAPVendor C
			ON A.[intEntityVendorId] = C.[intEntityId]
		LEFT JOIN tblEMEntityLocation loc
			ON loc.intEntityLocationId = A.intPayToAddressId

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

	--Compute Discount Here, if there is no value computed or added
	UPDATE A
		SET dblDiscount = CAST(dbo.fnGetDiscountBasedOnTerm(ISNULL(@datePaid, GETDATE()), A.dtmBillDate, A.intTermsId, A.dblTotal) AS DECIMAL(18,2))
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId) AND A.intTransactionType = 1
	AND A.dblDiscount = 0

	--This is usually discount from origin or discount calculated in voucher side
	SELECT
		@discount = SUM(ISNULL(A.dblDiscount,0))
	FROM tblAPBill A
	WHERE 
		A.intBillId IN (SELECT intID FROM #tmpBillsId)
	AND A.ysnIsPaymentScheduled = 0

	--Compute Interest Here
	UPDATE A
		SET dblInterest = dbo.fnGetInterestBasedOnTerm(A.dblTotal, A.dtmBillDate, ISNULL(@datePaid, GETDATE()), NULL, A.intTermsId)
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId) AND A.intTransactionType = 1

	SELECT
		@interest = SUM(ISNULL(A.dblInterest,0))
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId)
	
	IF ((SELECT COUNT(*) FROM #tmpBillsId) = 1) SET @autoPay = 1

	IF @autoPay = 1 AND @amountPaid IS NULL AND @isPost = 0
	BEGIN
		SET @amountPaid = (
							SELECT SUM(dblAmountDue)
							FROM 
							(
							SELECT 
								((SUM(dblTotal) - SUM(ISNULL(appliedPrepays.dblPayment, 0))) - SUM(dblPaymentTemp)) dblAmountDue
							FROM tblAPBill A
							OUTER APPLY (
								SELECT SUM(APD.dblAmountApplied) AS dblPayment
								FROM tblAPAppliedPrepaidAndDebit APD
								WHERE APD.intBillId = A.intBillId AND APD.ysnApplied = 1
							) appliedPrepays
							WHERE 
								A.intBillId IN (SELECT intID FROM #tmpBillsId)
							AND A.ysnIsPaymentScheduled = 0
							UNION ALL
							SELECT SUM(dblPayment - dblDiscount) dblAmountDue
							FROM tblAPVoucherPaymentSchedule B
							WHERE 
								B.intBillId IN (SELECT intID FROM #tmpBillsId)
							AND B.ysnPaid = 0 AND B.ysnInPayment = 0
							) paymentData
						) 
		SET @amountPaid = @amountPaid + @interest - ISNULL(@discount,0)
		SET @detailAmountPaid = @amountPaid; --discount subtracted
	END
	ELSE
	BEGIN
		SET @amountPaid = @amountPaid + @interest - @discount;
	END

	--SUBTRACT THE ALREADY SAVED PAYMENTS
	DECLARE @ysnInPayment AS BIT = 0;
	SELECT @ysnInPayment =  ysnInPayment
	FROM tblAPBill
	WHERE intBillId IN (SELECT intID FROM #tmpBillsId)
	IF @ysnInPayment = 1
	BEGIN
		RAISERROR('This transaction is already saved in other payments.', 16, 1);
		RETURN;
	END

	--Compute Withheld Here
	--Compute only if the payment that will create is posted
	IF @vendorWithhold = 1 AND @isPost = 0
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

	SET @lien =  STUFF((
								SELECT DISTINCT ' and ' + strName
								FROM tblAPVendorLien LIEN
								INNER JOIN tblEMEntity ENT ON LIEN.intEntityLienId = ENT.intEntityId
								WHERE LIEN.intEntityVendorId = @vendorId AND LIEN.ysnActive = 1 AND ISNULL(@datePaid,GETDATE()) BETWEEN LIEN.dtmStartDate AND LIEN.dtmEndDate
								FOR XML PATH('')), 
								1, 1, '')
	IF @lien IS NOT NULL
	BEGIN
		SET @payee = @payee + ' ' + @lien
		SET @lienExists = 1;
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
		[strPayee],
		[strPaymentRecordNum],
		[strNotes],
		[dtmDatePaid],
		[dblAmountPaid],
		[dblUnapplied],
		[dblExchangeRate],
		[ysnPosted],
		[dblWithheld],
		[intEntityId],
		[ysnLienExists],
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
		[strPayee]				= @payee,
		[strPaymentRecordNum]	= @paymentRecordNum,
		[strNotes]				= @notes,
		[dtmDatePaid]			= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(@datePaid, GETDATE())), 0),
		[dblAmountPaid]			= CAST(ISNULL(@payment,0) AS DECIMAL(18,2)),
		[dblUnapplied]			= 0,
		[dblExchangeRate]		= @rate,
		[ysnPosted]				= @isPost,
		[dblWithheld]			= CAST(ISNULL(@withholdAmount,0) AS DECIMAL(18,2)),
		[intEntityId]			= @userId,
		[ysnLienExists]			= @lienExists,
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
		[dblTotal],
		[ysnOffset],
		[intPayScheduleId])
	SELECT 
		[intPaymentId],
		[intBillId],
		[intAccountId],
		[dblDiscount],
		[dblWithheld],
		dblAmountDue,
		(dblPayment) - dblDiscount + dblInterest,
		[dblInterest],
		dblTotal,
		[ysnOffset],
		[intPayScheduleId]
		FROM (
			SELECT 
				[intPaymentId]	= @paymentId,
				[intBillId]		= A.intBillId,
				[intAccountId]	= CASE WHEN A.intTransactionType = 2 AND A.ysnPrepayHasPayment = 0 THEN details.intAccountId ELSE A.intAccountId END,
				[dblDiscount]	= ISNULL(C.dblDiscount, A.dblDiscount),
				[dblWithheld]	= CAST(@withholdAmount * @rate AS DECIMAL(18,2)),
				[dblAmountDue]	= ISNULL(C.dblPayment, A.dblAmountDue
									--CAST((B.dblTotal + B.dblTax) - ((ISNULL(A.dblPayment,0) / A.dblTotal) * (B.dblTotal + B.dblTax)) AS DECIMAL(18,2)) --handle transaction with prepaid
								),
				[dblPayment]	= ISNULL(C.dblPayment,
									((A.dblTotal - ISNULL(appliedPrepays.dblPayment, 0)) - A.dblPaymentTemp)
									--CAST((B.dblTotal + B.dblTax) - ((ISNULL(A.dblPayment,0) / A.dblTotal) * (B.dblTotal + B.dblTax)) AS DECIMAL(18,2))
								  ),
				[dblInterest]	= A.dblInterest,
				[dblTotal]		= ISNULL(C.dblPayment, A.dblTotal),
				[ysnOffset]		= CAST
									(
										CASE 
										WHEN A.intTransactionType = 1  THEN 0
										WHEN A.intTransactionType = 14 THEN 0
										WHEN A.intTransactionType = 2 AND A.ysnPrepayHasPayment = 0 THEN 0
										WHEN A.intTransactionType = 13 AND A.ysnPrepayHasPayment = 0 THEN 0
										ELSE 1 END
									AS BIT),
				[intPayScheduleId]= C.intId
			FROM tblAPBill A
			-- INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			CROSS APPLY
			(
				SELECT TOP 1 intAccountId, intBillId FROM tblAPBillDetail dtls WHERE dtls.intBillId = A.intBillId
			) details
			LEFT JOIN tblAPVoucherPaymentSchedule C
				ON C.intBillId = A.intBillId AND C.ysnPaid = 0 AND C.ysnInPayment = 0
			OUTER APPLY (
				SELECT SUM(APD.dblAmountApplied) AS dblPayment
				FROM tblAPAppliedPrepaidAndDebit APD
				WHERE APD.intBillId = A.intBillId AND APD.ysnApplied = 1
			) appliedPrepays
			WHERE A.intBillId IN (SELECT [intID] FROM #tmpBillsId)
		) vouchers
	--GROUP BY intPaymentId, intBillId, intAccountId, dblDiscount, dblInterest, dblWithheld, ysnOffset
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
	 @withholdAmount DECIMAL(18, 6),
	 @datePaid DATETIME,
	 @isPost BIT,
	 @payToAddress INT,
	 @rateType INT,
	 @payee NVARCHAR(300),
	 @rate DECIMAL(18,6),
	 @currency INT,
	 @lienExists BIT,
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
	 @withholdAmount = @withholdAmount,
	 @datePaid = @datePaid,
	 @isPost = @isPost,
	 @payToAddress = @payToAddress,
	 @rateType = @rateType,
	 @rate = @rate,
	 @currency = @currency,
	 @payee = @payee,
	 @lienExists = @lienExists,
	 @paymentId = @paymentId OUTPUT;

	EXEC sp_executesql @queryPaymentDetail, 
	N'@paymentId INT,
	@withholdPercent DECIMAL(18,6),
	@rate DECIMAL(18,6),
	@withholdAmount DECIMAL(18,6),
	@paymentDetail DECIMAL(18,6)',
	 @paymentId = @paymentId,
	 @withholdPercent = @withholdPercent,
	 @withholdAmount = @withholdAmount,
	 @rate = @rate,
	 @paymentDetail = @detailAmountPaid;

	--  UPDATE A
	-- 	SET A.dblWithheld = Withheld.dblWithheld
	-- 	,A.dblAmountPaid = CAST((A.dblAmountPaid - Withheld.dblWithheld) AS DECIMAL(18,2))
	--  FROM tblAPPayment A
	--  CROSS APPLY 
	--  (
	-- 	SELECT SUM(dblWithheld) dblWithheld FROM tblAPPaymentDetail B
	-- 	WHERE B.intPaymentId = A.intPaymentId
	--  ) Withheld
	-- WHERE A.intPaymentId = @paymentId

	--UNDO THE DISCOUNT AFTER CREATING PAYMENT AS WE ARE UPDATING THE INTEREST OF VOUCHER ONCE PAYMENT IS POSTED
	UPDATE A
		SET dblInterest = 0
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId)
	AND A.ysnPaid = 0


	UPDATE P  -- updates the strPayee which is displayed in pay voucher details screen
	SET strPayee = dbo.fnAPGetCheckPayee(P.strPaymentRecordNum, P.dtmDatePaid , P.intEntityVendorId, P.intPayToAddressId)
	FROM tblAPPayment P JOIN tblAPPaymentDetail PD
	ON  PD.intPaymentId = P.intPaymentId
	JOIN tblAPBill B on PD.intBillId = B.intBillId
	JOIN #tmpBillsId C ON C.intID = B.intBillId

	 SET @createdPaymentId = @paymentId

	 EXEC uspAPUpdateVoucherPayment @createdPaymentId, 1
END