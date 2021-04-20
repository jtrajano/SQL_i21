CREATE PROCEDURE uspAP_APCQueryResults
AS

SET NOCOUNT ON
--SET XACT_ABORT OFF

DECLARE @hasResult BIT = 0;

--PRINT 'APC1 Results'

DECLARE @tmpAPC1 TABLE (
	strBillId NVARCHAR(50),
	strReference NVARCHAR(200),
	strMiscDescription NVARCHAR(500),
	dblTotal DECIMAL(18,6)
)

INSERT INTO @tmpAPC1
SELECT
A2.strBillId, A2.strReference, A.strMiscDescription, A.dblTotal
FROM tblAPBillDetail A
INNER JOIN tblAPBill A2 ON A.intBillId = A2.intBillId
LEFT JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
LEFT JOIN (tblGLDetail gl INNER JOIN vyuGLAccountDetail glAccnt ON gl.intAccountId = glAccnt.intAccountId)
	ON gl.strTransactionId = A2.strBillId 
	AND gl.intJournalLineNo = A.intBillDetailId
WHERE 
	A.intInventoryReceiptItemId IS NULL
AND A.intCustomerStorageId IS NULL
AND A.intLoadDetailId IS NULL
AND A.intInventoryReceiptChargeId IS NULL
AND A.intInventoryShipmentChargeId IS NULL
AND ISNULL(A.strMiscDescription,'') NOT LIKE '%Patronage%'
AND (B.intAccountCategoryId = 45 OR glAccnt.intAccountCategoryId = 45)

SELECT * FROM @tmpAPC1

--PRINT 'APC2 Results'

DECLARE @tmpAPC2 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemTaxId INT,
	dblClearingTax DECIMAL(18,2)
)


DECLARE @nine TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

INSERT INTO @nine
--GET ALL THE RECEIPT TAX DETAIL WHICH POSTED CLEARING BUT WERE NOT VOUCHERED
SELECT
	A.intBillId,
	A.strBillId, 
	B3.strReceiptNumber,
	B.intBillDetailId,
	--receiptTaxOut.dblTax AS dblTax,
	receiptTaxOut.intInventoryReceiptItemTaxId,
	receiptTax.dblTax AS dblClearingTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
OUTER APPLY (
	SELECT SUM(C.dblTax) dblTax
	FROM tblAPBillDetailTax C
	INNER JOIN tblICInventoryReceiptItemTax D
		ON C.intTaxClassId = D.intTaxClassId
			AND C.intTaxCodeId = D.intTaxCodeId
	WHERE B.intInventoryReceiptItemId = D.intInventoryReceiptItemId AND C.intBillDetailId = B.intBillDetailId
) receiptTax
OUTER APPLY (
	SELECT 
		--SUM(C.dblTax) dblTax 
		C.*
		--, D.*
	FROM tblICInventoryReceiptItemTax C
	LEFT JOIN (tblAPBillDetailTax D INNER JOIN tblAPBillDetail E ON D.intBillDetailId = E.intBillDetailId)
		ON C.intTaxClassId = D.intTaxClassId
			AND C.intTaxCodeId = D.intTaxCodeId
			AND E.intBillDetailId = B.intBillDetailId
	WHERE C.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	 --AND D.intBillDetailId = B.intBillDetailId
	AND D.intBillDetailId IS NULL
) receiptTaxOut
WHERE
	B.intInventoryReceiptItemId > 0
AND B.intInventoryReceiptChargeId IS NULL
AND receiptTax.dblTax != 0
--AND receiptTaxOut.dblTax != 0
AND receiptTaxOut.intInventoryReceiptItemTaxId IS NOT NULL
AND receiptTaxOut.dblTax <> 0
AND B2.dblBillQty >= B2.dblOpenReceive

--SELECT ''[affectedData],* FROM @nine

DECLARE @icTaxData AS TABLE(strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS, intGLDetailId INT, intInventoryReceiptItemTaxId INT, intGLCount INT)
INSERT INTO @icTaxData
SELECT
DISTINCT 
	A2.strReceiptNumber
	,A.intGLDetailId
	,A2.intInventoryReceiptItemTaxId
	,ROW_NUMBER() OVER(PARTITION BY A2.strReceiptNumber ORDER BY A.intGLDetailId)
FROM tblGLDetail A
INNER JOIN @nine A2 ON A.strTransactionId = A2.strReceiptNumber AND A.intJournalLineNo = A2.intInventoryReceiptItemTaxId
INNER JOIN vyuGLAccountDetail A6 ON A.intAccountId = A6.intAccountId
AND NOT EXISTS (
	--NO FIX YET
	SELECT 
		A3.strTransactionId
	FROM tblGLDetail A3
	WHERE 
		A3.strTransactionId = A2.strReceiptNumber
	AND A3.intJournalLineNo = A2.intInventoryReceiptItemTaxId
	AND A3.strComments LIKE '%No voucher reversal fix%'
	AND A3.ysnIsUnposted = 0
)

INSERT INTO @tmpAPC2
SELECT
A.*
FROM @nine A
INNER JOIN @icTaxData B ON A.strReceiptNumber = B.strReceiptNumber
	AND A.intInventoryReceiptItemTaxId = B.intInventoryReceiptItemTaxId

SELECT * FROM @tmpAPC2

--PRINT 'APC3 Results'

DECLARE @tmpAPC3 TABLE(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	dblTax DECIMAL(18,2)
)

BEGIN TRY
BEGIN TRAN

DECLARE @date DATETIME = NULL
DECLARE @fiscalFrom DATETIME, @fiscalTo DATETIME;

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
END

DECLARE @intUserId INT = (SELECT intEntityId FROM tblEMEntityCredential WHERE LOWER(strUserName) = 'irelyadmin')
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
DECLARE @SYSTEM_CURRENCY NVARCHAR(25) = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)
DECLARE @GLEntries AS RecapTableType

DECLARE @ten TABLE(intBillId INT, strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	dblTax DECIMAL(18,2)
)
--GET THOSE TAX IN VOUCHER IS A BIT DIFFERENT ON VALUES WITH RECEIPT BL-198580
INSERT INTO @ten
SELECT
	A2.intBillId,
	A2.strBillId, 
	receiptTaxDetails.strReceiptNumber,
	A.intBillDetailId,
	A3.intBillDetailTaxId,
	receiptTaxDetails.intInventoryReceiptItemTaxId,
	ISNULL(A3.dblAdjustedTax, A3.dblTax) - receiptTaxDetails.dblTax AS dblTax
FROM tblAPBillDetail A
INNER JOIN tblAPBill A2 ON A.intBillId = A2.intBillId
INNER JOIN tblAPBillDetailTax A3 ON A.intBillDetailId = A3.intBillDetailId
INNER JOIN (
	SELECT
		A4.intInventoryReceiptItemId,
		A4.intInventoryReceiptItemTaxId,
		A4.intTaxClassId,
		A4.intTaxCodeId,
		A4.intTaxGroupId,
		A5.dblTax AS dblReceiptTax,
		A4.dblTax,
		A4.dblAdjustedTax,
		A6.strReceiptNumber
	FROM tblICInventoryReceiptItemTax A4
	INNER JOIN tblICInventoryReceiptItem A5 ON A4.intInventoryReceiptItemId = A5.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt A6 ON A5.intInventoryReceiptId = A6.intInventoryReceiptId
) receiptTaxDetails
	ON A.intInventoryReceiptItemId = receiptTaxDetails.intInventoryReceiptItemId
	AND A3.intTaxCodeId = receiptTaxDetails.intTaxCodeId
	AND A3.intTaxClassId = receiptTaxDetails.intTaxClassId
	AND A3.intTaxGroupId = receiptTaxDetails.intTaxGroupId
	AND ISNULL(A3.dblAdjustedTax, A3.dblTax) <> ISNULL(receiptTaxDetails.dblAdjustedTax, receiptTaxDetails.dblTax) --get only the specific issue
LEFT JOIN (
	SELECT SUM(ISNULL(A6.dblAdjustedTax, A6.dblTax)) dblTotalTax, A6.intBillDetailId
	FROM tblAPBillDetailTax A6
	GROUP BY A6.intBillDetailId
	--WHERE A6.intBillDetailId = A.intBillDetailId
) billDetailTax
	ON billDetailTax.intBillDetailId = A.intBillDetailId
WHERE 
	A.intInventoryReceiptItemId > 0
AND A.intInventoryReceiptChargeId IS NULL
--AND A.dblTax = billDetailTax.dblTotalTax --tax detail total equals to bill detail tax
AND A.dblTax != receiptTaxDetails.dblReceiptTax --tax total not equal
AND ISNULL(A3.dblAdjustedTax, A3.dblTax) != 0 --get only those taxes not equal to 0 or adjusted by user
AND ISNULL(receiptTaxDetails.dblAdjustedTax, receiptTaxDetails.dblTax) != 0--get only those taxes in receipt originally not 0
AND receiptTaxDetails.dblTax <> A3.dblAdjustedTax --EXCLUDE THOSE TAX IS ADJUSTED TO MATCH WITH RECEIPT

DECLARE @affectedTaxDetails TABLE(intBillDetailTaxId INT)

UPDATE A3
SET A3.dblTax = receiptTaxDetails.dblTax,	
	A3.ysnTaxAdjusted = 1
OUTPUT inserted.intBillDetailTaxId INTO @affectedTaxDetails
FROM tblAPBillDetail A
INNER JOIN tblAPBill A2 ON A.intBillId = A2.intBillId
INNER JOIN @ten ten ON A2.strBillId = ten.strBillId 
INNER JOIN tblAPBillDetailTax A3 ON A.intBillDetailId = A3.intBillDetailId AND A3.intBillDetailTaxId = ten.intBillDetailTaxId
INNER JOIN (
	SELECT
		A4.intInventoryReceiptItemId,
		A4.intTaxClassId,
		A4.intTaxCodeId,
		A4.intTaxGroupId,
		A5.dblTax AS dblReceiptTax,
		A4.dblTax,
		A4.dblAdjustedTax,
		A6.strReceiptNumber
	FROM tblICInventoryReceiptItemTax A4
	INNER JOIN tblICInventoryReceiptItem A5 ON A4.intInventoryReceiptItemId = A5.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt A6 ON A5.intInventoryReceiptId = A6.intInventoryReceiptId
) receiptTaxDetails
	ON A.intInventoryReceiptItemId = receiptTaxDetails.intInventoryReceiptItemId
	AND A3.intTaxCodeId = receiptTaxDetails.intTaxCodeId
	AND A3.intTaxClassId = receiptTaxDetails.intTaxClassId
	AND A3.intTaxGroupId = receiptTaxDetails.intTaxGroupId
	--AND ISNULL(A3.dblAdjustedTax, A3.dblTax) <> ISNULL(receiptTaxDetails.dblAdjustedTax, receiptTaxDetails.dblTax) 
LEFT JOIN (
	SELECT SUM(ISNULL(A6.dblAdjustedTax, A6.dblTax)) dblTotalTax, A6.intBillDetailId
	FROM tblAPBillDetailTax A6
	GROUP BY A6.intBillDetailId
	--WHERE A6.intBillDetailId = A.intBillDetailId
) billDetailTax
	ON billDetailTax.intBillDetailId = A.intBillDetailId
--RECREATE TAX ENTRIES
DECLARE @billIds AS TABLE(intBillId INT, intBillDetailTaxId INT)
INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @ten A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

DECLARE @tenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @tenWithGLIssues
SELECT
	ten.strBillId,
	ten.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @ten ten
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = ten.strBillId AND
	A.intJournalLineNo = ten.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = ten.strBillId AND
	 ten.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	newGLTax.dblTotal <> glTax.dblTotal
AND newGLTax.strAccountCategory = glTax.strAccountCategory


INSERT INTO @tmpAPC3
SELECT B.*
FROM tblGLDetail A
INNER JOIN @ten B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @tenWithGLIssues ten ON ten.strBillId = A.strTransactionId AND ten.intBillDetailTaxId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC3

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC3 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC3
END CATCH


--PRINT 'APC4 Results'

DECLARE @tmpAPC4 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	dblClearingTax DECIMAL(18,2)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @three TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

--RECEIPT WITH TAXES
--VOUCHER HAVE TAXES AND ADJUSTED TO 0 TO MATCH WITH RECEIPT
INSERT INTO @three
SELECT
	A.intBillId,
	A.strBillId, 
	B3.strReceiptNumber,
	B.intBillDetailId,
	C.intBillDetailTaxId,
	receiptTax.intInventoryReceiptItemTaxId,
	receiptTax.dblTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
--INNER JOIN tblGLDetail gl
--	ON gl.intJournalLineNo = C.intBillDetailTaxId AND gl.strTransactionId = A.strBillId
CROSS APPLY (
	SELECT SUM(ISNULL(C2.dblAdjustedTax, C2.dblTax)) dblTotalTax FROM tblAPBillDetailTax C2 
	WHERE C2.intBillDetailId = B.intBillDetailId
) totalTax
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId
WHERE
	C.dblTax <> receiptTax.dblTax
--AND B.dblTax = B2.dblTax --AS LONG AS TAX IS ADJUSTED TO 0, AND RECEIPT IS 0, THERE SHOULD BE NO CLEARING AND TAX ACCOUNT
AND C.ysnTaxAdjusted = 1
AND C.dblAdjustedTax = 0
AND receiptTax.dblTax = 0
AND receiptTax.dblAdjustedTax = 0
--AND A.strBillId = 'BL-205945'


--UPDATE THE VOUCHER DETAIL TAX TO 0 AND SET TO ysnTaxAdjusted
UPDATE C
SET
	C.dblTax = receiptTax.dblTax
	,C.ysnTaxExempt = CASE WHEN receiptTax.dblTax = 0 AND receiptTax.dblAdjustedTax = 0 THEN 1 ELSE 0 END --MAKE IT TAX EXEMPT
	,C.ysnTaxAdjusted = CASE WHEN receiptTax.dblTax = 0 THEN 0 ELSE 1 END --MAKE THE ADJUSTMENT FALSE
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
--INNER JOIN tblGLDetail gl
--	ON gl.intJournalLineNo = C.intBillDetailTaxId AND gl.strTransactionId = A.strBillId
CROSS APPLY (
	SELECT SUM(ISNULL(C2.dblAdjustedTax, C2.dblTax)) dblTotalTax FROM tblAPBillDetailTax C2 
	WHERE C2.intBillDetailId = B.intBillDetailId
) totalTax
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId
WHERE
	C.dblTax != receiptTax.dblTax
--AND B.dblTax = B2.dblTax --AS LONG AS TAX IS ADJUSTED TO 0, AND RECEIPT IS 0, THERE SHOULD BE NO CLEARING AND TAX ACCOUNT
AND C.ysnTaxAdjusted = 1
AND C.dblAdjustedTax = 0
AND receiptTax.dblTax = 0
AND receiptTax.dblAdjustedTax = 0

--RECREATE TAX ENTRIES
INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @three A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
--SELECT ''[newGL],@@ROWCOUNT

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @threeWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @threeWithGLIssues
SELECT
	three.strBillId,
	three.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @three three
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = three.strBillId AND
	A.intJournalLineNo = three.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = three.strBillId AND
	 three.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--SELECT ''[threeglissue],* FROM @threeWithGLIssues

INSERT INTO @tmpAPC4
SELECT B.*
FROM tblGLDetail A
INNER JOIN @three B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @threeWithGLIssues three ON three.strBillId = A.strTransactionId AND three.intBillDetailTaxId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC4

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC4 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC4
END CATCH

--PRINT 'APC5 Results'

DECLARE @tmpAPC5 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	dblClearingTax DECIMAL(18,2)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @seventeen TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

--RECEIPT WITH TAXES
--VOUCHER ADJUSTED TO MATCH WITH RECEIPT NOT ZERO
INSERT INTO @seventeen
SELECT
	A.intBillId,
	A.strBillId, 
	B3.strReceiptNumber,
	B.intBillDetailId,
	C.intBillDetailTaxId,
	receiptTax.intInventoryReceiptItemTaxId,
	receiptTax.dblTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
--INNER JOIN tblGLDetail gl
--	ON gl.intJournalLineNo = C.intBillDetailTaxId AND gl.strTransactionId = A.strBillId
CROSS APPLY (
	SELECT SUM(ISNULL(C2.dblAdjustedTax, C2.dblTax)) dblTotalTax FROM tblAPBillDetailTax C2 
	WHERE C2.intBillDetailId = B.intBillDetailId
) totalTax
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId
WHERE
	C.dblAdjustedTax = receiptTax.dblTax --USER ADJUSTED TAX TO MATCH WITH RECEIPT
AND C.ysnTaxAdjusted = 1
AND C.dblAdjustedTax <> 0
AND receiptTax.dblTax <> 0


--UPDATE THE VOUCHER DETAIL TAX TO MATCH WITH RECEIPT AND MAKE ADJUSTEMENT FALSE
UPDATE C
SET
	C.dblTax = receiptTax.dblTax
	,C.ysnTaxAdjusted = 0
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
INNER JOIN @seventeen D ON A.intBillId = D.intBillId AND C.intBillDetailTaxId = D.intBillDetailTaxId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId

--RECREATE TAX ENTRIES
INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @seventeen A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--SELECT ''[newGL],@@ROWCOUNT

--SELECT * FROM @GLEntries WHERE strTransactionId = 'BL-204013'

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @seventeenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @seventeenWithGLIssues
SELECT
	seventeen.strBillId,
	seventeen.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @seventeen seventeen
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = seventeen.strBillId AND
	A.intJournalLineNo = seventeen.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = seventeen.strBillId AND
	 seventeen.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	newGLTax.dblTotal <> glTax.dblTotal
AND newGLTax.strAccountCategory = glTax.strAccountCategory

