CREATE VIEW [dbo].[vyuAPClearables]

AS

--QUERY FOR MAIN VENDOR WITH CHARGES
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, Receipt.strOrderNumber
	, Bill.dtmDate
	, Bill.intBillId 
	, strBillId = ISNULL(Bill.strBillId, 'New Voucher')
	, dblAmountPaid = 0
	, dblTotal = CASE WHEN Receipt.strReceiptType = 'Inventory Return' 
					  THEN (Receipt.dblLineTotal + ISNULL(ReceiptTaxes.dblTotalTax,0) + ISNULL(ReceiptCharges.dblCharges,0)) *-1
					  ELSE Receipt.dblLineTotal + ISNULL(ReceiptTaxes.dblTotalTax,0) + ISNULL(ReceiptCharges.dblCharges,0)
				 END
	, dblAmountDue = CASE 
						WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
						THEN Bill.dblDetailTotal * -1 
						ELSE Bill.dblDetailTotal 
					END  
	, dblVoucherAmount = ISNULL(Bill.dblDetailTotal,0) 
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
	,dblQtyToReceive = (CASE WHEN Receipt.strReceiptType = 'Inventory Return' 
							 THEN Receipt.dblQtyToReceive * -1 
							 ELSE Receipt.dblQtyToReceive END)
	,dblQtyVouchered = (CASE WHEN Receipt.strReceiptType = 'Inventory Return' 
							 THEN ISNULL(Bill.dblQtyReceived,ISNULL(Receipt.dblBillQty,0)) *-1
							 ELSE ISNULL(Bill.dblQtyReceived,ISNULL(Receipt.dblBillQty,0)) END)
	,dblQtyToVoucher = (CASE WHEN Receipt.strReceiptType = 'Inventory Return' 
							 THEN (Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) *-1
							 ELSE (Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) END) 
	,dblAmountToVoucher =
					  (CASE WHEN Receipt.strReceiptType = 'Inventory Return' 
					  THEN
						  (CASE
							WHEN Receipt.dblQtyToReceive = 0 THEN 0
							ELSE CAST((ISNULL(Receipt.dblLineTotal,0) +  ISNULL(ReceiptTaxes.dblTotalTax,0) + ISNULL(ReceiptCharges.dblCharges,0)) / 
								(Receipt.dblQtyToReceive)*(Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) AS DECIMAL (18,2))
						  END) *-1
					  ELSE 
						  (CASE
							WHEN Receipt.dblQtyToReceive = 0 THEN 0
							ELSE CAST((ISNULL(Receipt.dblLineTotal,0) +  ISNULL(ReceiptTaxes.dblTotalTax,0) + ISNULL(ReceiptCharges.dblCharges,0)) / 
								(Receipt.dblQtyToReceive)*(Receipt.dblQtyToReceive - ISNULL(Receipt.dblBillQty,0)) AS DECIMAL (18,2))
						  END)END)                    
	,0 AS dblChargeAmount	
	,Receipt.strContainer
FROM vyuICGetInventoryReceiptItem Receipt
	LEFT JOIN (
		SELECT DISTINCT 
			  Header.strBillId
			, Header.dtmBillDate
			, Header.dtmDate
			, Header.dtmDueDate
			, Header.intBillId
			, Header.dblAmountDue
			, Header.intTransactionType
			, Header.ysnPaid
			, Detail.intInventoryReceiptItemId
			, Detail.dblQtyReceived
			, Detail.dblDetailTotal
			, Header.dblTotal
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intInventoryReceiptItemId,
					SUM(dblQtyReceived) AS dblQtyReceived,
					SUM(A.dblTotal)	+  SUM(A.dblTax) AS dblDetailTotal
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intInventoryReceiptChargeId IS NULL
				GROUP BY intInventoryReceiptItemId
			) Detail		
		WHERE ISNULL(intInventoryReceiptItemId, '') <> '' 
	) Bill ON Bill.intInventoryReceiptItemId = Receipt.intInventoryReceiptItemId
	--RECEIPT TAXES
	OUTER APPLY (
		SELECT SUM(dblTax) AS dblTotalTax FROM dbo.tblICInventoryReceiptItemTax A 
		WHERE A.intInventoryReceiptItemId = Receipt.intInventoryReceiptItemId
	) ReceiptTaxes
	--RECEIPT CHARGES EXCLUDE 3RD PARTY VENDOR
	OUTER APPLY (
		SELECT SUM(dblAmount) + SUM(dblTax) AS dblCharges FROM dbo.tblICInventoryReceiptCharge A 
		WHERE A.intInventoryReceiptId = Receipt.intInventoryReceiptId AND A.intEntityVendorId IN (select intEntityVendorId FROM tblAPVendor WHERE strVendorId = Receipt.strVendorId)
	) ReceiptCharges
	OUTER APPLY (
				SELECT 
					SUM(dblQtyReceived) AS totalReceivedQty
				FROM dbo.tblAPBillDetail A
				WHERE A.intInventoryReceiptChargeId IS NULL AND A.intInventoryReceiptItemId = Receipt.intInventoryReceiptItemId
				GROUP BY intInventoryReceiptItemId 
	) totalRcvdQty	
