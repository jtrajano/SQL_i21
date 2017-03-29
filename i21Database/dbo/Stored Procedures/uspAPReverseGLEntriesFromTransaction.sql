CREATE PROCEDURE [dbo].[uspAPReverseGLEntriesFromTransaction]
		@transactionIds		NVARCHAR(MAX)
		,@dtmDateReverse	DATETIME = NULL 
		,@intUserId			INT
		,@setUnposted		BIT = 1
		,@transactionType	NVARCHAR(50)
		,@userId			INT
AS

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 

DECLARE @strBatchId AS NVARCHAR(40)
EXEC uspSMGetStartingNumber 3, @strBatchId OUT

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25)

CREATE TABLE #tmpTransacions (
	[intTransactionId] [int] PRIMARY KEY,
	UNIQUE (intTransactionId)
);
INSERT INTO #tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

--Units
--SELECT	
--	A.[dblLbsPerUnit]
--	, B.[intAccountId]
--INTO #tmpGLUnits
--FROM tblGLAccountUnit A 
--	INNER JOIN tblGLAccount B 
--		ON A.[intAccountUnitId] = B.[intAccountUnitId]

IF @transactionType = 'Bill' OR @transactionType = 'Debit Memo' OR @transactionType = 'Vendor Prepayment'
BEGIN

	SET @SCREEN_NAME = 'Bill'
	--Bill
	INSERT INTO @GLEntries
	(
		[dtmDate] 
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
	)
	--CREDIT
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@strBatchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	A.dblTotal,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	'Posted Bill',
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	CASE WHEN @setUnposted = 1 THEN 0 ELSE 1 END,
		[intUserId]						=	@userId,
		[intEntityId]					=	@userId,
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
				ON A.intEntityVendorId = C.[intEntityId]
			--CROSS APPLY
			--(
			--	SELECT * FROM #tmpGLUnits WHERE intAccountId = A.intAccountId
			--) Units
	WHERE	A.intBillId IN (SELECT intTransactionId FROM #tmpTransacions)
	
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@strBatchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=	B.dblTotal, --Bill Detail
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
		[#tmpTransacions]				=	B.intBillDetailId,
		[ysnIsUnposted]					=	CASE WHEN @setUnposted = 1 THEN 1 ELSE 0 END,
		[intUserId]						=	@userId,
		[intEntityId]					=	@userId,
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
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intBillId IN (SELECT intTransactionId FROM #tmpTransacions)
END

EXEC uspGLBookEntries @GLEntries, 0

