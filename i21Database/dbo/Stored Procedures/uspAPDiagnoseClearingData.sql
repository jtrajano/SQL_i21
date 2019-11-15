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
DECLARE @end DATETIME = CASE WHEN @dateEnd IS NOT NULL THEN @dateStart ELSE GETDATE() END

SELECT
	SUM(dblTotal),
	intAccountId,
	strReceiptNumber
FROM 
(
--BILLS
SELECT
	dblCredit - dblDebit AS dblTotal,
	A.intAccountId,
	receiptDetails.strReceiptNumber
FROM tblGLDetail A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
INNER JOIN tblAPBill C 
	ON A.strTransactionId = C.strBillId 
OUTER APPLY (
	SELECT TOP 1
		D.strReceiptNumber
	FROM tblAPBillDetail C2
	INNER JOIN (tblICInventoryReceipt D INNER JOIN tblICInventoryReceiptItem D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
		ON C2.intInventoryReceiptItemId = D2.intInventoryReceiptItemId
	WHERE C2.intInventoryReceiptItemId > 0 AND C2.intBillId = C.intBillId
) receiptDetails
WHERE 
	ysnIsUnposted = 0
AND 1 = CASE WHEN @account > 0 THEN 
			CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
		ELSE 1
		END
AND B.intAccountCategoryId = 45
AND A.intJournalLineNo != 1
AND receiptDetails.strReceiptNumber IS NOT NULL
AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
--AND A.strTransactionId IN ('BL-216317','BL-216418')
UNION ALL
--RECEIPTS
SELECT
	dblCredit - dblDebit AS dblTotal,
	A.intAccountId,
	D.strReceiptNumber
FROM tblGLDetail A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
INNER JOIN tblICInventoryReceipt D ON A.strTransactionId = D.strReceiptNumber
WHERE 
	ysnIsUnposted = 0
AND 1 = CASE WHEN @account > 0 THEN 
			CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
		ELSE 1
		END
AND B.intAccountCategoryId = 45
AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
--AND A.strTransactionId IN ('IR-102')
) glDetails
GROUP BY
	intAccountId,
	strReceiptNumber
ORDER BY strReceiptNumber

;WITH receiptTotal (
     dtmReceiptDate,
	 dblTotal,
	 strReceiptNumber
)
AS (
	SELECT
	   A.dtmReceiptDate,
	   SUM(B.dblLineTotal + B.dblTax) * (CASE WHEN A.strReceiptType = 'Inventory Return' THEN -1 ELSE 1 END) AS dblTotal,
	   A.strReceiptNumber
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
	ON A.intInventoryReceiptId = B.intInventoryReceiptId
	GROUP BY A.dtmReceiptDate, A.strReceiptNumber, A.strReceiptType
),
receiptGLTotal (
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
	GROUP BY A.strTransactionId, A.dtmDate
)

SELECT
	A.strReceiptNumber,
	A.dtmReceiptDate,
	A.dblTotal,
	B.dblTotal AS dblGLTotal
FROM receiptTotal A
INNER JOIN receiptGLTotal B ON A.strReceiptNumber = B.strReceiptNumber
WHERE A.dblTotal != B.dblTotal

;WITH billTotal (
     dtmBillDate,
	 dblTotal,
	 strBillId
)
AS (
	SELECT
	   A.dtmBillDate,
	   SUM(B.dblTotal + B.dblTax) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) AS dblTotal,
	   A.strBillId
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B
	ON A.intBillId = B.intBillId AND B.intInventoryReceiptItemId > 0
	GROUP BY A.dtmBillDate, A.strBillId, A.intTransactionType
),
billGLTotal (
	dtmDate,
	dblTotal,
	strBillId
)
AS (
	SELECT
		A.dtmDate,
		SUM(dblDebit - dblCredit),
		A.strTransactionId
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B
	ON A.intAccountId = B.intAccountId
	WHERE B.intAccountCategoryId = 45
	AND A.ysnIsUnposted = 0
	AND A.strCode != 'ICA'
	GROUP BY A.strTransactionId, A.dtmDate
)

SELECT
	A.strBillId,
	A.dtmBillDate,
	A.dblTotal,
	B.dblTotal AS dblGLTotal
FROM billTotal A
INNER JOIN billGLTotal B ON A.strBillId = B.strBillId
WHERE A.dblTotal != B.dblTotal