--specific issue
INSERT INTO @tmpAPC5
SELECT B.*
FROM tblGLDetail A
INNER JOIN @seventeen B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @seventeenWithGLIssues seventeen ON seventeen.strBillId = A.strTransactionId AND seventeen.intBillDetailTaxId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC5

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC5 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC5
END CATCH

--PRINT 'APC6 Results'

DECLARE @tmpAPC6 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @fifteen TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

--RECEIPT WITH TAXES
--VOUCHER HAVE TAXES AND RECEIPT IS 0
INSERT INTO @fifteen
SELECT
	A.intBillId,
	A.strBillId, 
	B3.strReceiptNumber,
	B.intBillDetailId,
	C.intBillDetailTaxId,
	receiptTax.intInventoryReceiptItemTaxId,
	receiptTax.dblTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
--INNER JOIN tblGLDetail gl
--	ON gl.intJournalLineNo = C.intBillDetailTaxId AND gl.strTransactionId = A.strBillId
CROSS APPLY (
	SELECT SUM(ISNULL(C2.dblAdjustedTax, C2.dblTax)) dblTotalTax FROM tblAPBillDetailTax C2 
	WHERE C2.intBillDetailId = B.intBillDetailId
) totalTax
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId
WHERE
	C.dblTax <> receiptTax.dblTax
--AND B.dblTax = B2.dblTax --AS LONG AS TAX IS ADJUSTED TO 0, AND RECEIPT IS 0, THERE SHOULD BE NO CLEARING AND TAX ACCOUNT
--AND C.ysnTaxAdjusted = 0
AND C.dblAdjustedTax <> 0
AND receiptTax.dblTax = 0
AND receiptTax.dblAdjustedTax = 0


--UPDATE THE VOUCHER DETAIL TAX TO 0 AND SET TO ysnTaxAdjusted = 1
UPDATE C
SET
	C.dblTax = receiptTax.dblTax
	,C.ysnTaxAdjusted = 1
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
INNER JOIN @fifteen D ON A.intBillId = D.intBillId AND C.intBillDetailTaxId = D.intBillDetailTaxId
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intInventoryReceiptItemTaxId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId

--RECREATE TAX ENTRIES
INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @fifteen A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @fifteenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @fifteenWithGLIssues
SELECT
	fifteen.strBillId,
	fifteen.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @fifteen fifteen
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = fifteen.strBillId AND
	A.intJournalLineNo = fifteen.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = fifteen.strBillId AND
	 fifteen.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	newGLTax.dblTotal <> glTax.dblTotal
AND newGLTax.strAccountCategory = glTax.strAccountCategory

--specific issue
INSERT INTO @tmpAPC6
SELECT B.*
FROM tblGLDetail A
INNER JOIN @fifteen B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @fifteenWithGLIssues fifteen ON fifteen.strBillId = A.strTransactionId AND fifteen.intBillDetailTaxId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC6

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC6 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC6
END CATCH

--PRINT 'APC7 Results'

DECLARE @tmpAPC7 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	dblClearingTax DECIMAL(18,2)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @eleven TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

--GET ALL THE RECEIPT TAX DETAIL WHICH POSTED CLEARING BUT WERE NOT VOUCHERED, ZERO IN VOUCHER
INSERT INTO @eleven
SELECT
	A.intBillId,
	A.strBillId, 
	receiptTaxDetails.strReceiptNumber,
	B.intBillDetailId,
	B4.intBillDetailTaxId,
	receiptTaxDetails.intInventoryReceiptItemTaxId,
	receiptTaxDetails.dblTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax B4 ON B4.intBillDetailId = B.intBillDetailId
INNER JOIN (
	SELECT
		A4.intInventoryReceiptItemId,
		A4.intInventoryReceiptItemTaxId,
		A4.intTaxClassId,
		A4.intTaxCodeId,
		A4.intTaxGroupId,
		A5.dblTax AS dblReceiptTax,
		A4.dblTax,
		A4.dblAdjustedTax,
		A5.dblBillQty,
		A5.dblOpenReceive,
		A6.strReceiptNumber
	FROM tblICInventoryReceiptItemTax A4
	INNER JOIN tblICInventoryReceiptItem A5 ON A4.intInventoryReceiptItemId = A5.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt A6 ON A5.intInventoryReceiptId = A6.intInventoryReceiptId
) receiptTaxDetails
	ON B.intInventoryReceiptItemId = receiptTaxDetails.intInventoryReceiptItemId
	AND B4.intTaxCodeId = receiptTaxDetails.intTaxCodeId
	AND B4.intTaxClassId = receiptTaxDetails.intTaxClassId
	AND B4.intTaxGroupId = receiptTaxDetails.intTaxGroupId
WHERE
	B.intInventoryReceiptItemId > 0
AND B.intInventoryReceiptChargeId IS NULL
AND receiptTaxDetails.dblTax <> 0
AND receiptTaxDetails.dblBillQty >= receiptTaxDetails.dblOpenReceive
AND B4.dblAdjustedTax = 0
--AND A.strBillId = 'BL-164939'

--SELECT * FROM @eleven WHERE strBillId = 'BL-164939'

--MATCH THE tblAPBillDetailTax.dblTax to Receipt Tax to generate tax correctly
UPDATE A
SET
	A.dblTax = receiptTaxDetails.dblTax, A.ysnTaxAdjusted = 1
FROM tblAPBillDetailTax A
INNER JOIN @eleven A2 ON A.intBillDetailTaxId = A.intBillDetailTaxId
INNER JOIN tblAPBillDetail A3 ON A.intBillDetailId = A3.intBillDetailId
INNER JOIN tblAPBill A4 ON A3.intBillId = A4.intBillId
INNER JOIN (
	SELECT
		A4.intInventoryReceiptItemId,
		A4.intInventoryReceiptItemTaxId,
		A4.intTaxClassId,
		A4.intTaxCodeId,
		A4.intTaxGroupId,
		A5.dblTax AS dblReceiptTax,
		A4.dblTax,
		A4.dblAdjustedTax,
		A5.dblBillQty,
		A5.dblOpenReceive,
		A6.strReceiptNumber
	FROM tblICInventoryReceiptItemTax A4
	INNER JOIN tblICInventoryReceiptItem A5 ON A4.intInventoryReceiptItemId = A5.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt A6 ON A5.intInventoryReceiptId = A6.intInventoryReceiptId
) receiptTaxDetails
	ON A3.intInventoryReceiptItemId = receiptTaxDetails.intInventoryReceiptItemId
	AND A.intTaxCodeId = receiptTaxDetails.intTaxCodeId
	AND A.intTaxClassId = receiptTaxDetails.intTaxClassId
	AND A.intTaxGroupId = receiptTaxDetails.intTaxGroupId
WHERE
	A3.intInventoryReceiptItemId > 0
AND receiptTaxDetails.dblTax <> 0
AND receiptTaxDetails.dblBillQty >= receiptTaxDetails.dblOpenReceive
AND A.dblAdjustedTax = 0

--SELECT ''[eleven],* FROM @eleven WHERE strBillId = 'BL-207418'

--RECREATE TAX ENTRIES
INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @eleven A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

--SELECT * FROM @GLEntries WHERE strTransactionId = 'BL-164939'

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--SELECT ''[newGL],@@ROWCOUNT

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @elevenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @elevenWithGLIssues
SELECT
	eleven.strBillId,
	eleven.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @eleven eleven
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eleven.strBillId AND
	A.intJournalLineNo = eleven.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eleven.strBillId AND
	 eleven.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC7
SELECT B.*
FROM tblGLDetail A
INNER JOIN @eleven B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @elevenWithGLIssues eleven ON A.strTransactionId = eleven.strBillId AND eleven.intBillDetailTaxId = A.intJournalLineNo 
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC7

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC7 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC7
END CATCH

--PRINT 'APC8 Results'

DECLARE @tmpAPC8 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intChargeExpenseAccountId INT,
	intItemId INT,
	dblTotalDiff DECIMAL(18,2),
	dblTotalQtyDiff DECIMAL(38,20)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @fourteen TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intChargeExpenseAccountId INT,
	intItemId INT,
	dblTotalDiff DECIMAL(18,2),
	dblTotalQtyDiff DECIMAL(38,20)
)
--voucher with different net weight from receipt

INSERT INTO @fourteen
SELECT 
	A4.dtmDate,
	A4.intBillId,
	A4.strBillId, 
	A3.strReceiptNumber,
	A.intBillDetailId,
	A2.intInventoryReceiptItemId,
	[dbo].[fnGetItemGLAccount](A.intItemId, itemLoc.intItemLocationId, 'Inventory Adjustment'),
	A.intItemId,
	--A2.dblLineTotal - A.dblTotal AS dblTotalDiff,
	--ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	--THEN (CASE 
	--		WHEN A.intWeightUOMId > 0 
	--			THEN CAST(A.dblCost / ISNULL(A4.intSubCurrencyCents,1)  * (ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)
	--			) * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
	--		WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
	--			THEN CAST((ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)) 
	--				*  (A.dblCost / ISNULL(A4.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
	--		ELSE CAST((ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)) 
	--			* (A.dblCost / ISNULL(A4.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
	--	END)
	--ELSE (CASE 
	--		WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
	--			THEN CAST(A.dblCost  * (ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived))
	--				 * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
	--		WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
	--			THEN CAST((ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)) 
	--				*  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
	--		ELSE CAST((ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)) * (A.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
	--	END)
	--END),0) AS dblTotalDiff,
	glReceiptItem.dblReceiptClearing - glVoucherItem.dblVoucherClearing AS dblTotalDiff,
	ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive) - ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived)
FROM tblAPBillDetail A
INNER JOIN tblAPBill A4 ON A.intBillId = A4.intBillId
INNER JOIN (tblICInventoryReceiptItem A2 INNER JOIN tblICInventoryReceipt A3 ON A2.intInventoryReceiptId = A3.intInventoryReceiptId)
	ON A2.intInventoryReceiptItemId = A.intInventoryReceiptItemId
INNER JOIN tblAPVendor v ON A4.intEntityVendorId = v.intEntityId
CROSS APPLY (
	SELECT SUM(B.dblCredit - B.dblDebit) AS dblReceiptClearing
		--B.*
	FROM tblGLDetail B
	INNER JOIN tblICInventoryTransaction B2 
		ON B.strTransactionId = B2.strTransactionId AND B.intJournalLineNo = B2.intInventoryTransactionId
	INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
	WHERE A3.strReceiptNumber = B.strTransactionId
	AND B3.intAccountCategoryId = 45
	AND A2.intInventoryReceiptItemId = B2.intTransactionDetailId
) glReceiptItem
CROSS APPLY (
	SELECT SUM(B.dblDebit - B.dblCredit) AS dblVoucherClearing
		--B.*
	FROM tblGLDetail B
	INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
	WHERE A4.strBillId = B.strTransactionId
	AND B3.intAccountCategoryId = 45
	AND A.intBillDetailId = B.intJournalLineNo
	AND (B.dblDebitUnit <> 0 OR B.dblCreditUnit <> 0) --exclude other gl entry for the item to correctly calculate the actual difference
) glVoucherItem
OUTER APPLY (
	SELECT COUNT(*) AS intCountVoucher FROM tblAPBillDetail A5
	WHERE A5.intInventoryReceiptItemId = A2.intInventoryReceiptItemId AND A5.intInventoryReceiptChargeId IS NULL
) voucherCount
LEFT JOIN tblICItemLocation itemLoc ON A.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = A4.intShipToId
WHERE 
	ISNULL(NULLIF(A.dblNetWeight,0), A.dblQtyReceived) <> ISNULL(NULLIF(A2.dblNet,0), A2.dblOpenReceive)
AND voucherCount.intCountVoucher = 1
AND A.dblTotal <> A2.dblLineTotal
--INVRCT-2421 HAVE .01 DIFFERENCE, BUT THE ISSUE IN NET WEIGHT EXISTS
--BUT TOTAL ONLY HAVE .01 DIFFERENCE
--AND ABS(A.dblTotal - A2.dblLineTotal) > 1 --DO NOT INCLUDE LOWER DIFFERENCE
AND A2.dblBillQty >= A2.dblOpenReceive
AND A.intInventoryReceiptChargeId IS NULL
--AND A3.strReceiptNumber = 'INVRCT-9471'

DECLARE @accountError NVARCHAR(200);
SELECT TOP 1
	@accountError = B.strItemNo + ' does not have Inventory Adjustment account setup.'
FROM @fourteen A
INNER JOIN tblICItem B ON A.intItemId = B.intItemId
WHERE A.intChargeExpenseAccountId IS NULL

IF ISNULL(@accountError,'') <> ''
BEGIN
	RAISERROR(@accountError, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	A.dblTotalDiff						
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	A.dblTotalQtyDiff					
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	A.dblTotalDiff				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@fourteen A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @fourteen)
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intChargeExpenseAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	A.dblTotalDiff						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	A.dblTotalQtyDiff					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	A.dblTotalDiff				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@fourteen A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @fourteen)

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @fourteenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @fourteenWithGLIssues
SELECT
	fourteen.strBillId,
	fourteen.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @fourteen fourteen
OUTER APPLY
(
	--NEW GL
	SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
	FROM (
	--SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	--FROM @GLEntries A
	--INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	--WHERE strTransactionId = fourteen.strBillId AND
	--A.intJournalLineNo = fourteen.intBillDetailId AND
	--B.intAccountCategoryId = 45 AND
	--	ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	----GROUP BY B.strAccountCategory--, A.strTransactionId
	--UNION ALL
	--OLD GL
	SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = fourteen.strBillId AND
	B.intAccountCategoryId = 45 AND
	A.intJournalLineNo = fourteen.intBillDetailId AND
		ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	--GROUP BY B.strAccountCategory--, A.strTransactionId
	) tmp
	--GROUP BY strAccountCategory
) newGLTax
OUTER APPLY 
(
	--RECEIPT GL
	SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblICInventoryTransaction C
		ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
		AND C.intTransactionDetailId = fourteen.intInventoryReceiptItemId
	WHERE A.strTransactionId = fourteen.strReceiptNumber AND
	B.intAccountCategoryId = 45 AND
	--A.intJournalLineNo = 409558 AND
		A.ysnIsUnposted = 0
	--GROUP BY B.strAccountCategory
) rcptClearing
WHERE 
	(newGLTax.dblTotal <> rcptClearing.dblTotal AND ABS(newGLTax.dblTotal - rcptClearing.dblTotal) > .20)
	OR rcptClearing.dblTotal IS NULL

--specific issue
INSERT INTO @tmpAPC8
SELECT B.*
FROM tblGLDetail A
INNER JOIN @fourteen B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @fourteenWithGLIssues eleven ON A.strTransactionId = eleven.strBillId AND eleven.intBillDetailId = A.intJournalLineNo 
WHERE A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC8

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC8 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC8
END CATCH

--PRINT 'APC9 Results'

DECLARE @tmpAPC9 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	dblGLDiff DECIMAL(18,6)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT @date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @eighteen TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	dblGLDiff DECIMAL(18,6)
)
--voucher with different net weight from receipt

INSERT INTO @eighteen
--GET THOSE VOUCHERS WHICH HAS .01 DIFFERENCE IN TOTAL FOR RECEIPT
SELECT * 
FROM (
SELECT
C.dtmDate,
C.intBillId,
C.strBillId,
D2.strReceiptNumber,
A.intBillDetailId,
D.intInventoryReceiptItemId,
[dbo].[fnGetItemGLAccount](A.intItemId, itemLoc.intItemLocationId, 'Inventory Adjustment') intAccountId,
item.strItemNo,
glReceiptItem.dblReceiptClearing,
glVoucherItem.dblVoucherClearing,
--ABS(
CASE WHEN WC.intWeightClaimDetailId IS NOT NULL--C.intTransactionType = 11
THEN 
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN
		CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	ELSE 
		CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	END),0)
ELSE
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN (CASE 
			WHEN A.intWeightUOMId > 0 
				THEN CAST(A.dblCost / ISNULL(C.intSubCurrencyCents,1)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
		END)
	ELSE (CASE 
			WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
				THEN CAST(A.dblCost  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (A.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
		END)
	END),0)
END - 
	A.dblTotal AS dblDiff,
	glReceiptItem.dblReceiptClearing - glVoucherItem.dblVoucherClearing AS dblGLDiff
FROM tblAPBillDetail A
	INNER JOIN tblAPBill C ON A.intBillId = C.intBillId
	INNER JOIN (tblICInventoryReceiptItem D INNER JOIN tblICInventoryReceipt D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
		ON D.intInventoryReceiptItemId = A.intInventoryReceiptItemId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
	CROSS APPLY (
		SELECT SUM(B.dblCredit - B.dblDebit) AS dblReceiptClearing
			--B.*
		FROM tblGLDetail B
		INNER JOIN tblICInventoryTransaction B2 
			ON B.strTransactionId = B2.strTransactionId AND B.intJournalLineNo = B2.intInventoryTransactionId
		INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
		WHERE D2.strReceiptNumber = B.strTransactionId
		AND B3.intAccountCategoryId = 45
		AND D.intInventoryReceiptItemId = B2.intTransactionDetailId
	) glReceiptItem
	CROSS APPLY (
		SELECT SUM(B.dblDebit - B.dblCredit) AS dblVoucherClearing
			--B.*
		FROM tblGLDetail B
		INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
		WHERE C.strBillId = B.strTransactionId
		AND B3.intAccountCategoryId = 45
		AND A.intBillDetailId = B.intJournalLineNo
		--AND B.strCode <> 'ICA' --exclude ICA to calculate correctly the actual difference between receipt total and voucher total
		AND (B.dblDebitUnit <> 0 OR B.dblCreditUnit <> 0) --exclude other gl entry for the item to correctly calculate the actual difference
	) glVoucherItem
	LEFT JOIN tblLGWeightClaimDetail WC ON WC.intBillId = C.intBillId
	LEFT JOIN tblICItemLocation itemLoc ON A.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = D2.intLocationId
WHERE 
	--D.dblNet <> 0 AND A.dblNetWeight = 0
	A.intInventoryReceiptChargeId IS NULL
	AND A.dblOldCost IS NULL
	AND (
		ABS(D.dblLineTotal - A.dblTotal) = .01 OR
		 ABS(D.dblLineTotal - A.dblTotal) = .02 --OR
		 --ABS(glReceiptItem.dblReceiptClearing - glVoucherItem.dblVoucherClearing) = .01
		 --DO NOT ADD THIS, IF THERE IS DIFFERENCE IN GL BUT NOT IN ACTUAL TRANSACTION, CREATE GENERIC FIX SEPARATELY
		 )
) tmp
WHERE ABS(dblDiff) = .01
OR ABS(dblDiff) = .02
--OR ABS(dblGLDiff) = .01

DECLARE @noAccount NVARCHAR(200);

SELECT TOP 1 @noAccount = 'There are no Inventory Adjustment account setup for the item ' + A.strItemNo + ' on ' + A.strBillId
FROM @eighteen A
WHERE A.intAccountId IS NULL

IF ISNULL(@noAccount,'') <> ''
BEGIN 
	--SET @accountError = 'There are no COGS account setup for the item on ' + @noAccount
	RAISERROR(@noAccount, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	A.dblDiff						
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	0				
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	A.dblDiff				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@eighteen A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @eighteen)
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	A.dblDiff						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	A.dblDiff					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	A.dblDiff				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@eighteen A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @eighteen)

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @eighteenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @eighteenWithGLIssues
SELECT
	eighteen.strBillId,
	eighteen.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @eighteen eighteen
