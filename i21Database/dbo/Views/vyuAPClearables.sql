CREATE VIEW [dbo].[vyuAPClearables]

AS
--QUERY FOR MAIN VENDOR W/O CHARGES
SELECT	DISTINCT	 
			 dtmReceiptDate
			,strReceiptNumber
			,intInventoryReceiptId
			,strBillOfLading	
			,strOrderNumber
			,dtmLastVoucherDate AS dtmDate
			,0 AS intBillId --Bill.intBillId 
			,strAllVouchers COLLATE Latin1_General_CI_AS AS strBillId 
			,dblAmountPaid = 0
			,dblTotal = ISNULL(dblReceiptLineTotal + dblReceiptTax,0)
			,dblAmountDue = ISNULL(dblItemsPayable + dblTaxesPayable,0)
			,dblVoucherAmount = CASE 
								WHEN bill.ysnPosted = 1 AND  (dblReceiptQty - dblVoucherQty) != 0 THEN
								ISNULL((CASE WHEN dblVoucherLineTotal = 0 THEN totalVouchered.dblTotal ELSE dblVoucherLineTotal END),0)
								ELSE 0 END    
			,dblWithheld = 0
			,dblDiscount = 0 
			,dblInterest = 0 
			,vendor.strVendorId
			,strVendorIdName = vendor.strVendorId + ' ' + entity.strName
			,bill.dtmDueDate
			,ysnPosted
			,ysnPaid
			,(CASE WHEN bill.ysnPosted = 1 THEN bill.strTerm ELSE '' END) AS strTerm
			,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
			,dblQtyToReceive = dblReceiptQty
			,dblQtyVouchered = CASE WHEN bill.ysnPosted = 1 AND  (dblReceiptQty - dblVoucherQty) != 0 THEN dblVoucherQty ELSE 0 END
			,dblQtyToVoucher = dblOpenQty
			,dblAmountToVoucher = CASE 
									WHEN bill.ysnPosted = 1 AND  (dblReceiptQty - dblVoucherQty) != 0 THEN
									ISNULL((dblReceiptLineTotal + dblReceiptTax) - (totalVouchered.dblTotal),0)
									ELSE (dblReceiptLineTotal + dblReceiptTax)  END                                    
			,dblChargeAmount = 0
			,strContainer = strContainerNumber
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryReceiptVoucherItems items
				WHERE	items.intEntityVendorId = vendor.intEntityId
			) receiptItem
			OUTER APPLY (
				SELECT strTerm,ysnPosted,ysnPaid,A.dtmDueDate FROM dbo.tblAPBill A 
				INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
				INNER JOIN tblSMTerm C ON C.intTermID = A.intTermsId
				WHERE 
				B.intInventoryReceiptChargeId IS NULL AND B.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
			) bill
			OUTER APPLY (
				SELECT 
					SUM(dblTotal) + SUM(dblTax) AS dblTotal
				FROM dbo.tblAPBillDetail A
				WHERE A.intInventoryReceiptChargeId IS NULL AND A.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
				GROUP BY intInventoryReceiptItemId 
			) totalVouchered
WHERE ((dblReceiptQty - dblVoucherQty)) != 0 
UNION ALL 

--QUERY FOR RECEIPT VENDOR ACCRUE CHARGES
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, dtmDate = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.dtmDate ELSE NULL END 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0)) + (ISNULL(dblTax,0)) 
	, dblAmountDue = ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal 
		ELSE Bill.dblDetailTotal 
	  END,0)  
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strTerm ELSE '' END 
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,dblQtyToReceive = 1 
	,dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 1 ELSE 0 END 
	,dblQtyToVoucher = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 0 ELSE 1 END 
	,dblAmountToVoucher = CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) AS DECIMAL (18,2)) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.ysnAccrue = 1 AND ReceiptCharge.ysnPrice = 0
										AND ReceiptCharge.intEntityVendorId = Receipt.intEntityVendorId
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = Receipt.intEntityVendorId
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
			, Header.ysnPosted
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
--QUERY FOR RECEIPT VENDOR PRICE DOWN CHARGES
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, dtmDate = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.dtmDate ELSE NULL END 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0) * -1 ) + (ISNULL(dblTax,0) * -1) 
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal 
		ELSE Bill.dblDetailTotal 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) * -1 ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strTerm ELSE '' END 
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	, dblQtyToReceive = -1 
	, dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN -1 ELSE 0 END 
	, dblQtyToVoucher = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 0 ELSE -1 END 
	, dblAmountToVoucher = CAST(( (ISNULL(dblAmount,0)* -1) + (ISNULL(dblTax,0)* -1)) AS DECIMAL (18,2)) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.ysnPrice = 1
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = Receipt.intEntityVendorId
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
			, Header.ysnPosted
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
	, dtmDate = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.dtmDate ELSE NULL END 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0)) + (ISNULL(ReceiptCharge.dblTax,0)) 
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) * -1 
		ELSE Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) * -1 ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strTerm ELSE '' END 
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	, dblQtyToReceive = 1
	, dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 1 ELSE 0 END 
	, dblQtyToVoucher = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 0 ELSE 1 END 
	, dblAmountToVoucher =  CAST(((ISNULL(dblAmount,0)) + (ISNULL(ReceiptCharge.dblTax,0))) AS DECIMAL (18,2)) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.intEntityVendorId NOT IN (Receipt.intEntityVendorId)
LEFT JOIN dbo.tblICInventoryReceiptChargeTax ReceiptChargeTax 
	ON ReceiptChargeTax.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = ReceiptCharge.intEntityVendorId
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
			, Header.ysnPosted
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
	) Bill ON Bill.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId AND Bill.intEntityVendorId NOT IN (Receipt.intEntityVendorId)
WHERE Receipt.ysnPosted = 1 AND ReceiptCharge.ysnAccrue = 1
	  AND ReceiptCharge.intInventoryReceiptChargeId NOT IN (SELECT DISTINCT intInventoryReceiptChargeId FROM tblAPBillDetail A
																				  INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE intInventoryReceiptChargeId IS NOT NULL AND B.ysnPosted = 1)
