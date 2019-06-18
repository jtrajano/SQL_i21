CREATE VIEW [dbo].[vyuAPClearingFilterData]
AS

--Receipt Item
SELECT DISTINCT
	receiptItems.dtmDate
	,receiptItems.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,receiptItems.strAccountId
	,compLoc.strLocationName
FROM 
(
	SELECT	
		receipt.dtmReceiptDate AS dtmDate
		,receipt.strReceiptNumber AS strTransactionNumber
		,receiptItem.intItemId
		,receipt.intEntityVendorId
		,receipt.intLocationId
		,0 AS dblVoucherQty
		,CASE	
			WHEN receiptItem.intWeightUOMId IS NULL THEN 
				ISNULL(receiptItem.dblOpenReceive, 0) 
			ELSE 
				CASE 
					WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
						ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
					ELSE 
						ISNULL(receiptItem.dblNet, 0) 
				END 
		END AS dblReceiptQty
		,APClearing.strAccountId
	FROM tblICInventoryReceipt receipt 
	INNER JOIN tblICInventoryReceiptItem receiptItem
		ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
	LEFT JOIN tblSMFreightTerms ft
		ON ft.intFreightTermId = receipt.intFreightTermId
	LEFT JOIN tblICItem item
		ON item.intItemId = receiptItem.intItemId
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblICInventoryTransaction t INNER JOIN tblGLDetail gd
				ON t.strTransactionId = gd.strTransactionId
				AND t.strBatchId = gd.strBatchId
				AND t.intInventoryTransactionId = gd.intJournalLineNo
			INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			t.strTransactionId = receipt.strReceiptNumber
			AND t.intTransactionId = receipt.intInventoryReceiptId
			AND t.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
			AND t.intItemId = receiptItem.intItemId
			AND ag.strAccountType = 'Liability'
			AND t.ysnIsUnposted = 0 
	) APClearing
	WHERE 
		receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
	--DO NOT INCLUDE RECEIPT WHICH USES IN-TRANSIT AS GL
	--CLEARING FOR THIS IS ALREADY PART OF vyuAPLoadClearing
	AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
	AND receipt.strReceiptType != 'Transfer Order'
	AND receiptItem.intOwnershipType != 2
	AND receipt.ysnPosted = 1
	UNION ALL
	--Vouchers for receipt items
	SELECT
		bill.dtmDate AS dtmDate
		,receipt.strReceiptNumber
		,billDetail.intItemId
		,bill.intEntityVendorId
		,bill.intShipToId
		,CASE 
			WHEN billDetail.intWeightUOMId IS NULL THEN 
				ISNULL(billDetail.dblQtyReceived, 0) 
			ELSE 
				CASE 
					WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
						ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
					ELSE 
						ISNULL(billDetail.dblNetWeight, 0) 
				END
		END AS dblVoucherQty
		,CASE	
			WHEN receiptItem.intWeightUOMId IS NULL THEN 
				ISNULL(receiptItem.dblOpenReceive, 0) 
			ELSE 
				CASE 
					WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
						ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
					ELSE 
						ISNULL(receiptItem.dblNet, 0) 
				END 
		END AS dblReceiptQty
		,accnt.strAccountId
	FROM tblAPBill bill
	INNER JOIN tblAPBillDetail billDetail
		ON bill.intBillId = billDetail.intBillId
	INNER JOIN tblICInventoryReceiptItem receiptItem
		ON billDetail.intInventoryReceiptItemId  = receiptItem.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt receipt
		ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
	INNER JOIN tblGLAccount accnt
		ON billDetail.intAccountId = accnt.intAccountId
	LEFT JOIN tblSMFreightTerms ft
		ON ft.intFreightTermId = receipt.intFreightTermId
	WHERE 
		billDetail.intInventoryReceiptItemId IS NOT NULL
	AND billDetail.intInventoryReceiptChargeId IS NULL
	AND bill.ysnPosted = 1 --voucher should be posted in 18.3
	AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
	AND receipt.strReceiptType != 'Transfer Order'
	AND receiptItem.intOwnershipType != 2
) receiptItems
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = receiptItems.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON receiptItems.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = receiptItems.intItemId
GROUP BY
	receiptItems.intEntityVendorId
	,item.strItemNo
	,receiptItems.intLocationId
	,receiptItems.strTransactionNumber
	,receiptItems.dblReceiptQty
	,receiptItems.dtmDate
	,receiptItems.strAccountId
	,receiptItems.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (receiptItems.dblReceiptQty - SUM(receiptItems.dblVoucherQty)) != 0