OUTER APPLY
(
	--NEW GL
	SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
	FROM (
	--SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	--FROM @GLEntries A
	--INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	--WHERE strTransactionId = eighteen.strBillId AND
	--A.intJournalLineNo = eighteen.intBillDetailId AND
	--B.intAccountCategoryId = 45 AND
	--	ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	----GROUP BY B.strAccountCategory--, A.strTransactionId
	--UNION ALL
	--OLD GL
	SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eighteen.strBillId AND
	B.intAccountCategoryId = 45 AND
	A.intJournalLineNo = eighteen.intBillDetailId AND
		ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	--GROUP BY B.strAccountCategory--, A.strTransactionId
	) tmp
	--GROUP BY strAccountCategory
) newGLTax
OUTER APPLY 
(
	--RECEIPT GL
	SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblICInventoryTransaction C
		ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
		AND C.intTransactionDetailId = eighteen.intInventoryReceiptItemId
	WHERE A.strTransactionId = eighteen.strReceiptNumber AND
	B.intAccountCategoryId = 45 AND
	--A.intJournalLineNo = 409558 AND
		A.ysnIsUnposted = 0
	--GROUP BY B.strAccountCategory
) rcptClearing
WHERE 
	(newGLTax.dblTotal <> rcptClearing.dblTotal 
		AND (
			ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .01 OR
			ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .02
		))
	OR rcptClearing.dblTotal IS NULL

INSERT INTO @tmpAPC9
SELECT B.*
FROM tblGLDetail A
INNER JOIN @eighteen B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @eighteenWithGLIssues eleven ON A.strTransactionId = eleven.strBillId AND eleven.intBillDetailId = A.intJournalLineNo 
WHERE A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC9

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC9 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC9
END CATCH

--PRINT 'APC10 Results'

DECLARE @tmpAPC10 TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemTaxId INT,
	dblClearingTax DECIMAL(18,2)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY
BEGIN TRAN

--ISSUE 19
DECLARE @nineteen TABLE
(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemTaxId INT,
	--dblTax DECIMAL(18,2),
	dblClearingTax DECIMAL(18,2)
)

INSERT INTO @nineteen
--GET ALL THE RECEIPT TAX DETAIL WHICH POSTED CLEARING BUT WERE NOT VOUCHERED (NO TAX DETAILS)
SELECT
	A.intBillId,
	A.strBillId, 
	B3.strReceiptNumber,
	B.intBillDetailId,
	--receiptTaxOut.dblTax AS dblTax,
	receiptTaxOut.intInventoryReceiptItemTaxId,
	receiptTax.dblTax AS dblClearingTax
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceiptItem B2 INNER JOIN tblICInventoryReceipt B3 ON B2.intInventoryReceiptId = B3.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = B2.intInventoryReceiptItemId
OUTER APPLY (
	SELECT SUM(C.dblTax) dblTax
	FROM tblAPBillDetailTax C
	INNER JOIN tblICInventoryReceiptItemTax D
		ON C.intTaxClassId = D.intTaxClassId
			AND C.intTaxCodeId = D.intTaxCodeId
	WHERE B.intInventoryReceiptItemId = D.intInventoryReceiptItemId AND C.intBillDetailId = B.intBillDetailId
) receiptTax
OUTER APPLY (
	SELECT 
		--SUM(C.dblTax) dblTax 
		C.*
		--, D.*
	FROM tblICInventoryReceiptItemTax C
	LEFT JOIN (tblAPBillDetailTax D INNER JOIN tblAPBillDetail E ON D.intBillDetailId = E.intBillDetailId)
		ON C.intTaxClassId = D.intTaxClassId
			AND C.intTaxCodeId = D.intTaxCodeId
			AND E.intBillDetailId = B.intBillDetailId
	WHERE C.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	 --AND D.intBillDetailId = B.intBillDetailId
	AND D.intBillDetailId IS NULL
) receiptTaxOut
WHERE
	B.intInventoryReceiptItemId > 0
AND B.intInventoryReceiptChargeId IS NULL
AND receiptTax.dblTax IS NULL
AND B2.dblTax <> 0
--AND receiptTaxOut.dblTax != 0
AND receiptTaxOut.intInventoryReceiptItemTaxId IS NOT NULL
AND B2.dblBillQty >= B2.dblOpenReceive
--AND B3.strReceiptNumber = 'INVRCT-4600'

--SELECT ''[affectedData],* FROM @nineteen

INSERT INTO @icTaxData
SELECT
DISTINCT 
	A2.strReceiptNumber
	,A.intGLDetailId
	,A2.intInventoryReceiptItemTaxId
	,ROW_NUMBER() OVER(PARTITION BY A2.strReceiptNumber ORDER BY A.intGLDetailId)
FROM tblGLDetail A
INNER JOIN @nineteen A2 ON A.strTransactionId = A2.strReceiptNumber AND A.intJournalLineNo = A2.intInventoryReceiptItemTaxId
INNER JOIN vyuGLAccountDetail A6 ON A.intAccountId = A6.intAccountId
AND NOT EXISTS (
	--NO FIX YET
	SELECT 
		A3.strTransactionId
	FROM tblGLDetail A3
	WHERE 
		A3.strTransactionId = A2.strReceiptNumber
	AND A3.intJournalLineNo = A2.intInventoryReceiptItemTaxId
	AND A3.strComments LIKE '%No voucher reversal fix%'
	AND A3.ysnIsUnposted = 0
)

INSERT INTO @tmpAPC10
SELECT
A.*
FROM @nineteen A
INNER JOIN @icTaxData B ON A.strReceiptNumber = B.strReceiptNumber
	AND A.intInventoryReceiptItemTaxId = B.intInventoryReceiptItemTaxId

SELECT * FROM @tmpAPC10

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC10 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC10
END CATCH

--PRINT 'APC11 Results'

DECLARE @tmpAPC11 TABLE(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemId INT,
	dblReceiptTax DECIMAL(18,6),
	intVoucherCount INT,
	ysnHasMultipleVoucher BIT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY
BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END


--ISSUE 20
DECLARE @twenty TABLE(intBillId INT, strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT,
	intInventoryReceiptItemId INT,
	dblReceiptTax DECIMAL(18,6),
	intVoucherCount INT,
	ysnHasMultipleVoucher BIT
)
--GET THOSE VOUCHER THAT HAS COST ADJUSTMENT BUT TAX IS NOT SET TO COST ADJUST
INSERT INTO @twenty
SELECT
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	A.intBillDetailTaxId,
	C2.intInventoryReceiptItemId,
	C.dblTax,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptItemId, B.intBillDetailId ORDER BY B.intBillDetailId) AS intVoucherCount,
	0
FROM tblAPBillDetailTax A
INNER JOIN (tblAPBillDetail B INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId)
	ON A.intBillDetailId = B.intBillDetailId
INNER JOIN (tblICInventoryReceiptItemTax C INNER JOIN tblICInventoryReceiptItem C2 ON C.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId
	AND A.intTaxClassId = C.intTaxClassId
	AND A.intTaxCodeId = C.intTaxCodeId
	AND A.intTaxGroupId = C.intTaxGroupId
WHERE B2.ysnPosted = 1 AND
B.dblCost != C2.dblUnitCost AND
(
	--IF IT IS LINKED TO VOUCHER AND RECEIPT ITEM TAX IS NOT 0, WE SHOULD CALCULATE THE COST ADJUSTMENT
	(A.ysnTaxAdjusted = 0 AND C.dblTax <> 0) --EXCLUDE THOSE TAXES WHICH VALUE HAS 0
	--(A.ysnTaxAdjusted = 0 AND A.dblTax <> 0 AND C.dblTax <> 0) --EXCLUDE THOSE TAXES WHICH VALUE HAS 0
	OR
	(A.ysnTaxAdjusted = 1 AND A.dblTax = A.dblAdjustedTax AND A.dblTax <> 0 AND A.dblAdjustedTax <> 0) --ADJUSTED BUT IT IS JUST THE SAME
)

UPDATE A
SET
	A.ysnHasMultipleVoucher = CASE WHEN dtlsCnt.intCount > 1 THEN 1 ELSE 0 END
FROM @twenty A
OUTER APPLY (
	SELECT COUNT(DISTINCT intBillDetailId) intCount FROM @twenty B
	WHERE B.intInventoryReceiptItemId = A.intInventoryReceiptItemId
) dtlsCnt

DECLARE @newVoucherDetailTaxes TABLE
(
	[intBillDetailTaxId]			INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[ysnSeparateOnBill]			BIT DEFAULT 0
	,[intTaxAccountId]				INT
	,[ysnTaxAdjusted]				BIT DEFAULT 0
	,[ysnCheckoffTax]				BIT DEFAULT 0
	,[ysnTaxExempt]					BIT DEFAULT 0
	,[ysnTaxOnly]					BIT DEFAULT 0
)

DECLARE @billDetailids AS Id
DECLARE @billDetailId AS INT;

INSERT INTO @billDetailids
SELECT DISTINCT intBillDetailId FROM @twenty

DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR

SELECT intId FROM @billDetailids

OPEN c;

FETCH c INTO @billDetailId

WHILE @@FETCH_STATUS = 0
BEGIN
	
	DECLARE @voucherPayableTax AS VoucherDetailTax
	INSERT INTO @voucherPayableTax
	(
		[intVoucherPayableId]       
		,[intTaxGroupId]				
		,[intTaxCodeId]				
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]	
		,[strCalculationMethod]		
		,[dblRate]					
		,[intAccountId]				
		,[dblTax]					
		,[dblAdjustedTax]			
		,[ysnTaxAdjusted]			
		,[ysnSeparateOnBill]			
		,[ysnCheckOffTax]			
		,[ysnTaxExempt]              
		,[ysnTaxOnly]				
	)
	SELECT
		D.[intBillDetailId]
		,D.[intTaxGroupId]				
		,D.[intTaxCodeId]				
		,D.[intTaxClassId]				
		,D.[strTaxableByOtherTaxes]	
		,D.[strCalculationMethod]		
		,D.[dblRate]					
		,D.[intAccountId]				
		,D.[dblTax]					
		,D.[dblAdjustedTax]			
		,D.[ysnTaxAdjusted]			
		,D.[ysnSeparateOnBill]			
		,D.[ysnCheckOffTax]			
		,D.[ysnTaxExempt]              
		,D.[ysnTaxOnly]			
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @twenty C ON B.intBillDetailId = C.intBillDetailId
	INNER JOIN tblAPBillDetailTax D ON C.intBillDetailId = D.intBillDetailId
	WHERE B.intBillDetailId = @billDetailId

	INSERT INTO @newVoucherDetailTaxes
	SELECT
		A2.intBillDetailId,
		tax.*
	FROM tblAPBillDetail A2
	INNER JOIN tblAPBill A3 ON A2.intBillId = A3.intBillId
	INNER JOIN (tblICInventoryReceiptItem A4 INNER JOIN tblICInventoryReceipt A5 ON A4.intInventoryReceiptId = A5.intInventoryReceiptId)
		ON A4.intInventoryReceiptItemId = A2.intInventoryReceiptItemId
	CROSS APPLY dbo.fnAPRecomputeTaxes(@voucherPayableTax, A4.dblUnitCost, (CASE WHEN A2.intWeightUOMId > 0 AND A2.dblNetWeight <> 0 THEN A2.dblNetWeight ELSE A2.dblQtyReceived END)) tax
	WHERE A2.intBillDetailId = @billDetailId

	--SELECT * FROM @newVoucherDetailTaxes

	--UPDATE THE TAX INFO
	--fnAPRecomputeTaxes
	UPDATE A
	SET A.dblTax = CASE WHEN twenty.ysnHasMultipleVoucher = 0 THEN twenty.dblReceiptTax
					ELSE
						--CALCULATE CORRECT TAX IF MULTIPLE VOUCHER PER RECEIPT ITEM
						Taxes.dblTax
					END,	
		A.ysnTaxAdjusted = 1
	FROM tblAPBillDetailTax A
	INNER JOIN @twenty twenty ON A.intBillDetailTaxId = twenty.intBillDetailTaxId 
	INNER JOIN tblAPBillDetail A2 ON A.intBillDetailId = A2.intBillDetailId
	INNER JOIN @newVoucherDetailTaxes Taxes
		ON A.intTaxCodeId = Taxes.intTaxCodeId AND A.intTaxClassId = Taxes.intTaxClassId
	WHERE A.intBillDetailId = @billDetailId

	DELETE FROM @newVoucherDetailTaxes
	DELETE FROM @voucherPayableTax

	FETCH c INTO @billDetailId
END

CLOSE c; DEALLOCATE c;

INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @twenty A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @twentyWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @twentyWithGLIssues
SELECT
	twenty.strBillId,
	twenty.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @twenty twenty
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twenty.strBillId AND
	A.intJournalLineNo = twenty.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twenty.strBillId AND
	 twenty.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC11
SELECT B.*
FROM tblGLDetail A
INNER JOIN @twenty B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @twentyWithGLIssues twenty ON twenty.strBillId = A.strTransactionId AND twenty.intBillDetailTaxId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC11

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC11 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC11
END CATCH

--PRINT 'APC12 Results'

DECLARE @tmpAPC12 TABLE
(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

--DECLARE #twentyone TABLE
CREATE TABLE #twentyone
(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6)
)

--fix long running query
--SELECT TOp 1 * FROM tblAPBill
--SELECT TOP 1 * FROM tblAPBillDetail
--SELECT TOP 1 * FROM tblICInventoryReceiptCharge

SELECT
	'Test',
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	C2.intInventoryReceiptChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryReceiptCharge C2 
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
--LEFT JOIN (
--	SELECT ABS(SUM(B3.dblTotal)) dblTotal, B3.intInventoryReceiptChargeId FROM tblAPBillDetail B3 
--	GROUP BY B3.intInventoryReceiptChargeId
--) allDetails
--	ON allDetails.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
WHERE 
	B2.ysnPosted = 1
AND B.intInventoryReceiptChargeId > 0
AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
AND ABS(B.dblTotal) <> C2.dblAmount
AND B.dblOldCost IS NOT NULL
--AND ISNULL(allDetails.dblTotal,0) = C2.dblAmount --GET ONLY THOSE TOTAL OF ALL VOUCHERS EQUAL TO THE AMOUNT OF CHARGE

--GET ALL VOUCHER WITH RECEIPT CHARGE AND IS PRORATED INVRCT-3622
--RECEIPT CHARGE AMOUNT ARE IN FULL IN BOTH VOUCHER
--EX. IR-1 Charge = 100 Clearing 100, BL-1 50 Clearing = 100, BL-2 50 Clearing 100
;WITH twentyone (
	intBillId,
	strBillId,
	strReceiptNumber,
	intBillDetailId,
	intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
)
AS (
SELECT
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	C2.intInventoryReceiptChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryReceiptCharge C2 
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
LEFT JOIN (
	SELECT ABS(SUM(B3.dblTotal)) dblTotal, B3.intInventoryReceiptChargeId FROM tblAPBillDetail B3 
	GROUP BY B3.intInventoryReceiptChargeId
) allDetails
	ON allDetails.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
WHERE 
	B2.ysnPosted = 1
AND B.intInventoryReceiptChargeId > 0
AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
AND ABS(B.dblTotal) <> C2.dblAmount
AND B.dblOldCost IS NOT NULL
AND ISNULL(allDetails.dblTotal,0) = C2.dblAmount --GET ONLY THOSE TOTAL OF ALL VOUCHERS EQUAL TO THE AMOUNT OF CHARGE
--AND C3.strReceiptNumber = 'INVRCT-3622'
)

INSERT INTO #twentyone
SELECT 
	A.intBillId,
	A.strBillId,
	A.strReceiptNumber,
	A.intBillDetailId,
	A.intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount
FROM twentyone A
WHERE A.intInventoryReceiptChargeId IN (
	SELECT intInventoryReceiptChargeId FROM twentyone B WHERE B.intVoucherCount > 1
)

