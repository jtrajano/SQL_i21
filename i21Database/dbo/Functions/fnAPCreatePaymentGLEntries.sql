﻿CREATE FUNCTION [dbo].[fnAPCreatePaymentGLEntries]
(
	@transactionIds		NVARCHAR(MAX)
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
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
	DECLARE @WithholdAccount INT, @DiscountAccount INT, @InterestAccount INT;
	DECLARE @userLocation INT;
	DECLARE @applyWithHold BIT = 0, @applyDiscount INT = 0, @applyInterest INT = 0;

	SET @userLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityId = @intUserId);
	IF (@userLocation IS NOT NULL AND @userLocation > 0)
	BEGIN
		SELECT TOP 1
			@WithholdAccount = intWithholdAccountId
			,@DiscountAccount = intDiscountAccountId
			,@InterestAccount = intInterestAccountId
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @userLocation
	END

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.intEntityVendorId
					WHERE A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.ysnWithholding = 1))
	BEGIN
		SET @applyWithHold = 1;
	END

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				WHERE A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.dblDiscount <> 0))
	BEGIN
		SET @applyDiscount = 1;
	END

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				WHERE A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions) AND B.dblInterest <> 0))
	BEGIN
		SET @applyInterest = 1;
	END

	--CREDIT SIDE
	INSERT INTO @returntable
	SELECT
		[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]				=	@batchId,
		[intAccountId]				=	A.intAccountId,
		[dblDebit]					=	0,
		[dblCredit]					=	A.dblAmountPaid,
		[dblDebitUnit]				=	0,
		[dblCreditUnit]				=	0,
		[strDescription]			=	A.strNotes,
		[strCode]					=	'AP',
		[strReference]				=	C.strVendorId,
		[intCurrencyId]				=	A.intCurrencyId,
		[dblExchangeRate]			=	1,
		[dtmDateEntered]			=	GETDATE(),
		[dtmTransactionDate]		=	NULL,
		[strJournalLineDescription]	=	'Posted Payment',
		[intJournalLineNo]			=	1,
		[ysnIsUnposted]				=	0,
		[intUserId]					=	@intUserId,
		[intEntityId]				=	@intUserId,
		[strTransactionId]			=	A.strPaymentRecordNum,
		[intTransactionId]			=	A.intPaymentId,
		[strTransactionType]		=	@SCREEN_NAME,
		[strTransactionForm]		=	@SCREEN_NAME,
		[strModuleName]				=	@MODULE_NAME,
		[intConcurrencyId]			=	1
	FROM	[dbo].tblAPPayment A 
	INNER JOIN tblAPVendor C
		ON A.intEntityVendorId = C.intEntityVendorId
	WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)

	--Withheld
	IF (@applyWithHold = 1 AND @WithholdAccount IS NOT NULL AND @WithholdAccount > 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	@WithholdAccount,
			[dblDebit]					=	0,
			[dblCredit]					=	A.dblWithheld,
			[dblDebitUnit]				=	0,
			[dblCreditUnit]				=	0,
			[strDescription]			=	'Posted Payment - Withheld',
			[strCode]					=	'AP',
			[strReference]				=	A.strNotes,
			[intCurrencyId]				=	1,
			[dblExchangeRate]			=	1,
			[dtmDateEntered]			=	GETDATE(),
			[dtmTransactionDate]		=	NULL,
			[strJournalLineDescription]	=	'Withheld',
			[intJournalLineNo]			=	2,
			[ysnIsUnposted]				=	0,
			[intUserId]					=	@intUserId,
			[intEntityId]				=	@intUserId,
			[strTransactionId]			=	A.strPaymentRecordNum,
			[intTransactionId]			=	A.intPaymentId,
			[strTransactionType]		=	@SCREEN_NAME,
			[strTransactionForm]		=	@SCREEN_NAME,
			[strModuleName]				=	@MODULE_NAME,
			[intConcurrencyId]			=	1
			FROM [dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intAccountId = GLAccnt.intAccountId
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId AND B.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)
	END

	--Discount
	IF(@applyDiscount = 1 AND @DiscountAccount IS NOT NULL AND @DiscountAccount > 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	@DiscountAccount,
			[dblDebit]					=	0,
			[dblCredit]					=	SUM(B.dblDiscount),
			[dblDebitUnit]				=	0,
			[dblCreditUnit]				=	0,
			[strDescription]			=	'Posted Payment - Discount',
			[strCode]					=	'AP',
			[strReference]				=	A.strNotes,
			[intCurrencyId]				=	A.intCurrencyId,
			[dblExchangeRate]			=	1,
			[dtmDateEntered]			=	GETDATE(),
			[dtmTransactionDate]		=	NULL,
			[strJournalLineDescription]	=	'Discount',
			[intJournalLineNo]			=	3,
			[ysnIsUnposted]				=	0,
			[intUserId]					=	@intUserId,
			[intEntityId]				=	@intUserId,
			[strTransactionId]			=	A.strPaymentRecordNum,
			[intTransactionId]			=	A.intPaymentId,
			[strTransactionType]		=	@SCREEN_NAME,
			[strTransactionForm]		=	@SCREEN_NAME,
			[strModuleName]				=	@MODULE_NAME,
			[intConcurrencyId]			=	1
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intEntityVendorId = C.intEntityVendorId
		WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)
		AND 1 = (CASE WHEN B.dblAmountDue = ((B.dblPayment + B.dblDiscount) - B.dblInterest) THEN 1 ELSE 0 END)
		AND B.dblDiscount <> 0 AND B.dblPayment > 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.intCurrencyId,
		A.strNotes,
		A.dtmDatePaid
	END
		
	---- DEBIT SIDE
	INSERT INTO @returntable
	SELECT	
		[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
		[strBatchId]				=	@batchId,
		[intAccountId]				=	B.intAccountId,
		[dblDebit]                  =    SUM(dbo.fnAPGetPaymentDetailPayment(B.intPaymentDetailId)),
		[dblCredit]					=	0,
		[dblDebitUnit]				=	0,
		[dblCreditUnit]				=	0,
		[strDescription]			=	'Posted Payment',
		[strCode]					=	'AP',
		[strReference]				=	A.strNotes,
		[intCurrencyId]				=	A.intCurrencyId,
		[dblExchangeRate]			=	1,
		[dtmDateEntered]			=	GETDATE(),
		[dtmTransactionDate]		=	NULL,
		[strJournalLineDescription]	=	(SELECT strBillId FROM tblAPBill WHERE intBillId = B.intBillId),
		[intJournalLineNo]			=	B.intPaymentDetailId,
		[ysnIsUnposted]				=	0,
		[intUserId]					=	@intUserId,
		[intEntityId]				=	@intUserId,
		[strTransactionId]			=	A.strPaymentRecordNum,
		[intTransactionId]			=	A.intPaymentId,
		[strTransactionType]		=	@SCREEN_NAME,
		[strTransactionForm]		=	@SCREEN_NAME,
		[strModuleName]				=	@MODULE_NAME,
		[intConcurrencyId]			=	1
	FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.intEntityVendorId 
	WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.dblPayment <> 0
	GROUP BY A.[strPaymentRecordNum],
	A.intPaymentId,
	B.intBillId,
	D.strVendorId,
	A.dtmDatePaid,
	A.intCurrencyId,
	A.strNotes,
	B.intPaymentDetailId,
	A.dblAmountPaid,
	B.intAccountId
		
	--Interest
	IF (@applyInterest = 1 AND @InterestAccount IS NOT NULL AND @InterestAccount > 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	@InterestAccount,
			[dblDebit]					=	SUM(B.dblInterest),
			[dblCredit]					=	0,
			[dblDebitUnit]				=	0,
			[dblCreditUnit]				=	0,
			[strDescription]			=	'Posted Payment - Interest',
			[strCode]					=	'AP',
			[strReference]				=	A.strNotes,
			[intCurrencyId]				=	A.intCurrencyId,
			[dblExchangeRate]			=	1,
			[dtmDateEntered]			=	GETDATE(),
			[dtmTransactionDate]		=	NULL,
			[strJournalLineDescription]	=	'Interest',
			[intJournalLineNo]			=	3,
			[ysnIsUnposted]				=	0,
			[intUserId]					=	@intUserId,
			[intEntityId]				=	@intUserId,
			[strTransactionId]			=	A.strPaymentRecordNum,
			[intTransactionId]			=	A.intPaymentId,
			[strTransactionType]		=	@SCREEN_NAME,
			[strTransactionForm]		=	@SCREEN_NAME,
			[strModuleName]				=	@MODULE_NAME,
			[intConcurrencyId]			=	1
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intEntityVendorId = C.intEntityVendorId
		WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)
		AND 1 = (CASE WHEN B.dblAmountDue = ((B.dblPayment + B.dblDiscount) - B.dblInterest) THEN 1 ELSE 0 END)
		AND B.dblInterest <> 0 AND B.dblPayment > 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.intCurrencyId,
		A.strNotes,
		A.dtmDatePaid;
	END

	--OVERPAYMENT
	IF(EXISTS(SELECT 1 FROM tblAPPayment WHERE dblUnapplied > 0 AND intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)))
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	(SELECT TOP 1 intAccountId FROM tblAPPaymentDetail WHERE intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)), --use the first AP account only
			[dblDebit]					=	A.dblUnapplied,
			[dblCredit]					=	0,
			[dblDebitUnit]				=	0,
			[dblCreditUnit]				=	0,
			[strDescription]			=	'Posted Payment - Overpayment',
			[strCode]					=	'AP',
			[strReference]				=	A.strNotes,
			[intCurrencyId]				=	A.intCurrencyId,
			[dblExchangeRate]			=	1,
			[dtmDateEntered]			=	GETDATE(),
			[dtmTransactionDate]		=	NULL,
			[strJournalLineDescription]	=	'Overpayment',
			[intJournalLineNo]			=	3,
			[ysnIsUnposted]				=	0,
			[intUserId]					=	@intUserId,
			[intEntityId]				=	@intUserId,
			[strTransactionId]			=	A.strPaymentRecordNum,
			[intTransactionId]			=	A.intPaymentId,
			[strTransactionType]		=	@SCREEN_NAME,
			[strTransactionForm]		=	@SCREEN_NAME,
			[strModuleName]				=	@MODULE_NAME,
			[intConcurrencyId]			=	1
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId
		WHERE	A.intPaymentId IN (SELECT intTransactionId FROM @tmpTransacions)
		AND A.dblUnapplied > 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		A.dblUnapplied,
		A.intCurrencyId,
		A.strNotes,
		A.dtmDatePaid;
	END

	RETURN
END