UNION --RECEIPT CHARGES, USE 'UNION' TO REMOVE DUPLICATES ON REPORT FILTER
SELECT
	receiptChargeItems.dtmDate
	,receiptChargeItems.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,receiptChargeItems.strAccountId
	,compLoc.strLocationName
FROM
(
	--PRICE VENDOR
	SELECT  
		
		Receipt.dtmReceiptDate AS dtmDate  
		,Receipt.strReceiptNumber  AS strTransactionNumber 
		,ReceiptCharge.intChargeId AS intItemId  
		,Receipt.intEntityVendorId AS intEntityVendorId  
		,Receipt.intLocationId
		,0 AS dblVoucherQty  
		,ISNULL(ReceiptCharge.dblQuantity,0) * -1 AS dblReceiptChargeQty  
		,APClearing.strAccountId
	FROM tblICInventoryReceiptCharge ReceiptCharge  
	INNER JOIN tblICInventoryReceipt Receipt   
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId   
	INNER JOIN tblSMCompanyLocation compLoc  
		ON Receipt.intLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = Receipt.strReceiptNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE   
		Receipt.ysnPosted = 1    
	AND ReceiptCharge.ysnPrice = 1
	UNION ALL --RECEIPT VENDOR
	SELECT  
		Receipt.dtmReceiptDate AS dtmDate  
		,Receipt.strReceiptNumber  AS strTransactionNumber
		,ReceiptCharge.intChargeId AS intItemId  
		,ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId  
		,Receipt.intLocationId  
		,0 AS dblVoucherQty  
		,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty  
		,APClearing.strAccountId
	FROM tblICInventoryReceiptCharge ReceiptCharge  
	INNER JOIN tblICInventoryReceipt Receipt   
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId   
			AND ReceiptCharge.ysnAccrue = 1   
			AND ReceiptCharge.ysnPrice = 0  
	INNER JOIN tblSMCompanyLocation compLoc  
		ON Receipt.intLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = Receipt.strReceiptNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE   
		Receipt.ysnPosted = 1    
	AND ReceiptCharge.ysnAccrue = 1  
	AND Receipt.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) --make sure that the result would be for receipt vendor only
	UNION ALL --RECEIPT VENDOR
	SELECT  
		Receipt.dtmReceiptDate AS dtmDate  
		,Receipt.strReceiptNumber  AS strTransactionNumber
		,ReceiptCharge.intChargeId AS intItemId  
		,ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId  
		,Receipt.intLocationId  
		,0 AS dblVoucherQty  
		,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty  
		,APClearing.strAccountId
	FROM tblICInventoryReceiptCharge ReceiptCharge  
	INNER JOIN tblICInventoryReceipt Receipt   
		ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId   
			AND ReceiptCharge.ysnAccrue = 1   
			AND ReceiptCharge.ysnPrice = 0  
	INNER JOIN tblSMCompanyLocation compLoc  
		ON Receipt.intLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = Receipt.strReceiptNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE   
		Receipt.ysnPosted = 1    
	AND ReceiptCharge.ysnAccrue = 1  
	AND ReceiptCharge.intEntityVendorId IS NOT NULL
	AND ReceiptCharge.intEntityVendorId != Receipt.intEntityVendorId --make sure that the result would be for third party vendor only
	UNION ALL  
	--Voucher For Receipt Charges  
	SELECT  
		
		bill.dtmDate AS dtmDate  
		,receipt.strReceiptNumber  
		,billDetail.intItemId  
		,bill.intEntityVendorId  
		,receipt.intLocationId  
		,CASE   
			WHEN billDetail.intWeightUOMId IS NULL THEN   
				ISNULL(billDetail.dblQtyReceived, 0)   
			ELSE   
				CASE   
					WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN   
						ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)  
					ELSE   
						ISNULL(billDetail.dblNetWeight, 0)   
				END  
		END AS dblVoucherQty  
		,receiptCharge.dblQuantity   
			* (CASE WHEN receiptCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty  
		,APClearing.strAccountId 
	FROM tblAPBill bill  
	INNER JOIN tblAPBillDetail billDetail  
		ON bill.intBillId = billDetail.intBillId  
	INNER JOIN tblICInventoryReceiptCharge receiptCharge  
		ON billDetail.intInventoryReceiptChargeId  = receiptCharge.intInventoryReceiptChargeId  
	INNER JOIN tblICInventoryReceipt receipt  
		ON receipt.intInventoryReceiptId  = receiptCharge.intInventoryReceiptId  
	INNER JOIN tblSMCompanyLocation compLoc  
		ON receipt.intLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = receipt.strReceiptNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE   
		billDetail.intInventoryReceiptChargeId IS NOT NULL  
	AND bill.ysnPosted = 1
) receiptChargeItems
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = receiptChargeItems.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON receiptChargeItems.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = receiptChargeItems.intItemId
GROUP BY
	receiptChargeItems.intEntityVendorId
	,item.strItemNo
	,receiptChargeItems.intLocationId
	,receiptChargeItems.strTransactionNumber
	,receiptChargeItems.dblReceiptChargeQty
	,receiptChargeItems.dtmDate
	,receiptChargeItems.strAccountId
	,receiptChargeItems.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (receiptChargeItems.dblReceiptChargeQty - SUM(receiptChargeItems.dblVoucherQty)) != 0