SELECT '21',* FROM #twentyone

UPDATE A
SET
	A.dblOldCost = NULL
FROM tblAPBillDetail A
INNER JOIN #twentyone B ON A.intBillDetailId = B.intBillDetailId

--RECREATE TAX ENTRIES
DECLARE @voucherInfo AS TABLE(intBillId INT, intBillDetailId INT)
INSERT INTO @voucherInfo
SELECT DISTINCT A.intBillId, A.intBillDetailId 
FROM #twentyone A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherChargeItemGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo)
AND voucherDetails.intBillDetailId IS NOT NULL

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--SELECT * FROM @GLEntries WHERE strTransactionId = 'BL-7059'

DECLARE @twentyoneWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @twentyoneWithGLIssues
SELECT
	twentyone.strBillId,
	twentyone.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM #twentyone twentyone
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentyone.strBillId AND
	A.intJournalLineNo = twentyone.intBillDetailId AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentyone.strBillId AND
	 twentyone.intBillDetailId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC12
SELECT B.*
FROM tblGLDetail A
INNER JOIN #twentyone B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @twentyoneWithGLIssues twentyone ON twentyone.strBillId = A.strTransactionId AND twentyone.intBillDetailId = A.intJournalLineNo
WHERE 
	A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC12

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC12 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC12
END CATCH

--PRINT 'APC13 Results'

DECLARE @tmpAPC13 TABLE(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intExpenseAccountId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	intVoucherCount INT
)

DECLARE @twentytwo TABLE(intBillId INT, strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intExpenseAccountId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	intVoucherCount INT
)
--GET ALL RECEIPT CHARGE WITH DOUBLE VOUCHER
;WITH twentytwo (
	intBillId,
	strBillId,
	strReceiptNumber,
	intBillDetailId,
	intItemId,
	intExpenseAccountId,
	intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
)
AS (
SELECT
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	B.intItemId,
	[dbo].[fnGetItemGLAccount](B.intItemId, itemLoc.intItemLocationId, 'Other Charge Expense') AS intExpenseAccountId,
	C2.intInventoryReceiptChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryReceiptCharge C2 
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
INNER JOIN vyuGLAccountDetail D ON B.intAccountId = D.intAccountId
LEFT JOIN tblICItemLocation itemLoc ON B.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = B2.intShipToId
WHERE 
	B.intInventoryReceiptChargeId > 0
AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
AND ABS(B.dblTotal) = C2.dblAmount
AND ABS(B.dblTotal) <> 0 AND C2.dblAmount <> 0
AND D.intAccountCategoryId = 45
AND B2.ysnPosted = 1
--AND C3.strReceiptNumber = 'INVRCT-2922'
)

INSERT INTO @twentytwo
SELECT 
	A.intBillId,
	A.strBillId,
	A.strReceiptNumber,
	A.intBillDetailId,
	A.intExpenseAccountId,
	A.intItemId,
	A.intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
FROM twentytwo A
WHERE A.intInventoryReceiptChargeId IN (
	SELECT intInventoryReceiptChargeId FROM twentytwo B WHERE B.intVoucherCount > 1
)

INSERT INTO @tmpAPC13
SELECT * FROM @twentytwo

SELECT * FROM @tmpAPC13

--PRINT 'APC14 Results'

DECLARE @tmpAPC14 TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	dblChargeAmount DECIMAL(18,6),
	dblGLChargeAmount DECIMAL(18,6)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
END

--ISSUE 23
DECLARE @twentythree TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	dblChargeAmount DECIMAL(18,6),
	dblGLChargeAmount DECIMAL(18,6)
)
--GET ALL CHARGES WITH A SINGLE VOUCHER
--WHICH AMOUNT IS INCORRECT SIDE OF DEBIT/CREDIT SEE BL-7747 ITHACA
INSERT INTO @twentythree
SELECT
	B.intBillId,
	B.strBillId,
	C2.strReceiptNumber,
	A.intBillDetailId,
	C.intInventoryReceiptChargeId,
	C.dblAmount * (CASE WHEN B.intEntityVendorId = ISNULL(NULLIF(C.intEntityVendorId,0), C2.intEntityVendorId) THEN -1 ELSE 1 END),
	(D.dblDebit - D.dblCredit)
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceiptCharge C INNER JOIN tblICInventoryReceipt C2 ON C.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON C.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
INNER JOIN tblGLDetail D ON
	D.intJournalLineNo = A.intBillDetailId AND
	D.strTransactionId = B.strBillId AND
	D.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail E ON
	E.intAccountId = D.intAccountId AND
	E.intAccountCategoryId = 45
WHERE
	B.ysnPosted = 1 AND
	A.dblOldCost IS NOT NULL AND
	--GET ALL CHARGES WITH A SINGLE VOUCHER
	--WHICH AMOUNT IS INCORRECT SIDE OF DEBIT/CREDIT SEE BL-7747 ITHACA
	(D.dblDebit - D.dblCredit) <> (C.dblAmount * (CASE WHEN B.intEntityVendorId = ISNULL(NULLIF(C.intEntityVendorId,0), C2.intEntityVendorId) THEN -1 ELSE 1 END)) AND
	ABS(D.dblDebit - D.dblCredit) = ABS(C.dblAmount * (CASE WHEN B.intEntityVendorId = ISNULL(NULLIF(C.intEntityVendorId,0), C2.intEntityVendorId) THEN -1 ELSE 1 END)) --AND
	--B.strBillId = 'BL-7747'

--RECREATE TAX ENTRIES
DECLARE @voucherInfo23 AS TABLE(intBillId INT, intBillDetailId INT)
INSERT INTO @voucherInfo23
SELECT DISTINCT A.intBillId, A.intBillDetailId 
FROM @twentythree A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherReceiptItemCostAdjGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IS NOT NULL
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherChargeItemGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IS NOT NULL

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

DECLARE @twentythreeWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @twentythreeWithGLIssues
SELECT
	twentythree.strBillId,
	twentythree.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @twentythree twentythree
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentythree.strBillId AND
	A.intJournalLineNo = twentythree.intBillDetailId AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentythree.strBillId AND
	 twentythree.intBillDetailId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC14
SELECT B.*
FROM tblGLDetail A
INNER JOIN @twentythree B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @twentythreeWithGLIssues twentythree ON twentythree.strBillId = A.strTransactionId AND twentythree.intBillDetailId = A.intJournalLineNo
WHERE 
	A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC14

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC14 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC14
END CATCH

--PRINT 'APC15 Results'

DECLARE @tmpAPC15 TABLE 
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblVoucherClearing DECIMAL(18,6),
	dblReceiptClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)

DECLARE @intFunctionalCurrencyId  AS INT 
SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
--GET ALL ICA WHICH HAS .01 DISCREPANCY
--SEE BL-5816
CREATE TABLE #twentyfour
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblVoucherClearing DECIMAL(18,6),
	dblReceiptClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)

--GET ALL ICA Entries IN GL WHICH HAS .01 DIFFERENCE WITH AP CLEARING
INSERT INTO #twentyfour
SELECT DISTINCT
	tmp.*,
	dblGLAdjustment - dblAdjustment AS dblDiff
FROM (
	SELECT
		A.dtmDate,
		A.intBillId,
		A.strBillId,
		E1.strReceiptNumber,
		B.intBillDetailId,
		E2.intInventoryReceiptItemId,
		[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'Inventory Adjustment') intAccountId,
		item.strItemNo,
		CAST(
		dbo.fnMultiply(
			--[Voucher Qty]
			CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
			--[Voucher Cost]
			,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
					dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
						COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
						(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
				ELSE 
					dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
						COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
						(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
			END 													
		)
		AS DECIMAL(18,2))
		- 
		CAST(
		dbo.fnMultiply(
			--[Voucher Qty]
			CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													
			,--[Receipt Cost]
			CASE WHEN E2.ysnSubCurrency = 1 AND E1.intSubCurrencyCents <> 0 THEN 
					CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
							dbo.fnCalculateCostBetweenUOM(
								receiptCostUOM.intItemUOMId
								, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
								, E2.dblUnitCost
							) 
							/ E1.intSubCurrencyCents
							* E2.dblForexRate
						ELSE 
							dbo.fnCalculateCostBetweenUOM(
								receiptCostUOM.intItemUOMId
								, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
								, E2.dblUnitCost
							) 
							/ E1.intSubCurrencyCents
					END 
				ELSE
					CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
						dbo.fnCalculateCostBetweenUOM(
							receiptCostUOM.intItemUOMId
							, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
							, E2.dblUnitCost
						) 
						* E2.dblForexRate
					ELSE 
						dbo.fnCalculateCostBetweenUOM(
							receiptCostUOM.intItemUOMId
							, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
							, E2.dblUnitCost
						) 
				END 
			END
		)
		AS DECIMAL(18,2)) AS dblAdjustment,
		gl.dblCredit - gl.dblDebit AS dblGLAdjustment
	FROM tblAPBill A 
	INNER JOIN tblAPBillDetail B
		ON A.intBillId = B.intBillId
	INNER JOIN (
		tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
			ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
		LEFT JOIN tblICItemLocation sourceLocation
			ON sourceLocation.intItemId = E2.intItemId
			AND sourceLocation.intLocationId = E1.intLocationId
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = E1.intFreightTermId
		LEFT JOIN tblICFobPoint fp
			ON fp.strFobPoint = ft.strFreightTerm
	)
		ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
	INNER JOIN tblICInventoryTransaction invTran
			ON invTran.strTransactionId = A.strBillId AND invTran.intTransactionDetailId = B.intBillDetailId
	INNER JOIN (tblGLDetail gl INNER JOIN vyuGLAccountDetail glAccnt ON gl.intAccountId = glAccnt.intAccountId)
		ON gl.strTransactionId = A.strBillId AND glAccnt.intAccountCategoryId = 45
		AND gl.intJournalLineNo = invTran.intInventoryTransactionId
		AND gl.strCode = 'ICA'
		AND gl.ysnIsUnposted = 0
	INNER JOIN tblICItem item 
		ON B.intItemId = item.intItemId
	INNER JOIN tblICItemLocation D
		ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
	LEFT JOIN tblICItemUOM itemUOM
		ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
	LEFT JOIN tblICItemUOM voucherCostUOM
		ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
	LEFT JOIN tblICItemUOM receiptCostUOM
		ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
	LEFT JOIN tblICInventoryTransactionType transType
		ON transType.strName = 'Bill' -- 'Cost Adjustment'

	WHERE	 
		B.intInventoryReceiptChargeId IS NULL 
	AND B.intInventoryReceiptItemId > 0
	AND B.dblCost <> E2.dblUnitCost
	--AND A.strBillId = 'BL-5816'
) tmp
WHERE 
--	dblAdjustment <> dblGLAdjustment
--AND 
ABS(dblAdjustment - dblGLAdjustment ) = .01

INSERT INTO @tmpAPC15
SELECT A.* 
FROM #twentyfour A
WHERE NOT EXISTS (
	SELECT 1 FROM tblGLDetail B
	WHERE B.strTransactionId = A.strBillId
	AND B.ysnIsUnposted = 0
	AND B.strComments LIKE '%.01 difference on ICA%'
)

SELECT * FROM @tmpAPC15

--NOT APC16 DATA FIX ----PRINT 'APC16 Results'

--PRINT 'APC17 Results'

DECLARE @tmpAPC17 TABLE 
(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intExpenseAccountId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	intVoucherCount INT
)

--DECLARE #apc17 TABLE
CREATE TABLE #apc17
(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intExpenseAccountId INT,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	intVoucherCount INT
)
--GET ALL RECEIPT CHARGE WITH DOUBLE VOUCHER
;WITH twentytwo (
	intBillId,
	strBillId,
	strReceiptNumber,
	intBillDetailId,
	intItemId,
	intExpenseAccountId,
	intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
)
AS (
SELECT
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	B.intItemId,
	[dbo].[fnGetItemGLAccount](B.intItemId, itemLoc.intItemLocationId, 'Other Charge Expense') AS intExpenseAccountId,
	C2.intInventoryReceiptChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryReceiptCharge C2 
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
INNER JOIN vyuGLAccountDetail D ON B.intAccountId = D.intAccountId
LEFT JOIN tblICItemLocation itemLoc ON B.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = B2.intShipToId
WHERE 
	B.intInventoryReceiptChargeId > 0
AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
AND ABS(B.dblTotal) = C2.dblAmount
AND ABS(B.dblTotal) <> 0 AND C2.dblAmount <> 0
AND D.intAccountCategoryId = 45
AND B2.ysnPosted = 1
--AND C3.strReceiptNumber = 'INVRCT-2922'
)

INSERT INTO #apc17
SELECT 
	A.intBillId,
	A.strBillId,
	A.strReceiptNumber,
	A.intBillDetailId,
	A.intExpenseAccountId,
	A.intItemId,
	A.intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
FROM twentytwo A
WHERE A.intInventoryReceiptChargeId IN (
	SELECT intInventoryReceiptChargeId FROM twentytwo B WHERE B.intVoucherCount > 1
)

INSERT INTO @tmpAPC17
SELECT * FROM #apc17

SELECT * FROM @tmpAPC17

--PRINT 'APC18 Results'

DECLARE @tmpAPC18 TABLE 
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT
)
--SELECT TOP 1 * FROM tblAPBillDetail
--SELECT TOP 1 * FROM tblAPBill
--SELECT TOP 1 * FROM tblICInventoryReceiptCharge
--SELECT TOP 1 * FROM tblICInventoryReceipt

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT @date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
END

DECLARE @voucherInfo27 AS TABLE(intBillId INT, intBillDetailId INT)

--DECLARE #twentyseven TABLE
CREATE TABLE #twentyseven
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT
)

--GET INCORRECT GL ENTRIES FOR RECEIPT CHARGE
INSERT INTO #twentyseven
SELECT
	B.dtmDate,
	B.intBillId,
	B.strBillId,
	C2.strReceiptNumber,
	A.intBillDetailId,
	C.intInventoryReceiptChargeId
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceiptCharge C INNER JOIN tblICInventoryReceipt C2 ON C.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON C.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
INNER JOIN tblGLDetail D ON
	D.intJournalLineNo = A.intBillDetailId AND
	D.strTransactionId = B.strBillId AND
	D.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail E ON
	E.intAccountId = D.intAccountId AND
	E.intAccountCategoryId = 45
WHERE
	B.ysnPosted = 1 AND
	--A.dblOldCost IS NOT NULL AND
	A.intInventoryReceiptChargeId > 0 
	--AND B.strBillId = 'BL-8303'

INSERT INTO @voucherInfo27
SELECT DISTINCT A.intBillId, A.intBillDetailId 
FROM #twentyseven A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherReceiptItemCostAdjGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo27)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo27)
AND voucherDetails.intBillDetailId IS NOT NULL
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherChargeItemGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo27)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo27)
AND voucherDetails.intBillDetailId IS NOT NULL

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

DECLARE @twentysevenWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @twentysevenWithGLIssues
SELECT
	twentyseven.strBillId,
	twentyseven.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM #twentyseven twentyseven
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentyseven.strBillId AND
	A.intJournalLineNo = twentyseven.intBillDetailId AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGL
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentyseven.strBillId AND
	 twentyseven.intBillDetailId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory
) oldGL
WHERE 
	((newGL.dblTotal <> oldGL.dblTotal OR oldGL.dblTotal IS NULL)
	AND (newGL.strAccountCategory = oldGL.strAccountCategory OR oldGL.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC18
SELECT B.*
FROM tblGLDetail A
INNER JOIN #twentyseven B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @twentysevenWithGLIssues twentyseven ON twentyseven.strBillId = A.strTransactionId AND twentyseven.intBillDetailId = A.intJournalLineNo
WHERE 
	A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC18

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC18 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC18
END CATCH

--PRINT 'APC19 Results'

DECLARE @tmpAPC19 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptItemId INT,
	intBillDetailId INT,
	intBillDetailTaxId INT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT @date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

DECLARE @voucherInfo28 AS TABLE(intBillId INT, intBillDetailTaxId INT)

DECLARE @twentyeight TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptItemId INT,
	intBillDetailId INT,
	intBillDetailTaxId INT
)

--GET ALL TAX DETAIL IN VOUCHER NOT IN RECEIPT TAX DETAIL
INSERT INTO @twentyeight
SELECT 
	A.dtmDate,
	A.intBillId,
	A.strBillId,
	B.intInventoryReceiptItemId,
	B.intBillDetailId,
	C.intBillDetailTaxId
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
INNER JOIN tblGLDetail gl
	ON gl.intJournalLineNo = C.intBillDetailTaxId AND gl.strTransactionId = A.strBillId
INNER JOIN vyuGLAccountDetail accnt
	ON gl.intAccountId = accnt.intAccountId
CROSS APPLY (
	SELECT SUM(ISNULL(C2.dblAdjustedTax, C2.dblTax)) dblTotalTax FROM tblAPBillDetailTax C2 
	WHERE C2.intBillDetailId = B.intBillDetailId
) totalTax
LEFT JOIN (
	SELECT D.dblTax, D.dblAdjustedTax, D.ysnTaxExempt, D.intInventoryReceiptItemId,D.intTaxClassId, D.intTaxCodeId
	FROM tblICInventoryReceiptItemTax D
	INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt F ON E.intInventoryReceiptId = F.intInventoryReceiptId
) receiptTax
	ON B.intInventoryReceiptItemId = receiptTax.intInventoryReceiptItemId
	AND C.intTaxClassId = receiptTax.intTaxClassId
	AND C.intTaxCodeId = receiptTax.intTaxCodeId
WHERE
	C.ysnTaxAdjusted = 0
AND B.intInventoryReceiptItemId > 0
AND receiptTax.intInventoryReceiptItemId IS NULL
AND (gl.dblDebit - gl.dblCredit) != 0
--THIS SHOULD NOT USE AP CLEARING ACCOUNT, IT SHOULD USE TAX ACCOUNT IF RECEIPT DO NOT HAVE THE SAME TAX DETAIL
AND accnt.intAccountCategoryId = 45 
--AND NOT EXISTS (
--	SELECT 1 FROM tblGLDetail fixGL
--	WHERE fixGL.strTransactionId = A.strBillId
--	AND fixGL.ysnIsUnposted = 0
--	AND 
--)

INSERT INTO @voucherInfo28
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @twentyeight A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @voucherInfo28)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @voucherInfo28)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @voucherInfo28)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @voucherInfo28)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @twentyeightWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT)
INSERT INTO @twentyeightWithGLIssues
SELECT
	twentyeight.strBillId,
	twentyeight.intBillDetailTaxId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @twentyeight twentyeight