WHERE Receipt.ysnPosted = 1 AND ((Receipt.dblQtyToReceive - ISNULL(totalRcvdQty.totalReceivedQty,Receipt.dblBillQty)) != 0 OR  (CASE WHEN Receipt.dblQtyToReceive = 0  THEN 0  
																										ELSE (ISNULL(Receipt.dblLineTotal,0)/Receipt.dblQtyToReceive)*(Receipt.dblQtyToReceive - ISNULL(totalRcvdQty.totalReceivedQty,Receipt.dblBillQty))END) != 0)
																										--AND Receipt.strReceiptNumber = 'INVRCT-4604'
UNION ALL																									
--QUERY FOR RECEIPT VENDOR PRICE DOWN WITH CHARGES
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, Bill.dtmDate
	, Bill.intBillId 
	, strBillId = ISNULL(Bill.strBillId, 'New Voucher')
	, dblAmountPaid = 0
	, (ISNULL(dblAmount,0) * -1 ) + (ISNULL(dblTax,0) * -1) AS dblTotal
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal 
		ELSE Bill.dblDetailTotal 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = ISNULL(Bill.dblDetailTotal,0)
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' - ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, Bill.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,-1 AS dblQtyToReceive
	,dblQtyVouchered = ABS(ISNULL(Bill.dblQtyReceived,ISNULL(CASE WHEN dblAmountBilled <> 0 THEN 1 ELSE 0 END,0))) * -1
	,CASE WHEN Bill.dblQtyReceived <> 0 THEN 0 ELSE -1 END AS dblQtyToVoucher 
	, dblAmountToVoucher = CAST(( (ISNULL(dblAmount,0)* -1) + (ISNULL(dblTax,0)* -1)) AS DECIMAL (18,2)) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.ysnPrice = 1
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityVendorId = Receipt.intEntityVendorId
	LEFT JOIN (
		SELECT DISTINCT 
			  Header.strBillId
			, Header.dtmBillDate
			, Header.dtmDate
			, Header.dtmDueDate
			, Header.intBillId
			, Header.dblAmountDue
			, Header.intTransactionType
			, Header.ysnPaid
			, Header.intEntityVendorId
			, Detail.intInventoryReceiptChargeId
			, Detail.dblQtyReceived
			, Detail.dblDetailTotal
			, Header.dblTotal
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intInventoryReceiptChargeId,
					SUM(dblQtyReceived) AS dblQtyReceived,
					SUM(A.dblTotal)	+ SUM(A.dblTax) AS dblDetailTotal
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intInventoryReceiptChargeId IS NOT NULL
				GROUP BY intInventoryReceiptChargeId
			) Detail		
		WHERE ISNULL(intInventoryReceiptChargeId, '') <> ''
	) Bill ON Bill.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId AND Bill.intEntityVendorId = Receipt.intEntityVendorId
WHERE Receipt.ysnPosted = 1 
	  AND ReceiptCharge.intInventoryReceiptChargeId NOT IN (SELECT DISTINCT intInventoryReceiptChargeId FROM tblAPBillDetail A
																				  INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE intInventoryReceiptChargeId IS NOT NULL AND B.ysnPosted = 1)