UNION --SHIPMENT CHARGE
SELECT
	shipmentCharges.dtmDate
	,shipmentCharges.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,shipmentCharges.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT DISTINCT  
		Shipment.dtmShipDate AS dtmDate  
		,Shipment.strShipmentNumber   AS strTransactionNumber
		,ShipmentCharge.intChargeId  AS intItemId
		,Shipment.intEntityCustomerId AS intEntityVendorId  
		,Shipment.intShipFromLocationId  AS intLocationId
		,0 AS dblVoucherQty  
		,ISNULL(ShipmentCharge.dblQuantity,0) AS dblReceiptChargeQty  
		,APClearing.strAccountId
	FROM dbo.tblICInventoryShipmentCharge ShipmentCharge  
	INNER JOIN tblICInventoryShipment Shipment   
	ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId  
	INNER JOIN tblSMCompanyLocation compLoc  
		ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = Shipment.strShipmentNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE Shipment.ysnPosted = 1 AND ShipmentCharge.ysnAccrue = 1  
	UNION ALL  
	SELECT  
		bill.dtmDate AS dtmDate  
		,Shipment.strShipmentNumber  
		,billDetail.intItemId  
		,bill.intEntityVendorId  
		,Shipment.intShipFromLocationId  
		,CASE   
			WHEN billDetail.intWeightUOMId IS NULL THEN   
				ISNULL(billDetail.dblQtyReceived, 0)   
			ELSE   
				CASE   
					WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN   
						ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)  
					ELSE   
						ISNULL(billDetail.dblNetWeight, 0)   
				END  
		END AS dblVoucherQty  
		,ShipmentCharge.dblQuantity   
			* (CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty  
		,APClearing.strAccountId
	FROM tblAPBill bill  
	INNER JOIN tblAPBillDetail billDetail  
		ON bill.intBillId = billDetail.intBillId  
	INNER JOIN tblICInventoryShipmentCharge ShipmentCharge  
		ON billDetail.intInventoryShipmentChargeId  = ShipmentCharge.intInventoryShipmentChargeId  
	INNER JOIN tblICInventoryShipment Shipment  
		ON Shipment.intInventoryShipmentId  = ShipmentCharge.intInventoryShipmentId  
	INNER JOIN tblSMCompanyLocation compLoc  
		ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
	OUTER APPLY (
		SELECT TOP 1
			ga.strAccountId
			,ga.intAccountId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON ga.intAccountId = gd.intAccountId
			INNER JOIN tblGLAccountGroup ag
				ON ag.intAccountGroupId = ga.intAccountGroupId
		WHERE
			gd.strTransactionId = Shipment.strShipmentNumber
			AND ag.strAccountType = 'Liability'
			AND gd.ysnIsUnposted = 0 
	) APClearing
	WHERE   
		billDetail.intInventoryShipmentChargeId IS NOT NULL  
	AND bill.ysnPosted = 1
) shipmentCharges
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = shipmentCharges.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON shipmentCharges.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = shipmentCharges.intItemId
GROUP BY
	shipmentCharges.intEntityVendorId
	,item.strItemNo
	,shipmentCharges.intLocationId
	,shipmentCharges.strTransactionNumber
	,shipmentCharges.dblReceiptChargeQty
	,shipmentCharges.dtmDate
	,shipmentCharges.strAccountId
	,shipmentCharges.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (shipmentCharges.dblReceiptChargeQty - SUM(shipmentCharges.dblVoucherQty)) != 0
