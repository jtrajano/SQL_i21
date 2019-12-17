﻿CREATE FUNCTION [dbo].[fnAPCreatePaymentGLEntries]
(
	@paymentIds			Id READONLY
	,@intUserId			INT
	,@batchId			NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (38, 20) NULL,
	[strRateType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
	DECLARE @WithholdAccount INT, @DiscountAccount INT, @InterestAccount INT, @GainLossAccount INT;
	DECLARE @userLocation INT;
	DECLARE @applyWithHold BIT = 0, @applyDiscount INT = 0, @applyInterest INT = 0;
	DECLARE @functionalCurrency INT;

	SET @userLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @intUserId);
	IF (@userLocation IS NOT NULL AND @userLocation > 0)
	BEGIN
		SELECT TOP 1
			@WithholdAccount = intWithholdAccountId
			,@DiscountAccount = intDiscountAccountId
			,@InterestAccount = intInterestAccountId
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @userLocation
	END

	SELECT TOP 1 
		@functionalCurrency = intDefaultCurrencyId 
	FROM tblSMCompanyPreference

	SELECT TOP 1 
		@GainLossAccount = intAccountsPayableRealizedId 
	FROM tblSMMultiCurrency

	--DECLARE @tmpTransacions TABLE (
	--	[intTransactionId] [int] PRIMARY KEY,
	--	UNIQUE (intTransactionId)
	--);
	
	--INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	--IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.[intEntityId]
	--				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.ysnWithholding = 1))
	--BEGIN
	--	SET @applyWithHold = 1;
	--END

	--IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	--			WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.dblDiscount <> 0))
	--BEGIN
	--	SET @applyDiscount = 1;
	--END

	--IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	--			WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.dblInterest <> 0))
	--BEGIN
	--	SET @applyInterest = 1;
	--END

	--CREDIT SIDE
	INSERT INTO @returntable
	SELECT   DISTINCT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, P.[dtmDatePaid]), 0) 
		,[strBatchId]					=	@batchId
		,[intAccountId]					=	P.intAccountId
		,[dblDebit]						=	0
	    ,[dblCredit]					=	MainQuery.dblCredit
	    ,[dblDebitUnit]					=	0
		,[dblCreditUnit]				=	0
		,[strDescription]				=	P.strNotes
		,[strCode]						=	'AP'
		,[strReference]					=	C.strVendorId
		,[intCurrencyId]				=	P.intCurrencyId
		,[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId
		,[dblExchangeRate]				=	P.dblExchangeRate
		,[dtmDateEntered]				=	GETDATE()
		,[dtmTransactionDate]			=	NULL
		,[strJournalLineDescription]	=	'Posted Payment'
		,[intJournalLineNo]				=	1
		,[ysnIsUnposted]				=	0
		,[intUserId]					=	@intUserId
		,[intEntityId]					=	@intUserId
		,[strTransactionId]				=	P.strPaymentRecordNum
		,[intTransactionId]				=	P.intPaymentId
		,[strTransactionType]			=	@SCREEN_NAME
		,[strTransactionForm]			=	@SCREEN_NAME
		,[strModuleName]				=	@MODULE_NAME
		,[intConcurrencyId]				=	1
		,[dblDebitForeign]				=	0      
		,[dblDebitReport]				=	0
		,[dblCreditForeign]				=	MainQuery.dblCreditForeign
		,[dblCreditReport]				=	MainQuery.dblCredit
		,[dblReportingRate]				=	0
		,[dblForeignRate]				=	P.dblExchangeRate
		,[strRateType]					=	rateType.strCurrencyExchangeRateType
	FROM (
	SELECT		
			tmpSummaryPayment.intPaymentId
			,ROUND(SUM([dblCredit]),2) as [dblCredit]
			,ROUND(SUM([dblCreditForeign]),2) as [dblCreditForeign]	
	FROM
	(
		SELECT		DISTINCT
					[intPaymentId]					=	A.intPaymentId,
					[dblCredit]	 					=	CASE WHEN A.dblExchangeRate != 1 THEN CAST(
														dbo.fnAPGetPaymentAmountFactor((Details.dblTotal 
															- (CASE WHEN paymentDetail.dblWithheld > 0 THEN (Details.dblTotal * ISNULL(withHoldData.dblWithholdPercent,1)) ELSE 0 END)), 
															paymentDetail.dblPayment, voucher.dblTotal) * ISNULL(NULLIF(A.dblExchangeRate,0),1) 
														AS DECIMAL(18,6)) * (CASE WHEN voucher.intTransactionType NOT IN (1,14) AND A.ysnPrepay = 0 THEN -1 ELSE 1 END)
														ELSE
															CAST(A.dblAmountPaid AS DECIMAL(18,2)) END,
					[dblCreditForeign]				=	
														CASE WHEN A.dblExchangeRate != 1 THEN 
														CAST(
														dbo.fnAPGetPaymentAmountFactor((Details.dblTotal 
															- (CASE WHEN paymentDetail.dblWithheld > 0 THEN (Details.dblTotal * ISNULL(withHoldData.dblWithholdPercent,1)) ELSE 0 END)), 
															paymentDetail.dblPayment, voucher.dblTotal)
														AS DECIMAL(18,6)) * (CASE WHEN voucher.intTransactionType NOT IN (1,14) AND A.ysnPrepay = 0 THEN -1 ELSE 1 END)
														ELSE
															CAST(A.dblAmountPaid AS DECIMAL(18,2)) END,
					paymentDetail.intPaymentDetailId										
				
			FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail paymentDetail ON A.intPaymentId = paymentDetail.intPaymentId
			-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON paymentDetail.intBillId = paymentForex.intBillId
			INNER JOIN tblAPBill voucher ON paymentDetail.intBillId = voucher.intBillId
			CROSS APPLY
			(
				SELECT (R.dblTotal + R.dblTax) AS dblTotal 
				FROM dbo.tblAPBillDetail R
				WHERE R.intBillId = voucher.intBillId
			) Details
			OUTER APPLY (
				SELECT dblWithholdPercent / 100 AS dblWithholdPercent FROM tblSMCompanyLocation WHERE intCompanyLocationId = voucher.intShipToId
			) withHoldData
			-- LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
			WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
			AND paymentDetail.dblPayment != 0 AND paymentDetail.intInvoiceId IS NULL
			-- GROUP BY 
			-- A.intPaymentId, 
			-- A.dblAmountPaid,
			-- Details.dblTotal, 
			-- voucher.dblTotal,
			-- withHoldData.dblWithholdPercent,
			-- A.ysnPrepay , 
			-- A.dblWithheld,
			-- paymentDetail.dblPayment, 
			-- paymentDetail.dblWithheld,
			-- paymentDetail.dblDiscount,
			-- intTransactionType , 
			-- A.dblExchangeRate
			) AS tmpSummaryPayment
			GROUP BY tmpSummaryPayment.intPaymentId
			-- UNION ALL
			-- SELECT		DISTINCT
			-- 		[intPaymentId]					=	A.intPaymentId,
			-- 		[dblCredit]	 					=	CAST(paymentDetail.dblPayment * ISNULL(NULLIF(A.dblExchangeRate,0),1) AS DECIMAL(18,6)),
			-- 		[dblCreditForeign]				=	paymentDetail.dblPayment
			-- FROM	[dbo].tblAPPayment A 
			-- INNER JOIN tblAPPaymentDetail paymentDetail ON A.intPaymentId = paymentDetail.intPaymentId
			-- WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
			-- AND paymentDetail.dblPayment != 0 AND paymentDetail.intInvoiceId > 0

			UNION ALL
			SELECT		DISTINCT
					[intPaymentId]					=	A.intPaymentId,
					[dblCredit]	 					=	 CAST(CASE WHEN E.strTransactionType = 'Invoice' THEN -paymentDetail.dblPayment  ELSE paymentDetail.dblPayment END * ISNULL(NULLIF(A.dblExchangeRate,0),1) AS DECIMAL(18,6)),
					[dblCreditForeign]				=	 CAST(CASE WHEN E.strTransactionType = 'Invoice' THEN -paymentDetail.dblPayment  ELSE paymentDetail.dblPayment END * ISNULL(NULLIF(A.dblExchangeRate,0),1) AS DECIMAL(18,6))
			FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail paymentDetail ON A.intPaymentId = paymentDetail.intPaymentId
			INNER JOIN tblARInvoice E ON E.intInvoiceId = paymentDetail.intInvoiceId
			WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
			AND paymentDetail.dblPayment != 0 AND paymentDetail.intInvoiceId > 0
	)MainQuery	
	INNER JOIN tblAPPayment P on P.intPaymentId = MainQuery.intPaymentId
	INNER JOIN tblAPVendor C ON P.intEntityVendorId = C.[intEntityId]
	INNER JOIN tblAPPaymentDetail paymentDetail ON P.intPaymentId = paymentDetail.intPaymentId
	LEFT JOIN tblSMCurrencyExchangeRateType rateType ON P.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId

	UNION ALL
	--GAIN LOSS
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]					=	@batchId,
		[intAccountId]					=	@GainLossAccount,
		[dblDebit]						=   --CAST(A.dblAmountPaid * A.dblExchangeRate AS DECIMAL(18,2)) -
											-- (CAST(
											-- 	dbo.fnAPGetPaymentAmountFactor((voucherDetail.dblTotal + voucherDetail.dblTax), B.dblPayment + B.dblDiscount - B.dblInterest, voucher.dblTotal) * A.dblExchangeRate
											-- 	AS DECIMAL(18,2))
											-- -
											-- CAST(
											-- 	dbo.fnAPGetPaymentAmountFactor((voucherDetail.dblTotal + voucherDetail.dblTax), B.dblPayment + B.dblDiscount - B.dblInterest, voucher.dblTotal) * voucherDetail.dblRate
											-- 	AS DECIMAL(18,2))) * (CASE WHEN voucher.intTransactionType != 1 AND A.ysnPrepay = 0 THEN -1 ELSE 1 END),
											(CAST(
												dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
														+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
														- B.dblInterest, voucher.dblTotal) * A.dblExchangeRate
												AS DECIMAL(18,2))
											-
											CAST(
												dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
														+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
														- B.dblInterest, voucher.dblTotal) * voucherRate.dblExchangeRate
												AS DECIMAL(18,2))) * (CASE WHEN voucher.intTransactionType NOT IN (1,14) AND A.ysnPrepay = 0 THEN -1 ELSE 1 END),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Gain/Loss',
		[strCode]						=	'AP',
		[strReference]					=	A.strNotes,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	A.dblExchangeRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Gain/Loss',
		[intJournalLineNo]				=	B.intPaymentDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentRecordNum,
		[intTransactionId]				=	A.intPaymentId,
		[strTransactionType]			=	@SCREEN_NAME,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	A.dblExchangeRate,
		[strRateType]					=	rateType.strCurrencyExchangeRateType
	FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
			INNER JOIN tblAPBill voucher ON voucher.intBillId = B.intBillId
			-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON voucher.intBillId = paymentForex.intBillId
			-- INNER JOIN tblAPBillDetail voucherDetail ON voucherDetail.intBillId = voucher.intBillId
			INNER JOIN dbo.fnAPGetVoucherAverageRate() voucherRate ON voucher.intBillId = voucherRate.intBillId
			LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND B.dblPayment <> 0
	AND B.intInvoiceId IS NULL
	AND A.intCurrencyId != @functionalCurrency
	AND (CAST(
												dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
													+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
													- B.dblInterest, voucher.dblTotal) * A.dblExchangeRate
												AS DECIMAL(18,2))
											-
											CAST(
												dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
													+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
													- B.dblInterest, voucher.dblTotal) * voucherRate.dblExchangeRate
												AS DECIMAL(18,2))) != 0
	-- GROUP BY A.[strPaymentRecordNum],
	-- A.dblExchangeRate,
	-- A.intPaymentId,
	-- rateType.strCurrencyExchangeRateType,
	-- voucher.intTransactionType,
	-- B.intBillId,
	-- D.strVendorId,
	-- A.dtmDatePaid,
	-- A.intCurrencyId,
	-- A.strNotes,
	-- B.intPaymentDetailId,
	-- A.dblAmountPaid,
	-- B.intAccountId
	UNION ALL

	--Withheld
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]					=	@batchId,
		[intAccountId]					=	@WithholdAccount,
		[dblDebit]						=	0,
		[dblCredit]						=	A.dblWithheld,--CAST(A.dblWithheld * paymentForex.dblExchangeRate AS DECIMAL(18,2)),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Payment - Withheld',
		[strCode]						=	'AP',
		[strReference]					=	A.strNotes,
		[intCurrencyId]					=	1,
		[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	A.dblExchangeRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Withheld',
		[intJournalLineNo]				=	2,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentRecordNum,
		[intTransactionId]				=	A.intPaymentId,
		[strTransactionType]			=	@SCREEN_NAME,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	A.dblWithheld,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	A.dblExchangeRate,
		[strRateType]					=	rateType.strCurrencyExchangeRateType
		FROM [dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intAccountId = GLAccnt.intAccountId
			-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON A.intPaymentId = paymentForex.intPaymentId
			INNER JOIN tblAPVendor B
				ON A.intEntityVendorId = B.[intEntityId] AND B.ysnWithholding = 1
			LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND A.dblWithheld > 0
	UNION ALL
	--Discount
	SELECT
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]					=	@batchId,
			[intAccountId]					=	loc.intDiscountAccountId,
			[dblDebit]						=	0,
			[dblCredit]						=	CAST(B.dblDiscount * A.dblExchangeRate AS DECIMAL(18,2)),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Posted Payment - Discount',
			[strCode]						=	'AP',
			[strReference]					=	A.strNotes,
			[intCurrencyId]					=	A.intCurrencyId,
			[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
			[dblExchangeRate]				=	A.dblExchangeRate,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Discount',
			[intJournalLineNo]				=	3,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strPaymentRecordNum,
			[intTransactionId]				=	A.intPaymentId,
			[strTransactionType]			=	@SCREEN_NAME,
			[strTransactionForm]			=	@SCREEN_NAME,
			[strModuleName]					=	@MODULE_NAME,
			[intConcurrencyId]				=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	CAST(B.dblDiscount AS DECIMAL(18,2)),
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	A.dblExchangeRate,
			[strRateType]					=	rateType.strCurrencyExchangeRateType
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill B2 ON B2.intBillId = ISNULL(B.intBillId, B.intOrigBillId)
				-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON B2.intBillId = paymentForex.intBillId
				INNER JOIN tblSMCompanyLocation loc ON B2.intShipToId = loc.intCompanyLocationId
				INNER JOIN tblAPVendor C
					ON A.intEntityVendorId = C.[intEntityId]
				LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND 1 = (CASE WHEN B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) THEN 1 ELSE 0 END)
		AND B.dblDiscount <> 0 AND B.dblPayment > 0
		--GROUP BY A.[strPaymentRecordNum],
		--A.intPaymentId,
		--C.strVendorId,
		--A.intCurrencyId,
		--A.strNotes,
		--A.dtmDatePaid
	UNION ALL	
	---- DEBIT SIDE
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]					=	@batchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=  (CAST(
												SUM(
													dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
														+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
														- B.dblInterest, voucher.dblTotal) *  ISNULL(NULLIF(voucherRate.dblExchangeRate,0),1))
											AS DECIMAL(18,2))) * (CASE WHEN voucher.intTransactionType NOT IN (1,14) AND A.ysnPrepay = 0 THEN -1 ELSE 1 END),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Payment',
		[strCode]						=	'AP',
		[strReference]					=	A.strNotes,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherRate.dblExchangeRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	(SELECT strBillId FROM tblAPBill WHERE intBillId = B.intBillId),
		[intJournalLineNo]				=	B.intPaymentDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentRecordNum,
		[intTransactionId]				=	A.intPaymentId,
		[strTransactionType]			=	@SCREEN_NAME,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1,
		[dblDebitForeign]				=	CAST(
												SUM(
													dbo.fnAPGetPaymentAmountFactor(B.dblTotal, B.dblPayment 
													+ (CASE WHEN (B.dblPayment + B.dblDiscount = B.dblAmountDue) THEN B.dblDiscount ELSE 0 END)
													- B.dblInterest, voucher.dblTotal))
											AS DECIMAL(18,2))
											* (CASE WHEN voucher.intTransactionType NOT IN (1,14) AND A.ysnPrepay = 0 THEN -1 ELSE 1 END),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherRate.dblExchangeRate,
		[strRateType]					=	rateType.strCurrencyExchangeRateType
	FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
			INNER JOIN tblAPBill voucher ON voucher.intBillId = B.intBillId
			--INNER JOIN tblAPBillDetail voucherDetail ON voucherDetail.intBillId = voucher.intBillId
			INNER JOIN dbo.fnAPGetVoucherAverageRate() voucherRate ON voucher.intBillId = voucherRate.intBillId
			LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND B.dblPayment <> 0
	AND B.intInvoiceId IS NULL
	GROUP BY A.[strPaymentRecordNum],
	A.dblExchangeRate,
	A.intPaymentId,
	rateType.strCurrencyExchangeRateType,
	rateType.intCurrencyExchangeRateTypeId,
	voucher.intTransactionType,
	--voucherDetail.dblRate,
	voucherRate.dblExchangeRate,
	B.intBillId,
	D.strVendorId,
	A.dtmDatePaid,
	A.ysnPrepay,
	A.intCurrencyId,
	A.strNotes,
	B.intPaymentDetailId,
	A.dblAmountPaid,
	B.intAccountId
	UNION ALL
		
	--INVOICE
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]					=	@batchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=   CAST(CASE WHEN E.strTransactionType = 'Cash Refund' THEN B.dblPayment
											ELSE (B.dblPayment * -1) END * A.dblExchangeRate AS DECIMAL(18,2)),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Receivables',
		[strCode]						=	'AP',
		[strReference]					=	A.strNotes,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	A.dblExchangeRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	(SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = B.intInvoiceId),
		[intJournalLineNo]				=	B.intPaymentDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentRecordNum,
		[intTransactionId]				=	A.intPaymentId,
		[strTransactionType]			=	@SCREEN_NAME,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1,
		[dblDebitForeign]				=	CAST(CASE WHEN E.strTransactionType = 'Cash Refund' THEN B.dblPayment
											ELSE (B.dblPayment * -1) END AS DECIMAL(18,2)),    
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	A.dblExchangeRate,
		[strRateType]					=	NULL
	FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
			INNER JOIN tblARInvoice E ON B.intInvoiceId = E.intInvoiceId
			LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND B.dblPayment <> 0
	AND B.intInvoiceId IS NOT NULL
	--GROUP BY A.[strPaymentRecordNum],
	--A.intPaymentId,
	--B.intInvoiceId,
	--D.strVendorId,
	--A.dtmDatePaid,
	--A.intCurrencyId,
	--A.strNotes,
	--B.intPaymentDetailId,
	--A.dblAmountPaid,
	--B.intAccountId
	UNION ALL
	--Interest
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]					=	@batchId,
		[intAccountId]					=	loc.intInterestAccountId,
		[dblDebit]						=	CAST(B.dblInterest * A.dblExchangeRate AS DECIMAL(18,2)),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	'Posted Payment - Interest',
		[strCode]						=	'AP',
		[strReference]					=	A.strNotes,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	A.dblExchangeRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Interest',
		[intJournalLineNo]				=	3,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strPaymentRecordNum,
		[intTransactionId]				=	A.intPaymentId,
		[strTransactionType]			=	@SCREEN_NAME,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1,
		[dblDebitForeign]				=	CAST(B.dblInterest AS DECIMAL(18,2)),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	A.dblExchangeRate,
		[strRateType]					=	rateType.strCurrencyExchangeRateType
	FROM [dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill B2 ON B2.intBillId = ISNULL(B.intBillId, B.intOrigBillId)
			-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON B2.intBillId = paymentForex.intBillId
			INNER JOIN tblSMCompanyLocation loc ON B2.intShipToId = loc.intCompanyLocationId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.[intEntityId]
			LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND 1 = (CASE WHEN B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) THEN 1 
				  WHEN CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) < B.dblAmountDue THEN 1 
			 ELSE 0 END)
	AND B.dblInterest <> 0 AND B.dblPayment > 0
	--GROUP BY A.[strPaymentRecordNum],
	--A.intPaymentId,
	--C.strVendorId,
	--A.intCurrencyId,
	--A.strNotes,
	--A.dtmDatePaid
	UNION ALL
	--OVERPAYMENT
	SELECT
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]					=	@batchId,
			[intAccountId]					=	(SELECT TOP 1 intAccountId FROM tblAPPaymentDetail WHERE intPaymentId IN (SELECT intId FROM @paymentIds)), --use the first AP account only
			[dblDebit]						=	A.dblUnapplied,--CAST(A.dblUnapplied * paymentForex.dblExchangeRate AS DECIMAL(18,2)),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Posted Payment - Overpayment',
			[strCode]						=	'AP',
			[strReference]					=	A.strNotes,
			[intCurrencyId]					=	A.intCurrencyId,
			[intCurrencyExchangeRateTypeId]=	rateType.intCurrencyExchangeRateTypeId,
			[dblExchangeRate]				=	A.dblExchangeRate,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Overpayment',
			[intJournalLineNo]				=	3,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.strPaymentRecordNum,
			[intTransactionId]				=	A.intPaymentId,
			[strTransactionType]			=	@SCREEN_NAME,
			[strTransactionForm]			=	@SCREEN_NAME,
			[strModuleName]					=	@MODULE_NAME,
			[intConcurrencyId]				=	1,
			[dblDebitForeign]				=	CAST(A.dblUnapplied AS DECIMAL(18,2)),      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	A.dblExchangeRate,
			[strRateType]					=	rateType.strCurrencyExchangeRateType
		FROM [dbo].tblAPPayment A 
			-- INNER JOIN dbo.fnAPGetPaymentForexRate() paymentForex ON A.intPaymentId = paymentForex.intPaymentId
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.[intEntityId]
				LEFT JOIN tblSMCurrencyExchangeRateType rateType ON A.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND A.dblUnapplied > 0
		--GROUP BY A.[strPaymentRecordNum],
		--A.intPaymentId,
		--A.dblUnapplied,
		--A.intCurrencyId,
		--A.strNotes,
		--A.dtmDatePaid
	

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId

	RETURN
END