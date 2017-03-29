CREATE FUNCTION [dbo].[fnAPCreatePaymentGLEntries]
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
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
	DECLARE @WithholdAccount INT, @DiscountAccount INT, @InterestAccount INT;
	DECLARE @userLocation INT;
	DECLARE @applyWithHold BIT = 0, @applyDiscount INT = 0, @applyInterest INT = 0;

	SET @userLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @intUserId);
	IF (@userLocation IS NOT NULL AND @userLocation > 0)
	BEGIN
		SELECT TOP 1
			@WithholdAccount = intWithholdAccountId
			,@DiscountAccount = intDiscountAccountId
			,@InterestAccount = intInterestAccountId
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @userLocation
	END

	--DECLARE @tmpTransacions TABLE (
	--	[intTransactionId] [int] PRIMARY KEY,
	--	UNIQUE (intTransactionId)
	--);
	
	--INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.[intEntityId]
					WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.ysnWithholding = 1))
	BEGIN
		SET @applyWithHold = 1;
	END

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.dblDiscount <> 0))
	BEGIN
		SET @applyDiscount = 1;
	END

	IF(EXISTS(SELECT 1 FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds) AND B.dblInterest <> 0))
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
		[dblCredit]					=	CAST(A.dblAmountPaid AS DECIMAL(18,2)),
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
		[intConcurrencyId]			=	1,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]				=	NULL
	FROM	[dbo].tblAPPayment A 
	INNER JOIN tblAPVendor C
		ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)

	--Withheld
	IF (@applyWithHold = 1 AND @WithholdAccount IS NOT NULL AND @WithholdAccount > 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	@WithholdAccount,
			[dblDebit]					=	0,
			[dblCredit]					=	CAST(A.dblWithheld AS DECIMAL(18,2)),
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
			[intConcurrencyId]			=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
			FROM [dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intAccountId = GLAccnt.intAccountId
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.[intEntityId] AND B.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
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
			[dblCredit]					=	CAST(SUM(B.dblDiscount) AS DECIMAL(18,2)),
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
			[intConcurrencyId]			=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intEntityVendorId = C.[intEntityId]
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND 1 = (CASE WHEN B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) THEN 1 ELSE 0 END)
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
		[dblDebit]                  =   CAST(SUM(dbo.fnAPGetPaymentDetailPayment(B.intPaymentDetailId)) AS DECIMAL(18,2)),
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
		[intConcurrencyId]			=	1,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[strRateType]					=	NULL
	FROM	[dbo].tblAPPayment A 
			INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
	WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
	AND B.dblPayment <> 0
	AND B.intInvoiceId IS NULL
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
		
	--INVOICE
	IF EXISTS(SELECT 1 FROM tblAPPaymentDetail A WHERE A.intInvoiceId > 0 AND A.intPaymentId IN (SELECT intId FROM @paymentIds))
	BEGIN
		INSERT INTO @returntable
		SELECT	
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	B.intAccountId,
			[dblDebit]                  =   CAST(SUM(B.dblPayment * -1) AS DECIMAL(18,2)),
			[dblCredit]					=	0,
			[dblDebitUnit]				=	0,
			[dblCreditUnit]				=	0,
			[strDescription]			=	'Posted Receivables',
			[strCode]					=	'AP',
			[strReference]				=	A.strNotes,
			[intCurrencyId]				=	A.intCurrencyId,
			[dblExchangeRate]			=	1,
			[dtmDateEntered]			=	GETDATE(),
			[dtmTransactionDate]		=	NULL,
			[strJournalLineDescription]	=	(SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = B.intInvoiceId),
			[intJournalLineNo]			=	B.intPaymentDetailId,
			[ysnIsUnposted]				=	0,
			[intUserId]					=	@intUserId,
			[intEntityId]				=	@intUserId,
			[strTransactionId]			=	A.strPaymentRecordNum,
			[intTransactionId]			=	A.intPaymentId,
			[strTransactionType]		=	@SCREEN_NAME,
			[strTransactionForm]		=	@SCREEN_NAME,
			[strModuleName]				=	@MODULE_NAME,
			[intConcurrencyId]			=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND B.dblPayment <> 0
		AND B.intInvoiceId IS NOT NULL
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		B.intInvoiceId,
		D.strVendorId,
		A.dtmDatePaid,
		A.intCurrencyId,
		A.strNotes,
		B.intPaymentDetailId,
		A.dblAmountPaid,
		B.intAccountId
	END

	--Interest
	IF (@applyInterest = 1 AND @InterestAccount IS NOT NULL AND @InterestAccount > 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	@InterestAccount,
			[dblDebit]					=	CAST(SUM(B.dblInterest) AS DECIMAL(18,2)),
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
			[intConcurrencyId]			=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intEntityVendorId = C.[intEntityId]
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND 1 = (CASE WHEN B.dblAmountDue = CAST(((B.dblPayment + B.dblDiscount) - B.dblInterest) AS DECIMAL(18,2)) THEN 1 ELSE 0 END)
		AND B.dblInterest <> 0 AND B.dblPayment > 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.intCurrencyId,
		A.strNotes,
		A.dtmDatePaid;
	END

	--OVERPAYMENT
	IF(EXISTS(SELECT 1 FROM tblAPPayment WHERE dblUnapplied > 0 AND intPaymentId IN (SELECT intId FROM @paymentIds)))
	BEGIN
		INSERT INTO @returntable
		SELECT
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	(SELECT TOP 1 intAccountId FROM tblAPPaymentDetail WHERE intPaymentId IN (SELECT intId FROM @paymentIds)), --use the first AP account only
			[dblDebit]					=	CAST(A.dblUnapplied AS DECIMAL(18,2)),
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
			[intConcurrencyId]			=	1,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM [dbo].tblAPPayment A 
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.[intEntityId]
		WHERE	A.intPaymentId IN (SELECT intId FROM @paymentIds)
		AND A.dblUnapplied > 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		A.dblUnapplied,
		A.intCurrencyId,
		A.strNotes,
		A.dtmDatePaid;
	END

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId

	RETURN
END