UNION --LOAD TRANSACTION
SELECT
	loadTran.dtmDate
	,loadTran.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,loadTran.strAccountId
	,compLoc.strLocationName
FROM
(
	--Item for Clearing
	SELECT
		A.dtmPostedDate AS dtmDate
		,A.strLoadNumber AS strTransactionNumber
		,B.intItemId
		,B.intVendorEntityId AS intEntityVendorId
		,B.intPCompanyLocationId AS intLocationId
		,0 AS dblVoucherQty
		,CASE WHEN B.dblNet != 0 THEN B.dblNet ELSE B.dblQuantity END AS dblLoadDetailQty
		,GL.strAccountId
	FROM tblLGLoad A
	INNER JOIN tblLGLoadDetail B
		ON A.intLoadId = B.intLoadId
	INNER JOIN tblSMCompanyLocation compLoc
		ON B.intPCompanyLocationId = compLoc.intCompanyLocationId
	CROSS APPLY (SELECT TOP 1 GLD.intAccountId, GLA.strAccountId FROM tblGLDetail GLD
					INNER JOIN tblGLAccount GLA ON GLA.intAccountId = GLD.intAccountId
					INNER JOIN tblGLAccountGroup GLAG ON GLAG.intAccountGroupId = GLA.intAccountGroupId
					INNER JOIN tblGLAccountCategory GLAC ON GLAC.intAccountCategoryId = GLAG.intAccountCategoryId
				WHERE intTransactionId = A.intLoadId AND strTransactionId = A.strLoadNumber AND ysnIsUnposted = 0
					AND strCode IN ('LG', 'IC') AND GLAC.strAccountCategory = 'AP Clearing') GL
	LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
					ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2 AND receipt.ysnPosted = 1)
		ON receiptItem.intSourceId = B.intLoadDetailId
	WHERE 
		A.ysnPosted = 1 
	AND A.intPurchaseSale IN (1,3) --Inbound/Drop Ship load shipment type only have AP Clearing GL Entries.
	AND A.intSourceType != 1 --Source Type should not be 'None'
	UNION ALL
	--Voucher For Load Detail Item
	SELECT
		bill.dtmDate AS dtmDate
		,l.strLoadNumber
		,billDetail.intItemId
		,bill.intEntityVendorId
		,bill.intShipToId
		,CASE 
			WHEN billDetail.intWeightUOMId IS NULL THEN 
				ISNULL(billDetail.dblQtyReceived, 0) 
			ELSE 
				CASE 
					WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
						ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
					ELSE 
						ISNULL(billDetail.dblNetWeight, 0) 
				END
		END AS dblVoucherQty
		,CASE WHEN ld.dblNet != 0 THEN ld.dblNet ELSE ld.dblQuantity END AS dblLoadDetailQty
		,accnt.strAccountId
	FROM tblAPBill bill
	INNER JOIN tblAPBillDetail billDetail
		ON bill.intBillId = billDetail.intBillId
	INNER JOIN tblSMCompanyLocation compLoc
		ON bill.intShipToId = compLoc.intCompanyLocationId
	INNER JOIN tblLGLoadDetail ld
		ON billDetail.intLoadDetailId = ld.intLoadDetailId
	INNER JOIN tblLGLoad l
		ON ld.intLoadId = l.intLoadId
	INNER JOIN tblGLAccount accnt
		ON accnt.intAccountId = billDetail.intAccountId
	LEFT JOIN tblICInventoryReceiptItem ri
		ON billDetail.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
	WHERE 
		billDetail.intLoadDetailId IS NOT NULL
	AND bill.ysnPosted = 1
) loadTran
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = loadTran.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON loadTran.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = loadTran.intItemId
GROUP BY
	loadTran.intEntityVendorId
	,item.strItemNo
	,loadTran.intLocationId
	,loadTran.strTransactionNumber
	,loadTran.dblLoadDetailQty
	,loadTran.dtmDate
	,loadTran.strAccountId
	,loadTran.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (loadTran.dblLoadDetailQty - SUM(loadTran.dblVoucherQty)) != 0
