﻿CREATE FUNCTION [dbo].[fnAPCreateBillGLEntries]
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
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
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
		[dblCredit]						=	(CASE WHEN A.intTransactionType IN (2, 3) AND A.dblAmountDue > 0 
													THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END),
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
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A
			LEFT JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			--CROSS APPLY
			--(
			--	SELECT * FROM #tmpGLUnits WHERE intAccountId = A.intAccountId
			--) Units
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--PREPAY, DEBIT MEMO ENTRIES
	UNION ALL
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, C.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	C.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	B.dblAmountApplied,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
		[strDescription]				=	C.strReference,
		[strCode]						=	'AP',
		[strReference]					=	D.strVendorId,
		[intCurrencyId]					=	C.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	NULL,
		[strJournalLineDescription]		=	CASE WHEN C.intTransactionType = 2 THEN 'Applied Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Applied Debit Memo'
											ELSE 'NONE' END,
		[intJournalLineNo]				=	B.intTransactionId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN C.intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Debit Memo'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM tblAPBill A
	INNER JOIN tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
	INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
	LEFT JOIN tblAPVendor D ON C.intEntityVendorId = D.intEntityVendorId
	WHERE B.dblAmountApplied <> 0
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=	(CASE WHEN A.intTransactionType IN (2, 3) THEN B.dblTotal * (-1) 
												ELSE (CASE WHEN B.intInventoryReceiptItemId IS NULL THEN B.dblTotal 
														ELSE 
															(CASE WHEN B.dblOldCost != 0 THEN CAST((B.dblOldCost * B.dblQtyReceived) AS DECIMAL(18,2)) --COST ADJUSTMENT
																ELSE B.dblTotal END)
															+ CAST(ISNULL(Taxes.dblTotalICTax, 0) AS DECIMAL(18,2)) 
														END) --IC Tax
												END), --Bill Detail
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
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			LEFT JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			LEFT JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			OUTER APPLY (
				--Add the tax from IR
				SELECT 
					SUM(D.dblTax) dblTotalICTax
				FROM tblAPBillDetailTax D
				WHERE D.intBillDetailId = B.intBillDetailId
				GROUP BY D.intBillDetailId
			) Taxes
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.intInventoryReceiptChargeId IS NULL --EXCLUDE CHARGES
	--COST ADJUSTMENT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Cost Adjustment'),
		[dblDebit]						=	(CASE WHEN A.intTransactionType IN (1) THEN CAST(((B.dblCost - B.dblOldCost)  * B.dblQtyReceived) AS DECIMAL(18,2)) ELSE 0 END), 
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
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			INNER JOIN tblICItemLocation ItemLoc
				ON A.intShipToId = ItemLoc.intLocationId AND B.intItemId = ItemLoc.intItemId
			LEFT JOIN tblICInventoryReceiptItem E
				ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICInventoryReceiptCharge F
				ON B.intInventoryReceiptChargeId = F.intInventoryReceiptChargeId
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.dblOldCost != 0 AND B.dblCost != B.dblOldCost AND B.intInventoryReceiptItemId IS NOT NULL
	UNION ALL
	--CHARGES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	CASE WHEN D.[intInventoryReceiptChargeId] IS NULL THEN B.intAccountId
												ELSE dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') END,
		[dblDebit]						=	CASE WHEN D.[intInventoryReceiptChargeId] IS NULL THEN B.dblTotal
												ELSE (CASE WHEN A.intTransactionType IN (2, 3) THEN D.dblAmount * (-1) 
														ELSE D.dblAmount
													END)
											END, --Bill Detail
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
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			INNER JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			LEFT JOIN tblICInventoryReceiptItemAllocatedCharge D
				ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
			LEFT JOIN tblICInventoryReceiptItem E
				ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICItem F
				ON E.intItemId = F.intItemId
	WHERE B.intInventoryReceiptChargeId IS NOT NULL
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--TAXES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAccountId,
		--[dblDebit]						=	CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) ELSE SUM(D.dblTax) END,
		[dblDebit]						=	(CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) ELSE SUM(D.dblTax) END)
											* (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END),
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
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	0,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN tblAPVendor C
				ON A.intEntityVendorId = C.intEntityVendorId
			INNER JOIN tblAPBillDetailTax D
				ON B.intBillDetailId = D.intBillDetailId
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND A.intTransactionType IN (1,3)
	AND D.dblTax != 0
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
	,A.intTransactionType
	,A.strBillId
	,A.intBillId
	
	RETURN
END