--OUTER APPLY
--(
--	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
--	FROM @GLEntries A
--	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
--	WHERE strTransactionId = twentyeight.strBillId AND
--	A.intJournalLineNo = twentyeight.intBillDetailTaxId AND
--	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
--	GROUP BY B.strAccountCategory--, A.strTransactionId
--) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = twentyeight.strBillId AND
	 twentyeight.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax' AND
	 B.intAccountCategoryId = 45 --THERE SHOULD BE NO AP CLEARING
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	ISNULL(glTax.dblTotal,0) <> 0

--specific issue
INSERT INTO @tmpAPC19
SELECT B.*
FROM tblGLDetail A
INNER JOIN @twentyeight B ON A.strTransactionId = B.strBillId AND B.intBillDetailTaxId = A.intJournalLineNo
INNER JOIN @twentyeightWithGLIssues eleven ON A.strTransactionId = eleven.strBillId AND eleven.intBillDetailTaxId = A.intJournalLineNo 
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC19

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC19 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC19
END CATCH

--PRINT 'APC20 Results'

DECLARE @tmpAPC20 TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	strChargeCostMethod NVARCHAR(50),
	dblChargeAmount DECIMAL(18,6),
	dblChargeRate DECIMAL(18,6),
	dblTotal DECIMAL(18,6)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

--ISSUE 23
DECLARE @thirty TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptChargeId INT,
	strChargeCostMethod NVARCHAR(50),
	dblChargeAmount DECIMAL(18,6),
	dblChargeRate DECIMAL(18,6),
	dblTotal DECIMAL(18,6)
)
--GET ALL CHARGES WITH A SINGLE VOUCHER
--WITH INCORRECT GL ENTRIES IT IS NOT COST ADJUSTED
--NOT INVENTORY COST
INSERT INTO @thirty
SELECT
	B.intBillId,
	B.strBillId,
	C2.strReceiptNumber,
	A.intBillDetailId,
	C.intInventoryReceiptChargeId,
	C.strCostMethod,
	C.dblAmount,
	C.dblRate,
	A.dblTotal
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceiptCharge C INNER JOIN tblICInventoryReceipt C2 ON C.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON C.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
OUTER APPLY (
	SELECT COUNT(*) intCount FROM tblAPBillDetail D
	WHERE D.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
) vouchers
WHERE
	B.ysnPosted = 1 AND
	A.dblOldCost IS NULL AND
	ABS(A.dblTotal) <> ABS(C.dblAmount) AND
	ABS(C.dblAmount) <> 0 AND
	vouchers.intCount = 1 AND
	--IT SHOULD BE FULLY VOUCHER
	(COALESCE(C.dblAmountBilled, C.dblAmountPriced) >= C.dblAmount OR A.dblQtyReceived >= C.dblQuantity)
	--AND B.strBillId = 'BL-151562'

--MARK AS COST ADJUSTED TO CORRECTLY CALCULATE GL ENTRIES
UPDATE A
SET A.dblOldCost = CASE WHEN B.strChargeCostMethod IN ('Per Unit', 'Gross Unit') THEN B.dblChargeRate ELSE B.dblChargeAmount END
FROM tblAPBillDetail A
INNER JOIN @thirty B ON A.intBillDetailId = B.intBillDetailId

INSERT INTO @voucherInfo23
SELECT DISTINCT A.intBillId, A.intBillDetailId 
FROM @thirty A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherReceiptItemCostAdjGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IS NOT NULL
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherChargeItemGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo23)
AND voucherDetails.intBillDetailId IS NOT NULL

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

DECLARE @thirtyWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @thirtyWithGLIssues
SELECT
	thirty.strBillId,
	thirty.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @thirty thirty
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = thirty.strBillId AND
	A.intJournalLineNo = thirty.intBillDetailId AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = thirty.strBillId AND
	 thirty.intBillDetailId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC20
SELECT B.*
FROM tblGLDetail A
INNER JOIN @thirty B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @thirtyWithGLIssues thirty ON thirty.strBillId = A.strTransactionId AND thirty.intBillDetailId = A.intJournalLineNo
WHERE 
	A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC20

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC20 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC20
END CATCH

--PRINT 'APC21 Results'

DECLARE @tmpAPC21 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblVoucherClearing DECIMAL(18,6),
	dblReceiptClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)


SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
--GET ALL ICA WHICH HAS .01 DISCREPANCY
--SEE BL-5816
DECLARE @thirtyseven TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblVoucherClearing DECIMAL(18,6),
	dblReceiptClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)

--GET ALL ICA Entries IN GL WHICH HAS .01 DIFFERENCE WITH AP CLEARING
INSERT INTO @thirtyseven
SELECT 
	tmp.*,
	dblAdjustment - dblGLAdjustment AS dblDiff
FROM (
	SELECT
		A.dtmDate,
		A.intBillId,
		A.strBillId,
		E1.strReceiptNumber,
		B.intBillDetailId,
		E2.intInventoryReceiptItemId,
		[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'Inventory Adjustment') intAccountId,
		item.strItemNo,
		CAST(
		dbo.fnMultiply(
			--[Voucher Qty]
			CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
			--[Voucher Cost]
			,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
					dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
						COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
						(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
				ELSE 
					dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
						COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
						(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
			END 													
		)
		AS DECIMAL(18,2))
		- 
		CAST(
		dbo.fnMultiply(
			--[Voucher Qty]
			CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													
			,--[Receipt Cost]
			CASE WHEN E2.ysnSubCurrency = 1 AND E1.intSubCurrencyCents <> 0 THEN 
					CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
							dbo.fnCalculateCostBetweenUOM(
								receiptCostUOM.intItemUOMId
								, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
								, E2.dblUnitCost
							) 
							/ E1.intSubCurrencyCents
							* E2.dblForexRate
						ELSE 
							dbo.fnCalculateCostBetweenUOM(
								receiptCostUOM.intItemUOMId
								, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
								, E2.dblUnitCost
							) 
							/ E1.intSubCurrencyCents
					END 
				ELSE
					CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
						dbo.fnCalculateCostBetweenUOM(
							receiptCostUOM.intItemUOMId
							, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
							, E2.dblUnitCost
						) 
						* E2.dblForexRate
					ELSE 
						dbo.fnCalculateCostBetweenUOM(
							receiptCostUOM.intItemUOMId
							, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
							, E2.dblUnitCost
						) 
				END 
			END
		)
		AS DECIMAL(18,2)) AS dblAdjustment,
		gl.dblDebit - gl.dblCredit AS dblGLAdjustment
	FROM tblAPBill A 
	INNER JOIN tblAPBillDetail B
		ON A.intBillId = B.intBillId
	INNER JOIN (
		tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
			ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
		LEFT JOIN tblICItemLocation sourceLocation
			ON sourceLocation.intItemId = E2.intItemId
			AND sourceLocation.intLocationId = E1.intLocationId
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = E1.intFreightTermId
		LEFT JOIN tblICFobPoint fp
			ON fp.strFobPoint = ft.strFreightTerm
	)
		ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
	--INNER JOIN tblICInventoryTransaction invTran
	--		ON invTran.strTransactionId = A.strBillId AND invTran.intTransactionDetailId = B.intBillDetailId
	INNER JOIN (tblGLDetail gl INNER JOIN vyuGLAccountDetail glAccnt ON gl.intAccountId = glAccnt.intAccountId)
		ON gl.strTransactionId = A.strBillId AND glAccnt.intAccountCategoryId = 45
		AND gl.intJournalLineNo = B.intBillDetailId--invTran.intInventoryTransactionId
		--AND gl.strCode = 'ICA'
		AND gl.ysnIsUnposted = 0
	INNER JOIN tblICItem item 
		ON B.intItemId = item.intItemId
	INNER JOIN tblICItemLocation D
		ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
	LEFT JOIN tblICItemUOM itemUOM
		ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
	LEFT JOIN tblICItemUOM voucherCostUOM
		ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
	LEFT JOIN tblICItemUOM receiptCostUOM
		ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
	LEFT JOIN tblICInventoryTransactionType transType
		ON transType.strName = 'Bill' -- 'Cost Adjustment'

	WHERE	 
		B.intInventoryReceiptChargeId IS NULL 
	AND B.intInventoryReceiptItemId > 0
	AND B.dblCost <> E2.dblUnitCost
	--AND A.strBillId = 'BL-5816'
) tmp
WHERE 
--	dblAdjustment <> dblGLAdjustment
--AND 
ABS(dblAdjustment - dblGLAdjustment ) = .01

INSERT INTO @tmpAPC21
SELECT A.* 
FROM @thirtyseven A
WHERE NOT EXISTS (
	SELECT 1 FROM tblGLDetail B
	WHERE B.strTransactionId = A.strBillId
	AND B.ysnIsUnposted = 0
	AND B.strComments LIKE '%.01 difference on AP Cost Adjustment%'
)

SELECT * FROM @tmpAPC21

--PRINT 'APC22 Results'

DECLARE @tmpAPC22 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;

BEGIN TRY
BEGIN TRAN

SELECT @date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @thirtyeight TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6)
)
--voucher with different net weight from receipt

INSERT INTO @thirtyeight
--GET THOSE VOUCHERS WHICH HAS .01 DIFFERENCE IN TOTAL FOR RECEIPT
SELECT * 
FROM (
SELECT
C.dtmDate,
C.intBillId,
C.strBillId,
D2.strReceiptNumber,
A.intBillDetailId,
D.intInventoryReceiptItemId,
[dbo].[fnGetItemGLAccount](A.intItemId, itemLoc.intItemLocationId, 'Inventory Adjustment') intAccountId,
item.strItemNo,
glReceiptItem.dblReceiptClearing,
glVoucherItem.dblVoucherClearing,
--ABS(
CASE WHEN WC.intWeightClaimDetailId IS NOT NULL--C.intTransactionType = 11
THEN 
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN
		CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	ELSE 
		CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	END),0)
ELSE
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN (CASE 
			WHEN A.intWeightUOMId > 0 
				THEN CAST(A.dblCost / ISNULL(C.intSubCurrencyCents,1)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
		END)
	ELSE (CASE 
			WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
				THEN CAST(A.dblCost  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (A.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
		END)
	END),0)
END - 
	A.dblTotal AS dblDiff
FROM tblAPBillDetail A
	INNER JOIN tblAPBill C ON A.intBillId = C.intBillId
	INNER JOIN (tblICInventoryReceiptItem D INNER JOIN tblICInventoryReceipt D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
		ON D.intInventoryReceiptItemId = A.intInventoryReceiptItemId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
	CROSS APPLY (
		SELECT SUM(B.dblCredit - B.dblDebit) AS dblReceiptClearing
			--B.*
		FROM tblGLDetail B
		INNER JOIN tblICInventoryTransaction B2 
			ON B.strTransactionId = B2.strTransactionId AND B.intJournalLineNo = B2.intInventoryTransactionId
		INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
		WHERE D2.strReceiptNumber = B.strTransactionId
		AND B3.intAccountCategoryId = 45
		AND D.intInventoryReceiptItemId = B2.intTransactionDetailId
	) glReceiptItem
	CROSS APPLY (
		SELECT SUM(B.dblDebit - B.dblCredit) AS dblVoucherClearing
			--B.*
		FROM tblGLDetail B
		INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
		WHERE C.strBillId = B.strTransactionId
		AND B3.intAccountCategoryId = 45
		AND A.intBillDetailId = B.intJournalLineNo
		--AND B.strCode <> 'ICA' --exclude ICA to calculate correctly the actual difference between receipt total and voucher total
		AND (B.dblDebitUnit <> 0 OR B.dblCreditUnit <> 0) --exclude other gl entry for the item to correctly calculate the actual difference
	) glVoucherItem
	LEFT JOIN tblLGWeightClaimDetail WC ON WC.intBillId = C.intBillId
	LEFT JOIN tblICItemLocation itemLoc ON A.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = D2.intLocationId
WHERE 
	--D.dblNet <> 0 AND A.dblNetWeight = 0
	A.intInventoryReceiptChargeId IS NULL
	AND D.dblNet = 0
	AND D.dblOpenReceive = A.dblQtyReceived
	AND D.dblLineTotal <> A.dblTotal
	AND D.dblUnitCost = A.dblCost
	--AND (
	--	ABS(D.dblLineTotal - A.dblTotal) = .01 OR
	--	 ABS(D.dblLineTotal - A.dblTotal) = .02
	--	 )
	--AND C.strBillId = 'BL-23027'
) tmp
--WHERE ABS(dblDiff) = .01
--OR ABS(dblDiff) = .02

SELECT TOP 1 @noAccount = 'There are no Inventory Adjustment account setup for the item ' + A.strItemNo + ' on ' + A.strBillId
FROM @thirtyeight A
WHERE A.intAccountId IS NULL

IF ISNULL(@noAccount,'') <> ''
BEGIN 
	--SET @accountError = 'There are no COGS account setup for the item on ' + @noAccount
	RAISERROR(@noAccount, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	A.dblDiff						
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	0				
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	A.dblDiff				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@thirtyeight A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @thirtyeight)
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	A.dblDiff						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	A.dblDiff					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	A.dblDiff				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@thirtyeight A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @thirtyeight)

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @thirtyeightWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @thirtyeightWithGLIssues
SELECT
	eighteen.strBillId,
	eighteen.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @thirtyeight eighteen
OUTER APPLY
(
	--NEW GL
	SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
	FROM (
	--SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	--FROM @GLEntries A
	--INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	--WHERE strTransactionId = eighteen.strBillId AND
	--A.intJournalLineNo = eighteen.intBillDetailId AND
	--B.intAccountCategoryId = 45 AND
	--	ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	----GROUP BY B.strAccountCategory--, A.strTransactionId
	--UNION ALL
	--OLD GL
	SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eighteen.strBillId AND
	B.intAccountCategoryId = 45 AND
	A.intJournalLineNo = eighteen.intBillDetailId AND
		ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	--GROUP BY B.strAccountCategory--, A.strTransactionId
	) tmp
	--GROUP BY strAccountCategory
) newGLTax
OUTER APPLY 
(
	--RECEIPT GL
	SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblICInventoryTransaction C
		ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
		AND C.intTransactionDetailId = eighteen.intInventoryReceiptItemId
	WHERE A.strTransactionId = eighteen.strReceiptNumber AND
	B.intAccountCategoryId = 45 AND
	--A.intJournalLineNo = 409558 AND
		A.ysnIsUnposted = 0
	--GROUP BY B.strAccountCategory
) rcptClearing
WHERE 
	(newGLTax.dblTotal <> rcptClearing.dblTotal 
		--AND (
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .01 OR
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .02
		--)
		)
	OR rcptClearing.dblTotal IS NULL

INSERT INTO @tmpAPC22
SELECT
A.*
FROM @thirtyeight A
INNER JOIN @thirtyeightWithGLIssues B ON A.strBillId = B.strBillId
AND A.intBillDetailId = B.intBillDetailId

SELECT * FROM @tmpAPC22

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC22 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC22
END CATCH

--PRINT 'APC23 Results'

DECLARE @tmpAPC23 TABLE(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	intVoucherCount INT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;
SET @noAccount = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate


--ISSUE 22
DECLARE @thirtynine TABLE(intBillId INT, strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	intVoucherCount INT
)
--GET ALL VOUCHER THAT IS GREATER THAN THE RECEIPT, NO COST ADJUSTMENT, SINGLE VOUCHER
;WITH thirtynine (
	intBillId,
	strBillId,
	strReceiptNumber,
	intBillDetailId,
	intItemId,
	strItemNo,
	intAccountId,
	intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
)
AS (

SELECT
	B.intBillId,
	B2.strBillId,
	C3.strReceiptNumber,
	B.intBillDetailId,
	B.intItemId,
	item.strItemNo,
	[dbo].[fnGetItemGLAccount](B.intItemId, itemLoc.intItemLocationId, 'Other Charge Expense') AS intAccountId,
	C2.intInventoryReceiptChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryReceiptChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryReceiptCharge C2 
				INNER JOIN tblICInventoryReceipt C3 ON C3.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId
INNER JOIN vyuGLAccountDetail D ON B.intAccountId = D.intAccountId
INNER JOIN tblICItem item ON item.intItemId = B.intItemId
LEFT JOIN tblICItemLocation itemLoc ON B.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = B2.intShipToId
WHERE 
	B.intInventoryReceiptChargeId > 0
--AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
--AND ABS(B.dblTotal) = C2.dblAmount
AND ABS(ABS(B.dblTotal)  - ABS(C2.dblAmount)) = .01
AND B.dblOldCost IS NULL
AND C2.dblAmount <> 0
--AND D.intAccountCategoryId = 45
AND B2.ysnPosted = 1
AND (C2.dblQuantity = C2.dblQuantityBilled 
		OR C2.dblQuantity = C2.dblQuantityPriced 
		OR C2.dblAmount = C2.dblAmountBilled
		OR C2.dblQuantity = B.dblQtyReceived)
--AND C3.strReceiptNumber = 'INVRCT-2922'
)

INSERT INTO @thirtynine
SELECT 
	A.intBillId,
	A.strBillId,
	A.strReceiptNumber,
	A.intBillDetailId,
	A.intAccountId,
	A.intItemId,
	A.strItemNo,
	A.intInventoryReceiptChargeId,
	dblTotal,
	dblChargeAmount,
	ABS(dblChargeAmount) - ABS(dblTotal),
	intVoucherCount
FROM thirtynine A
WHERE A.intInventoryReceiptChargeId IN (
	SELECT intInventoryReceiptChargeId FROM thirtynine B WHERE B.intVoucherCount = 1
)

SELECT TOP 1 @noAccount = 'There are no Inventory Adjustment account setup for the item ' + A.strItemNo + ' on ' + A.strBillId
FROM @thirtynine A
WHERE A.intAccountId IS NULL

IF ISNULL(@noAccount,'') <> ''
BEGIN 
	--SET @accountError = 'There are no COGS account setup for the item on ' + @noAccount
	RAISERROR(@noAccount, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	A.dblDiff						
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	0				
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	A.dblDiff				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@thirtynine A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @thirtynine)
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	A.dblDiff						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	A.dblDiff					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	A.dblDiff				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@thirtynine A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @thirtynine)

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @thirtynineWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @thirtynineWithGLIssues
SELECT
	eighteen.strBillId,
	eighteen.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @thirtynine eighteen