UNION
SELECT
	loadCost.dtmDate
	,loadCost.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,loadCost.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		A.dtmPostedDate AS dtmDate
		,A.strLoadNumber AS strTransactionNumber
		,B.intItemId
		,ISNULL(C.intVendorId, B.intCustomerEntityId) AS intEntityVendorId
		,B.intSCompanyLocationId AS intLocationId
		,0 AS dblVoucherQty
		,CASE WHEN C.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
			(CASE WHEN B.dblNet > 0 THEN B.dblNet ELSE B.dblQuantity END)
		END AS dblLoadCostDetailQty
		,GL.strAccountId
	FROM tblLGLoad A
	INNER JOIN tblLGLoadDetail B
		ON A.intLoadId = B.intLoadId
	INNER JOIN tblLGLoadCost C
		ON A.intLoadId = C.intLoadId
	INNER JOIN tblSMCompanyLocation compLoc
		ON B.intSCompanyLocationId = compLoc.intCompanyLocationId
	CROSS APPLY (SELECT TOP 1 GLD.intAccountId, GLA.strAccountId FROM tblGLDetail GLD
					INNER JOIN tblGLAccount GLA ON GLA.intAccountId = GLD.intAccountId
					INNER JOIN tblGLAccountGroup GLAG ON GLAG.intAccountGroupId = GLA.intAccountGroupId
					INNER JOIN tblGLAccountCategory GLAC ON GLAC.intAccountCategoryId = GLAG.intAccountCategoryId
				WHERE intTransactionId = A.intLoadId AND strTransactionId = A.strLoadNumber AND ysnIsUnposted = 0
					AND strCode IN ('LG', 'IC') AND GLAC.strAccountCategory = 'AP Clearing') GL
	LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
	ON receiptItem.intSourceId = B.intLoadDetailId
	WHERE 
		A.ysnPosted = 1 
	AND A.intPurchaseSale = 2 --Outbound type is the only type that have AP Clearing for cost, this is also driven by company config
	AND C.ysnAccrue = 1
	UNION ALL
	SELECT
		bill.dtmDate
		,D.strLoadNumber
		,billDetail.intItemId
		,bill.intEntityVendorId
		,bill.intShipToId AS intLocationId
		,CASE 
			WHEN billDetail.intWeightUOMId IS NULL THEN 
				ISNULL(billDetail.dblQtyReceived, 0) 
			ELSE 
				CASE 
				WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
					ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
				ELSE 
					ISNULL(billDetail.dblNetWeight, 0) 
			END
			END AS dblVoucherQty
		,CASE WHEN E.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
			(CASE WHEN C.dblNet > 0 THEN C.dblNet ELSE C.dblQuantity END)
		END AS dblLoadCostDetailQty
		,accnt.strAccountId
	FROM tblAPBill bill
	INNER JOIN tblAPBillDetail billDetail
		ON bill.intBillId = billDetail.intBillId
	INNER JOIN (tblLGLoadDetail C INNER JOIN tblLGLoad D ON C.intLoadId = D.intLoadId INNER JOIN tblLGLoadCost E ON D.intLoadId = E.intLoadId)
		ON billDetail.intLoadDetailId = C.intLoadDetailId AND billDetail.intItemId = E.intItemId
	INNER JOIN tblSMCompanyLocation compLoc
		ON bill.intShipToId = compLoc.intCompanyLocationId
	INNER JOIN tblGLAccount accnt
		ON billDetail.intAccountId = accnt.intAccountId
	WHERE bill.ysnPosted = 1
) loadCost
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = loadCost.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON loadCost.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = loadCost.intItemId
GROUP BY
	loadCost.intEntityVendorId
	,item.strItemNo
	,loadCost.intLocationId
	,loadCost.strTransactionNumber
	,loadCost.dblLoadCostDetailQty
	,loadCost.dtmDate
	,loadCost.strAccountId
	,loadCost.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (loadCost.dblLoadCostDetailQty - SUM(loadCost.dblVoucherQty)) != 0