CREATE VIEW [dbo].[vyuAPClearablesOnly]

AS


--RECEIPT MAIN VENDOR W/O CHARGES--
SELECT	DISTINCT	 
			 dtmReceiptDate
			,strReceiptNumber
			,receiptItem.intInventoryReceiptId
			,strBillOfLading	
			,strOrderNumber
			,dtmReceiptDate AS dtmDate
			,dtmLastVoucherDate AS dtmBillDate
			,0 AS intBillId --Bill.intBillId 
			,strAllVouchers COLLATE Latin1_General_CI_AS AS strBillId 
			,dblAmountPaid = 0
			,dblTotal = ISNULL(dblReceiptLineTotal + dblReceiptTax,0)
			,dblAmountDue = ABS(ISNULL(dblItemsPayable + dblTaxesPayable,0))
			,dblVoucherAmount = CASE 
								WHEN (bill.ysnPosted = 1 OR bill.ysnPosted IS NULL)  AND  (dblReceiptQty - dblVoucherQty) != 0 THEN ISNULL((CASE WHEN dblVoucherLineTotal = 0 THEN totalVouchered.dblTotal ELSE  dblVoucherLineTotal + dblVoucherTax  END),0)
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
			,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) COLLATE Latin1_General_CI_AS as strCompanyAddress
			,dblQtyToReceive = dblReceiptQty
			,dblQtyVouchered = CASE WHEN (bill.ysnPosted = 1 OR bill.ysnPosted IS NULL)  AND  (dblReceiptQty - dblVoucherQty) != 0 THEN dblVoucherQty ELSE 0 END
			,dblQtyToVoucher = dblOpenQty
			,dblAmountToVoucher = CASE 
									WHEN (bill.ysnPosted = 1 OR bill.ysnPosted IS NULL) AND  (dblReceiptQty - dblVoucherQty) != 0 THEN ISNULL((dblReceiptLineTotal + dblReceiptTax)	,0) -  ISNULL((totalVouchered.dblTotal),0)
									WHEN bill.ysnPosted = 0 AND  (dblReceiptQty - dblVoucherQty) != 0 THEN ISNULL(dblItemsPayable + dblTaxesPayable,0)
									ELSE (dblReceiptLineTotal + dblReceiptTax)  END                                    
			,dblChargeAmount = 0
			,strContainer = strContainerNumber
			,dblVoucherQty = 0
			,dblReceiptQty = ABS(dblReceiptQty)
			,loc.strLocationName
	FROM	tblAPVendor vendor INNER JOIN tblEMEntity entity
				ON entity.intEntityId = vendor.intEntityId
			CROSS APPLY (
				SELECT	intInventoryReceiptId
						,intInventoryReceiptItemId
						,dblReceiptQty
						,ABS(dblVoucherQty) AS dblVoucherQty
						,dtmReceiptDate
						,strReceiptNumber
						,strBillOfLading
						,strOrderNumber
						,dtmLastVoucherDate
						,strAllVouchers
						,dblReceiptLineTotal
						,dblReceiptTax
						,dblItemsPayable
						,dblTaxesPayable
						,dblVoucherLineTotal
						,dblVoucherTax
						,dblOpenQty
						,strContainerNumber
						,dblUnitCost
				FROM	[vyuAPGetInventoryClearingReceiptVoucherItems] items
				WHERE	items.intEntityVendorId = vendor.intEntityId
			) receiptItem
			OUTER APPLY (
				SELECT strTerm,ysnPosted,ysnPaid,A.dtmDueDate FROM dbo.tblAPBill A 
				INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
				INNER JOIN tblSMTerm C ON C.intTermID = A.intTermsId
				WHERE 
				B.intInventoryReceiptChargeId IS NULL AND B.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId 
				--AND  A.ysnPosted = 0
			) bill
			OUTER APPLY (
				SELECT 
					SUM(dblTotal) + SUM(dblTax) AS dblTotal
				FROM dbo.tblAPBillDetail A
				WHERE A.intInventoryReceiptChargeId IS NULL AND A.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
				GROUP BY intInventoryReceiptItemId 
			) totalVouchered
			CROSS APPLY (
				SELECT CL.strLocationName FROM tblSMCompanyLocation CL
				INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = receiptItem.intInventoryReceiptId
				WHERE CL.intCompanyLocationId = IR.intLocationId
			) loc
WHERE 
((ABS(dblReceiptQty) - ABS(dblVoucherQty))) != 0 --HANDLE RETURN AND RECEIPT TRANSACTION
AND receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 

UNION ALL

