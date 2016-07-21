﻿/*
Usage:
1. Creating payment from Bill screen.
2. Creating payment from Importing of bills.

@userId - User that creates the payment
@bankAccount - Bank Account to use on creating payment
@paymentMethod
	1 - Check
	2 - eCheck
	3 - Debit memos and Payments
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
	DECLARE @amountPaid NUMERIC(18,6) = @payment;
	DECLARE @withholdAmount NUMERIC(18,6)
	DECLARE @withholdPercent NUMERIC(18,6)
	DECLARE @discountAmount NUMERIC(18,6) = 0;
	DECLARE @paymentMethodId INT = @paymentMethod
	DECLARE @intBankAccountId INT = @bankAccount;
	DECLARE @vendorWithhold BIT = 0;
	DECLARE @intGLBankAccountId INT;
	DECLARE @location INT;
	DECLARE @bills AS Id;
	DECLARE @autoPay BIT = 0; --Automatically compute the payment
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId

	--TODO Allow Multi Vendor
	SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT 
		TOP 1 @vendorId = C.[intEntityVendorId] 
		,@vendorWithhold = C.ysnWithholding
		,@location = A.intShipToId
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

	IF @location IS NULL
	BEGIN
		SET @location = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @userId)
		IF @location IS NULL
		BEGIN
			RAISERROR('Location setup is missing.', 16, 1);
			RETURN;
		END
	END

	--Make sure there is bank account to use
	IF @intBankAccountId IS NULL
	BEGIN
		SELECT @intGLBankAccountId = A.intCashAccount FROM tblSMCompanyLocation A
					WHERE A.intCompanyLocationId = @location

		SELECT TOP 1 @intBankAccountId = intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = @intGLBankAccountId

		IF @intBankAccountId IS NULL
		BEGIN
			RAISERROR('The Cash Account setup is missing on company location.', 16, 1);
			RETURN;
		END
	END

	IF @intGLBankAccountId IS NULL
	BEGIN
		SET @intGLBankAccountId = (SELECT TOP 1 intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId);
	END
		
	--Make sure there is payment method
	IF @paymentMethodId IS NULL
	BEGIN
		SELECT TOP 1 @paymentMethodId = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'
		IF @paymentMethodId IS NULL
		BEGIN
			RAISERROR('There is no check payment method setup.', 16, 1);
			RETURN;
		END
	END

	--Compute Discount Here
	UPDATE A
		SET dblDiscount = dbo.fnGetDiscountBasedOnTerm(ISNULL(@datePaid, GETDATE()), A.dtmDate, A.intTermsId, A.dblTotal)
	FROM tblAPBill A
	WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId)
	--Compute Interest Here
	--UPDATE A
	--	SET dblInterest = dbo.fnGetDiscountBasedOnTerm(ISNULL(@datePaid, GETDATE()), A.dtmDate, A.intTermsId, A.dblTotal)
	--FROM tblAPBill A
	--WHERE A.intBillId IN (SELECT intID FROM #tmpBillsId)

	
	IF ((SELECT COUNT(*) FROM #tmpBillsId) = 1) SET @autoPay = 1

	IF @autoPay = 1 AND @amountPaid IS NULL AND @isPost = 0
	BEGIN
		SET @amountPaid = (SELECT SUM(dblAmountDue) FROM tblAPBill WHERE intBillId IN (SELECT intID FROM #tmpBillsId)) 
		SET @amountPaid = @amountPaid - (SELECT SUM(dblDiscount) FROM tblAPBill WHERE intBillId IN (SELECT intID FROM #tmpBillsId)) 
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
				WHERE A.[intEntityUserSecurityId] = @userId
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
		[dblAmountPaid]			= CAST(ISNULL(@payment,0) AS DECIMAL(18,2)),
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
		[dblWithheld]	= CASE WHEN @withholdPercent > 0 AND A.dblWithheld <= 0 THEN CAST(ROUND(A.dblTotal * (@withholdPercent / 100), 6) AS NUMERIC(18,6)) ELSE A.dblWithheld END,
		[dblAmountDue]	= A.dblAmountDue, -- (A.dblTotal - A.dblDiscount - A.dblPayment),
		[dblPayment]	= CAST((CASE WHEN ISNULL(@payment,0) = 0 THEN 0 ELSE A.dblPayment END) - A.dblDiscount AS DECIMAL(18,2)),
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
	@withholdPercent NUMERIC(18,6),
	@payment NUMERIC(18,6)',
	 @paymentId = @paymentId,
	 @withholdPercent = @withholdPercent,
	 @payment = @amountPaid;

	 UPDATE A
		SET A.dblWithheld = Withheld.dblWithheld
		,A.dblAmountPaid = CAST((A.dblAmountPaid - Withheld.dblWithheld) AS DECIMAL(18,2))
	 FROM tblAPPayment A
	 CROSS APPLY 
	 (
		SELECT SUM(dblWithheld) dblWithheld FROM tblAPPaymentDetail B
		WHERE B.intPaymentId = A.intPaymentId
	 ) Withheld
	WHERE A.intPaymentId = @paymentId
		 
	 SET @createdPaymentId = @paymentId
END