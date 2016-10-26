CREATE VIEW [dbo].[vyuAPClearables]

AS 
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, Receipt.strOrderNumber
	, Bill.dtmDate
	, Bill.intBillId 
	, strBillId = ISNULL(Bill.strBillId, 'New Voucher')
	, 0 AS dblAmountPaid 
	, Receipt.dblLineTotal + ISNULL(dblTotalTax,0) +  ISNULL(Charges.dblAmount,0) AS dblTotal
	, CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblAmountDue > 0 
		THEN Bill.dblAmountDue * -1 
		ELSE Bill.dblAmountDue 
	  END AS dblAmountDue 
	, dblVoucherAmount = 
	  CASE
		WHEN Receipt.dblQtyToReceive = 0
		THEN 0
		ELSE (Receipt.dblLineTotal + ISNULL(dblTotalTax,0) +  ISNULL(Charges.dblAmount,0) /Receipt.dblQtyToReceive)* ISNULL(Receipt.dblBillQty,0)
	  END
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Receipt.strVendorId 
	, ISNULL(Receipt.strVendorId,'') + ' - ' + ISNULL(Receipt.strVendorName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, Bill.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,Receipt.dblQtyToReceive
	,dblQtyVouchered = ISNULL(Bill.dblQtyReceived,ISNULL(Receipt.dblBillQty,0))
	,(Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) dblQtyToVoucher
	,dblAmountToVoucher =
	  CASE
		WHEN Receipt.dblQtyToReceive = 0
		THEN 0
		ELSE CAST((ISNULL(Receipt.dblLineTotal + ISNULL(dblTotalTax,0) +  ISNULL(Charges.dblAmount,0),0)/Receipt.dblQtyToReceive)*(Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) AS DECIMAL (18,2))
	  END
	,ISNULL(Charges.dblAmount,0.00) AS dblChargeAmount
FROM vyuICGetInventoryReceiptItem Receipt
	LEFT JOIN (
		SELECT DISTINCT 
			  Header.strBillId
			, Header.dtmBillDate
			, Header.dtmDate
			, Header.dtmDueDate
			, Detail.intInventoryReceiptItemId
			, Header.intBillId
			, Detail.dblQtyReceived
			, Header.dblAmountDue
			, Header.intTransactionType
			, Header.ysnPaid
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intInventoryReceiptItemId,
					SUM(dblQtyReceived) AS dblQtyReceived
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intInventoryReceiptChargeId IS NULL
				GROUP BY intInventoryReceiptItemId
			) Detail
		OUTER APPLY
		(
			SELECT SUM(dblLineTotal) AS dblLineTotal
			FROM vyuICGetInventoryReceiptItem ReceiptItem 
			WHERE Detail.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		) ReceiptDetail				
		WHERE ISNULL(intInventoryReceiptItemId, '') <> '' 
	) Bill ON Bill.intInventoryReceiptItemId = Receipt.intInventoryReceiptItemId

	OUTER APPLY (
		SELECT DISTINCT
			SUM(Receipt.dblLineTotal) AS dblTotal
			,strReceiptNumber
		FROM vyuICGetInventoryReceiptItem Receipt
		GROUP BY strReceiptNumber
	) Receipt2
	OUTER APPLY (
		SELECT SUM(dblAmount) + SUM(dblTax) AS dblAmount 
		FROM dbo.tblICInventoryReceiptCharge A WHERE A.intInventoryReceiptId = Receipt.intInventoryReceiptId
	) Charges
	OUTER APPLY (
		SELECT SUM(dblTax) AS dblTotalTax FROM dbo.tblICInventoryReceiptItemTax A WHERE A.intInventoryReceiptItemId = Receipt.intInventoryReceiptItemId
	) ReceiptTaxes
WHERE Receipt.ysnPosted = 1 AND ((Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) != 0 OR (CASE WHEN Receipt.dblQtyToReceive = 0  THEN 0  
																										ELSE (ISNULL(Receipt.dblLineTotal,0)/Receipt.dblQtyToReceive)*(Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0))END) != 0)
																										--AND Receipt.strReceiptNumber = 'IR-209'
UNION ALL  

SELECT 
	  Receipts.dtmReceiptDate
	, Receipts.strReceiptNumber
	, Receipts.intInventoryReceiptId
	, '' AS strBillOfLading
	, '' AS strOrderNumber
	, A.dtmDatePaid AS dtmDate 
	, B.intBillId
	, C.strBillId 
	, CASE WHEN C.intTransactionType != 1 AND B.dblPayment > 0 THEN B.dblPayment * -1 ELSE B.dblPayment END AS dblAmountPaid
	, dblTotal = 0 
	, dblAmountDue = 0 
	, dblAmountToVoucher = 0
	, dblWithheld = B.dblWithheld
	, B.dblDiscount 
	, B.dblInterest 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, T.strTerm
	, (SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,0 AS dblQtyToReceive
	,0 AS dblQtyVouchered
	,0 AS dblQtyToVoucher
	,0 AS dblAmountToVoucher
	,0 AS dblChargeAmount
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN dbo.tblSMTerm T  ON C.intTermsId = T.intTermID
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityVendorId] = D2.intEntityId)
	ON A.[intEntityVendorId] = D.[intEntityVendorId]
OUTER APPLY (
		SELECT DISTINCT 
			IR.dtmReceiptDate,
			IR.strReceiptNumber,
			IR.intInventoryReceiptId,
			IR.ysnPosted
		FROM tblICInventoryReceipt IR
			LEFT JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
			INNER JOIN dbo.tblAPBillDetail BD ON BD.intInventoryReceiptItemId  = IRI.intInventoryReceiptItemId
		WHERE C.intBillId = BD.intBillId AND ISNULL(BD.intInventoryReceiptItemId, '') <> ''  
	) Receipts
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND Receipts.ysnPosted = 1
	AND ysnPaid = 0 
GO