--RECEIPT VENDOR ACCRUE CHARGES--
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, dtmDate = Receipt.dtmReceiptDate
	, dtmBillDate = Bill.dtmDate 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0)) + (ISNULL(dblTax,0)) 
	, dblAmountDue = ISNULL(CASE 
		WHEN Bill.dblDetailTotal IS NULL THEN (ISNULL(dblAmount,0)) + (ISNULL(dblTax,0)) 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 THEN Bill.dblDetailTotal 
		ELSE ISNULL(Bill.dblDetailTotal ,0)
	  END,0)  
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor2.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = Bill.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,dblQtyToReceive = ISNULL(ReceiptCharge.dblQuantity,1)
	,dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblQtyReceived,1) ELSE 0 END 
	,dblQtyToVoucher = (ISNULL(ReceiptCharge.dblQuantity,0) - ISNULL(ReceiptCharge.dblQuantityBilled, 0))
	,dblAmountToVoucher = CASE  WHEN ReceiptCharge.dblQuantityBilled = 0  THEN CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) AS DECIMAL (18,2)) 
								WHEN Bill.dblQtyReceived <> 0 THEN CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) -  ISNULL(Bill.dblDetailTotal,0) AS DECIMAL (18,2)) 
								ELSE CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) AS DECIMAL (18,2)) 
								END  
	, 0 AS dblChargeAmount	
	, ''AS strContainer
	,dblVoucherQty = 0
	,dblReceiptQty = ABS( ReceiptCharge.dblQuantity)
	,CL.strLocationName
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.ysnAccrue = 1 AND ReceiptCharge.ysnPrice = 0
										AND ReceiptCharge.intEntityVendorId = Receipt.intEntityVendorId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Receipt.intLocationId
LEFT JOIN tblAPVendor Vendor
   ON Vendor.intEntityId = Receipt.intEntityVendorId
LEFT JOIN tblEMEntity Vendor2 ON Vendor2.intEntityId = Receipt.intEntityVendorId

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
	  AND (ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)) != 0
	  AND ReceiptCharge.dblAmount != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
UNION ALL						
										
--RECEIPT VENDOR PRICE DOWN CHARGES
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, dtmDate = Receipt.dtmReceiptDate
	, dtmBillDate = Bill.dtmDate 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0) * -1 ) + (ISNULL(dblTax,0) * -1) 
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal 
		ELSE Bill.dblDetailTotal 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor2.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = Bill.strTerm 
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	, dblQtyToReceive = ISNULL(-ReceiptCharge.dblQuantity,-1)
	, dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(ReceiptCharge.dblQuantityPriced,-1) ELSE 0 END 
	, dblQtyToVoucher = -(ISNULL(ReceiptCharge.dblQuantity,0) - ISNULL(ReceiptCharge.dblQuantityBilled, 0)) 
	, dblAmountToVoucher = -(CASE WHEN ReceiptCharge.dblQuantityBilled = 0 AND strCostMethod = 'Per Unit'  THEN CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) AS DECIMAL (18,2)) 
								  WHEN Bill.dblQtyReceived <> 0  THEN CAST(((ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) -  (ISNULL(Bill.dblDetailTotal,0)) AS DECIMAL (18,2)) 
								  ELSE CAST(( (ISNULL(dblAmount,0)) + (ISNULL(dblTax,0))) AS DECIMAL (18,2))  
							 END) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
	,dblVoucherQty = 0
	,dblReceiptQty = ABS(ReceiptCharge.dblQuantity)
	,CL.strLocationName
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.ysnPrice = 1
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Receipt.intLocationId
LEFT JOIN tblAPVendor Vendor
			ON Vendor.intEntityId = Receipt.intEntityVendorId
LEFT JOIN tblEMEntity Vendor2 ON Vendor2.intEntityId = Receipt.intEntityVendorId
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
	  AND (ReceiptCharge.dblQuantity - ABS(ISNULL(ReceiptCharge.dblQuantityPriced, 0))) != 0
	  AND ReceiptCharge.dblAmount != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
UNION ALL  

--3RD PARTY ACRUE VENDOR WITH CHARGES 
SELECT DISTINCT
	  Receipt.dtmReceiptDate
	, Receipt.strReceiptNumber
	, Receipt.intInventoryReceiptId
	, Receipt.strBillOfLading
	, '' AS strOrderNumber
	, Receipt.dtmReceiptDate as dtmDate
	, dtmBillDate = Bill.dtmDate 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(dblAmount,0)) + (ISNULL(ReceiptCharge.dblTax,0)) 
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) * -1 
		ELSE Bill.dblDetailTotal + ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0) 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Receipt.ysnPosted 
	, Bill.ysnPaid
	, strTerm = Bill.strTerm
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	, dblQtyToReceive = ISNULL(ReceiptCharge.dblQuantity,1)
	, dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblQtyReceived,1) ELSE 0 END 
	, dblQtyToVoucher = (ISNULL(ReceiptCharge.dblQuantity,0) - ISNULL(ReceiptCharge.dblQuantityBilled, 0))
	, dblAmountToVoucher = CASE  
								WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN CAST(((ISNULL(dblAmount,0)) + (ISNULL(ReceiptCharge.dblTax,0))) -  ISNULL(Bill.dblDetailTotal,0) AS DECIMAL (18,2)) 
								ELSE CAST(((ISNULL(dblAmount,0)) + (ISNULL(ReceiptCharge.dblTax,0))) AS DECIMAL (18,2)) 
							END 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
	,dblVoucherQty = 0
	,dblReceiptQty = ABS( ReceiptCharge.dblQuantity)
	,CL.strLocationName