OUTER APPLY
(
	--NEW GL
	SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
	FROM (
	SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eighteen.strBillId AND
	B.intAccountCategoryId = 45 AND
	A.intJournalLineNo = eighteen.intBillDetailId AND
		ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	--GROUP BY B.strAccountCategory--, A.strTransactionId
	) tmp
	--GROUP BY strAccountCategory
) newGLTax
OUTER APPLY 
(
	--RECEIPT GL
	SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	--INNER JOIN tblICInventoryTransaction C
	--	ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
	--	AND C.intTransactionDetailId = eighteen.intInventoryReceiptItemId
	WHERE A.strTransactionId = eighteen.strReceiptNumber AND
	A.intJournalLineNo = eighteen.intInventoryReceiptChargeId AND
	B.intAccountCategoryId = 45 AND
	--A.intJournalLineNo = 409558 AND
		A.ysnIsUnposted = 0
	--GROUP BY B.strAccountCategory
) rcptClearing
WHERE 
	(newGLTax.dblTotal <> rcptClearing.dblTotal 
		--AND (
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .01 OR
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .02
		--)
		)
	OR rcptClearing.dblTotal IS NULL

INSERT INTO @tmpAPC23
SELECT A.*
FROM @thirtynine A
INNER JOIN @thirtynineWithGLIssues B ON A.strBillId = B.strBillId AND A.intBillDetailId = B.intBillDetailId

SELECT * FROM @tmpAPC23

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC23 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC23
END CATCH

--PRINT 'APC24 Results'

DECLARE @tmpAPC24 TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @apc24 TABLE(
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intBillDetailTaxId INT
)

--GET ALL VOUCHERS WHERE TAXES IS POSTED IN A SINGLE ENTRY

INSERT INTO @apc24
SELECT
	A.intBillId,
	A.strBillId,
	B.intBillDetailId,
	C.intBillDetailTaxId
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
INNER JOIN tblGLDetail D ON
	D.strTransactionId = A.strBillId
AND D.intJournalLineNo = B.intBillDetailId
AND D.strJournalLineDescription = 'Purchase Tax'
AND D.ysnIsUnposted = 0
WHERE
	B.dblTax <> 0

INSERT INTO @billIds
SELECT DISTINCT A.intBillId, A.intBillDetailTaxId 
FROM @apc24 A
--INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
--INNER JOIN tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
--INNER JOIN @affectedTaxDetails D ON C.intBillDetailTaxId = D.intBillDetailTaxId

--SELECT * FROM @ten WHERE strBillId = 'BL-206942'

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherTaxGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
AND voucherDetails.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
UNION ALL --TAX ADJUSTMENT
SELECT	
		[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
		[strBatchID]					=	gl.strBatchId,
		[intAccountId]					=	D.intAccountId,
		[dblDebit]						=	CASE WHEN charges.intInventoryReceiptChargeId > 0 
													THEN (CASE WHEN A.intEntityVendorId <> ISNULL(NULLIF(charges.intEntityVendorId,0), receipts.intEntityVendorId) 
															AND charges.ysnPrice = 1 
																	THEN 
																		CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																				* ISNULL(NULLIF(B.dblRate,0), 1) AS DECIMAL(18,2))
																			- 
																			CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																		* -1
														WHEN A.intEntityVendorId = receipts.intEntityVendorId AND charges.ysnPrice = 0 --THIRD PARTY
															THEN 
																(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																		* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
																	 - CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
														END) 
												ELSE 
													(CAST(SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) 
																* ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)) 
															- CAST(SUM(D.dblTax) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2)))
												END
												* (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
		-- [dblDebit]						=	CAST((SUM(ISNULL(D.dblAdjustedTax, D.dblTax)) - SUM(D.dblTax)) * ISNULL(NULLIF(B.dblRate,0),1) AS DECIMAL(18,2))
											-- * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END),
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
			OUTER APPLY (
				SELECT TOP 1 *
				FROM tblGLDetail glData
				WHERE glData.strTransactionId = A.strBillId
			) gl
	WHERE	A.intBillId IN (SELECT intBillId FROM @billIds)
	AND D.intBillDetailTaxId IN (SELECT intBillDetailTaxId FROM @billIds)
	AND A.intTransactionType IN (1,3)
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
	,gl.strBatchId
	,gl.dtmDate

UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @apc24WithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailTaxId INT, intBillDetailId INT)
INSERT INTO @apc24WithGLIssues
SELECT
	thirtyeight.strBillId,
	thirtyeight.intBillDetailTaxId,
	thirtyeight.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @apc24 thirtyeight
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = thirtyeight.strBillId AND
	A.intJournalLineNo = thirtyeight.intBillDetailTaxId AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGLTax
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = thirtyeight.strBillId AND
	 thirtyeight.intBillDetailTaxId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 AND strJournalLineDescription = 'Purchase Tax'
	GROUP BY B.strAccountCategory
) glTax
WHERE 
	((newGLTax.dblTotal <> glTax.dblTotal OR glTax.dblTotal IS NULL)
	AND (newGLTax.strAccountCategory = glTax.strAccountCategory OR glTax.strAccountCategory IS NULL))

--specific issue
INSERT INTO @tmpAPC24
SELECT B.*
FROM tblGLDetail A
INNER JOIN @apc24 B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @apc24WithGLIssues thirtyeight ON thirtyeight.strBillId = A.strTransactionId AND thirtyeight.intBillDetailId = A.intJournalLineNo
WHERE A.strJournalLineDescription = 'Purchase Tax'
AND A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC24

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC24 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC24
END CATCH

--PRINT 'APC25 Results'

DECLARE @tmpAPC25 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryShipmentChargeId INT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;
SET @noAccount = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @voucherInfo41 AS TABLE(intBillId INT, intBillDetailId INT)

DECLARE @fourtyone TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryShipmentChargeId INT
)

INSERT INTO @fourtyone
SELECT
	B.dtmDate,
	B.intBillId,
	B.strBillId,
	C2.strShipmentNumber,
	A.intBillDetailId,
	C.intInventoryShipmentChargeId
FROM tblAPBillDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryShipmentCharge C INNER JOIN tblICInventoryShipment C2 ON C.intInventoryShipmentId = C2.intInventoryShipmentId)
	ON C.intInventoryShipmentChargeId = A.intInventoryShipmentChargeId
INNER JOIN tblGLDetail D ON
	D.intJournalLineNo = A.intBillDetailId AND
	D.strTransactionId = B.strBillId AND
	D.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail E ON
	E.intAccountId = D.intAccountId AND
	E.intAccountCategoryId = 45
WHERE
	B.ysnPosted = 1 AND
	--A.dblOldCost IS NOT NULL AND
	--A.intInventoryShipmentChargeId = 4 AND
	A.intInventoryShipmentChargeId > 0 


INSERT INTO @voucherInfo41
SELECT DISTINCT A.intBillId, A.intBillDetailId 
FROM @fourtyone A

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strRateType ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY (
			SELECT
				B.intBillDetailId
				,B.strMiscDescription
				,CAST((CASE	WHEN A.intTransactionType IN (1) 
						THEN (B.dblTotal - 
									(charges.dblAmount * ISNULL(NULLIF(B.dblRate,0),1))) 
						ELSE 0 END) AS  DECIMAL(18, 2)) AS dblTotal
				,CAST((CASE	WHEN A.intTransactionType IN (1) 
						THEN (B.dblTotal - 
									(charges.dblAmount))
						ELSE 0 END) AS  DECIMAL(18, 2)) AS dblForeignTotal
				--,(CASE WHEN F.intItemId IS NULL THEN B.dblQtyReceived 
				--		ELSE
				--			CASE WHEN F.strType = 'Inventory' THEN --units is only of inventory item
				--				dbo.fnCalculateQtyBetweenUOM((CASE WHEN B.intWeightUOMId > 0 
				--												THEN B.intWeightUOMId ELSE B.intUnitOfMeasureId END), 
				--											itemUOM.intItemUOMId,
				--											CASE WHEN B.intWeightUOMId > 0 THEN B.dblNetWeight ELSE B.dblQtyReceived END)
				--			ELSE 0 END
				--END) as dblTotalUnits
				,CASE 
					WHEN B.intPurchaseDetailId > 0 AND poDetail.intAccountId > 0
						THEN poDetail.intAccountId
					WHEN B.intInventoryShipmentChargeId > 0 OR F.strType = 'Non-Inventory'
						THEN [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Other Charge Expense')
					END AS intAccountId
				,G.intCurrencyExchangeRateTypeId
				,G.strCurrencyExchangeRateType
				,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate
			FROM tblAPBillDetail B
			LEFT JOIN tblICInventoryReceiptItem E
				ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId
			LEFT JOIN (tblICInventoryShipmentCharge charges INNER JOIN tblICInventoryShipment r ON charges.intInventoryShipmentId = r.intInventoryShipmentId)
				ON B.intInventoryShipmentChargeId = charges.intInventoryShipmentChargeId
			LEFT JOIN tblPOPurchaseDetail poDetail
				ON B.intPurchaseDetailId = poDetail.intPurchaseDetailId
			LEFT JOIN dbo.tblSMCurrencyExchangeRateType G
				ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId
			LEFT JOIN tblICItem B2
				ON B.intItemId = B2.intItemId
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId
			LEFT JOIN tblICItem F
				ON B.intItemId = F.intItemId
			LEFT JOIN tblICItemUOM itemUOM ON F.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1	
			--OUTER APPLY (
			--	SELECT dblTotal = CAST (
			--			CASE WHEN B.intInventoryReceiptChargeId > 0
			--			THEN charges.dblAmount
			--			 WHEN B.intInventoryShipmentChargeId > 0
			--	 		THEN shipmentCharges.dblAmount
			--			ELSE (CASE	
			--					-- If there is a Gross/Net UOM, compute by the net weight. 
			--					WHEN E.intWeightUOMId IS NOT NULL THEN 
			--						-- Convert the Cost UOM to Gross/Net UOM. 
			--						dbo.fnCalculateCostBetweenUOM(
			--							ISNULL(E.intCostUOMId, E.intUnitMeasureId)
			--							, E.intWeightUOMId
			--							, E.dblUnitCost
			--						) 
			--						/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END 
			--						* B.dblNetWeight

			--					-- If Gross/Net UOM is missing: compute by the receive qty. 
			--					ELSE 
			--						-- Convert the Cost UOM to Gross/Net UOM. 
			--						dbo.fnCalculateCostBetweenUOM(
			--							ISNULL(E.intCostUOMId, E.intUnitMeasureId)
			--							, E.intUnitMeasureId
			--							, E.dblUnitCost
			--						) 
			--						/ CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END  
			--						* B.dblQtyReceived
			--				END)
			--			END				
			--			AS DECIMAL(18, 2)
			--		)
			--) usingOldCost
			WHERE A.intBillId = B.intBillId
			AND B.dblTotal > charges.dblAmount
			AND B.intCustomerStorageId IS NULL
			AND B.intInventoryShipmentChargeId > 0
		) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo41)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo41)
AND voucherDetails.intBillDetailId IS NOT NULL
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END,
	[strBatchID]					=	gl.strBatchId,
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
	[dblSourceUnitCredit]			=	0,
	[dblSourceUnitDebit]			=	0,
	[intCommodityId]				=	A.intCommodityId,
	[intSourceLocationId]			=	A.intStoreLocationId,
	[strSourceDocumentId]			=	A.strVendorOrderNumber
FROM	[dbo].tblAPBill A 
		CROSS APPLY dbo.fnAPGetVoucherShipmentChargeItemGLEntry(A.intBillId) voucherDetails
		LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
			ON A.intEntityVendorId = C.[intEntityId]
		OUTER APPLY (
			SELECT TOP 1 *
			FROM tblGLDetail glData
			WHERE glData.strTransactionId = A.strBillId
		) gl
WHERE A.intBillId IN (SELECT intBillId FROM @voucherInfo41)
AND voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @voucherInfo41)
AND voucherDetails.intBillDetailId IS NOT NULL


UPDATE A
SET
	A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

DECLARE @fourtyoneWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @fourtyoneWithGLIssues
SELECT
	fourtyone.strBillId,
	fourtyone.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @fourtyone fourtyone
OUTER APPLY
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory --,A.strTransactionId
	FROM @GLEntries A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = fourtyone.strBillId AND
	A.intJournalLineNo = fourtyone.intBillDetailId AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory--, A.strTransactionId
) newGL
OUTER APPLY 
(
	SELECT SUM(dblCredit - dblDebit) AS dblTotal, B.strAccountCategory-- , A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = fourtyone.strBillId AND
	 fourtyone.intBillDetailId = A.intJournalLineNo AND
	 ysnIsUnposted = 0 
	GROUP BY B.strAccountCategory
) oldGL
WHERE 
	((newGL.dblTotal <> oldGL.dblTotal OR oldGL.dblTotal IS NULL)
	AND (newGL.strAccountCategory = oldGL.strAccountCategory OR oldGL.strAccountCategory IS NULL))


--specific issue
INSERT INTO @tmpAPC25
SELECT B.*
FROM tblGLDetail A
INNER JOIN @fourtyone B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @fourtyoneWithGLIssues twentyseven ON twentyseven.strBillId = A.strTransactionId AND twentyseven.intBillDetailId = A.intJournalLineNo
WHERE 
	A.ysnIsUnposted = 0

SELECT * FROM @tmpAPC25
	
ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC25 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC25
END CATCH

--PRINT 'APC26 Results'

DECLARE @tmpAPC26 TABLE(
	intBillId INT, 
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryShipmentChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	intVoucherCount INT
)

DELETE FROM @affectedTaxDetails
DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;
SET @noAccount = NULL;

BEGIN TRY

BEGIN TRAN

SELECT 
	@date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

--ISSUE 22
DECLARE @fourty TABLE(intBillId INT, strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryShipmentChargeId INT,
	dblDetailTotal DECIMAL(18,6),
	dblChargeAmount DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	intVoucherCount INT
)
--GET ALL VOUCHER THAT IS GREATER THAN THE RECEIPT, NO COST ADJUSTMENT, SINGLE VOUCHER
;WITH fourty (
	intBillId,
	strBillId,
	strReceiptNumber,
	intBillDetailId,
	intItemId,
	strItemNo,
	intAccountId,
	intInventoryShipmentChargeId,
	dblTotal,
	dblChargeAmount,
	intVoucherCount
)
AS (

SELECT
	B.intBillId,
	B2.strBillId,
	C3.strShipmentNumber,
	B.intBillDetailId,
	B.intItemId,
	item.strItemNo,
	[dbo].[fnGetItemGLAccount](B.intItemId, itemLoc.intItemLocationId, 'Other Charge Expense') AS intAccountId,
	C2.intInventoryShipmentChargeId,
	ABS(B.dblTotal),
	C2.dblAmount,
	ROW_NUMBER() OVER(PARTITION BY C2.intInventoryShipmentChargeId ORDER BY B.intBillDetailId) AS intVoucherCount
FROM tblAPBillDetail B
INNER JOIN tblAPBill B2 ON B.intBillId = B2.intBillId
INNER JOIN (tblICInventoryShipmentCharge C2 
				INNER JOIN tblICInventoryShipment C3 ON C3.intInventoryShipmentId = C2.intInventoryShipmentId)
	ON B.intInventoryShipmentChargeId = C2.intInventoryShipmentChargeId
INNER JOIN vyuGLAccountDetail D ON B.intAccountId = D.intAccountId
INNER JOIN tblICItem item ON item.intItemId = B.intItemId
LEFT JOIN tblICItemLocation itemLoc ON B.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = B2.intShipToId
WHERE 
	B.intInventoryShipmentChargeId > 0
--AND B.intContractDetailId > 0 --FROM CONTRACT, PRORATED
--AND ABS(B.dblTotal) = C2.dblAmount
AND ABS(ABS(B.dblTotal)  - ABS(C2.dblAmount)) = .01
AND B.dblOldCost IS NULL
AND C2.dblAmount <> 0
--AND D.intAccountCategoryId = 45
AND B2.ysnPosted = 1
AND (C2.dblQuantity = C2.dblQuantityBilled 
		OR C2.dblQuantity = C2.dblQuantityPriced 
		OR C2.dblAmount = C2.dblAmountBilled
		OR C2.dblQuantity = B.dblQtyReceived)
--AND C3.strReceiptNumber = 'INVRCT-2922'
)

