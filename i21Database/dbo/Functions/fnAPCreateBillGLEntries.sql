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
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblSourceUnitCredit]		NUMERIC(18, 9)	NULL,
	[dblSourceUnitDebit]		NUMERIC(18, 9)	NULL,
	[intCommodityId]			INT				NULL,
	[intSourceLocationId]		INT				NULL,
	[strSourceDocumentId]       NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
	DECLARE @SYSTEM_CURRENCY NVARCHAR(25) = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)
	DECLARE @OtherChargeTaxes AS NUMERIC(18, 6),
			@ReceiptId as INT,
			@VendorId AS INT;
	DECLARE @tmpTransacions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	-- Get Total Value of Other Charges Taxes
	 --SELECT @ReceiptId = IRI.intInventoryReceiptId
	 --	 FROM tblAPBillDetail APB
	 --INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = APB.intInventoryReceiptItemId
	 --WHERE APB.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	 --print @ReceiptId

	  --SELECT TOP 1 @VendorId = intEntityVendorId FROM tblAPBill WHERE intBillId IN (SELECT intTransactionId FROM @tmpTransacions)

	 --SELECT @OtherChargeTaxes = SUM(CASE 
		--	  WHEN ReceiptCharge.ysnPrice = 1
		--	   THEN ISNULL(ReceiptCharge.dblTax,0) * -1
		--	  ELSE ISNULL(ReceiptCharge.dblTax,0) 
		--	 END )
	 --FROM tblICInventoryReceiptCharge ReceiptCharge
	 --WHERE ReceiptCharge.intInventoryReceiptId = @ReceiptId AND ReceiptCharge.intEntityVendorId = @VendorId --get the charges only for that vendor
	 --print @OtherChargeTaxes

	INSERT INTO @returntable
	--CREDIT
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	 
											--CAST(CASE WHEN ForexRate.dblRate > 0 
											--	 THEN  (CASE WHEN A.intTransactionType IN (2, 3, 11) AND Details.dblTotal > 0 THEN Details.dblTotal * -1 
											--		 ELSE Details.dblTotal END) * ISNULL(NULLIF(Details.dblRate,0),1) 
											--ELSE (
											--		(CASE WHEN A.intTransactionType IN (2, 3, 11) AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 
											--		 ELSE A.dblAmountDue END))
											--END AS DECIMAL(18,2)),
											--Subtract the payment on detail total using percentage
											-- CAST(((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
											-- 		 ELSE Details.dblTotal END) - (CASE WHEN A.intTransactionType IN (2, 3, 11, 13) 
											-- 												THEN (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal * -1 
											-- 												ELSE (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal END)) * ISNULL(NULLIF(Details.dblRate,0),1) AS DECIMAL(18,2)),
											CAST((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
													 ELSE Details.dblTotal END)  * ISNULL(NULLIF(Details.dblRate,0),1) AS DECIMAL(18,2)),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	ISNULL(Details.dblUnits,0),--ISNULL(units.dblTotalUnits,0),
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	Details.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	ISNULL(NULLIF(Details.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	CASE WHEN intTransactionType = 1 THEN 'Posted Bill'
												WHEN intTransactionType = 2 THEN 'Posted Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Posted Debit Memo'
												WHEN intTransactionType = 13 THEN 'Posted Basis Advance'
												WHEN intTransactionType = 14 THEN 'Posted Deferred Interest'
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
												WHEN intTransactionType = 13 THEN 'Basis Advance'
												WHEN intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	--CAST(((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
											--		 ELSE Details.dblTotal END) - (CASE WHEN A.intTransactionType IN (2, 3, 11, 13) 
											--												THEN (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal * -1 
											--												ELSE (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal END)) AS DECIMAL(18,2)),
											CAST((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
													 ELSE Details.dblTotal END) AS DECIMAL(18,2)),
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]                =    ISNULL(NULLIF(Details.dblRate,0),1),--CASE WHEN ForexRateCounter.ysnUniqueForex = 0 THEN ForexRate.dblRate ELSE 0 END,
		[strRateType]                   =    Details.strCurrencyExchangeRateType,
		[strDocument]					=	D.strName + ' - ' + A.strVendorOrderNumber,
		[strComments]					=	D.strName + ' - ' + Details.strComment,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	Details.dblUnits,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A
			-- CROSS APPLY dbo.fnAPCalculateVoucherUnits(A.intBillId) units	
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			-- CROSS APPLY
			-- (
			-- 	SELECT TOP 1 A.intCurrencyExchangeRateTypeId,B.strCurrencyExchangeRateType,A.dblRate,A.ysnSubCurrency
			-- 	FROM dbo.tblAPBillDetail A 
			-- 	LEFT JOIN dbo.tblSMCurrencyExchangeRateType B ON A.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
			-- 	WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			-- ) ForexRate
			-- CROSS APPLY
			-- (
			-- 	SELECT CASE COUNT(DISTINCT A.dblRate) WHEN 1 THEN 0 ELSE 1 END AS ysnUniqueForex
			-- 	FROM tblAPBillDetail A
			-- 	WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			-- ) ForexRateCounter
			-- OUTER APPLY
			-- (
			-- 	SELECT (R.dblTotal + R.dblTax) AS dblTotal , R.dblRate  AS dblRate
			-- 	FROM dbo.tblAPBillDetail R
			-- 	WHERE R.intBillId = A.intBillId AND dblRate > 0
			-- ) Details
			OUTER APPLY
            (
                SELECT 
					(R.dblTotal) AS dblTotal, 
					R.dblRate  AS dblRate, 
					exRates.intCurrencyExchangeRateTypeId, 
					exRates.strCurrencyExchangeRateType,
					dblUnits = (CASE WHEN item.intItemId IS NULL OR R.intInventoryReceiptChargeId > 0 OR item.strType NOT IN ('Inventory','Finished Good', 'Raw Material') THEN R.dblQtyReceived
									ELSE
									dbo.fnCalculateQtyBetweenUOM(CASE WHEN R.intWeightUOMId > 0 
											THEN R.intWeightUOMId ELSE R.intUnitOfMeasureId END, 
											itemUOM.intItemUOMId, CASE WHEN R.intWeightUOMId > 0 THEN R.dblNetWeight ELSE R.dblQtyReceived END)
								END) * (CASE WHEN A.intTransactionType NOT IN (1,14) THEN -1 ELSE 1 END),
					R.strComment										
                FROM dbo.tblAPBillDetail R
				LEFT JOIN tblICItem item ON item.intItemId = R.intItemId
				LEFT JOIN tblICItemUOM itemUOM ON item.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1
                LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
                WHERE R.intBillId = A.intBillId
				UNION ALL --taxes
				SELECT 
					CASE WHEN charges.intInventoryReceiptChargeId > 0 
								THEN (CASE WHEN (A.intEntityVendorId = receipts.intEntityVendorId)
												AND charges.ysnPrice = 1
											THEN R2.dblAdjustedTax * -1 ELSE R2.dblAdjustedTax END) 
						ELSE R2.dblAdjustedTax
					END 
				-- R2.dblAdjustedTax 
				-- * (CASE WHEN charges.ysnPrice = 1 THEN -1 ELSE 1 END) 
				-- * (CASE WHEN R2.ysnCheckOffTax = 1 THEN -1 ELSE 1 END)
				AS dblTotal ,
				 R.dblRate  AS dblRate, 
				 exRates.intCurrencyExchangeRateTypeId,
				  exRates.strCurrencyExchangeRateType,
				  0,
				  ''
                FROM dbo.tblAPBillDetail R
				INNER JOIN tblAPBillDetailTax R2 ON R.intBillDetailId = R2.intBillDetailId
				LEFT JOIN tblICInventoryReceiptCharge charges
					ON R.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
				LEFT JOIN tblICInventoryReceipt receipts
					ON charges.intInventoryReceiptId = receipts.intInventoryReceiptId
                LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
                WHERE R.intBillId = A.intBillId --AND R.dblTax != 0 AND CAST(R2.dblTax AS DECIMAL(18,2)) != 0
				-- UNION ALL --discount
				-- SELECT
				-- 	(R.dblTotal * (ISNULL(R.dblDiscount,0) / 100)) AS dblTotal
				-- 	,R.dblRate
				-- 	,exRates.intCurrencyExchangeRateTypeId
				-- 	,exRates.strCurrencyExchangeRateType
				-- 	,0
				-- FROM tblAPBillDetail R
				-- LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
				-- WHERE R.dblDiscount <> 0 AND R.intBillId = A.intBillId
            ) Details

			
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--PREPAY, DEBIT MEMO ENTRIES
	UNION ALL
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	C.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	CAST(B.dblAmountApplied AS DECIMAL(18,2)) * ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
		[strDescription]				=	C.strReference,
		[strCode]						=	'AP',
		[strReference]					=	D.strVendorId,
		[intCurrencyId]					=	C.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	ForexRate.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	CASE WHEN C.intTransactionType = 2 THEN 'Applied Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Applied Debit Memo'
												WHEN C.intTransactionType = 13 THEN 'Applied Basis Advance'
												WHEN C.intTransactionType = 14 THEN 'Applied Deferred Interest'
											ELSE 'NONE' END,
		[intJournalLineNo]				=	B.intTransactionId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN C.intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Debit Memo'
												WHEN C.intTransactionType = 13 THEN 'Basis Advance'
												WHEN C.intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	CAST(B.dblAmountApplied AS DECIMAL(18,2)),
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[strRateType]					=	ForexRate.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM tblAPBill A
	INNER JOIN tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
	INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
	LEFT JOIN (tblAPVendor D INNER JOIN tblEMEntity E ON E.intEntityId = D.intEntityId)
				ON C.intEntityVendorId = D.[intEntityId]
	CROSS APPLY
			(
				SELECT TOP 1 A.intCurrencyExchangeRateTypeId,B.strCurrencyExchangeRateType,A.dblRate,A.ysnSubCurrency 
				FROM dbo.tblAPBillDetail A 
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType B ON A.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
				WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			) ForexRate
	WHERE B.ysnApplied = 1
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)

	--PREPAY, DEBIT MEMO ENTRIES AP SIDE
	UNION ALL
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	CAST(B.dblAmountApplied AS DECIMAL(18,2)) * ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
		[strDescription]				=	C.strReference,
		[strCode]						=	'AP',
		[strReference]					=	D.strVendorId,
		[intCurrencyId]					=	C.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	ForexRate.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	CASE WHEN C.intTransactionType = 2 THEN 'Applied Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Applied Debit Memo'
												WHEN C.intTransactionType = 13 THEN 'Applied Basis Advance'
												WHEN C.intTransactionType = 14 THEN 'Applied Deferred Interest'
											ELSE 'NONE' END,
		[intJournalLineNo]				=	B.intTransactionId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN C.intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Debit Memo'
												WHEN C.intTransactionType = 13 THEN 'Basis Advance'
												WHEN C.intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	CAST(B.dblAmountApplied AS DECIMAL(18,2)),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[strRateType]					=	ForexRate.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM tblAPBill A
	INNER JOIN tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
	INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
	LEFT JOIN (tblAPVendor D INNER JOIN tblEMEntity E ON E.intEntityId = D.intEntityId)
				ON C.intEntityVendorId = D.[intEntityId]
	CROSS APPLY
			(
				SELECT TOP 1 A.intCurrencyExchangeRateTypeId,B.strCurrencyExchangeRateType,A.dblRate,A.ysnSubCurrency 
				FROM dbo.tblAPBillDetail A 
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType B ON A.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
				WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			) ForexRate
	WHERE B.ysnApplied = 1
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	voucherDetails.intAccountId,
		[dblDebit]						=	voucherDetails.dblTotal,
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	ISNULL(voucherDetails.dblTotalUnits,0),
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	voucherDetails.strMiscDescription,
		[intJournalLineNo]				=	voucherDetails.intBillDetailId,
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
												WHEN intTransactionType = 13 THEN 'Basis Advance'
												WHEN intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	voucherDetails.dblForeignTotal,
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherDetails.dblRate,
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	D.strName + ' - ' + A.strVendorOrderNumber,
		[strComments]					=	D.strName + ' - ' + voucherDetails.strComment,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	ISNULL(voucherDetails.dblTotalUnits,0),
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			CROSS APPLY dbo.fnAPGetVoucherDetailDebitEntry(A.intBillId) voucherDetails
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	-- UNION ALL
	-- --DISCOUNT
	-- SELECT
	-- 	[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
	-- 	[strBatchID]					=	@batchId,
	-- 	[intAccountId]					=	B.intAccountId,
	-- 	[dblDebit]						=	CAST((B.dblTotal + B.dblTax)* (ISNULL(B.dblDiscount,0) / 100) AS DECIMAL(18,2)) * ISNULL(NULLIF(ForexRate.dblRate,0),1),
	-- 	[dblCredit]						=	0,
	-- 	[dblDebitUnit]					=	0,
	-- 	[dblCreditUnit]					=	0,--ISNULL(A.[dblTotal], 0)  * ISNULL(Units.dblLbsPerUnit, 0),
	-- 	[strDescription]				=	A.strReference,
	-- 	[strCode]						=	'AP',
	-- 	[strReference]					=	D.strVendorId,
	-- 	[intCurrencyId]					=	A.intCurrencyId,
	-- 	[dblExchangeRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
	-- 	[dtmDateEntered]				=	GETDATE(),
	-- 	[dtmTransactionDate]			=	A.dtmDate,
	-- 	[strJournalLineDescription]		=	'Discount',
	-- 	[intJournalLineNo]				=	B.intBillDetailId,
	-- 	[ysnIsUnposted]					=	0,
	-- 	[intUserId]						=	@intUserId,
	-- 	[intEntityId]					=	@intUserId,
	-- 	[strTransactionId]				=	A.strBillId, 
	-- 	[intTransactionId]				=	A.intBillId, 
	-- 	[strTransactionType]			=	CASE WHEN A.intTransactionType = 2 THEN 'Vendor Prepayment'
	-- 											WHEN A.intTransactionType = 3 THEN 'Debit Memo'
	-- 											WHEN A.intTransactionType = 13 THEN 'Basis Advance'
	-- 											WHEN A.intTransactionType = 1 THEN 'Voucher'
	-- 										ELSE 'NONE' END,
	-- 	[strTransactionForm]			=	@SCREEN_NAME,
	-- 	[strModuleName]					=	@MODULE_NAME,
	-- 	[dblDebitForeign]				=	0,      
	-- 	[dblDebitReport]				=	0,
	-- 	[dblCreditForeign]				=	CAST((B.dblTotal + B.dblTax)* (ISNULL(B.dblDiscount,0) / 100) AS DECIMAL(18,2)),
	-- 	[dblCreditReport]				=	0,
	-- 	[dblReportingRate]				=	0,
	-- 	[dblForeignRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
	-- 	[strRateType]					=	ForexRate.strCurrencyExchangeRateType,
	-- 	[strDocument]					=	A.strVendorOrderNumber,
	-- 	[strComments]					=	A.strReference,
	-- 	[intConcurrencyId]				=	1
	-- [dblSourceUnitCredit]			=	0,
	-- [dblSourceUnitDebit]			=	0,
	-- [intCommodityId]				=	A.intCommodityId,
	-- [intSourceLocationId]			=	A.intStoreLocationId
	-- FROM tblAPBill A
	-- INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	-- LEFT JOIN tblAPVendor D ON A.intEntityVendorId = D.[intEntityId]
	-- CROSS APPLY
	-- (
	-- 	SELECT TOP 1 A.intCurrencyExchangeRateTypeId,B.strCurrencyExchangeRateType,A.dblRate,A.ysnSubCurrency
	-- 	FROM dbo.tblAPBillDetail A 
	-- 	LEFT JOIN dbo.tblSMCurrencyExchangeRateType B ON A.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
	-- 	WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	-- ) ForexRate
	-- WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	-- AND B.dblDiscount <> 0
	--COST ADJUSTMENT RECEIPT ITEM
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	voucherDetails.intAccountId,
		[dblDebit]						=	voucherDetails.dblTotal, 
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	voucherDetails.strMiscDescription,
		[intJournalLineNo]				=	voucherDetails.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
												WHEN intTransactionType = 13 THEN 'Basis Advance'
												WHEN intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	voucherDetails.dblForeignTotal,       
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherDetails.dblRate,
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			CROSS APPLY dbo.fnAPGetVoucherReceiptItemCostAdjGLEntry(A.intBillId) voucherDetails
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND voucherDetails.intBillDetailId IS NOT NULL
	--COST ADJUSTMENT STORAGE ITEM
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	voucherDetails.intAccountId,
											-- CASE WHEN B.intCustomerStorageId > 0 THEN [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense')
											-- 	ELSE [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
											-- END,
		[dblDebit]						=	voucherDetails.dblTotal, 
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	voucherDetails.strMiscDescription,
		[intJournalLineNo]				=	voucherDetails.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
												WHEN intTransactionType = 13 THEN 'Basis Advance'
												WHEN intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	voucherDetails.dblForeignTotal,       
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherDetails.dblRate,
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			CROSS APPLY dbo.fnAPGetVoucherStorageItemCostAdjGLEntry(A.intBillId) voucherDetails
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--CHARGES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		--[intAccountId]					=	CASE WHEN D.[intInventoryReceiptChargeId] IS NULL OR D.ysnInventoryCost = 0 THEN B.intAccountId
		--										ELSE dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') END,
		--[intAccountId]					=	dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing'), --AP-3227 always use the AP Clearing Account
		[intAccountId]					=	voucherDetails.intAccountId, --NO NEED TO GET THE ACCOUNT WHEN CREATING GL ENTRIES, ACCOUNT ON TRANSACTION DETAIL SHOULD BE THE ONE TO USE
		[dblDebit]						=	voucherDetails.dblTotal,
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	voucherDetails.dblTotalUnits,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	voucherDetails.strMiscDescription,
		[intJournalLineNo]				=	voucherDetails.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
												WHEN intTransactionType = 13 THEN 'Basis Advance'
												WHEN intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	voucherDetails.dblForeignTotal,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherDetails.dblRate,
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			CROSS APPLY dbo.fnAPGetVoucherChargeItemGLEntry(A.intBillId) voucherDetails
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND voucherDetails.intBillDetailId IS NOT NULL
	UNION ALL
	--TAXES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	voucherDetails.intAccountId, --AP-3227 always use the AP Clearing Account,
		[dblDebit]						=	voucherDetails.dblTotal,
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',	
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	'Purchase Tax',
		[intJournalLineNo]				=	voucherDetails.intBillDetailTaxId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	'Bill',
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	voucherDetails.dblForeignTotal,
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	voucherDetails.dblRate,
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	/*AND 1 = (
		--create tax only from item receipt if it is adjusted / Cost is Adjusted  / third party vendor tax in other charge of receipt (AP-3227) // third party inv shipment vendor tax // PO Tax
		CASE WHEN B.intInventoryReceiptItemId IS NULL AND D.ysnTaxAdjusted = 0 AND B.dblOldCost IS NULL AND B.intInventoryReceiptChargeId IS NULL AND B.intInventoryShipmentChargeId IS NULL AND B.intPurchaseDetailId IS NULL --Commented for AP-3461 
				THEN 0 --AP-2792
		ELSE 1 END
	)*/
	-- GROUP BY A.dtmDate
	-- ,D.ysnTaxAdjusted
	-- ,D.intAccountId
	-- ,A.strReference
	-- ,C.strVendorId
	-- ,D.intBillDetailTaxId
	-- ,A.intCurrencyId
	-- ,A.intTransactionType
	-- ,A.strBillId
	-- ,A.intBillId
	-- ,B.dblRate
	-- ,G.strCurrencyExchangeRateType
	-- ,B.dblOldCost
	-- --,dblTotalTax
	-- ,charges.intInventoryReceiptChargeId
	-- ,charges.ysnPrice
	-- ,receipts.intEntityVendorId
	-- ,A.intEntityVendorId
	-- ,F.intItemId
	-- ,loc.intItemLocationId
	-- ,B.intInventoryReceiptItemId
	-- ,B.intInventoryReceiptChargeId
	UNION ALL 
	--Tax Adjustment
	--When creating tax adjustment gl entry, we have to convert first the adjusted tax to foreign rate (same with original tax) 
	--before subtracting with the original tax to accurately get the difference and avoid .01 discrepancy issue
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAccountId,
		-- [dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
		-- 											THEN (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 
		-- 															THEN 
		-- 																CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
		-- 																		* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
		-- 																	- 
		-- 																	CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
		-- 																* -1
		-- 												WHEN A.intEntityVendorId != receipts.intEntityVendorId --THIRD PARTY
		-- 													THEN 
		-- 														(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
		-- 																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
		-- 															 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
		-- 												END) 
		-- 										ELSE 
		-- 											(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
		-- 														* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
		-- 													- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
		-- 										END
		-- 										* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		[dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',	
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	G.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
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
		-- [dblDebitForeign]				=	CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax) AS DECIMAL(18,2)),
		[dblDebitForeign]				=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),    
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]                   =   B.strComment + ' ' + E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			INNER JOIN tblAPBillDetailTax D
				ON B.intBillDetailId = D.intBillDetailId
			LEFT JOIN tblICInventoryReceiptCharge charges
				ON B.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
			LEFT JOIN tblICInventoryReceipt receipts
				ON charges.intInventoryReceiptId = receipts.intInventoryReceiptId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON G.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
			INNER JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND A.intTransactionType IN (1,3)
	--AND D.dblTax != 0 --include zero because we load the exempted tax, we expect that it will be adjusted to non zero
	-- AND (B.intInventoryReceiptItemId > 0 OR B.intInventoryShipmentChargeId > 0 OR B.intCustomerStorageId > 0) --create tax adjustment only for integration
	AND D.ysnTaxAdjusted = 1
	GROUP BY A.dtmDate
	,D.ysnTaxAdjusted
	,D.intAccountId
	,A.strReference
	,A.strVendorOrderNumber
	,C.strVendorId
	,D.intBillDetailTaxId
	,A.intCurrencyId
	,A.intTransactionType
	,A.strBillId
	,A.intBillId
	,charges.intInventoryReceiptChargeId
	,charges.ysnPrice
	,receipts.intEntityVendorId
	,charges.intEntityVendorId
	,A.intEntityVendorId
	,B.dblRate
	,G.strCurrencyExchangeRateType
	,G.intCurrencyExchangeRateTypeId
	,B.dblOldCost
	,F.intItemId
	,loc.intItemLocationId
	,B.intInventoryReceiptItemId
	,B.intInventoryReceiptChargeId
	,A.intCommodityId
	,A.intStoreLocationId
	,E.strName
	,B.strComment

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
	
	RETURN
END
