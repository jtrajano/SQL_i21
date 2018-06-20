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
											CAST(((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
													 ELSE Details.dblTotal END) - (CASE WHEN A.intTransactionType IN (2, 3, 11, 13) 
																							THEN CAST((Details.dblTotal / A.dblTotal) AS DECIMAL(18,2)) * ISNULL(A.dblPayment,0) * -1 
																							ELSE CAST((Details.dblTotal / A.dblTotal) AS DECIMAL(18,2)) * ISNULL(A.dblPayment,0) END)) * ISNULL(NULLIF(Details.dblRate,0),1) AS DECIMAL(18,2)),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	ISNULL(Details.dblUnits,0),--ISNULL(units.dblTotalUnits,0),
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	1,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
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
		[dblCreditForeign]				=	--CAST(((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
											--		 ELSE Details.dblTotal END) - (CASE WHEN A.intTransactionType IN (2, 3, 11, 13) 
											--												THEN (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal * -1 
											--												ELSE (ISNULL(A.dblPayment,0) / A.dblTotal) * Details.dblTotal END)) AS DECIMAL(18,2)),
											CAST(((CASE WHEN A.intTransactionType IN (2, 3, 11, 13) AND Details.dblTotal <> 0 THEN Details.dblTotal * -1 
													 ELSE Details.dblTotal END) - (CASE WHEN A.intTransactionType IN (2, 3, 11, 13) 
																							THEN CAST((Details.dblTotal / A.dblTotal) AS DECIMAL(18,2)) * ISNULL(A.dblPayment,0) * -1 
																							ELSE CAST((Details.dblTotal / A.dblTotal) AS DECIMAL(18,2)) * ISNULL(A.dblPayment,0) END)) AS DECIMAL(18,2)),
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]                =    ISNULL(NULLIF(Details.dblRate,0),1),--CASE WHEN ForexRateCounter.ysnUniqueForex = 0 THEN ForexRate.dblRate ELSE 0 END,
		[strRateType]                   =    Details.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	Details.dblUnits,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A
			CROSS APPLY dbo.fnAPCalculateVoucherUnits(A.intBillId) units	
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			CROSS APPLY
			(
				SELECT TOP 1 A.intCurrencyExchangeRateTypeId,B.strCurrencyExchangeRateType,A.dblRate,A.ysnSubCurrency
				FROM dbo.tblAPBillDetail A 
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType B ON A.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
				WHERE A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
			) ForexRate
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
					dblUnits = CASE WHEN item.intItemId IS NULL OR item.strType != 'Inventory' THEN 0
									ELSE
									dbo.fnCalculateQtyBetweenUOM(CASE WHEN R.intWeightUOMId > 0 
											THEN R.intWeightUOMId ELSE R.intUnitOfMeasureId 
									END, 
									itemUOM.intItemUOMId, CASE WHEN R.intWeightUOMId > 0 THEN R.dblNetWeight ELSE R.dblQtyReceived END)
				END
                FROM dbo.tblAPBillDetail R
				LEFT JOIN tblICItem item ON item.intItemId = R.intItemId
				LEFT JOIN tblICItemUOM itemUOM ON item.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1
                LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
                WHERE R.intBillId = A.intBillId
				UNION ALL --taxes
				SELECT 
						-- CASE WHEN charges.intInventoryReceiptChargeId > 0 
						-- 			THEN (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 
						-- 						THEN R2.dblAdjustedTax * -1 ELSE R2.dblAdjustedTax END) 
						-- 	ELSE R2.dblAdjustedTax
						-- END 
				R2.dblAdjustedTax AS dblTotal ,
				 R.dblRate  AS dblRate, 
				 exRates.intCurrencyExchangeRateTypeId,
				  exRates.strCurrencyExchangeRateType,
				  0
                FROM dbo.tblAPBillDetail R
				INNER JOIN tblAPBillDetailTax R2 ON R.intBillDetailId = R2.intBillDetailId
				LEFT JOIN tblICInventoryReceiptCharge charges
					ON R.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
				LEFT JOIN tblICInventoryReceipt receipts
					ON charges.intInventoryReceiptId = receipts.intInventoryReceiptId
                LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
                WHERE R.intBillId = A.intBillId AND R.dblTax != 0 AND CAST(R2.dblTax AS DECIMAL(18,2)) != 0
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
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, C.dtmDate), 0),
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
		[dblExchangeRate]				=	ISNULL(NULLIF(ForexRate.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	CASE WHEN C.intTransactionType = 2 THEN 'Applied Vendor Prepayment'
												WHEN C.intTransactionType = 3 THEN 'Applied Debit Memo'
												WHEN C.intTransactionType = 13 THEN 'Applied Basis Advance'
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
	--DEBIT
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	CASE WHEN B.intInventoryShipmentChargeId IS NOT NULL THEN dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') --AP-3492 use AP Clearing if tansaction is From IS
											ELSE B.intAccountId
											END,
		[dblDebit]						=	CAST(
												
												CASE	WHEN A.intTransactionType IN (2, 3, 11, 13) THEN -B.dblTotal /*- CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2))*/ --IC Tax Commented AP-3485
														ELSE
															CASE	WHEN B.intCustomerStorageId > 0 THEN 
																		CASE WHEN B.dblOldCost IS NOT NULL
																		THEN
																			CASE WHEN B.dblOldCost = 0 THEN 0 ELSE storageOldCost.dblPaidAmount END
																		ELSE B.dblTotal
																		END
																	WHEN B.intInventoryReceiptItemId IS NULL THEN B.dblTotal 
																	ELSE 
																		CASE	WHEN B.dblOldCost IS NOT NULL THEN  																				
																					CASE	WHEN B.dblOldCost = 0 THEN 0 
																							ELSE usingOldCost.dblTotal --COST ADJUSTMENT
																					END 
																				ELSE 
																					B.dblTotal 
																		END																		
																		--+ CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2)) --IC Tax Commented AP-3485
															END
															
															
														END
												* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) , --Bill Detail
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	ISNULL(units.dblTotalUnits,0),
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
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
												WHEN intTransactionType = 13 THEN 'Basis Advance'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	CAST(
												
												CASE	WHEN A.intTransactionType IN (2, 3, 11, 13) THEN -B.dblTotal /*- CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2))*/ --IC Tax Commented AP-3485
														ELSE
															CASE	WHEN B.intCustomerStorageId > 0 THEN 
																		CASE WHEN B.dblOldCost IS NOT NULL
																		THEN
																			CASE WHEN B.dblOldCost = 0 THEN 0 ELSE storageOldCost.dblPaidAmount END
																		ELSE B.dblTotal
																		END
																	WHEN B.intInventoryReceiptItemId IS NULL THEN B.dblTotal 
																	ELSE 
																		
																		CASE	WHEN B.dblOldCost IS NOT NULL THEN  																				
																					CASE	WHEN B.dblOldCost = 0 THEN 0 
																							ELSE usingOldCost.dblTotal --COST ADJUSTMENT
																					END 
																				ELSE 
																					B.dblTotal 
																		END																		
																		--+ CAST(ISNULL(Taxes.dblTotalTax + ISNULL(@OtherChargeTaxes,0), 0) AS DECIMAL(18,2)) --IC Tax Commented AP-3485
														END
														END
												AS DECIMAL(18,2)
											), --Bill Detail Foreign,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	ISNULL(units.dblTotalUnits,0),
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			LEFT JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			--CROSS APPLY dbo.fnAPCalculateVoucherDetailUnits(B.intBillDetailId) units
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			LEFT JOIN tblICInventoryReceiptItem E
				ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICInventoryReceiptCharge charges
				ON B.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId
			LEFT JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
			LEFT JOIN tblICItemUOM itemUOM ON F.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1					
			OUTER APPLY( --	AP-4269 TIMEOUT ISSUE
					SELECT
							(CASE WHEN item.intItemId IS NULL OR item.strType != 'Inventory' THEN 0 ELSE
														CASE WHEN item.strType = 'Inventory' THEN --units is only of inventory item
															dbo.fnCalculateQtyBetweenUOM((CASE WHEN billDetails.intWeightUOMId > 0 
																							THEN billDetails.intWeightUOMId ELSE billDetails.intUnitOfMeasureId END), 
																						itemUOM.intItemUOMId,
																						CASE WHEN billDetails.intWeightUOMId > 0 THEN billDetails.dblNetWeight ELSE billDetails.dblQtyReceived END)
														ELSE 0 END
									END) as dblTotalUnits
						FROM tblAPBillDetail billDetails
						LEFT JOIN tblICItem item ON F.intItemId = item.intItemId
						WHERE billDetails.intBillDetailId = B.intBillDetailId	
			) units									
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
						CASE WHEN B.intInventoryReceiptChargeId > 0
						THEN charges.dblAmount
						ELSE (CASE	
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
							END)
						END				
						AS DECIMAL(18, 2)
					)
			) usingOldCost
			OUTER APPLY (
				SELECT TOP 1
					storageHistory.dblPaidAmount
				FROM tblGRSettleStorage storage 
				INNER JOIN tblGRSettleStorageTicket storageTicket ON storage.intSettleStorageId = storageTicket.intSettleStorageId
				INNER JOIN tblGRCustomerStorage customerStorage ON storageTicket.intCustomerStorageId = customerStorage.intCustomerStorageId 
																	AND B.intCustomerStorageId = customerStorage.intCustomerStorageId
				INNER JOIN tblGRStorageHistory storageHistory ON storageHistory.intCustomerStorageId = customerStorage.intCustomerStorageId 
															AND storageHistory.intSettleStorageId = storageTicket.intSettleStorageId
				WHERE B.intBillId = storage.intBillId
			) storageOldCost



	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.intInventoryReceiptChargeId IS NULL --EXCLUDE CHARGES
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
		[intAccountId]					=	CASE WHEN B.intInventoryReceiptChargeId > 0 THEN [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense')
												ELSE [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
											END,
		[dblDebit]						=	CAST((CASE	WHEN A.intTransactionType IN (1) THEN (B.dblTotal - 
															usingOldCost.dblTotal * (CASE WHEN B.intInventoryReceiptChargeId > 0 
																								AND A.intEntityVendorId = F.intEntityVendorId AND F.ysnPrice = 1
																						THEN -1 ELSE 1 END)) 
																				* ISNULL(NULLIF(B.dblRate,0),1) 
											 ELSE 0 END) AS  DECIMAL(18, 2)), 
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
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
		[dblDebitForeign]				=	CAST((CASE WHEN A.intTransactionType IN (1) THEN (B.dblTotal - usingOldCost.dblTotal)
											 ELSE 0 END) AS  DECIMAL(18, 2)),       
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			INNER JOIN tblICItemLocation ItemLoc
				ON A.intShipToId = ItemLoc.intLocationId AND B.intItemId = ItemLoc.intItemId
			LEFT JOIN tblICInventoryReceiptItem E
				ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICInventoryReceiptCharge F
				ON B.intInventoryReceiptChargeId = F.intInventoryReceiptChargeId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId	
			OUTER APPLY (
				SELECT dblTotal = CAST (
							CASE WHEN B.intInventoryReceiptChargeId > 0 
							THEN F.dblAmount
							ELSE 
								(CASE	
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
								END)
							END				
						AS DECIMAL(18, 2)
					)
			) usingOldCost 


	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.dblOldCost IS NOT NULL AND B.dblCost != B.dblOldCost AND B.intInventoryReceiptItemId IS NOT NULL
	AND 1 = (CASE WHEN B.intInventoryReceiptChargeId > 0 AND F.ysnInventoryCost = 0 THEN 1 
			WHEN B.intInventoryReceiptItemId > 0 THEN 1 ELSE 0 END) --created adjustment for charges only if inventory cost yes
	--COST ADJUSTMENT STORAGE ITEM
	UNION ALL 
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'),
											-- CASE WHEN B.intCustomerStorageId > 0 THEN [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense')
											-- 	ELSE [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
											-- END,
		[dblDebit]						=	CAST((CASE	WHEN A.intTransactionType IN (1) THEN (B.dblTotal - 
															storageOldCost.dblPaidAmount * ISNULL(NULLIF(B.dblRate,0),1)) 
											 ELSE 0 END) AS  DECIMAL(18, 2)), 
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
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
		[dblDebitForeign]				=	CAST((CASE WHEN A.intTransactionType IN (1) THEN (B.dblTotal - storageOldCost.dblPaidAmount)
											 ELSE 0 END) AS  DECIMAL(18, 2)),       
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	D.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			INNER JOIN tblICItemLocation ItemLoc
				ON A.intShipToId = ItemLoc.intLocationId AND B.intItemId = ItemLoc.intItemId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId	
			OUTER APPLY (
				SELECT TOP 1
					storageHistory.dblPaidAmount
				FROM tblGRSettleStorage storage 
				INNER JOIN tblGRSettleStorageTicket storageTicket ON storage.intSettleStorageId = storageTicket.intSettleStorageId
				INNER JOIN tblGRCustomerStorage customerStorage ON storageTicket.intCustomerStorageId = customerStorage.intCustomerStorageId 
																	AND B.intCustomerStorageId = customerStorage.intCustomerStorageId
				INNER JOIN tblGRStorageHistory storageHistory ON storageHistory.intCustomerStorageId = customerStorage.intCustomerStorageId 
															AND storageHistory.intSettleStorageId = storageTicket.intSettleStorageId
				WHERE B.intBillId = storage.intBillId
			) storageOldCost 
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND B.dblOldCost IS NOT NULL AND B.dblCost != B.dblOldCost
	AND B.intCustomerStorageId IS NOT NULL
	UNION ALL
	--CHARGES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		--[intAccountId]					=	CASE WHEN D.[intInventoryReceiptChargeId] IS NULL OR D.ysnInventoryCost = 0 THEN B.intAccountId
		--										ELSE dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing') END,
		--[intAccountId]					=	dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing'), --AP-3227 always use the AP Clearing Account
		[intAccountId]					=	B.intAccountId, --NO NEED TO GET THE ACCOUNT WHEN CREATING GL ENTRIES, ACCOUNT ON TRANSACTION DETAIL SHOULD BE THE ONE TO USE
		[dblDebit]						=	CAST(CASE WHEN B.dblOldCost IS NULL THEN B.dblTotal 
												 ELSE (CASE WHEN A.intEntityVendorId = D.intEntityVendorId AND D.ysnPrice = 1 
												 			THEN D.dblAmount * -1 
															 ELSE D.dblAmount
															END)
												 		--D.dblAmount--(CASE WHEN D.ysnInventoryCost = 0 THEN D.dblAmount ELSE B.dblTotal END)
													--commented on AP-3227, taxes for other charges should not be added here as it is already part of taxes entries
											END 
											* ISNULL(NULLIF(B.dblRate,0),1) 
											* CASE WHEN A.intTransactionType IN (2, 3, 13) THEN (-1) 
														ELSE 1 END AS DECIMAL(18,2)),
		[dblCredit]						=	0, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
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
												WHEN intTransactionType = 13 THEN 'Basis Advance'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	CAST(CASE WHEN B.dblOldCost IS NULL THEN B.dblTotal 
												 ELSE D.dblAmount--(CASE WHEN D.ysnInventoryCost = 0 THEN D.dblAmount ELSE B.dblTotal END)
													--commented on AP-3227, taxes for other charges should not be added here as it is already part of taxes entries
												 END 
											-- * ISNULL(NULLIF(B.dblRate,0),1) 
											* CASE WHEN A.intTransactionType IN (2, 3, 13) THEN (-1) 
														ELSE 1 END AS DECIMAL(18,2)),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM	[dbo].tblAPBill A 
			INNER JOIN [dbo].tblAPBillDetail B
				ON A.intBillId = B.intBillId
			CROSS APPLY dbo.fnAPCalculateVoucherDetailUnits(B.intBillDetailId) units
			INNER JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			INNER JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
				ON A.intEntityVendorId = C.[intEntityId]
			LEFT JOIN tblICInventoryReceiptCharge D
				ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
			--LEFT JOIN tblICInventoryReceiptItem E
			--	ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON G.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
	WHERE B.intInventoryReceiptChargeId IS NOT NULL
	AND A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	UNION ALL
	--TAXES
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	CASE WHEN B.intInventoryReceiptItemId IS NOT NULL OR B.intInventoryReceiptChargeId IS NOT NULL
												 THEN  dbo.[fnGetItemGLAccount](F.intItemId, loc.intItemLocationId, 'AP Clearing')
												 ELSE D.intAccountId
											END, --AP-3227 always use the AP Clearing Account,
		--[dblDebit]						=	CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) ELSE SUM(D.dblTax) END,
		--[dblDebit]						=	CASE WHEN B.dblOldCost IS NOT NULL THEN 0 ELSE 
		--												(CASE WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax) 
		--												WHEN B.dblRate > 0 THEN  CAST(SUM(D.dblTax) / CASE WHEN @SYSTEM_CURRENCY != A.intCurrencyId THEN B.dblRate ELSE 1 END AS DECIMAL(18,2))
		--												ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END) 
		--									END,
		--[dblDebit]						=	(CASE WHEN B.dblOldCost IS NOT NULL 
		--										 THEN  																				
		--										    CASE WHEN B.dblOldCost = 0 THEN 0 
		--												 WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)  --COST ADJUSTMENT
		--											END 
		--										ELSE (CASE  WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)
		--													ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END)
		--									END) * ISNULL(NULLIF(B.dblRate,0),1),		
		--[dblCredit]						=	(CASE WHEN B.dblOldCost IS NOT NULL THEN (CASE WHEN B.dblOldCost = 0 THEN 0 --AP-2458
		--																				   ELSE CAST((Taxes.dblTotalTax - SUM(D.dblTax)) AS DECIMAL(18,2)) END) 
		--										  ELSE 0 END),--COST ADJUSTMENT,  --AP-2792
		[dblDebit]						=	
											-- ROUND(CASE WHEN charges.intInventoryReceiptChargeId > 0 
											-- 		THEN (D.dblTax / B.dblTax) * B.dblTax
											-- 			* (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 THEN -1 ELSE 1 END)
											-- ELSE (D.dblTax / B.dblTax) * B.dblTax END 
											ROUND((D.dblTax * ISNULL(NULLIF(B.dblRate,0),1)) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END), 2),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',	
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
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
		[dblDebitForeign]				=	
											-- ROUND(CASE WHEN charges.intInventoryReceiptChargeId > 0 
											-- 		THEN (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 THEN D.dblTax * -1 
											-- 				--WHEN A.intEntityVendorId != receipts.intEntityVendorId --THIRD PARTY
											-- 					ELSE D.dblTax
											-- 		END) 
											-- ELSE D.dblTax END 
											ROUND(D.dblTax * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END), 2),
		-- [dblDebitForeign]				=	SUM(D.dblTax) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END),
		--[dblDebitForeign]				=	(CASE WHEN B.dblOldCost IS NOT NULL 
		--										 THEN  																				
		--										    CASE WHEN B.dblOldCost = 0 THEN 0 
		--												 WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)  --COST ADJUSTMENT
		--											END 
		--										ELSE (CASE  WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)
		--													ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END)
		--									END),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
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
			LEFT JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
			--OUTER APPLY (
			--	SELECT 
			--		SUM(D.dblTax) dblTotalTax
			--	FROM tblAPBillDetailTax D
			--	WHERE D.intBillDetailId = B.intBillDetailId
			--	GROUP BY D.intBillDetailId
			--) Taxes
	WHERE	A.intBillId IN (SELECT intTransactionId FROM @tmpTransacions)
	AND A.intTransactionType IN (1,3)
	AND D.dblTax != 0
	AND ROUND(CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (D.dblTax / B.dblTax) * B.dblTax
														* (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 THEN -1 ELSE 1 END)
											ELSE (D.dblTax / B.dblTax) * B.dblTax END * ISNULL(NULLIF(B.dblRate,0),1) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END), 2) != 0
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
	UNION ALL --Tax Adjustment
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CAST(CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 1 
																	THEN (SUM(ISNULL(NULLIF(D.dblAdjustedTax,0), D.dblTax)) - SUM(D.dblTax)) * -1
														WHEN A.intEntityVendorId != receipts.intEntityVendorId --THIRD PARTY
															THEN (SUM(ISNULL(NULLIF(D.dblAdjustedTax,0), D.dblTax)) - SUM(D.dblTax))
													END) * ISNULL(NULLIF(B.dblRate,0),1) 
											ELSE (SUM(ISNULL(NULLIF(D.dblAdjustedTax,0), D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) END
											* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) AS DECIMAL(18,2)),
		--[dblDebit]						=	(SUM(ISNULL(NULLIF(D.dblAdjustedTax,0), D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',	
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
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
		[dblDebitForeign]				=	(SUM(ISNULL(NULLIF(D.dblAdjustedTax,0), D.dblTax)) - SUM(D.dblTax)),
		--[dblDebitForeign]				=	(CASE WHEN B.dblOldCost IS NOT NULL 
		--										 THEN  																				
		--										    CASE WHEN B.dblOldCost = 0 THEN 0 
		--												 WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)  --COST ADJUSTMENT
		--											END 
		--										ELSE (CASE  WHEN D.ysnTaxAdjusted = 1 THEN SUM(D.dblAdjustedTax - D.dblTax)
		--													ELSE SUM(D.dblTax) END) * (CASE WHEN A.intTransactionType = 3 THEN -1 ELSE 1 END)
		--									END),      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(B.dblRate,0),1),
		[strRateType]					=	G.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
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
	AND D.dblTax != 0
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
	,A.intEntityVendorId
	,B.dblRate
	,G.strCurrencyExchangeRateType
	,B.dblOldCost
	,F.intItemId
	,loc.intItemLocationId
	,B.intInventoryReceiptItemId
	,B.intInventoryReceiptChargeId
	,A.intCommodityId
	,A.intStoreLocationId
	,E.strName
	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
	
	RETURN
END
