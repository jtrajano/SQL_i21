CREATE PROCEDURE [dbo].[uspAPDiagnoseClearingData]
	@account INT = NULL,
	@dateStart DATETIME = NULL,
	@dateEnd DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @start DATETIME = CASE WHEN @dateStart IS NOT NULL THEN @dateStart ELSE '1/1/1900' END
DECLARE @end DATETIME = CASE WHEN @dateEnd IS NOT NULL THEN @dateEnd ELSE GETDATE() END

--RECEIPT CLEARING VS RECEIPT GL CLEARING
DECLARE @receiptTotal TABLE(dtmReceiptDate DATETIME, dblTotal DECIMAL(18,2), strReceiptNumber NVARCHAR(50));
;WITH receiptTotal (
     dtmReceiptDate,
	 dblTotal,
	 strReceiptNumber
)
AS (
	SELECT
		dtmReceiptDate
		,SUM(dblTotal) AS dblTotal
		,strReceiptNumber
	FROM 
	(
	SELECT
	   A.dtmReceiptDate,
	   SUM(B.dblLineTotal + B.dblTax) * (CASE WHEN A.strReceiptType = 'Inventory Return' THEN -1 ELSE 1 END) AS dblTotal,
	   A.strReceiptNumber
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
	ON A.intInventoryReceiptId = B.intInventoryReceiptId
	--WHERE DATEADD(dd, DATEDIFF(dd, 0,A.dtmReceiptDate), 0) BETWEEN @start AND @end
	GROUP BY A.dtmReceiptDate, A.strReceiptNumber, A.strReceiptType
	UNION ALL
	SELECT
		Receipt.dtmReceiptDate
		,CAST(
		SUM(
		(CASE 
			WHEN ReceiptCharge.ysnSubCurrency = 1 AND ReceiptCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
				ABS(ISNULL(ReceiptCharge.dblRate, 0)) * 100
			WHEN ReceiptCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
				ABS(ISNULL(ReceiptCharge.dblRate, 0))
			WHEN ReceiptCharge.ysnSubCurrency = 1 THEN 
				ABS(ISNULL(ReceiptCharge.dblAmount, 0)) * 100
			ELSE 
				ABS(ISNULL(ReceiptCharge.dblAmount, 0))
		END
		*
		(
			CASE 
				WHEN ISNULL(ReceiptCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
					THEN -(ISNULL(ReceiptCharge.dblQuantity, 1)) 
				ELSE ISNULL(ReceiptCharge.dblQuantity, 1)
			END 
		
		))
		+
		ISNULL(ReceiptCharge.dblTax,0)) AS DECIMAL(18,2))
		,Receipt.strReceiptNumber
	FROM 
		tblICInventoryReceiptCharge ReceiptCharge  INNER JOIN tblICItem Item 
			ON ReceiptCharge.intChargeId = Item.intItemId
		INNER JOIN tblICInventoryReceipt Receipt 
			ON ReceiptCharge.intInventoryReceiptId = Receipt.intInventoryReceiptId
	WHERE	ReceiptCharge.ysnAccrue = 1 
	GROUP BY Receipt.dtmReceiptDate, ReceiptCharge.dblRate, ReceiptCharge.strCostMethod, ReceiptCharge.ysnSubCurrency, Receipt.strReceiptNumber
	-- Query for 'Price' Other Charges. 
	UNION ALL 
	SELECT
		Receipt.dtmReceiptDate
		,CAST(
		SUM(
		(CASE 
			WHEN ReceiptCharge.ysnSubCurrency = 1 AND ReceiptCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
				ABS(ISNULL(ReceiptCharge.dblRate, 0)) * 100
			WHEN ReceiptCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
				ABS(ISNULL(ReceiptCharge.dblRate, 0))
			WHEN ReceiptCharge.ysnSubCurrency = 1 THEN 
				ABS(ISNULL(ReceiptCharge.dblAmount, 0)) * 100
			ELSE 
				ABS(ISNULL(ReceiptCharge.dblAmount, 0))
		END
		*
		(
			CASE 
				WHEN ReceiptCharge.dblAmount > 0 
					--Negate Quantity if amount is positive for Price Down charges; Amount is negated in Voucher for Price Down so no need to negate quantity for negative amount
					THEN -(ISNULL(ReceiptCharge.dblQuantity, 1))
				ELSE 
					ISNULL(ReceiptCharge.dblQuantity, 1)
			END 
		))
		+ ISNULL(ReceiptCharge.dblTax,0))
		AS DECIMAL(18,2))
		,Receipt.strReceiptNumber
	FROM tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICItem Item 
			ON ReceiptCharge.intChargeId = Item.intItemId
		INNER JOIN tblICInventoryReceipt Receipt
			ON ReceiptCharge.intInventoryReceiptId = Receipt.intInventoryReceiptId
	WHERE	ReceiptCharge.ysnPrice = 1
	GROUP BY Receipt.dtmReceiptDate, ReceiptCharge.dblRate, ReceiptCharge.strCostMethod, ReceiptCharge.ysnSubCurrency, Receipt.strReceiptNumber
	) tmp
	GROUP BY strReceiptNumber, dtmReceiptDate
)

INSERT INTO @receiptTotal
SELECT * FROM receiptTotal

--RECEIPT GL TOTAL
DECLARE @receiptGLTotal TABLE(dtmReceiptDate DATETIME, dblTotal DECIMAL(18,2), strReceiptNumber NVARCHAR(50));
;WITH receiptGLTotal (
	dtmDate,
	dblTotal,
	strReceiptNumber
)
AS (
	SELECT
		A.dtmDate,
		SUM(dblCredit - dblDebit),
		A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B
	ON A.intAccountId = B.intAccountId
	WHERE B.intAccountCategoryId = 45
	AND A.ysnIsUnposted = 0
	AND A.strModuleName = 'Inventory'
	--AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
	--AND A.strDescription NOT LIKE '%Charges from%'
	GROUP BY A.strTransactionId, A.dtmDate
)

INSERT INTO @receiptGLTotal
SELECT * FROM receiptGLTotal

--VOUCHER TOTAL
DECLARE @voucherTotal TABLE(dtmReceiptDate DATETIME, dblTotal DECIMAL(18,2), strReceiptNumber NVARCHAR(50));
;WITH voucherTotal (
	dtmReceiptDate,
	 dblTotal,
	 strReceiptNumber
)
AS (
	SELECT
		dtmReceiptDate
		,SUM(dblTotal) AS dblTotal
		,strReceiptNumber
	FROM 
	(
		SELECT
			A.dtmDate AS dtmReceiptDate
			,B.dblTotal + B.dblTax AS dblTotal
			,C.strReceiptNumber
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN (tblICInventoryReceipt C 
						INNER JOIN tblICInventoryReceiptItem C2 ON C.intInventoryReceiptId = C2.intInventoryReceiptId)
			ON (B.intInventoryReceiptItemId = C2.intInventoryReceiptItemId)
		LEFT JOIN tblSMFreightTerms ft
			ON ft.intFreightTermId = C.intFreightTermId
		WHERE 
			C2.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
		--DO NOT INCLUDE RECEIPT WHICH USES IN-TRANSIT AS GL
		--CLEARING FOR THIS IS ALREADY PART OF vyuAPLoadClearing
		AND 1 = (CASE WHEN C.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
		AND C.strReceiptType != 'Transfer Order'
		AND C2.intOwnershipType != 2
		AND C.ysnPosted = 1
	) tmp
	GROUP BY strReceiptNumber, dtmReceiptDate
)

INSERT INTO @voucherTotal
SELECT * FROM voucherTotal

--VOUCHER RECEIPT GL
DECLARE @voucherGLTotal TABLE(strReceiptNumber NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH voucherGLTotal (
	strReceiptNumber,
	dblTotal
)
AS (
	SELECT
		strReceiptNumber,
		SUM(dblTotal) AS dblTotal
	FROM (
		SELECT
			E2.strReceiptNumber,
			D.strAccountId,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM tblGLDetail A
		INNER JOIN tblAPBill B ON A.strTransactionId = B.strBillId
		INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intBillDetailId = A.intJournalLineNo
		INNER JOIN vyuGLAccountDetail D ON C.intAccountId = D.intAccountId
		INNER JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2 ON E.intInventoryReceiptId = E2.intInventoryReceiptId)
			ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		WHERE 
			A.ysnIsUnposted = 0
		AND D.intAccountCategoryId = 45
		AND A.strModuleName = 'Accounts Payable'
		AND (C.intInventoryReceiptItemId > 0 OR C.intInventoryReceiptChargeId > 0)
		--AND A.strTransactionId = 'BL-4496'
		GROUP BY E2.strReceiptNumber, D.strAccountId
		UNION ALL --TAX
		SELECT
			E2.strReceiptNumber,
			D.strAccountId,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM tblGLDetail A
		INNER JOIN tblAPBill B ON A.strTransactionId = B.strBillId
		INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId
		INNER JOIN tblAPBillDetailTax C2 ON C.intBillDetailId = C2.intBillDetailId AND A.intJournalLineNo = C2.intBillDetailTaxId
		INNER JOIN vyuGLAccountDetail D ON C.intAccountId = D.intAccountId
		INNER JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2 ON E.intInventoryReceiptId = E2.intInventoryReceiptId)
			ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		WHERE 
			A.ysnIsUnposted = 0
		AND D.intAccountCategoryId = 45
		AND A.strModuleName = 'Accounts Payable'
		AND (C.intInventoryReceiptItemId > 0 OR C.intInventoryReceiptChargeId > 0)
		--AND A.strTransactionId = 'BL-4496'
		GROUP BY E2.strReceiptNumber, D.strAccountId
	) tmp
	GROUP BY strReceiptNumber
)

INSERT INTO @voucherGLTotal
SELECT * FROM voucherGLTotal

--RECEIPT TOTAL VS RECEIPT GL TOTAL
SELECT
	A.strReceiptNumber,
	A.dblTotal AS dblReceiptTotal,
	B.dblTotal AS dblReceiptGLTotal,
	A.dblTotal - B.dblTotal AS dblDifference
FROM @receiptTotal A
INNER JOIN @receiptGLTotal B ON A.strReceiptNumber = B.strReceiptNumber
WHERE (A.dblTotal - B.dblTotal) != 0

--RECEIPT TOTAL VS VOUCHER TOTAL
SELECT
	A.strReceiptNumber,
	A.dblTotal AS dblReceiptTotal,
	B.dblTotal AS dblVoucherTotal,
	A.dblTotal - B.dblTotal AS dblDifference
FROM @receiptTotal A
INNER JOIN @voucherTotal B ON A.strReceiptNumber = B.strReceiptNumber
WHERE (A.dblTotal - B.dblTotal) != 0

--VOUCHER TOTAL VS VOUCHER GL TOTAL
SELECT
	A.strReceiptNumber,
	A.dblTotal AS dblVoucherTotal,
	B.dblTotal AS dblVoucherGLTotal,
	A.dblTotal - B.dblTotal AS dblDifference
FROM @voucherTotal A
INNER JOIN @voucherGLTotal B ON A.strReceiptNumber = B.strReceiptNumber
WHERE (A.dblTotal + B.dblTotal) != 0

--RECEIPT GL VS VOUCHER GL
SELECT 
	A.strTransactionNumber,
	A.dblClearingAmount,
	B.dblTotal
FROM (
SELECT  
   B.intEntityVendorId  
--    ,B.intInventoryReceiptItemId
   ,B.strTransactionNumber  
   ,SUM(B.dblReceiptTotal) AS dblReceiptTotal
   ,SUM(B.dblReceiptQty) AS dblReceiptQty
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal  
   ,SUM(B.dblVoucherQty) AS dblVoucherQty  
   ,SUM(B.dblReceiptQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty 
   ,SUM(B.dblReceiptTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount 
   ,B.intLocationId  
   ,B.strLocationName
  FROM (
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intInventoryReceiptId  
    --   ,intInventoryReceiptItemId  
    --   ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptTotal  
      ,dblReceiptQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPReceiptClearing  
	 WHERE strAccountId = '30200-90-80'
	 --AND strTransactionNumber = 'INVRCT-1'
  ) B  
  GROUP BY   
   intEntityVendorId  
--    ,intInventoryReceiptItemId
   ,strTransactionNumber  
--    ,intItemId  
   ,intLocationId  
   ,strLocationName
  --HAVING (SUM(B.dblReceiptQty) - SUM(B.dblVoucherQty)) != 0 OR (SUM(B.dblReceiptTotal) - SUM(B.dblVoucherTotal)) != 0
  ) A
  LEFT JOIN (
	SELECT
		strReceiptNumber,
		SUM(dblTotal) AS dblTotal
	FROM (
		SELECT
			E2.strReceiptNumber,
			D.strAccountId,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM tblGLDetail A
		INNER JOIN tblAPBill B ON A.strTransactionId = B.strBillId
		INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intBillDetailId = A.intJournalLineNo
		INNER JOIN vyuGLAccountDetail D ON C.intAccountId = D.intAccountId
		INNER JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2 ON E.intInventoryReceiptId = E2.intInventoryReceiptId)
			ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		WHERE 
			A.ysnIsUnposted = 0
		AND D.intAccountCategoryId = 45
		AND (A.strModuleName = 'Accounts Payable')
		AND (C.intInventoryReceiptItemId > 0 OR C.intInventoryReceiptChargeId > 0)
		--AND A.strTransactionId = 'BL-24728'
		AND D.strAccountId = '30200-90-80'
		GROUP BY E2.strReceiptNumber, D.strAccountId
		UNION ALL --TAX
		SELECT
			E2.strReceiptNumber,
			D.strAccountId,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM tblGLDetail A
		INNER JOIN tblAPBill B ON A.strTransactionId = B.strBillId
		INNER JOIN (tblAPBillDetail C INNER JOIN tblAPBillDetailTax C2 
						ON C.intBillDetailId = C2.intBillDetailId)
		ON B.intBillId = C.intBillId AND A.intJournalLineNo = C2.intBillDetailTaxId
		INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
		INNER JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2 ON E.intInventoryReceiptId = E2.intInventoryReceiptId)
			ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		WHERE 
			A.ysnIsUnposted = 0
		AND D.intAccountCategoryId = 45
		AND (A.strModuleName = 'Accounts Payable')
		AND (C.intInventoryReceiptItemId > 0 OR C.intInventoryReceiptChargeId > 0)
		--AND A.strTransactionId = 'BL-24728'
		AND D.strAccountId = '30200-90-80'
		GROUP BY E2.strReceiptNumber, D.strAccountId
		UNION ALL --COST ADJUSTMENT
		SELECT
			E2.strReceiptNumber,
			D.strAccountId,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM tblGLDetail A
		INNER JOIN tblAPBill B ON A.strTransactionId = B.strBillId
		INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId --AND C.intBillDetailId = A.intJournalLineNo
		INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
		INNER JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2	
						ON E.intInventoryReceiptId = E2.intInventoryReceiptId
					INNER JOIN tblICInventoryTransaction E3 ON E2.intInventoryReceiptId = E3.intRelatedTransactionId)
			ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId AND A.intJournalLineNo = E3.intInventoryTransactionId
		WHERE 
			A.ysnIsUnposted = 0
		AND D.intAccountCategoryId = 45
		AND A.strModuleName = 'Inventory'
		AND A.strCode = 'ICA'
		AND D.strAccountId = '30200-90-80'
		AND (C.intInventoryReceiptItemId > 0 OR C.intInventoryReceiptChargeId > 0)
		--AND A.strTransactionId = 'BL-24935'
		GROUP BY E2.strReceiptNumber, D.strAccountId
		UNION ALL
		SELECT
			--A.dtmDate,
			A.strTransactionId,
			B.strAccountId,
			SUM(dblCredit - dblDebit)
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B
		ON A.intAccountId = B.intAccountId
		WHERE B.intAccountCategoryId = 45
		AND A.ysnIsUnposted = 0
		AND A.strModuleName = 'Inventory'
		AND B.strAccountId = '30200-90-80'
		--AND A.strTransactionId = 'INVRCT-12'
		--AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
		--AND A.strDescription NOT LIKE '%Charges from%'
		--GROUP BY A.strTransactionId, A.dtmDate
		GROUP BY A.strTransactionId, B.strAccountId
	) tmp
	GROUP BY strReceiptNumber
  ) B ON A.strTransactionNumber = B.strReceiptNumber
  WHERE A.dblClearingAmount != B.dblTotal OR B.dblTotal IS NULL

