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
	DECLARE @SYSTEM_CURRENCY NVARCHAR(25) = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)
	DECLARE @OtherChargeTaxes AS NUMERIC(18, 6),
			@ReceiptId as INT;
	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	-- Get Total Value of Other Charges Taxes
	 SELECT @ReceiptId = IRI.intInventoryReceiptId
	 FROM tblAPBillDetail APB
	 INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = APB.intInventoryReceiptItemId
	 WHERE APB.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	 --print @ReceiptId

	 SELECT @OtherChargeTaxes = SUM(CASE 
			  WHEN ReceiptCharge.ysnPrice = 1
			   THEN ISNULL(ReceiptCharge.dblTax,0) * -1
			  ELSE ISNULL(ReceiptCharge.dblTax,0) 
			 END )
	 FROM tblICInventoryReceiptCharge ReceiptCharge
	 WHERE ReceiptCharge.intInventoryReceiptId = @ReceiptId 
	 --print @OtherChargeTaxes

	INSERT INTO @returntable
	--CREDIT
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	CAST((CASE WHEN A.intTransactionType IN (2, 3, 11) AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 
												  WHEN A.intTransactionType IN (1) AND Rate.dblRate > 0 THEN A.dblAmountDue / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN Rate.dblRate ELSE 1 END)
											 ELSE A.dblAmountDue END) AS DECIMAL(18,2)),
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
			CROSS APPLY
			(
				SELECT TOP 1 dblRate,ysnSubCurrency FROM dbo.tblAPBillDetail A WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			) Rate
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
		[dblCredit]						=	CAST(B.dblAmountApplied / CASE WHEN Rate.dblRate > 0 AND @SYSTEM_CURRENCY != A.intCurrencyId THEN Rate.dblRate ELSE 1 END AS DECIMAL(18,2)),
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
	CROSS APPLY
	(
		SELECT TOP 1 dblRate FROM dbo.tblAPBillDetail A WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	) Rate
	WHERE B.dblAmountApplied <> 0
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	B.intAccountId,
		[dblDebit]						=	CAST(
												
												CASE	WHEN A.intTransactionType IN (2, 3, 11) THEN -B.dblTotal - CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2)) --IC Tax
														ELSE
															CASE	WHEN B.intInventoryReceiptItemId IS NULL THEN B.dblTotal 
																	ELSE 
																		
																		CASE	WHEN B.dblOldCost IS NOT NULL THEN  																				
																					CASE	WHEN B.dblOldCost = 0 THEN 0 
																							ELSE usingOldCost.dblTotal --COST ADJUSTMENT
																					END 
																				ELSE 
																					B.dblTotal 
																		END																		
																		+ CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2)) --IC Tax
															END
															/ 
															CASE WHEN B.dblRate > 0 AND @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END 
															
														END
												AS DECIMAL(18,2)
											), --Bill Detail


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
												WHEN intTransactionType = 11 THEN 'Claim'
												WHEN intTransactionType = 8 THEN 'Overpayment'
												WHEN intTransactionType = 9 THEN '1099 Adjustment'
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
			LEFT JOIN tblICInventoryReceiptItem E
				ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId

			OUTER APPLY (
				--Add the tax from IR
				SELECT 
					SUM(D.dblTax) dblTotalTax
				FROM tblAPBillDetailTax D
				WHERE D.intBillDetailId = B.intBillDetailId
				GROUP BY D.intBillDetailId
			) Taxes
			OUTER APPLY (
				SELECT dblTotal = CAST (
						CASE	
							-- If there is a Gross/Net UOM, compute by the net weight. 
							WHEN E.intWeightUOMId IS NOT NULL THEN 
								-- Convert the Cost UOM to Gross/Net UOM. 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(E.intCostUOMId, E.intUnitMeasureId)
									, E.intWeightUOMId
									, E.dblUnitCost
								) 
								/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END 
								* B.dblNetWeight

							-- If Gross/Net UOM is missing: compute by the receive qty. 
							ELSE 
								-- Convert the Cost UOM to Gross/Net UOM. 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(E.intCostUOMId, E.intUnitMeasureId)
									, E.intUnitMeasureId
									, E.dblUnitCost
								) 
								/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END  
								* B.dblQtyReceived
						END				
						AS DECIMAL(18, 2)
					)
			) usingOldCost



	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.intInventoryReceiptChargeId IS NULL --EXCLUDE CHARGES
	--COST ADJUSTMENT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'),--[dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Auto-Variance'),
		[dblDebit]						=	(CASE	WHEN A.intTransactionType IN (1) THEN (B.dblTotal - usingOldCost.dblTotal)
													WHEN A.intTransactionType IN (1) AND B.dblRate > 0 AND B.ysnSubCurrency = 0 THEN (B.dblTotal - usingOldCost.dblTotal) / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END)
													WHEN A.intTransactionType IN (1) AND B.dblRate > 0 AND B.ysnSubCurrency > 0  THEN (B.dblTotal - usingOldCost.dblTotal) / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END)
											 ELSE 0 END), 

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
			OUTER APPLY (
				SELECT dblTotal = CAST (
						CASE	
							-- If there is a Gross/Net UOM, compute by the net weight. 
							WHEN E.intWeightUOMId IS NOT NULL THEN 
								-- Convert the Cost UOM to Gross/Net UOM. 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(E.intCostUOMId, E.intUnitMeasureId)
									, E.intWeightUOMId
									, E.dblUnitCost
								) 
								* B.dblNetWeight

							-- If Gross/Net UOM is missing: compute by the receive qty. 
							ELSE 
								-- Convert the Cost UOM to Gross/Net UOM. 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(E.intCostUOMId, E.intUnitMeasureId)
									, E.intUnitMeasureId
									, E.dblUnitCost
								) 
								* B.dblQtyReceived
						END				
						AS DECIMAL(18, 2)
					)
			) usingOldCost 


	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.dblOldCost IS NOT NULL AND B.dblCost != B.dblOldCost AND B.intInventoryReceiptItemId IS NOT NULL
	UNION ALL
	--CHARGES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	CASE WHEN D.[intInventoryReceiptChargeId] IS NULL OR D.ysnInventoryCost = 0 THEN B.intAccountId
												ELSE dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') END,
		[dblDebit]						=	CAST(CASE WHEN D.[intInventoryReceiptChargeId] IS NULL THEN B.dblTotal
												 WHEN B.dblRate > 0 AND B.ysnSubCurrency = 0 AND D.[intInventoryReceiptChargeId] IS NULL THEN B.dblTotal / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END) 
												 WHEN B.dblRate > 0 AND B.ysnSubCurrency > 0 AND D.[intInventoryReceiptChargeId] IS NULL THEN B.dblTotal / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END)
												ELSE (CASE WHEN A.intTransactionType IN (2, 3) THEN D.dblAmount * (-1) 
														ELSE 
															(CASE WHEN D.ysnInventoryCost = 0 
																THEN 
																	(CASE WHEN B.dblRate > 0 AND B.ysnSubCurrency > 0 THEN B.dblTotal / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END)
																		  WHEN B.dblRate > 0 AND B.ysnSubCurrency = 0 THEN B.dblTotal / (CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END)
																		ELSE B.dblTotal  END) --Get the amount from voucher if NOT inventory cost
																ELSE D.dblAmount END)
													END)
											END AS DECIMAL(18,2)), --Bill Detail
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
			LEFT JOIN tblICInventoryReceiptCharge D
				ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
			--LEFT JOIN tblICInventoryReceiptItem E
			--	ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
	WHERE B.intInventoryReceiptChargeId IS NOT NULL
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--TAXES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAccountId,
		--[dblDebit]						=	CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) ELSE SUM(D.dblTax) END,
		--[dblDebit]						=	CASE WHEN B.dblOldCost IS NOT NULL THEN 0 ELSE 
		--												(CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) 
		--												WHEN B.dblRate > 0 THEN  CAST(SUM(D.dblTax) / CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END AS DECIMAL(18,2))
		--												ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END) 
		--									END,
		[dblDebit]						=	
											(CASE WHEN B.dblOldCost IS NOT NULL 
												 THEN  																				
												    CASE WHEN B.dblOldCost = 0 THEN 0 
														 WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)  --COST ADJUSTMENT
													END 
												ELSE (CASE  WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)
														WHEN B.dblRate > 0 THEN  CAST(SUM(D.dblTax) / CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END AS DECIMAL(18,2))
														ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END)
											END	),			
		[dblCredit]						=	(CASE WHEN B.dblOldCost IS NOT NULL THEN (CASE WHEN B.dblOldCost = 0 THEN 0 --AP-2458
																						   ELSE CAST((Taxes.dblTotalTax - SUM(D.dblTax)) AS DECIMAL(18,2)) END) 
												  ELSE 0 END),--COST ADJUSTMENT,  --AP-2792
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
			OUTER APPLY (
				SELECT 
					SUM(D.dblTax) dblTotalTax
				FROM tblAPBillDetailTax D
				WHERE D.intBillDetailId = B.intBillDetailId
				GROUP BY D.intBillDetailId
				--SELECT 
				--	SUM(D.dblTax) dblTotalICTax
				--FROM tblICInventoryReceiptItemTax D
				--WHERE D.intInventoryReceiptItemId = B.intInventoryReceiptItemId
				--GROUP BY D.intInventoryReceiptItemId
			) Taxes
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND A.intTransactionType IN (1,3)
	AND D.dblTax != 0
	AND 1 = (
		--create tax only from item receipt if it is adjusted / Cost is Adjusted
		CASE WHEN B.intInventoryReceiptItemId IS NOT NULL AND D.ysnTaxAdjusted = 0 AND B.dblOldCost IS NULL THEN 0 --AP-2792
		ELSE 1 END
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
	,B.dblRate
	,B.dblOldCost
	,dblTotalTax

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
	
	RETURN
END