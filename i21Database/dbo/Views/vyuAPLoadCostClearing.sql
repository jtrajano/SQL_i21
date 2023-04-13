﻿CREATE VIEW [dbo].[vyuAPLoadCostClearing]
AS 

SELECT
	ISNULL(C.intVendorId, B.intCustomerEntityId) AS intEntityVendorId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber AS strTransactionNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,B.intLoadDetailId
	,C.intLoadCostId
	,C.intItemId
	,C.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,C.dblAmount AS dblLoadCostDetailTotal
	,CASE WHEN C.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
		(CASE WHEN B.dblNet > 0 THEN B.dblNet ELSE B.dblQuantity END)
	END AS dblLoadCostDetailQty
	,B.intSCompanyLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
	,GL.intAccountId
	,GL.strAccountId
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblLGLoadCost C
	ON A.intLoadId = C.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intSCompanyLocationId = compLoc.intCompanyLocationId
INNER JOIN 
(
	SELECT 
		GLD.intAccountId
		,GLAcc.strAccountId 
		,GLD.strTransactionId
		,GLD.intTransactionId
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAcc ON GLD.intAccountId = GLAcc.intAccountId
	WHERE ysnIsUnposted = 0
		AND GLD.strCode IN ('LG') AND GLAcc.intAccountCategoryId = 45
) GL
ON
	GL.strTransactionId = A.strLoadNumber
AND GL.intTransactionId = A.intLoadId
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
			ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
ON receiptItem.intSourceId = B.intLoadDetailId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = B.intItemUOMId
WHERE 
	A.ysnPosted = 1 
AND A.intPurchaseSale = 2 --Outbound type is the only type that have AP Clearing for cost, this is also driven by company config
AND C.ysnAccrue = 1
-- MON -- FILTER OUT NORMAL LOAD SHIPMENT TRANSACTION
AND (NOT (A.intSourceType = 1 and A.intTransUsedBy = 2))
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,D.strLoadNumber
	,C.intLoadId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,C.intLoadDetailId
	,E.intLoadCostId
	,billDetail.intItemId
	,C.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
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
	,0 AS dblLoadCostDetailTotal
	,0 AS dblLoadCostDetailQty
	-- ,E.dblAmount AS dblLoadCostDetailTotal
	-- ,CASE WHEN E.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
	-- 	(CASE WHEN C.dblNet > 0 THEN C.dblNet ELSE C.dblQuantity END)
	--  END AS dblLoadCostDetailQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,1 --allow voucher if there is no receipt
	,accnt.intAccountId
	,accnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblLGLoadDetail C INNER JOIN tblLGLoad D ON C.intLoadId = D.intLoadId INNER JOIN tblLGLoadCost E ON D.intLoadId = E.intLoadId)
	ON billDetail.intLoadDetailId = C.intLoadDetailId AND billDetail.intItemId = E.intItemId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
INNER JOIN tblGLAccount accnt
    ON accnt.intAccountId = billDetail.intAccountId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = C.intItemUOMId
WHERE bill.ysnPosted = 1

-- MON -- FILTER OUT NORMAL LOAD SHIPMENT TRANSACTION
AND (NOT (D.intSourceType = 1 and D.intTransUsedBy = 2))


--SPECIAL CASE FOR LOAD SHIPMENT - TICKET LOAD REFERENCE DISTRIBUTION
UNION ALL

SELECT
	ISNULL(C.intVendorId, B.intEntityId) AS intEntityVendorId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber AS strTransactionNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,NULL AS intLoadDetailId
	,C.intLoadCostId
	,C.intItemId
	,C.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,C.dblAmount AS dblLoadCostDetailTotal
	,CASE WHEN C.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
		B.dblNetUnits
	END AS dblLoadCostDetailQty
	,B.intProcessingLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
	,GL.intAccountId
	,GL.strAccountId
FROM tblLGLoad A
INNER JOIN tblSCTicket B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblLGLoadCost C
	ON A.intLoadId = C.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intProcessingLocationId = compLoc.intCompanyLocationId
LEFT JOIN 
(
	SELECT 
		GLD.intAccountId
		,GLAcc.strAccountId 
		,GLD.strTransactionId
		,GLD.intTransactionId
	FROM tblGLDetail GLD
		INNER JOIN vyuGLAccountDetail GLAcc ON GLD.intAccountId = GLAcc.intAccountId
	WHERE ysnIsUnposted = 0
		AND GLD.strCode IN ('LG') AND GLAcc.intAccountCategoryId = 45
) GL
ON
	GL.strTransactionId = A.strLoadNumber
AND GL.intTransactionId = A.intLoadId
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
			ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
ON receiptItem.intSourceId = B.intLoadDetailId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = B.intItemUOMIdTo
WHERE 
	C.ysnAccrue = 1
	AND B.strTicketStatus = 'C'
-- MON -- FILTER OUT NORMAL LOAD SHIPMENT TRANSACTION
AND ((A.intSourceType = 1 and A.intTransUsedBy = 2))
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,D.strLoadNumber
	,C.intLoadId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,NULL AS intLoadDetailId
	,E.intLoadCostId
	,billDetail.intItemId
	,C.intItemUOMIdTo  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
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
	,0 AS dblLoadCostDetailTotal
	,0 AS dblLoadCostDetailQty
	-- ,E.dblAmount AS dblLoadCostDetailTotal
	-- ,CASE WHEN E.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE 
	-- 	(CASE WHEN C.dblNet > 0 THEN C.dblNet ELSE C.dblQuantity END)
	--  END AS dblLoadCostDetailQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,1 --allow voucher if there is no receipt
	,accnt.intAccountId
	,accnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblLGLoad D INNER JOIN tblSCTicket C ON D.intLoadId = C.intLoadId INNER JOIN tblLGLoadCost E ON D.intLoadId = E.intLoadId)
	ON billDetail.intLoadId = C.intLoadId AND billDetail.intItemId = E.intItemId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
INNER JOIN tblGLAccount accnt
    ON accnt.intAccountId = billDetail.intAccountId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = C.intItemUOMIdTo
WHERE bill.ysnPosted = 1	
-- MON -- FILTER OUT NORMAL LOAD SHIPMENT TRANSACTION
AND ((D.intSourceType = 1 and D.intTransUsedBy = 2))


--END -- SPECIAL CASE FOR LOAD SHIPMENT - TICKET LOAD REFERENCE DISTRIBUTION