INSERT INTO @fourty
SELECT 
	A.intBillId,
	A.strBillId,
	A.strReceiptNumber,
	A.intBillDetailId,
	A.intAccountId,
	A.intItemId,
	A.strItemNo,
	A.intInventoryShipmentChargeId,
	dblTotal,
	dblChargeAmount,
	ABS(dblChargeAmount) - ABS(dblTotal),
	intVoucherCount
FROM fourty A
WHERE A.intInventoryShipmentChargeId IN (
	SELECT intInventoryShipmentChargeId FROM fourty B WHERE B.intVoucherCount = 1
)

SELECT TOP 1 @noAccount = 'There are no Inventory Adjustment account setup for the item ' + A.strItemNo + ' on ' + A.strBillId
FROM @fourty A
WHERE A.intAccountId IS NULL

IF ISNULL(@noAccount,'') <> ''
BEGIN 
	--SET @accountError = 'There are no COGS account setup for the item on ' + @noAccount
	RAISERROR(@noAccount, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	A.dblDiff						
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	0				
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	A.dblDiff				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@fourty A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @fourty)
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	A.dblDiff						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	A.dblDiff					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	A.dblDiff				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@fourty A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND glData.ysnIsUnposted = 0
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @fourty)

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @fourtyWithGLIssues AS TABLE(strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS, intBillDetailId INT)
INSERT INTO @fourtyWithGLIssues
SELECT
	eighteen.strBillId,
	eighteen.intBillDetailId
	--nine.*,
	--newGLTax.*,
	--glTax.*
FROM @fourty eighteen
OUTER APPLY
(
	--NEW GL
	SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
	FROM (
	SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE strTransactionId = eighteen.strBillId AND
	B.intAccountCategoryId = 45 AND
	A.intJournalLineNo = eighteen.intBillDetailId AND
		ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
	--GROUP BY B.strAccountCategory--, A.strTransactionId
	) tmp
	--GROUP BY strAccountCategory
) newGLTax
OUTER APPLY 
(
	--RECEIPT GL
	SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	--INNER JOIN tblICInventoryTransaction C
	--	ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
	--	AND C.intTransactionDetailId = eighteen.intInventoryReceiptItemId
	WHERE A.strTransactionId = eighteen.strReceiptNumber AND
	A.intJournalLineNo = eighteen.intInventoryShipmentChargeId AND
	B.intAccountCategoryId = 45 AND
	--A.intJournalLineNo = 409558 AND
		A.ysnIsUnposted = 0
	--GROUP BY B.strAccountCategory
) rcptClearing
WHERE 
	(newGLTax.dblTotal <> rcptClearing.dblTotal 
		--AND (
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .01 OR
		--	ABS(newGLTax.dblTotal - rcptClearing.dblTotal) = .02
		--)
		)
	OR rcptClearing.dblTotal IS NULL

INSERT INTO @tmpAPC26
SELECT A.*
FROM @fourty A
INNER JOIN @fourtyWithGLIssues B ON A.strBillId = B.strBillId AND A.intBillDetailId = B.intBillDetailId

SELECT * FROM @tmpAPC26

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC26 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC26
END CATCH

--PRINT 'APC27 Results'

DECLARE @tmpAPC27 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	dblGLDiff DECIMAL(18,6),
	dblMultiTotal DECIMAL(18,6),
	intVoucherCount INT
)

DELETE FROM @billIds
DELETE FROM @GLEntries
DELETE FROM @icTaxData
DELETE FROM @voucherInfo23
SET @accountError = NULL;
SET @noAccount = NULL;

BEGIN TRY

BEGIN TRAN

SELECT @date = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0), GETDATE()) --USE FIRST DAY OF THE CURRENT FISCAL MONTH
	,@fiscalFrom = A.dtmDateFrom, @fiscalTo = A.dtmDateTo
FROM tblGLFiscalYear A
INNER JOIN tblGLFiscalYearPeriod B ON A.intFiscalYearId = B.intFiscalYearId
WHERE A.ysnCurrent = 1
AND GETDATE() BETWEEN B.dtmStartDate AND B.dtmEndDate

IF @date IS NULL
BEGIN
	--SET @date = GETDATE()
	RAISERROR('No fiscal year set for this month', 16, 1);
	RETURN;
END

DECLARE @apc27 TABLE
(
	dtmDate DATETIME,
	intBillId INT,
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillDetailId INT,
	intInventoryReceiptItemId INT,
	intAccountId INT,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblReceiptClearing DECIMAL(18,6),
	dblVoucherClearing DECIMAL(18,6),
	dblDiff DECIMAL(18,6),
	dblGLDiff DECIMAL(18,6),
	dblMultiTotal DECIMAL(18,6),
	intVoucherCount INT
)
--voucher with different net weight from receipt

