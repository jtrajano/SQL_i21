CREATE FUNCTION [dbo].[fnAPCreateWriteOffGLEntries]
(
	@prepaymentId		INT
	,@intUserId			INT
	,@batchId			NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
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
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'

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
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]				=	NULL  ,
			[intConcurrencyId]			=	1
		FROM	[dbo].tblAPPayment A 
		INNER JOIN tblAPVendor C
			ON A.intEntityVendorId = C.[intEntityId]
		WHERE	A.intPaymentId IN (@prepaymentId)
		---- DEBIT SIDE
		UNION ALL 
		SELECT	
			[dtmDate]					=	DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0),
			[strBatchId]				=	@batchId,
			[intAccountId]				=	B.intAccountId,
			[dblDebit]					=	SUM(B.dblPayment),
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
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]				=	NULL  ,
			[intConcurrencyId]			=	1
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId] 
		WHERE	A.intPaymentId IN (@prepaymentId)
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
		
	RETURN
END