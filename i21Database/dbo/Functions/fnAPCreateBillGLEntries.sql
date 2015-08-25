CREATE FUNCTION [dbo].[fnAPCreateBillGLEntries]
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
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'

	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	INSERT INTO @returntable
	--CREDIT
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	(CASE WHEN A.intTransactionType IN (2, 3) AND A.dblTotal > 0 
													THEN A.dblTotal * -1 ELSE A.dblTotal END) - Taxes.dblTotalICTax,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	CASE WHEN intTransactionType = 1 THEN 'Posted Bill'
												WHEN intTransactionType = 2 THEN 'Posted Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Posted Debit Memo'
											ELSE 'NONE' END,
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A
			LEFT JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			CROSS APPLY (
			--Subtract the tax from IR because IC already entered the gl entries for taxes
				SELECT 
					SUM(D.dblTax) dblTotalICTax
				FROM tblAPBillDetailTax D
				WHERE D.intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail E
											WHERE E.intBillId = A.intBillId
											AND E.intInventoryReceiptItemId IS NOT NULL)
				GROUP BY D.intBillDetailId
			) Taxes
			--CROSS APPLY
			--(
			--	SELECT * FROM #tmpGLUnits WHERE intAccountId = A.intAccountId
			--) Units
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=	CASE WHEN A.intTransactionType IN (2, 3) AND A.dblTotal > 0  THEN B.dblTotal * (-1) ELSE B.dblTotal END, --Bill Detail
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	B.strMiscDescription,
		[intJournalLineNo]				=	B.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			LEFT JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			LEFT JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--TAXES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax) ELSE SUM(D.dblTax) END,
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	'Purchase Tax',
		[intJournalLineNo]				=	D.intBillDetailTaxId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	'Bill',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			INNER JOIN tblAPBillDetailTax D
				ON B.intBillDetailId = D.intBillDetailId
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND A.intTransactionType = 1
	AND 1 = (
		--create tax only from item receipt if it is adjusted
		CASE WHEN B.intInventoryReceiptItemId IS NOT NULL AND D.ysnTaxAdjusted = 0 THEN 0 ELSE 1 END
	)
	GROUP BY A.dtmDate
	,D.ysnTaxAdjusted
	,D.intAccountId
	,A.strReference
	,C.strVendorId
	,D.intBillDetailTaxId
	,A.intCurrencyId
	,A.strBillId
	,A.intBillId
	
	RETURN
END