UNION ALL  
--QUERY FOR 3RD PARTY ACRUE VENDOR WITH CHARGES 
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, Bill.dtmDate
	, Bill.intBillId 
	, strBillId = ISNULL(Bill.strBillId, 'New Voucher')
	, dblAmountPaid = 0
	, ISNULL(dblAmount,0) + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) AS dblTotal
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) * -1 
		ELSE Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = ISNULL(Bill.dblDetailTotal,0) + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0)
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' - ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, Bill.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,1 AS dblQtyToReceive
	,dblQtyVouchered = ABS(ISNULL(Bill.dblQtyReceived,ISNULL(CASE WHEN dblAmountBilled <> 0 THEN 1 ELSE 0 END,0)))
	,CASE WHEN Bill.dblQtyReceived <> 0 THEN 0 ELSE 1 END AS dblQtyToVoucher
	, dblAmountToVoucher = CAST(( ISNULL(dblAmount,0) + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0)) AS DECIMAL (18,2))
	, 0 AS dblChargeAmount	
	, ''AS strContainer
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.intEntityVendorId NOT IN (Receipt.intEntityVendorId)
LEFT JOIN dbo.tblICInventoryReceiptChargeTax ReceiptChargeTax 
	ON ReceiptChargeTax.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityVendorId = ReceiptCharge.intEntityVendorId
	LEFT JOIN (
		SELECT DISTINCT 
			  Header.strBillId
			, Header.dtmBillDate
			, Header.dtmDate
			, Header.dtmDueDate
			, Header.intBillId
			, Header.dblAmountDue
			, Header.intTransactionType
			, Header.ysnPaid
			, Header.intEntityVendorId
			, Detail.intInventoryReceiptChargeId
			, Detail.dblQtyReceived
			, Detail.dblDetailTotal
			, Header.dblTotal
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intInventoryReceiptChargeId,
					SUM(dblQtyReceived) AS dblQtyReceived,
					SUM(A.dblTotal)		AS dblDetailTotal
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intInventoryReceiptChargeId IS NOT NULL
				GROUP BY intInventoryReceiptChargeId
			) Detail		
		WHERE ISNULL(intInventoryReceiptChargeId, '') <> '' 
	) Bill ON Bill.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId AND Bill.intEntityVendorId NOT IN (Receipt.intEntityVendorId)
WHERE Receipt.ysnPosted = 1 AND ReceiptCharge.ysnAccrue = 1
	  AND ReceiptCharge.intInventoryReceiptChargeId NOT IN (SELECT DISTINCT intInventoryReceiptChargeId FROM tblAPBillDetail A
																				  INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE intInventoryReceiptChargeId IS NOT NULL AND B.ysnPosted = 1)

-- UNION ALL
-- SELECT 
-- 	  Receipts.dtmReceiptDate
-- 	, Receipts.strReceiptNumber
-- 	, Receipts.intInventoryReceiptId
-- 	, '' AS strBillOfLading
-- 	, '' AS strOrderNumber
-- 	, A.dtmDatePaid AS dtmDate 
-- 	, B.intBillId
-- 	, C.strBillId 
-- 	, CASE WHEN C.intTransactionType != 1 AND B.dblPayment > 0 THEN B.dblPayment * -1 ELSE B.dblPayment END AS dblAmountPaid
-- 	, dblTotal = 0 
-- 	, dblAmountDue = 0 
-- 	, dblAmountToVoucher = 0
-- 	, dblWithheld = B.dblWithheld
-- 	, B.dblDiscount 
-- 	, B.dblInterest 
-- 	, D.strVendorId 
-- 	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
-- 	, C.dtmDueDate 
-- 	, C.ysnPosted 
-- 	, C.ysnPaid
-- 	, T.strTerm
-- 	, (SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
-- 	,0 AS dblQtyToReceive
-- 	,0 AS dblQtyVouchered
-- 	,0 AS dblQtyToVoucher
-- 	,0 AS dblAmountToVoucher
-- 	,0 AS dblChargeAmount
-- 	,'' AS strContainer
-- FROM dbo.tblAPPayment  A
--  LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
--  LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
--  LEFT JOIN dbo.tblSMTerm T  ON C.intTermsId = T.intTermID
--  LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityVendorId] = D2.intEntityId)
-- 	ON A.[intEntityVendorId] = D.[intEntityVendorId]
-- OUTER APPLY (
-- 		SELECT DISTINCT 
-- 			IR.dtmReceiptDate,
-- 			IR.strReceiptNumber,
-- 			IR.intInventoryReceiptId,
-- 			IR.ysnPosted
-- 		FROM tblICInventoryReceipt IR
-- 			LEFT JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
-- 			INNER JOIN dbo.tblAPBillDetail BD ON BD.intInventoryReceiptItemId  = IRI.intInventoryReceiptItemId
-- 		WHERE C.intBillId = BD.intBillId AND ISNULL(BD.intInventoryReceiptItemId, '') <> ''  
-- 	) Receipts
--  WHERE A.ysnPosted = 1  
-- 	AND C.ysnPosted = 1
-- 	AND Receipts.ysnPosted = 1
-- 	AND ysnPaid = 0