INSERT INTO @apc27
--GET THOSE VOUCHERS WHICH HAS .01 DIFFERENCE IN TOTAL FOR RECEIPT
SELECT * 
FROM (
SELECT
C.dtmDate,
C.intBillId,
C.strBillId,
D2.strReceiptNumber,
A.intBillDetailId,
D.intInventoryReceiptItemId,
[dbo].[fnGetItemGLAccount](A.intItemId, itemLoc.intItemLocationId, 'Inventory Adjustment') intAccountId,
item.strItemNo,
glReceiptItem.dblReceiptClearing,
glVoucherItem.dblVoucherClearing,
--ABS(
CASE WHEN WC.intWeightClaimDetailId IS NOT NULL--C.intTransactionType = 11
THEN 
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN
		CAST((A.dblQtyReceived) *  (ISNULL(A.dblOldCost, A.dblCost) / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	ELSE 
		CAST((A.dblQtyReceived) *  (ISNULL(A.dblOldCost, A.dblCost))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
	END),0)
ELSE
	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
	THEN (CASE 
			WHEN A.intWeightUOMId > 0 
				THEN CAST(ISNULL(A.dblOldCost, A.dblCost) / ISNULL(C.intSubCurrencyCents,1)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (ISNULL(A.dblOldCost, A.dblCost) / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (ISNULL(A.dblOldCost, A.dblCost) / ISNULL(C.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
		END)
	ELSE (CASE 
			WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
				THEN CAST(ISNULL(A.dblOldCost, A.dblCost)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
			WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
				THEN CAST((A.dblQtyReceived) *  (ISNULL(A.dblOldCost, A.dblCost))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
			ELSE CAST((A.dblQtyReceived) * (ISNULL(A.dblOldCost, A.dblCost))  AS DECIMAL(18,2))  --Orig Calculation
		END)
	END),0)
END - 
	A.dblTotal AS dblDiff,
	glReceiptItem.dblReceiptClearing - glVoucherItem.dblVoucherClearing AS dblGLDiff,
	D.dblLineTotal - multiple.dblTotal AS dblMultiTotal,
	ROW_NUMBER() OVER(PARTITION BY A.intInventoryReceiptItemId ORDER BY A.intBillDetailId DESC) AS intVoucherCount
FROM tblAPBillDetail A
	INNER JOIN tblAPBill C ON A.intBillId = C.intBillId
	INNER JOIN (tblICInventoryReceiptItem D INNER JOIN tblICInventoryReceipt D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
		ON D.intInventoryReceiptItemId = A.intInventoryReceiptItemId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
	CROSS APPLY (
		SELECT SUM(B.dblCredit - B.dblDebit) AS dblReceiptClearing
			--B.*
		FROM tblGLDetail B
		INNER JOIN tblICInventoryTransaction B2 
			ON B.strTransactionId = B2.strTransactionId AND B.intJournalLineNo = B2.intInventoryTransactionId
		INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
		WHERE D2.strReceiptNumber = B.strTransactionId
		AND B3.intAccountCategoryId = 45
		AND D.intInventoryReceiptItemId = B2.intTransactionDetailId
	) glReceiptItem
	CROSS APPLY (
		SELECT SUM(dblVoucherClearing) AS dblVoucherClearing
		FROM (
			SELECT SUM(B.dblDebit - B.dblCredit) AS dblVoucherClearing
				--B.*
			FROM tblGLDetail B
			INNER JOIN vyuGLAccountDetail B3 ON B3.intAccountId = B.intAccountId
			WHERE C.strBillId = B.strTransactionId
			AND B3.intAccountCategoryId = 45
			AND A.intBillDetailId = B.intJournalLineNo
			--AND B.strCode <> 'ICA' --exclude ICA to calculate correctly the actual difference between receipt total and voucher total
			AND (B.dblDebitUnit <> 0 OR B.dblCreditUnit <> 0) --exclude other gl entry for the item to correctly calculate the actual difference
			UNION ALL --ICA
			SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
			FROM tblGLDetail B4
			INNER JOIN vyuGLAccountDetail B5 ON B5.intAccountId = B4.intAccountId
			INNER JOIN tblICInventoryTransaction invTran
				ON invTran.strTransactionId = B4.strTransactionId AND invTran.intInventoryTransactionId = B4.intJournalLineNo
			WHERE C.strBillId = B4.strTransactionId AND
			B5.intAccountCategoryId = 45 AND 
			B4.ysnIsUnposted = 0 AND
			B4.strCode = 'ICA'
		) voucher
	) glVoucherItem
	CROSS APPLY (
		SELECT SUM(ISNULL((CASE WHEN A2.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
			THEN (CASE 
					WHEN A2.intWeightUOMId > 0 
						THEN CAST(ISNULL(A2.dblOldCost, A2.dblCost) / ISNULL(C2.intSubCurrencyCents,1)  * A2.dblNetWeight * A2.dblWeightUnitQty / ISNULL(A2.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
					WHEN (A2.intUnitOfMeasureId > 0 AND A2.intCostUOMId > 0)
						THEN CAST((A2.dblQtyReceived) *  (ISNULL(A2.dblOldCost, A2.dblCost) / ISNULL(C2.intSubCurrencyCents,1))  * (A2.dblUnitQty/ ISNULL(A2.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
					ELSE CAST((A2.dblQtyReceived) * (ISNULL(A2.dblOldCost, A2.dblCost) / ISNULL(C2.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
				END)
			ELSE (CASE 
					WHEN A2.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
						THEN CAST(ISNULL(A2.dblOldCost, A2.dblCost)  * A2.dblNetWeight * A2.dblWeightUnitQty / ISNULL(A2.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
					WHEN (A2.intUnitOfMeasureId > 0 AND A2.intCostUOMId > 0)
						THEN CAST((A2.dblQtyReceived) *  (ISNULL(A2.dblOldCost, A2.dblCost))  * (A2.dblUnitQty/ ISNULL(A2.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
					ELSE CAST((A2.dblQtyReceived) * (ISNULL(A2.dblOldCost, A2.dblCost))  AS DECIMAL(18,2))  --Orig Calculation
				END)
			END),0)) AS dblTotal
		FROM tblAPBillDetail A2
		INNER JOIN tblAPBill C2 ON A2.intBillId = C2.intBillId
		WHERE A2.intInventoryReceiptItemId = A.intInventoryReceiptItemId
		AND C2.ysnPosted = 1 AND A2.intInventoryReceiptChargeId IS NULL
	) multiple
	LEFT JOIN tblLGWeightClaimDetail WC ON WC.intBillId = C.intBillId
	LEFT JOIN tblICItemLocation itemLoc ON A.intItemId = itemLoc.intItemId AND itemLoc.intLocationId = D2.intLocationId
WHERE 
	--D.dblNet <> 0 AND A.dblNetWeight = 0
	--D2.strReceiptNumber = 'IR-15581' AND
	A.intInventoryReceiptChargeId IS NULL
	AND A.dblOldCost IS NOT NULL
	AND (
		ABS(D.dblLineTotal - A.dblTotal) = .01 OR
		 ABS(D.dblLineTotal - A.dblTotal) = .02 OR
		 ABS(D.dblLineTotal - multiple.dblTotal) = .01 OR
		 ABS(glReceiptItem.dblReceiptClearing - glVoucherItem.dblVoucherClearing) = .01
		 )
) tmp
WHERE ABS(dblDiff) = .01
OR ABS(dblDiff) = .02
OR ABS(dblGLDiff) = .01
OR ABS(dblMultiTotal) = .01

--SELECT * FROM @eighteen

SELECT TOP 1 @noAccount = 'There are no Inventory Adjustment account setup for the item ' + A.strItemNo + ' on ' + A.strBillId
FROM @apc27 A
WHERE A.intAccountId IS NULL

IF ISNULL(@noAccount,'') <> ''
BEGIN 
	--SET @accountError = 'There are no COGS account setup for the item on ' + @noAccount
	RAISERROR(@noAccount, 16, 1);
	RETURN;
END

INSERT INTO @GLEntries (
	dtmDate ,
	strBatchId ,
	intAccountId ,
	dblDebit ,
	dblCredit ,
	dblDebitUnit ,
	dblCreditUnit ,
	strDescription ,
	strCode ,
	strReference ,
	intCurrencyId ,
	intCurrencyExchangeRateTypeId,
	dblExchangeRate ,
	dtmDateEntered ,
	dtmTransactionDate ,
	strJournalLineDescription ,
	intJournalLineNo ,
	ysnIsUnposted ,
	intUserId ,
	intEntityId ,
	strTransactionId ,
	intTransactionId ,
	strTransactionType ,
	strTransactionForm ,
	strModuleName ,
	dblDebitForeign ,
	dblDebitReport ,
	dblCreditForeign ,
	dblCreditReport ,
	dblReportingRate ,
	dblForeignRate ,
	strDocument,
	strComments,
	dblSourceUnitCredit,
	dblSourceUnitDebit,
	intCommodityId,
	intSourceLocationId,
	strSourceDocumentId
)
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	gl.[intAccountId]					
	,[dblDebit]						=	CASE WHEN A.dblDiff	IN (.01, .02) THEN A.dblDiff
											WHEN A.dblGLDiff	IN (.01, .02) THEN A.dblGLDiff
											WHEN A.dblMultiTotal IN (.01, .02) THEN A.dblMultiTotal
										END
	,[dblCredit]					=	0					
	,[dblDebitUnit]					=	0				
	,[dblCreditUnit]				=	0					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	CASE WHEN A.dblDiff	IN (.01, .02) THEN A.dblDiff
											WHEN A.dblGLDiff	IN (.01, .02) THEN A.dblGLDiff
											WHEN A.dblMultiTotal IN (.01, .02) THEN A.dblMultiTotal
										END				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	0				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]									
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@apc27 A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @eighteen)
AND A.intVoucherCount = 1
UNION ALL
SELECT	
	[dtmDate]						=	CASE WHEN dbo.fnIsOpenAccountingDate(gl.dtmDate) = 1 --THIS SHOULD BE THE CURRENT FISCAL DATE
											THEN gl.dtmDate ELSE @date END						
	,[strBatchID]					=	gl.[strBatchId]					
	,[intAccountId]					=	A.intAccountId					
	,[dblDebit]						=	0						
	,[dblCredit]					=	CASE WHEN A.dblDiff	IN (.01, .02) THEN A.dblDiff
											WHEN A.dblGLDiff	IN (.01, .02) THEN A.dblGLDiff
											WHEN A.dblMultiTotal IN (.01, .02) THEN A.dblMultiTotal
										END						
	,[dblDebitUnit]					=	0					
	,[dblCreditUnit]				=	CASE WHEN A.dblDiff	IN (.01, .02) THEN A.dblDiff
											WHEN A.dblGLDiff	IN (.01, .02) THEN A.dblGLDiff
											WHEN A.dblMultiTotal IN (.01, .02) THEN A.dblMultiTotal
										END					
	,[strDescription]				=	gl.[strDescription]				
	,[strCode]						=	gl.[strCode]						
	,[strReference]					=	gl.[strReference]					
	,[intCurrencyId]				=	gl.[intCurrencyId]					
	,[intCurrencyExchangeRateTypeId] =	gl.[intCurrencyExchangeRateTypeId] 
	,[dblExchangeRate]				=	gl.[dblExchangeRate]				
	,[dtmDateEntered]				=	GETDATE()			
	,[dtmTransactionDate]			=	gl.[dtmTransactionDate]			
	,[strJournalLineDescription]	=	gl.[strJournalLineDescription]		
	,[intJournalLineNo]				=	gl.[intJournalLineNo]				
	,[ysnIsUnposted]				=	gl.[ysnIsUnposted]					
	,[intUserId]					=	@intUserId						
	,[intEntityId]					=	gl.[intEntityId]					
	,[strTransactionId]				=	gl.[strTransactionId]				
	,[intTransactionId]				=	gl.[intTransactionId]				
	,[strTransactionType]			=	gl.[strTransactionType]			
	,[strTransactionForm]			=	gl.[strTransactionForm]			
	,[strModuleName]				=	gl.[strModuleName]					
	,[dblDebitForeign]				=	0				
	,[dblDebitReport]				=	gl.[dblDebitReport]				
	,[dblCreditForeign]				=	CASE WHEN A.dblDiff	IN (.01, .02) THEN A.dblDiff
											WHEN A.dblGLDiff	IN (.01, .02) THEN A.dblGLDiff
											WHEN A.dblMultiTotal IN (.01, .02) THEN A.dblMultiTotal
										END				
	,[dblCreditReport]				=	gl.[dblCreditReport]				
	,[dblReportingRate]				=	gl.[dblReportingRate]				
	,[dblForeignRate]				=	gl.[dblForeignRate]								
	,[strDocument]					=	gl.[strDocument]					
	,[strComments]					=	gl.[strComments]								
	,[dblSourceUnitCredit]			=	gl.[dblSourceUnitCredit]			
	,[dblSourceUnitDebit]			=	gl.[dblSourceUnitDebit]			
	,[intCommodityId]				=	gl.[intCommodityId]				
	,[intSourceLocationId]			=	gl.[intSourceLocationId]			
	,[strSourceDocumentId]			=	gl.[strSourceDocumentId]			
FROM	@apc27 A
		OUTER APPLY (
			SELECT TOP 1 glData.*
			FROM tblGLDetail glData
			INNER JOIN vyuGLAccountDetail B ON glData.intAccountId = B.intAccountId
			WHERE glData.strTransactionId = A.strBillId AND A.intBillDetailId = glData.intJournalLineNo
			AND B.intAccountCategoryId = 45
		) gl
WHERE	A.intBillId IN (SELECT intBillId FROM @eighteen)
AND A.intVoucherCount = 1

UPDATE A
SET A.strDescription = B.strDescription
FROM @GLEntries A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId

--GET ALL Voucher THAT HAVE ISSUES IN TAX ENTRIES
--COMPARE NEW TAX ENTRIES TO OLD TAX ENTRIES
DECLARE @apc27WithGLIssues AS TABLE(intInventoryReceiptItemId INT)
INSERT INTO @apc27WithGLIssues
SELECT
	intInventoryReceiptItemId
FROM (
	SELECT
		--eighteen.strBillId,
		--eighteen.intBillDetailId,
		eighteen.intInventoryReceiptItemId,
		--nine.*,
		SUM(newGLTax.dblTotal) AS dblVoucherTotal,
		rcptClearing.dblTotal AS dblReceiptTotal
	FROM @apc27 eighteen
	OUTER APPLY
	(
		--NEW GL
		SELECT SUM(dblTotal) AS dblTotal--, strAccountCategory
		FROM (
		--SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
		--FROM @GLEntries A
		--INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
		--WHERE strTransactionId = eighteen.strBillId AND
		--A.intJournalLineNo = eighteen.intBillDetailId AND
		--B.intAccountCategoryId = 45 AND
		--	ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
		----GROUP BY B.strAccountCategory--, A.strTransactionId
		--UNION ALL
		--OLD GL
		SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
		WHERE strTransactionId = eighteen.strBillId AND
		B.intAccountCategoryId = 45 AND
		A.intJournalLineNo = eighteen.intBillDetailId AND
			ysnIsUnposted = 0 --AND strJournalLineDescription = 'Purchase Tax'
		UNION ALL --ICA
		SELECT SUM(dblDebit - dblCredit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
		INNER JOIN tblICInventoryTransaction invTran
			ON invTran.strTransactionId = A.strTransactionId AND invTran.intInventoryTransactionId = A.intJournalLineNo
		WHERE A.strTransactionId = eighteen.strBillId AND
		B.intAccountCategoryId = 45 AND 
		A.ysnIsUnposted = 0 AND
		A.strCode = 'ICA'
		--GROUP BY B.strAccountCategory--, A.strTransactionId
		) tmp
		--GROUP BY strAccountCategory
	) newGLTax
	OUTER APPLY 
	(
		--RECEIPT GL
		SELECT SUM(dblCredit - dblDebit) AS dblTotal--, B.strAccountCategory --,A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
		INNER JOIN tblICInventoryTransaction C
			ON C.strTransactionId = A.strTransactionId AND C.intInventoryTransactionId = A.intJournalLineNo
			AND C.intTransactionDetailId = eighteen.intInventoryReceiptItemId
		WHERE A.strTransactionId = eighteen.strReceiptNumber AND
		B.intAccountCategoryId = 45 AND
		--A.intJournalLineNo = 409558 AND
			A.ysnIsUnposted = 0
		--GROUP BY B.strAccountCategory
	) rcptClearing
	GROUP BY eighteen.intInventoryReceiptItemId, rcptClearing.dblTotal
) tmp
WHERE 
	ABS(dblVoucherTotal - dblReceiptTotal) IN (.01, .02)

INSERT INTO @tmpAPC27
SELECT DISTINCT B.*
FROM tblGLDetail A
INNER JOIN @apc27 B ON A.strTransactionId = B.strBillId AND B.intBillDetailId = A.intJournalLineNo
INNER JOIN @apc27WithGLIssues eleven ON B.intInventoryReceiptItemId = eleven.intInventoryReceiptItemId
WHERE A.ysnIsUnposted = 0
AND B.intVoucherCount = 1

SELECT * FROM @tmpAPC27

ROLLBACK TRAN

END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @error_APC27 NVARCHAR(200) = ERROR_MESSAGE()
	PRINT @error_APC27
END CATCH

--PRINT 'APC28 Results'

DECLARE @tmpAPC28 TABLE
(
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillId INT,
	intBillDetailId INT,
	intBillDetailAccountId INT,
	intAccountId INT,
	strAccountId NVARCHAR(50),
	strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptId INT,
	intInventoryReceiptChargeId INT,
	intReceiptChargeAccountId INT,
	strReceiptChargeAccountId NVARCHAR(50)
)

--RECEIPT CHARGE ITEM
INSERT INTO @tmpAPC28
SELECT 
	A.strBillId,
	A.intBillId,
	B.intBillDetailId,
	B.intAccountId AS intBillDetailAccountId,
	D.intAccountId,
	D2.strAccountId,
	C.strReceiptNumber,
	C.intInventoryReceiptId,
	C2.intInventoryReceiptChargeId,
	E.intAccountId AS intReceiptChargeAccount,
	E2.strAccountId AS strReceiptChargeAccount
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryReceipt C INNER JOIN tblICInventoryReceiptCharge C2 ON C.intInventoryReceiptId = C2.intInventoryReceiptId)
	ON B.intInventoryReceiptChargeId = C2.intInventoryReceiptChargeId 
INNER JOIN (tblGLDetail D INNER JOIN vyuGLAccountDetail D2 ON D.intAccountId = D2.intAccountId)
	ON D.intJournalLineNo = B.intBillDetailId AND D.strTransactionId = A.strBillId
INNER JOIN (tblGLDetail E INNER JOIN vyuGLAccountDetail E2 ON E.intAccountId = E2.intAccountId)
	ON E.intJournalLineNo = C2.intInventoryReceiptChargeId AND E.strTransactionId = C.strReceiptNumber
WHERE 
	D.ysnIsUnposted = 0
AND D2.intAccountCategoryId = 45
AND E2.intAccountCategoryId = 45
AND B.intInventoryReceiptChargeId IS NOT NULL
AND	(
		B.intAccountId <> D.intAccountId --ACCOUNT IN BILL DETAIL NOT THE SAME WITH ITS GL
	OR	B.intAccountId <> E.intAccountId --ACCOUNT IN BILL DETAIL NOT THE SAME WITH GL OF RECEIPT ITEM
	OR	D.intAccountId <> E.intAccountId --BILL DETAIL GL ACCOUNT NOT THE SAME WITH GL OF RECEIPT ITEM
	)

SELECT * FROM @tmpAPC28

--PRINT 'APC29 Results'

DECLARE @tmpAPC29 TABLE
(
	strBillId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillId INT,
	intBillDetailId INT,
	intBillDetailAccountId INT,
	intAccountId INT,
	strAccountId NVARCHAR(50),
	intGLDetailId INT,
	strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryShipmentId INT,
	intInventoryShipmentChargeId INT,
	intShipmentChargeAccountId INT,
	strShipmentChargeAccountId NVARCHAR(50),
	strError NVARCHAR(200)
)

--SHIPMENT CHARGE ITEM
INSERT INTO @tmpAPC29
SELECT 
	A.strBillId,
	A.intBillId,
	B.intBillDetailId,
	B.intAccountId AS intBillDetailAccountId,
	D.intAccountId,
	D2.strAccountId,
	D.intGLDetailId,
	C.strShipmentNumber,
	C.intInventoryShipmentId,
	C3.intInventoryShipmentChargeId,
	E.intAccountId AS intShipmentChargeAccount,
	E2.strAccountId AS strShipmentChargeAccount,
	CASE WHEN B.intAccountId <> D.intAccountId THEN 'Bill detail account not equal to GL'
		WHEN B.intAccountId <> E.intAccountId THEN 'Bill detail account not equal to shipment charge account'
		ELSE ''
	END AS strError
FROM tblAPBill A
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN (tblICInventoryShipment C INNER JOIN tblICInventoryShipmentItem C2 ON C.intInventoryShipmentId = C2.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentCharge C3 ON C.intInventoryShipmentId = C3.intInventoryShipmentId)
	ON B.intInventoryShipmentChargeId = C3.intInventoryShipmentChargeId 
INNER JOIN (tblGLDetail D INNER JOIN vyuGLAccountDetail D2 ON D.intAccountId = D2.intAccountId)
	ON D.intJournalLineNo = B.intBillDetailId AND D.strTransactionId = A.strBillId
INNER JOIN (tblGLDetail E INNER JOIN vyuGLAccountDetail E2 ON E.intAccountId = E2.intAccountId)
	ON E.intJournalLineNo = C2.intInventoryShipmentItemId AND E.strTransactionId = C.strShipmentNumber
WHERE 
	D.ysnIsUnposted = 0
AND E.ysnIsUnposted = 0
AND D2.intAccountCategoryId = 45
AND E2.intAccountCategoryId = 45
AND B.intInventoryShipmentChargeId IS NOT NULL
--AND A.strBillId = 'BL-10054'
AND	(
		B.intAccountId <> D.intAccountId --ACCOUNT IN BILL DETAIL NOT THE SAME WITH ITS GL
	OR	B.intAccountId <> E.intAccountId --ACCOUNT IN BILL DETAIL NOT THE SAME WITH GL OF RECEIPT ITEM
	OR	D.intAccountId <> E.intAccountId --BILL DETAIL GL ACCOUNT NOT THE SAME WITH GL OF RECEIPT ITEM
	)

SELECT * FROM @tmpAPC29

--END QUERY RESULT

IF OBJECT_ID('tempdb..##tmpAPC1') IS NOT NULL DROP TABLE ##tmpAPC1
IF OBJECT_ID('tempdb..##tmpAPC2') IS NOT NULL DROP TABLE ##tmpAPC2
IF OBJECT_ID('tempdb..##tmpAPC3') IS NOT NULL DROP TABLE ##tmpAPC3
IF OBJECT_ID('tempdb..##tmpAPC4') IS NOT NULL DROP TABLE ##tmpAPC4
IF OBJECT_ID('tempdb..##tmpAPC5') IS NOT NULL DROP TABLE ##tmpAPC5
IF OBJECT_ID('tempdb..##tmpAPC6') IS NOT NULL DROP TABLE ##tmpAPC6
IF OBJECT_ID('tempdb..##tmpAPC7') IS NOT NULL DROP TABLE ##tmpAPC7
IF OBJECT_ID('tempdb..##tmpAPC8') IS NOT NULL DROP TABLE ##tmpAPC8
IF OBJECT_ID('tempdb..##tmpAPC9') IS NOT NULL DROP TABLE ##tmpAPC9
IF OBJECT_ID('tempdb..##tmpAPC10') IS NOT NULL DROP TABLE ##tmpAPC10
IF OBJECT_ID('tempdb..##tmpAPC11') IS NOT NULL DROP TABLE ##tmpAPC11
IF OBJECT_ID('tempdb..##tmpAPC12') IS NOT NULL DROP TABLE ##tmpAPC12
IF OBJECT_ID('tempdb..##tmpAPC13') IS NOT NULL DROP TABLE ##tmpAPC13
IF OBJECT_ID('tempdb..##tmpAPC14') IS NOT NULL DROP TABLE ##tmpAPC14
IF OBJECT_ID('tempdb..##tmpAPC15') IS NOT NULL DROP TABLE ##tmpAPC15
IF OBJECT_ID('tempdb..##tmpAPC17') IS NOT NULL DROP TABLE ##tmpAPC17
IF OBJECT_ID('tempdb..##tmpAPC18') IS NOT NULL DROP TABLE ##tmpAPC18
IF OBJECT_ID('tempdb..##tmpAPC19') IS NOT NULL DROP TABLE ##tmpAPC19
IF OBJECT_ID('tempdb..##tmpAPC20') IS NOT NULL DROP TABLE ##tmpAPC20
IF OBJECT_ID('tempdb..##tmpAPC21') IS NOT NULL DROP TABLE ##tmpAPC21
IF OBJECT_ID('tempdb..##tmpAPC22') IS NOT NULL DROP TABLE ##tmpAPC22
IF OBJECT_ID('tempdb..##tmpAPC23') IS NOT NULL DROP TABLE ##tmpAPC23
IF OBJECT_ID('tempdb..##tmpAPC24') IS NOT NULL DROP TABLE ##tmpAPC24
IF OBJECT_ID('tempdb..##tmpAPC25') IS NOT NULL DROP TABLE ##tmpAPC25
IF OBJECT_ID('tempdb..##tmpAPC26') IS NOT NULL DROP TABLE ##tmpAPC26
IF OBJECT_ID('tempdb..##tmpAPC27') IS NOT NULL DROP TABLE ##tmpAPC27
IF OBJECT_ID('tempdb..##tmpAPC28') IS NOT NULL DROP TABLE ##tmpAPC28
IF OBJECT_ID('tempdb..##tmpAPC29') IS NOT NULL DROP TABLE ##tmpAPC29

IF EXISTS(SELECT 1 FROM @tmpAPC1) 
BEGIN 
	SELECT * INTO ##tmpAPC1 FROM @tmpAPC1
END

IF EXISTS(SELECT 1 FROM @tmpAPC2) 
BEGIN
	SELECT * INTO ##tmpAPC2 FROM @tmpAPC2
END

IF EXISTS(SELECT 1 FROM @tmpAPC3) 
BEGIN
	SELECT * INTO ##tmpAPC3 FROM @tmpAPC3
END

IF EXISTS(SELECT 1 FROM @tmpAPC4) 
BEGIN
	SELECT * INTO ##tmpAPC4 FROM @tmpAPC4
END

IF EXISTS(SELECT 1 FROM @tmpAPC5) 
BEGIN
	SELECT * INTO ##tmpAPC5 FROM @tmpAPC5
END

IF EXISTS(SELECT 1 FROM @tmpAPC6) 
BEGIN
	SELECT * INTO ##tmpAPC6 FROM @tmpAPC6
END

IF EXISTS(SELECT 1 FROM @tmpAPC7) 
BEGIN
	SELECT * INTO ##tmpAPC7 FROM @tmpAPC7
END

IF EXISTS(SELECT 1 FROM @tmpAPC8) 
BEGIN
	SELECT * INTO ##tmpAPC8 FROM @tmpAPC8
END

IF EXISTS(SELECT 1 FROM @tmpAPC9) 
BEGIN
	SELECT * INTO ##tmpAPC9 FROM @tmpAPC9
END

IF EXISTS(SELECT 1 FROM @tmpAPC10) 
BEGIN
	SELECT * INTO ##tmpAPC10 FROM @tmpAPC10
END

IF EXISTS(SELECT 1 FROM @tmpAPC11) 
BEGIN
	SELECT * INTO ##tmpAPC11 FROM @tmpAPC11
END

IF EXISTS(SELECT 1 FROM @tmpAPC12) 
BEGIN
	SELECT * INTO ##tmpAPC12 FROM @tmpAPC12
END

IF EXISTS(SELECT 1 FROM @tmpAPC13) 
BEGIN
	SELECT * INTO ##tmpAPC13 FROM @tmpAPC13
END

IF EXISTS(SELECT 1 FROM @tmpAPC14) 
BEGIN
	SELECT * INTO ##tmpAPC14 FROM @tmpAPC14
END

IF EXISTS(SELECT 1 FROM @tmpAPC15) 
BEGIN
	SELECT * INTO ##tmpAPC15 FROM @tmpAPC15
END

IF EXISTS(SELECT 1 FROM @tmpAPC17) 
BEGIN
	SELECT * INTO ##tmpAPC17 FROM @tmpAPC17
END

IF EXISTS(SELECT 1 FROM @tmpAPC18) 
BEGIN
	SELECT * INTO ##tmpAPC18 FROM @tmpAPC18
END

IF EXISTS(SELECT 1 FROM @tmpAPC19) 
BEGIN
	SELECT * INTO ##tmpAPC19 FROM @tmpAPC19
END

IF EXISTS(SELECT 1 FROM @tmpAPC20) 
BEGIN
	SELECT * INTO ##tmpAPC20 FROM @tmpAPC20
END

IF EXISTS(SELECT 1 FROM @tmpAPC21) 
BEGIN
	SELECT * INTO ##tmpAPC21 FROM @tmpAPC21
END

IF EXISTS(SELECT 1 FROM @tmpAPC22) 
BEGIN
	SELECT * INTO ##tmpAPC22 FROM @tmpAPC22
END

IF EXISTS(SELECT 1 FROM @tmpAPC23) 
BEGIN
	SELECT * INTO ##tmpAPC23 FROM @tmpAPC23
END

IF EXISTS(SELECT 1 FROM @tmpAPC24) 
BEGIN
	SELECT * INTO ##tmpAPC24 FROM @tmpAPC24
END

IF EXISTS(SELECT 1 FROM @tmpAPC25) 
BEGIN
	SELECT * INTO ##tmpAPC25 FROM @tmpAPC25
END

IF EXISTS(SELECT 1 FROM @tmpAPC26) 
BEGIN
	SELECT * INTO ##tmpAPC26 FROM @tmpAPC26
END

IF EXISTS(SELECT 1 FROM @tmpAPC27) 
BEGIN
	SELECT * INTO ##tmpAPC27 FROM @tmpAPC27
END

IF EXISTS(SELECT 1 FROM @tmpAPC28) 
BEGIN
	SELECT * INTO ##tmpAPC28 FROM @tmpAPC28
END

IF EXISTS(SELECT 1 FROM @tmpAPC29) 
BEGIN
	SELECT * INTO ##tmpAPC29 FROM @tmpAPC29
END