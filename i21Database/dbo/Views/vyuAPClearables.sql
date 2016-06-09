﻿CREATE VIEW [dbo].[vyuAPClearables]

AS 
SELECT 
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Bill.dtmDate
	, Bill.intBillId 
	, Bill.strBillId 
	, 0 AS dblAmountPaid 
	, dblTotal = IRI.dblLineTotal /*CASE WHEN Bill.intTransactionType != 1 AND Bill.dblTotal > 0 THEN Bill.dblTotal * -1 ELSE Bill.dblTotal END AS dblTotal*/
	, CASE WHEN Bill.intTransactionType != 1 AND Bill.dblAmountDue > 0 THEN Bill.dblAmountDue * -1 ELSE Bill.dblAmountDue END AS dblAmountDue 
	, dblAmountToVoucher = CASE
		WHEN IRI.dblOpenReceive = 0
		THEN 0
		ELSE (IRI.dblLineTotal/IRI.dblOpenReceive)*(IRI.dblOpenReceive - ISNULL(IRI.dblBillQty,0))
	  END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, ISNULL(C1.strVendorId,'') + ' - ' + ISNULL(C2.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
FROM dbo.tblICInventoryReceipt Receipt
INNER JOIN dbo.tblICInventoryReceiptItem IRI 
	ON IRI.intInventoryReceiptId = Receipt.intInventoryReceiptId
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 
	ON C1.[intEntityVendorId] = C2.intEntityId)
	ON C1.[intEntityVendorId] = Receipt.[intEntityVendorId]
LEFT JOIN dbo.tblAPBillDetail Detail 
	ON Detail.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
LEFT JOIN dbo.tblAPBill Bill 
	ON Bill.intBillId = Detail.intBillId
LEFT JOIN vyuAPBillPayment BP ON BP.intBillId = Bill.intBillId 
WHERE Receipt.ysnPosted = 1 
	AND Bill.intTransactionType != 7 
	AND ISNULL(Detail.intInventoryReceiptItemId, '') <> ''

UNION ALL  

SELECT 
	  Receipts.dtmReceiptDate
	, Receipts.strReceiptNumber
	, Receipts.intInventoryReceiptId
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
	, (SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
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