FROM tblICInventoryReceiptCharge ReceiptCharge
INNER JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId AND ReceiptCharge.intEntityVendorId NOT IN (Receipt.intEntityVendorId)
LEFT JOIN dbo.tblICInventoryReceiptChargeTax ReceiptChargeTax 
	ON ReceiptChargeTax.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = ReceiptCharge.intEntityVendorId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Receipt.intLocationId
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
      AND (ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)) != 0
	  AND ReceiptCharge.dblAmount != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
UNION ALL  

--QUERY FOR 3RD PARTY ACRUE VENDOR WITH CHARGES INVENTORY SHIPMENT
SELECT DISTINCT
	  dtmReceiptDate = Shipment.dtmShipDate
	, strReceiptNumber = Shipment.strShipmentNumber 
	, intInventoryReceiptId = Shipment.intInventoryShipmentId
	, NULL AS strBillOfLading
	, '' AS strOrderNumber
	, dtmDate = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.dtmDate ELSE NULL END 
	, dtmBillDate = Bill.dtmDate 
	, 0 AS intBillId
	, strBillId = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN Bill.strBillId ELSE 'New Voucher' END	
	, dblAmountPaid = 0
	, dblTotal = (ISNULL(Bill.dblDetailTotal,(ISNULL(dblAmount,0)))) 
	, ISNULL(CASE 
		WHEN Bill.intTransactionType != 1 AND Bill.dblDetailTotal > 0 
		THEN Bill.dblDetailTotal /*+ ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0)*/ * -1 
		ELSE Bill.dblDetailTotal /*+ ISNULL(CASE WHEN ysnCheckoffTax > 0 THEN ReceiptCharge.dblTax ELSE ABS(ReceiptCharge.dblTax) END,0)*/ 
	  END,0) AS dblAmountDue 
	, dblVoucherAmount = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(Bill.dblDetailTotal,0) * -1 ELSE 0 END  
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, Vendor.strVendorId 
	, ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') as strVendorIdName 
	, Bill.dtmDueDate
	, Shipment.ysnPosted 
	, Bill.ysnPaid
	, strTerm = Bill.strTerm 
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	, dblQtyToReceive = ISNULL(ShipmentCharge.dblQuantity,1)
	, dblQtyVouchered = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN ISNULL(ShipmentCharge.dblQuantityBilled,1) ELSE 0 END 
	, dblQtyToVoucher = (ISNULL(ShipmentCharge.dblQuantity,0) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)) 
	, dblAmountToVoucher =  CAST(((ISNULL(dblAmount,0)) /*+ (ISNULL(ReceiptCharge.dblTax,0))*/) AS DECIMAL (18,2)) 
	, 0 AS dblChargeAmount	
	, ''AS strContainer
	,dblVoucherQty = ISNULL(ShipmentCharge.dblQuantityBilled, 0)
	,dblReceiptQty = ABS(ShipmentCharge.dblQuantity)
	,CL.strLocationName
FROM dbo.tblICInventoryShipmentCharge ShipmentCharge
INNER JOIN tblICInventoryShipment Shipment 
	ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId AND ShipmentCharge.intEntityVendorId NOT IN (Shipment.intEntityCustomerId)
LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = ShipmentCharge.intEntityVendorId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Shipment.intShipFromLocationId
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
			, Detail.intInventoryShipmentChargeId
			, Detail.dblQtyReceived
			, Detail.dblDetailTotal
			, Header.dblTotal
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intInventoryShipmentChargeId,
					SUM(dblQtyReceived) AS dblQtyReceived,
					SUM(A.dblTotal)	+ SUM(A.dblTax) AS dblDetailTotal
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intInventoryShipmentChargeId IS NOT NULL
				GROUP BY intInventoryShipmentChargeId
			) Detail		
		WHERE ISNULL(intInventoryShipmentChargeId, '') <> '' 
	) Bill ON Bill.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId AND Bill.intEntityVendorId NOT IN (Shipment.intEntityCustomerId)
WHERE Shipment.ysnPosted = 1 AND ShipmentCharge.ysnAccrue = 1
	  AND ShipmentCharge.intInventoryShipmentChargeId NOT IN (SELECT DISTINCT intInventoryShipmentChargeId FROM tblAPBillDetail A
	   																			  INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE intInventoryShipmentChargeId IS NOT NULL AND B.ysnPosted = 1)
	  AND (ShipmentCharge.dblQuantity - ISNULL(ShipmentCharge.dblQuantityBilled, 0)) != 0
	  AND ShipmentCharge.dblAmount != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
GO