--OLD
-- --Result of this should be all 0
-- SELECT
-- 	'' AS [Receipt/Voucher Total Clearing on GL],
-- 	SUM(dblTotal),
-- 	intAccountId,
-- 	strReceiptNumber
-- FROM 
-- (
-- --BILLS
-- SELECT
-- 	dblCredit - dblDebit AS dblTotal,
-- 	A.intAccountId,
-- 	receiptDetails.strReceiptNumber
-- FROM tblGLDetail A
-- INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
-- INNER JOIN tblAPBill C 
-- 	ON A.strTransactionId = C.strBillId 
-- OUTER APPLY (
-- 	SELECT TOP 1
-- 		D.strReceiptNumber
-- 	FROM tblAPBillDetail C2
-- 	INNER JOIN (tblICInventoryReceipt D INNER JOIN tblICInventoryReceiptItem D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
-- 		ON C2.intInventoryReceiptItemId = D2.intInventoryReceiptItemId
-- 	WHERE C2.intInventoryReceiptItemId > 0 AND C2.intBillId = C.intBillId
-- ) receiptDetails
-- WHERE 
-- 	ysnIsUnposted = 0
-- AND 1 = CASE WHEN @account > 0 THEN 
-- 			CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
-- 		ELSE 1
-- 		END
-- AND B.intAccountCategoryId = 45
-- AND A.intJournalLineNo != 1
-- AND receiptDetails.strReceiptNumber IS NOT NULL
-- AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
-- --AND A.strTransactionId IN ('BL-216317','BL-216418')
-- UNION ALL
-- --RECEIPTS
-- SELECT
-- 	dblCredit - dblDebit AS dblTotal,
-- 	A.intAccountId,
-- 	D.strReceiptNumber
-- FROM tblGLDetail A
-- INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
-- INNER JOIN tblICInventoryReceipt D ON A.strTransactionId = D.strReceiptNumber
-- WHERE 
-- 	ysnIsUnposted = 0
-- AND 1 = CASE WHEN @account > 0 THEN 
-- 			CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
-- 		ELSE 1
-- 		END
-- AND B.intAccountCategoryId = 45
-- AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
-- --AND A.strTransactionId IN ('IR-102')
-- ) glDetails
-- GROUP BY
-- 	intAccountId,
-- 	strReceiptNumber
-- ORDER BY strReceiptNumber

-- ;WITH receiptTotal (
--      dtmReceiptDate,
-- 	 dblTotal,
-- 	 strReceiptNumber
-- )
-- AS (
-- 	SELECT
-- 	   A.dtmReceiptDate,
-- 	   SUM(B.dblLineTotal + B.dblTax) * (CASE WHEN A.strReceiptType = 'Inventory Return' THEN -1 ELSE 1 END) AS dblTotal,
-- 	   A.strReceiptNumber
-- 	FROM tblICInventoryReceipt A
-- 	INNER JOIN tblICInventoryReceiptItem B
-- 	ON A.intInventoryReceiptId = B.intInventoryReceiptId
-- 	WHERE DATEADD(dd, DATEDIFF(dd, 0,A.dtmReceiptDate), 0) BETWEEN @start AND @end
-- 	GROUP BY A.dtmReceiptDate, A.strReceiptNumber, A.strReceiptType
-- ),
-- receiptGLTotal (
-- 	dtmDate,
-- 	dblTotal,
-- 	 strReceiptNumber
-- )
-- AS (
-- 	SELECT
-- 		A.dtmDate,
-- 		SUM(dblCredit - dblDebit),
-- 		A.strTransactionId
-- 	FROM tblGLDetail A
-- 	INNER JOIN vyuGLAccountDetail B
-- 	ON A.intAccountId = B.intAccountId
-- 	WHERE B.intAccountCategoryId = 45
-- 	AND A.ysnIsUnposted = 0
-- 	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
-- 	AND A.strDescription NOT LIKE '%Charges from%'
-- 	GROUP BY A.strTransactionId, A.dtmDate
-- )

-- SELECT
-- 	'' [Receipt Total Clearing vs GL Total Clearing],
-- 	A.strReceiptNumber,
-- 	A.dtmReceiptDate,
-- 	A.dblTotal,
-- 	B.dblTotal AS dblGLTotal
-- FROM receiptTotal A
-- INNER JOIN receiptGLTotal B ON A.strReceiptNumber = B.strReceiptNumber
-- WHERE A.dblTotal != B.dblTotal

-- ;WITH billTotal (
--      dtmBillDate,
-- 	 dblTotal,
-- 	 strBillId
-- )
-- AS (
-- 	SELECT
-- 	   A.dtmBillDate,
-- 	   SUM(B.dblTotal + B.dblTax) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) AS dblTotal,
-- 	   A.strBillId
-- 	FROM tblAPBill A
-- 	INNER JOIN tblAPBillDetail B
-- 	ON A.intBillId = B.intBillId AND B.intInventoryReceiptItemId > 0
-- 	WHERE DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
-- 	GROUP BY A.dtmBillDate, A.strBillId, A.intTransactionType
-- ),
-- billGLTotal (
-- 	dtmDate,
-- 	dblTotal,
-- 	strBillId
-- )
-- AS (
-- 	SELECT
-- 		A.dtmDate,
-- 		SUM(dblDebit - dblCredit),
-- 		A.strTransactionId
-- 	FROM tblGLDetail A
-- 	INNER JOIN vyuGLAccountDetail B
-- 	ON A.intAccountId = B.intAccountId
-- 	WHERE B.intAccountCategoryId = 45
-- 	AND A.ysnIsUnposted = 0
-- 	AND A.strCode != 'ICA'
-- 	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
-- 	GROUP BY A.strTransactionId, A.dtmDate
-- )

-- SELECT
-- 	'' [Voucher Total Clearing vs GL Total Clearing],
-- 	A.strBillId,
-- 	A.dtmBillDate,
-- 	A.dblTotal,
-- 	B.dblTotal AS dblGLTotal
-- FROM billTotal A
-- INNER JOIN billGLTotal B ON A.strBillId = B.strBillId
-- WHERE A.dblTotal != B.dblTotal